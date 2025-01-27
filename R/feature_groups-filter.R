#' @include main.R
NULL

#' Filtering of grouped features
#'
#' Basic rule based filtering of feature groups.
#'
#' @param fGroups,obj \code{\link{featureGroups}} object to which the filter is
#'   applied.
#' @param rGroups A character vector of replicate groups that should be kept
#'   (\code{filter}) or subtracted from (\code{replicateGroupSubtract}).
#'
#' @return A filtered \code{\link{featureGroups}} object. Feature groups that
#'   are filtered away have their intensity set to zero. In case a feature group
#'   is not present in any of the analyses anymore it will be removed
#'   completely.
#'
#' @name feature-filtering
#' @seealso \code{\link{featureGroups-class}}
#' @seealso \code{\link{feature-grouping}}
NULL

intensityFilter <- function(fGroups, absThreshold, relThreshold, negate = FALSE)
{
    if (length(fGroups) == 0)
        return(fGroups)
    
    threshold <- getHighestAbsValue(absThreshold, relThreshold, max(sapply(groupTable(fGroups), max)))
    if (threshold == 0)
        return(fGroups)

    return(doFGroupsFilter(fGroups, "intensity", c(threshold, negate), function(fGroups)
    {
        compF <- if (negate) function(x) x >= threshold else function(x) x < threshold
        delGroups <- setnames(as.data.table(matrix(FALSE, length(analyses(fGroups)), length(fGroups))),
                              names(fGroups))
        delGroups[, (names(delGroups)) := lapply(fGroups@groups, compF), by = rep(1, nrow(delGroups))]
        return(delete(fGroups, j = delGroups))
    }))
}

blankFilter <- function(fGroups, threshold, negate = FALSE)
{
    anaInfo <- analysisInfo(fGroups)
    gNames <- names(fGroups)
    rGroups <- unique(anaInfo$group)

    # multiple groups may be specified separated by comma
    blankGroups <- sapply(anaInfo$blank, function(rg) strsplit(rg, ","), USE.NAMES = FALSE)
    allBlanks <- unique(unlist(blankGroups))
    allBlanks <- allBlanks[allBlanks %in% rGroups]
    blAnaInds <- anaInfo$group %chin% allBlanks
    
    if (length(allBlanks) == 0)
    {
        warning("No suitable blank analyses found, skipping blank filter...")
        return(fGroups)
    }

    return(doFGroupsFilter(fGroups, "blank", c(threshold, negate), function(fGroups)
    {
        pred <- function(x, t) x < t
        if (negate)
            pred <- Negate(pred)

        avgBls <- lapply(allBlanks, function(bl)
        {
            avg <- vapply(fGroups@groups[anaInfo$group == bl], function(x) mean(x[x > 0]), FUN.VALUE = numeric(1),
                          USE.NAMES = FALSE)
            avg[is.na(avg)] <- 0
            return(avg)
        })
        avgBls <- transpose(avgBls)
        minInts <- sapply(avgBls, max) * threshold

        delGroups <- copy(fGroups@groups)
        
        for (j in seq_along(delGroups))
            set(delGroups, j = j, value = fifelse(pred(fGroups@groups[[j]], minInts[[j]]), 1, 0))
        return(delete(fGroups, j = delGroups))
    }))
}

minAnalysesFilter <- function(fGroups, absThreshold = 0, relThreshold = 0, negate = FALSE, verbose = TRUE)
{
    threshold <- getHighestAbsValue(absThreshold, relThreshold, length(analyses(fGroups)))
    if (threshold == 0)
        return(fGroups)
    return(doFGroupsFilter(fGroups, "minimum analyses", c(threshold, negate), verbose = verbose, function(fGroups)
    {
        pred <- function(x) sum(x > 0) >= threshold
        if (negate)
            pred <- Negate(pred)
        return(fGroups[, sapply(groupTable(fGroups), pred, USE.NAMES = FALSE)])
    }, "minAnalyses"))
}

minReplicatesFilter <- function(fGroups, absThreshold = 0, relThreshold = 0, negate = FALSE, verbose = TRUE)
{
    threshold <- getHighestAbsValue(absThreshold, relThreshold, length(replicateGroups(fGroups)))
    if (threshold == 0)
        return(fGroups)

    rGroupsAna <- analysisInfo(fGroups)$group

    return(doFGroupsFilter(fGroups, "minimum replicates", c(threshold, negate), function(fGroups)
    {
        pred <- function(x) length(unique(rGroupsAna[x > 0])) >= threshold
        if (negate)
            pred <- Negate(pred)

        return(fGroups[, sapply(groupTable(fGroups), pred, USE.NAMES = FALSE)])
    }, "minReplicates", verbose))
}

minFeaturesFilter <- function(fGroups, absThreshold = 0, relThreshold = 0, negate = FALSE, verbose = TRUE)
{
    threshold <- getHighestAbsValue(absThreshold, relThreshold, length(fGroups))
    if (threshold == 0)
        return(fGroups)

    return(doFGroupsFilter(fGroups, "minimum features", c(threshold, negate), function(fGroups)
    {
        pred <- function(x) sum(x > 0) >= threshold
        if (negate)
            pred <- Negate(pred)

        return(fGroups[sapply(transpose(groupTable(fGroups)), pred, USE.NAMES = FALSE)])
    }, "minReplicates", verbose))
}

replicateAbundanceFilter <- function(fGroups, absThreshold, relThreshold, maxIntRSD, negate = FALSE)
{
    if (NULLToZero(absThreshold) == 0 && NULLToZero(relThreshold) == 0 && NULLToZero(maxIntRSD) == 0)
        return(fGroups) # all thresholds NULL/0

    gNames <- names(fGroups)
    rGroupsAna <- fGroups@analysisInfo$group
    rGroups <- replicateGroups(fGroups)
    rGroupLens <- table(rGroupsAna)
    rGroupInds <- sapply(rGroups, function(rg) which(rGroupsAna == rg), simplify = FALSE)

    doThr <- !is.null(absThreshold) || !is.null(relThreshold)
    if (doThr)
    {
        if (!is.null(relThreshold))
            thresholds <- sapply(replicateGroups(fGroups),
                                 function(rg) getHighestAbsValue(absThreshold, relThreshold, sum(rGroupsAna == rg)))
        else
            thresholds <- setNames(rep(absThreshold, length(replicateGroups(fGroups))), replicateGroups(fGroups))
    }
    
    maxIntRSD <- NULLToZero(maxIntRSD)

    return(doFGroupsFilter(fGroups, "replicate abundance", c(absThreshold, relThreshold, maxIntRSD, negate), function(fGroups)
    {
        pred <- function(x, n, rg)
        {
            if (doThr && sum(x > 0) < thresholds[[rg]])
                return(TRUE)
            return(maxIntRSD != 0 && length(x) > 1 && any(x > 0) && (sd(x) / mean(x)) > maxIntRSD) # UNDONE: remove zeros?
        }
        
        if (negate)
            pred <- Negate(pred)

        delGroups <- copy(fGroups@groups)
        set(delGroups, j = "group", value = rGroupsAna)
        delGroups[, (gNames) := lapply(.SD, function(x) if (pred(x, .N, group)) 1 else 0), by = group, .SDcols = gNames]
        return(delete(fGroups, j = delGroups[, -"group"]))
    }, "replicateAbundance"))
}

retentionMzFilter <- function(fGroups, range, negate, what)
{
    return(doFGroupsFilter(fGroups, what, c(range, negate), function(fGroups)
    {
        pred <- function(x) numGTE(x, range[1]) & numLTE(x, range[2])

        if (negate)
            pred <- Negate(pred)

        checkVals <- switch(what,
                            retention = fGroups@groupInfo$rts,
                            mz = fGroups@groupInfo$mzs,
                            mzDefect = fGroups@groupInfo$mzs - floor(fGroups@groupInfo$mzs))

        return(fGroups[, pred(checkVals)])
    }))
}

chromWidthFilter <- function(fGroups, range, negate)
{
    ftindex <- groupFeatIndex(fGroups)
    fTable <- featureTable(fGroups)
    anas <- analyses(fGroups)

    return(doFGroupsFilter(fGroups, "chromwidth", c(range, negate), function(fGroups)
    {
        pred <- function(finds)
        {
            cwidths <- sapply(seq_along(finds), function(i)
            {
                if (finds[i] == 0)
                    return(0)
                else
                    return(fTable[[anas[i]]][["retmax"]][finds[i]] - fTable[[anas[i]]][["retmin"]][finds[i]])
            }, USE.NAMES = FALSE)
            return(cwidths < range[1] | cwidths > range[2])
        }
        
        if (negate)
            pred <- Negate(pred)
        
        delGroups <- setnames(as.data.table(matrix(FALSE, length(analyses(fGroups)), length(fGroups))),
                              names(fGroups))
        delGroups[, (names(delGroups)) := lapply(ftindex, pred), by = rep(1, nrow(delGroups))]
        return(delete(fGroups, j = delGroups))
    }))
}

replicateGroupFilter <- function(fGroups, rGroups, negate = FALSE, verbose = TRUE)
{
    return(doFGroupsFilter(fGroups, "replicate group", c(rGroups, negate), function(fGroups)
    {
        pred <- function(g) !g %chin% rGroups
        if (negate)
            pred <- Negate(pred)
        return(delete(fGroups, pred(analysisInfo(fGroups)$group)))
    }, "replicate_group", verbose))
}

resultsFilter <- function(fGroups, results, negate = FALSE, verbose = TRUE)
{
    return(doFGroupsFilter(fGroups, "results", c(results, negate), function(fGroups)
    {
        fgRes <- if (is.list(results)) unique(unlist(lapply(results, groupNamesResults))) else groupNamesResults(results)
        if (negate)
            fgRes <- setdiff(names(fGroups), fgRes)
        return(fGroups[, fgRes])
    }, verbose = verbose))
}

featQualityFilter <- function(fGroups, qualityRanges, negate)
{
    ftindex <- groupFeatIndex(fGroups)
    fTable <- featureTable(fGroups)
    anas <- analyses(fGroups)
    
    return(doFGroupsFilter(fGroups, "feature quality", c(qualityRanges, negate), function(fGroups)
    {
        pred <- function(finds)
        {
            qualsOK <- lapply(seq_along(finds), function(i)
            {
                if (finds[i] == 0)
                    return(rep(FALSE, length(qualityRanges)))
                qRow <- fTable[[anas[i]]][finds[i], names(qualityRanges), with = FALSE]
                return(mapply(qRow, qualityRanges, FUN = `%inrange%`))
            })
            if (negate)
                return(sapply(qualsOK, function(qo) any(qo)))
            return(sapply(qualsOK, function(qo) any(!qo)))
        }
        
        delGroups <- setnames(as.data.table(matrix(FALSE, length(analyses(fGroups)), length(fGroups))),
                              names(fGroups))
        delGroups[, (names(delGroups)) := lapply(ftindex, pred), by = rep(1, nrow(delGroups))]
        return(delete(fGroups, j = delGroups))
    }, "feat_quality"))
}

groupQualityFilter <- function(fGroups, qualityRanges, negate)
{
    qRanges <- qualityRanges[names(qualityRanges) %in% featureQualityNames()]
    qRangesScore <- qualityRanges[names(qualityRanges) %in% featureQualityNames(scores = TRUE)]
    
    return(doFGroupsFilter(fGroups, "group quality", c(qualityRanges, negate), function(fGroups)
    {
        pred <- function(q, qr) q %inrange% qr
        if (negate)
            pred <- Negate(pred)
        checkHow <- if (negate) any else all
        
        doF <- function(fg, qr, tab)
        {
            tab <- copy(tab)
            tab[, keep := checkHow(mapply(.SD, qr, FUN = pred)), by = seq_len(nrow(tab)), .SDcols = names(qr)]
            return(fg[, tab[keep == TRUE]$group])
        }
        
        if (length(qRanges) > 0)
            fGroups <- doF(fGroups, qRanges, groupQualities(fGroups))
        if (length(qRangesScore) > 0)
            fGroups <- doF(fGroups, qRangesScore, groupScores(fGroups))
        return(fGroups)
    }, "group_quality"))
}

checkFeaturesFilter <- function(fGroups, checkFeaturesSession, negate)
{
    return(doFGroupsFilter(fGroups, "checked features session", c(makeFileHash(checkFeaturesSession), negate), function(fGroups)
    {
        session <- readCheckSession(checkFeaturesSession, "featureGroups")
        if (negate)
            fGroups <- fGroups[, union(session$removeFully, names(session$removePartially))]
        else
            fGroups <- delete(fGroups, j = session$removeFully)
        
        if (length(session$removePartially) > 0)
        {
            anas <- analyses(fGroups)
            fGroups <- delete(fGroups, j = function(x, grp)
            {
                if (is.null(session$removePartially[[grp]]))
                    return(FALSE)
                anaRm <- anas %chin% session$removePartially[[grp]]
                return(if (negate) !anaRm else anaRm)
            })
        }
        
        return(fGroups)
    }, "checkedFeatures"))
}

#' @details \code{filter} performs common rule based filtering of feature groups such as blank subtraction, minimum
#'   intensity and minimum replicate abundance. Removing of features occurs by zeroing their intensity values.
#'   Furthermore, feature groups that are left completely empty (\emph{i.e.} all intensities are zero) will be
#'   automatically removed.
#'
#' @param preAbsMinIntensity,preRelMinIntensity As \code{absMinIntensity}/\code{relMinIntensity}, but applied
#'   \emph{before} any other filters. This is typically used to speed-up subsequent filter steps. However, care must be
#'   taken that a sufficiently low value is chosen that is not expected to affect subsequent filtering steps. See below
#'   why this may be important.
#' @param absMinAnalyses,relMinAnalyses Feature groups are only kept when they contain data for at least this (absolute
#'   or relative) amount of analyses. Set to \code{NULL} to ignore.
#' @param absMinReplicates,relMinReplicates Feature groups are only kept when they contain data for at least this
#'   (absolute or relative) amount of replicates. Set to \code{NULL} to ignore.
#' @param absMinFeatures,relMinFeatures Analyses are only kept when they contain at least this (absolute or relative)
#'   amount of features. Set to \code{NULL} to ignore.
#' @param absMinReplicateAbundance,relMinReplicateAbundance Minimum absolute/relative abundance that a grouped feature
#'   should be present within a replicate group. If this minimum is not met all features within the replicate group are
#'   removed. Set to \code{NULL} to skip this step.
#' @param maxReplicateIntRSD Maximum relative standard deviation (RSD) of intensity values for features within a
#'   replicate group. If the RSD is above this value all features within the replicate group are removed. Set to
#'   \code{NULL} to ignore.
#' @param results Only keep feature groups that have results in the object specified by \code{results}. Valid classes
#'   are \code{\link{featureAnnotations}} (\emph{e.g.} formula/compound annotations) and \code{\link{components}}. Can
#'   also be a \code{list} with multiple objects: in this case a feature group is kept if it has a result in \emph{any}
#'   of the objects. Set to \code{NULL} to ignore.
#' @param blankThreshold Feature groups that are also present in blank analyses (see
#'   \link[=analysis-information]{analysis info}) are filtered out unless their relative intensity is above this
#'   threshold. For instance, a value of \samp{5} means that only features with an intensity five times higher than that
#'   of the blank are kept. The relative intensity values between blanks and non-blanks are determined from the mean of
#'   all non-zero blank intensities. Set to \code{NULL} to skip this step.
#' @param removeBlanks Set to \code{TRUE} to remove all analyses that belong to replicate groups that are specified as a
#'   blank in the \link{analysis-information}. This is useful to simplify the analyses in the specified
#'   \code{\link{featureGroups}} object after blank subtraction. When both \code{blankThreshold} and this argument are
#'   set, blank subtraction is performed prior to removing any analyses.
#' @param groupQualityRange Like \code{featQualityRange}, but filters on group specific or averaged qualities/scores.
#' @param checkFeaturesSession If set then features and/or feature groups are removed that were selected for removal
#'   (see \link{check-GUI}). The session files are typically generated with the \code{\link{checkFeatures}} and
#'   \code{\link{predictCheckFeaturesSession}} functions. The value of \code{checkFeaturesSession} should either by a
#'   path to the session file or \code{TRUE}, in which case the default session file name is used. If \code{negate=TRUE}
#'   then all non-selected features/feature groups are removed instead.
#'
#' @templateVar feat FALSE
#' @template feat-filter-args
#'
#' @section Filter order: When multiple arguments are specified to \code{filter}, multiple filters are applied in
#'   sequence. Since some of these filters may affect each other, choosing their order correctly may be important for
#'   effective data filtering. For instance, when an intensity filter removes features from blank analyses, a subsequent
#'   blank filter may not adequately perform blank subtraction. Similarly, when intensity and blank filters are executed
#'   after the replicate abundance filter it may be necessary to ensure minimum replicate abundance again as the
#'   intensity and blank filters may have removed some features within a replicate group.
#'
#'   With this in mind, filters (if specified) occur in the following order:
#'
#'   \enumerate{
#'
#'   \item Features/feature groups selected for removal by the session specified by \code{checkFeaturesSession}.
#'
#'   \item Pre-Intensity filters (\emph{i.e.} \code{preAbsMinIntensity} and \code{preRelMinIntensity}).
#'
#'   \item Chromatography and mass filters (\emph{i.e} \code{retentionRange}, \code{mzRange}, \code{mzDefectRange},
#'   \code{chromWidthRange}, \code{featQualityRange} and \code{groupQualityRange}).
#'
#'   \item Replicate abundance filters (\emph{i.e.} \code{absMinReplicateAbundance}, \code{relMinReplicateAbundance} and
#'   \code{maxReplicateIntRSD}).
#'
#'   \item Blank filter (\emph{i.e.} blankThreshold).
#'
#'   \item Intensity filters (\emph{i.e.} \code{absMinIntensity} and \code{relMinIntensity}).
#'
#'   \item Replicate abundance filters (2nd time, only if previous filters affected results).
#'
#'   \item General abundance filters (\emph{i.e.} \code{absMinAnalyses}, \code{relMinAnalyses}, \code{absMinReplicates},
#'   \code{relMinReplicates}, \code{absMinFeatures} and \code{relMinFeatures}).
#'
#'   \item Replicate group filter (\emph{i.e.} \code{rGroups}), results filter (\emph{i.e.} \code{results}) and blank
#'   analyses removal (\emph{i.e.} if \code{removeBlanks=TRUE}).
#'
#'   }
#'
#'   If another filtering order is desired then \code{filter} should be called multiple times with only one filter
#'   argument at a time.
#'
#'
#' @rdname feature-filtering
#' @export
setMethod("filter", "featureGroups", function(obj, absMinIntensity = NULL, relMinIntensity = NULL,
                                              preAbsMinIntensity = NULL, preRelMinIntensity = NULL,
                                              absMinAnalyses = NULL, relMinAnalyses = NULL,
                                              absMinReplicates = NULL, relMinReplicates = NULL,
                                              absMinFeatures = NULL, relMinFeatures = NULL,
                                              absMinReplicateAbundance = NULL, relMinReplicateAbundance = NULL,
                                              maxReplicateIntRSD = NULL, blankThreshold = NULL,
                                              retentionRange = NULL, mzRange = NULL, mzDefectRange = NULL,
                                              chromWidthRange = NULL, featQualityRange = NULL, groupQualityRange = NULL,
                                              rGroups = NULL, results = NULL, removeBlanks = FALSE,
                                              checkFeaturesSession = NULL, negate = FALSE)
{
    if (isTRUE(checkFeaturesSession))
        checkFeaturesSession <- "checked-features.yml"
    
    ac <- checkmate::makeAssertCollection()
    aapply(checkmate::assertNumber, . ~ absMinIntensity + relMinIntensity + preAbsMinIntensity + preRelMinIntensity +
               absMinAnalyses + relMinAnalyses + absMinReplicates + relMinReplicates + absMinFeatures + relMinFeatures +
               absMinReplicateAbundance + relMinReplicateAbundance + maxReplicateIntRSD +
               blankThreshold,
           lower = 0, finite = TRUE, null.ok = TRUE, fixed = list(add = ac))
    aapply(assertRange, . ~ retentionRange + mzRange + mzDefectRange + chromWidthRange, null.ok = TRUE,
           fixed = list(add = ac))
    aapply(assertScoreRange, . ~ featQualityRange + groupQualityRange,
           list(c(featureQualityNames(group = FALSE), featureQualityNames(group = FALSE, scores = TRUE)),
                c(featureQualityNames(), featureQualityNames(scores = TRUE))), fixed = list(add = ac))
    checkmate::assertCharacter(rGroups, min.chars = 1, min.len = 1, any.missing = FALSE, null.ok = TRUE, add = ac)
    checkmate::assert(checkmate::checkNull(results),
                      checkmate::checkClass(results, "featureAnnotations"),
                      checkmate::checkClass(results, "components"),
                      checkmate::checkList(results, c("featureAnnotations", "components"), any.missing = FALSE,
                                           min.len = 1),
                      .var.name = "results")
    aapply(checkmate::assertFlag, . ~ removeBlanks + negate, fixed = list(add = ac))
    if (!is.logical(checkFeaturesSession))
        assertCheckSession(checkFeaturesSession, mustExist = TRUE,  null.ok = TRUE, add = ac)
    checkmate::reportAssertions(ac)

    if (length(obj) == 0)
        return(obj)

    maybeDoFilter <- function(func, arg1, ..., otherArgs = list())
    {
        args <- c(list(arg1), ...)
        if (any(!sapply(args, is.null)))
            return(do.call(func, c(list(obj, arg1, ..., negate = negate), otherArgs)))
        return(obj)
    }

    obj <- maybeDoFilter(checkFeaturesFilter, checkFeaturesSession)
    
    obj <- maybeDoFilter(intensityFilter, preAbsMinIntensity, preRelMinIntensity)

    obj <- maybeDoFilter(retentionMzFilter, retentionRange, otherArgs = list(what = "retention"))
    obj <- maybeDoFilter(retentionMzFilter, mzRange, otherArgs = list(what = "mz"))
    obj <- maybeDoFilter(retentionMzFilter, mzDefectRange, otherArgs = list(what = "mzDefect"))
    obj <- maybeDoFilter(chromWidthFilter, chromWidthRange)
    obj <- maybeDoFilter(featQualityFilter, featQualityRange)
    obj <- maybeDoFilter(groupQualityFilter, groupQualityRange)

    # replicate round #1
    obj <- maybeDoFilter(replicateAbundanceFilter, absMinReplicateAbundance, relMinReplicateAbundance, maxReplicateIntRSD)
    lenAfter <- length(obj)

    obj <- maybeDoFilter(blankFilter, blankThreshold)
    obj <- maybeDoFilter(intensityFilter, absMinIntensity, relMinIntensity)

    # replicate round #2 (only do if previous filters affected results)
    if (length(obj) != lenAfter)
        obj <- maybeDoFilter(replicateAbundanceFilter, absMinReplicateAbundance, relMinReplicateAbundance, maxReplicateIntRSD)


    obj <- maybeDoFilter(minAnalysesFilter, absMinAnalyses, relMinAnalyses)
    obj <- maybeDoFilter(minReplicatesFilter, absMinReplicates, relMinReplicates)
    obj <- maybeDoFilter(minFeaturesFilter, absMinFeatures, relMinFeatures)

    obj <- maybeDoFilter(replicateGroupFilter, rGroups)
    obj <- maybeDoFilter(resultsFilter, results)
    if (removeBlanks)
        obj <- replicateGroupFilter(obj, unique(analysisInfo(obj)$blank), negate = !negate)

    return(obj)
})

#' @details \code{replicateGroupSubtract} removes feature groups present in a
#'   given set of replicate groups (unless intensities are above a given
#'   threshold). The replicate groups that are subtracted will be removed.
#'
#' @param threshold Minimum relative threshold (compared to mean intensity of
#'   replicate group being subtracted) for a feature group to be \emph{not}
#'   removed. When \samp{0} a feature group is always removed when present in
#'   the given replicate groups.
#'
#' @rdname feature-filtering
#' @aliases replicateGroupSubtract
#' @export
setMethod("replicateGroupSubtract", "featureGroups", function(fGroups, rGroups, threshold)
{
    ac <- checkmate::makeAssertCollection()
    checkmate::assertCharacter(rGroups, min.chars = 1, add = ac)
    checkmate::assertNumber(threshold, lower = 0, finite = TRUE, add = ac)
    checkmate::reportAssertions(ac)

    if (length(fGroups) == 0)
        return(fGroups)

    checkIntensities <- threshold > 0
    gNames <- names(fGroups)

    filteredGroups <- replicateGroupFilter(fGroups, rGroups, verbose = FALSE)
    sharedGroups <- intersect(gNames, names(filteredGroups))

    if (length(sharedGroups) == 0)
        return(fGroups)

    if (checkIntensities)
    {
        avgGroups <- averageGroups(filteredGroups)
        thrs <- sapply(avgGroups, max) * threshold
    }

    if (!checkIntensities)
        fGroups <- delete(fGroups, j = sharedGroups)
    else
    {
        delGroups <- setnames(as.data.table(matrix(FALSE, length(analyses(fGroups)), length(fGroups))),
                              names(fGroups))
        delGroups[, (sharedGroups) := Map(fGroups@groups[, sharedGroups, with = FALSE], sharedGroups,
                                          f = function(x, grp) x < thrs[grp]),
                  by = rep(1, nrow(delGroups))]
        # fGroups <- delete(fGroups, j = function(x, grp) grp %chin% sharedGroups & x < thrs[grp])
        fGroups <- delete(fGroups, j = delGroups)
    }
    
    return(replicateGroupFilter(fGroups, rGroups, negate = TRUE, verbose = FALSE))
})
