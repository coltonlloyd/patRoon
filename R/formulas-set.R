#' @include main.R
#' @include formulas.R
#' @include workflow-step-set.R
#' @include utils-feat_annotations-set.R
NULL

# NOTE: some methods are set in utils-feat_annotations-set.R

#' @templateVar class formulasSet
#' @templateVar parent formulas
#' @templateVar generator generateFormulas
#' @templateVar classUnset formulasUnset
#' @templateVar exObj formulas
#' @templateVar consAlgo2 GenForm
#' @template featAnnSets-class
#'
#' @rdname formulas-class
#' @export
formulasSet <- setClass("formulasSet", slots = c(setThreshold = "numeric",
                                                 setThresholdAnn = "numeric",
                                                 origFGNames = "character"),
                        contains = c("formulas", "workflowStepSet"))

#' @rdname formulas-class
#' @export
formulasConsensusSet <- setClass("formulasConsensusSet", slots = c(mergedConsensusNames = "character"),
                                 contains = "formulasSet")


setMethod("updateSetConsensus", "formulasSet", function(obj)
{
    obj <- doUpdateSetConsensus(obj)
    
    # update feature formulas
    obj@featureFormulas <- pruneList(lapply(obj@featureFormulas, function(ff) pruneList(ff[groupNames(obj)])), TRUE)
    
    return(obj)
})

setMethod("mergedConsensusNames", "formulasSet", doFeatAnnMCNSets)
setMethod("mergedConsensusNames", "formulasConsensusSet", doFeatAnnMCNSetsCons)

#' @rdname formulas-class
#' @export
setMethod("show", "formulasSet", function(object)
{
    callAllNextMethods(object, show, firstClass = "formulas", startFrom = "formulasSet")
})

#' @rdname formulas-class
#' @export
setMethod("delete", "formulasSet", doFeatAnnDeleteSets)

#' @param drop Passed to the \code{\link[=filter,featureAnnotations-method]{featureAnnotations}} method.
#' @rdname formulas-class
#' @export
setMethod("[", c("formulasSet", "ANY", "missing", "missing"), doFeatAnnSubsetSets)

#' @param negate Passed to the \code{\link[=filter,featureAnnotations-method]{featureAnnotations}} method.
#' @rdname formulas-class
#' @export
setMethod("filter", "formulasSet", doFeatAnnFilterSets)

#' @rdname formulas-class
#' @export
setMethod("plotSpectrum", "formulasSet", function(obj, index, groupName, analysis = NULL, MSPeakLists,
                                                  title = NULL, specSimParams = getDefSpecSimParams(),
                                                  mincex = 0.9, xlim = NULL, ylim = NULL, perSet = TRUE,
                                                  mirror = TRUE, ...)
{
    ac <- checkmate::makeAssertCollection()
    checkmate::assertIntegerish(index, lower = 1, min.len = 1, max.len = 2, any.missing = FALSE, add = ac)
    checkmate::assertCharacter(groupName, min.len = 1, max.len = 2, min.chars = 1, add = ac)
    checkmate::assertCharacter(analysis, min.len = 1, max.len = 2, min.chars = 1, null.ok = TRUE, add = ac)
    if (length(index) != length(groupName))
        stop("Lengths of index and groupName should be equal.")
    if (!is.null(analysis) && length(analysis) != length(groupName))
        stop("Lengths of analysis and groupName should be equal.")
    assertSpecSimParams(specSimParams, add = ac)
    checkmate::assertClass(MSPeakLists, "MSPeakListsSet", add = ac)
    checkmate::assertString(title, null.ok = TRUE, add = ac)
    checkmate::assertNumber(mincex, lower = 0, finite = TRUE, add = ac)
    assertXYLim(xlim, ylim, add = ac)
    aapply(checkmate::assertFlag, . ~ perSet + mirror, fixed = list(add = ac))
    checkmate::reportAssertions(ac)
    
    if (!perSet || length(sets(obj)) == 1 || !is.null(analysis))
        return(callNextMethod(obj, index, groupName, analysis, MSPeakLists, title, specSimParams = specSimParams,
                              mincex, xlim, ylim, ...))
    
    if (length(groupName) == 1)
    {
        spec <- annotatedPeakList(obj, index, groupName, analysis, MSPeakLists)
        if (is.null(spec))
            return(NULL)

        if (index > nrow(obj[[groupName]]))
            stop(sprintf("Specified candidate index out of range %d/%d", index, nrow(obj[[groupName]])), call. = FALSE)

        if (is.null(title))
            title <- subscriptFormula(obj[[groupName]]$neutral_formula[index])
        
        specs <- split(spec, by = "set")
        # UNDONE: this will overwrite consensus algo if present, OK?
        specs <- lapply(specs, function(x)
        {
            if (!is.null(x[["ion_formula"]]))
                x[!is.na(ion_formula), mergedBy := set]
            return(x)
        })
        
        plotData <- getMSPlotDataOverlay(specs, mirror, TRUE, 1, NULL)
        return(makeMSPlotOverlay(plotData, title, mincex, xlim, ylim, ...))
    }
    else
    {
        for (i in seq_len(2))
        {
            if (is.null(obj[[groupName[i]]]))
                stop(paste("No data for specified feature group:", groupName[i]), call. = FALSE)
            if (index[i] > nrow(obj[[groupName[i]]]))
                stop(sprintf("Specified candidate index out of range %d/%d", index[i], nrow(obj[[groupName[i]]])),
                     call. = FALSE)
        }
        
        if (is.null(title))
            title <- subscriptFormula(obj[[groupName[1]]]$neutral_formula[index[1]],
                                      formulas2 = obj[[groupName[2]]]$neutral_formula[index])        
        theSets <- sets(obj)
        
        usObj <- sapply(theSets, unset, obj = obj, simplify = FALSE)
        
        # check which sets actually contain requested data
        theSets <- theSets[sapply(theSets, function(s) all(groupName %in% groupNames(usObj[[s]])))]
        if (length(theSets) == 0)
            return(NULL)
        usObj <- usObj[theSets]
        
        usMSPL <- checkAndUnSetOther(theSets, MSPeakLists, "MSPeakLists")
        binnedPLs <- Map(usMSPL, theSets, f = getBinnedPLPair,
                         MoreArgs = list(groupNames = groupName, analyses = NULL, MSLevel = 2,
                                         specSimParams = specSimParams, mustExist = FALSE))

        mergeBinnedAnn <- function(nr)
        {
            binPLs <- sapply(binnedPLs, "[[", nr, simplify = FALSE)
            annPLs <- Map(usObj, usMSPL, f = annotatedPeakList,
                          MoreArgs = list(index = index[nr], groupName = groupName[nr], analysis = analysis[nr]))
            annPLs <- Map(mergeBinnedAndAnnPL, binPLs, annPLs, MoreArgs = list(which = nr))
            annPLs <- rbindlist(annPLs, idcol = "set")
            return(annPLs)
        }
        
        topSpec <- mergeBinnedAnn(1); bottomSpec <- mergeBinnedAnn(2)
        allSpectra <- rbind(topSpec, bottomSpec)
        
        specs <- split(allSpectra, by = "which")
        plotData <- getMSPlotDataOverlay(specs, mirror, FALSE, 2, "overlap")
        
        makeMSPlotOverlay(plotData, title, mincex, xlim, ylim, ...)
    }
})

setMethod("plotSpectrumHash", "formulasSet", function(obj, index, groupName, analysis = NULL, MSPeakLists,
                                                      title = NULL, specSimParams = getDefSpecSimParams(),
                                                      mincex = 0.9, xlim = NULL, ylim = NULL,
                                                      perSet = TRUE, mirror = TRUE, ...)
{
    return(makeHash(callNextMethod(obj, index, groupName, analysis, MSPeakLists,
                                   title, specSimParams, mincex, xlim, ylim, ...),
                    perSet, mirror))
})

#' @rdname formulas-class
#' @export
setMethod("annotatedPeakList", "formulasSet", function(obj, index, groupName, analysis = NULL, MSPeakLists, ...)
{
    ac <- checkmate::makeAssertCollection()
    checkmate::assertCount(index, positive = TRUE, add = ac)
    assertChoiceSilent(groupName, groupNames(obj), add = ac)
    checkmate::assertString(analysis, min.chars = 1, null.ok = TRUE, add = ac)
    checkmate::assertClass(MSPeakLists, "MSPeakListsSet", add = ac)
    checkmate::reportAssertions(ac)

    return(doAnnotatePeakListSet(obj, index, groupName, MSPeakLists, formulas = NULL, analysis = analysis, ...))
})

#' @rdname formulas-class
#' @export
setMethod("consensus", "formulasSet", function(obj, ..., absMinAbundance = NULL, relMinAbundance = NULL,
                                               uniqueFrom = NULL, uniqueOuter = FALSE, rankWeights = 1, labels = NULL,
                                               filterSets = FALSE, setThreshold = 0, setThresholdAnn = 0)
{
    allAnnObjs <- c(list(obj), list(...))
    
    ac <- checkmate::makeAssertCollection()
    checkmate::assertList(allAnnObjs, types = "formulasSet", min.len = 2, any.missing = FALSE,
                          unique = TRUE, .var.name = "...", add = ac)
    checkmate::assertCharacter(labels, min.chars = 1, len = length(allAnnObjs), null.ok = TRUE, add = ac)
    checkmate::assertFlag(filterSets, add = ac)
    aapply(checkmate::assertNumber, . ~ setThreshold + setThresholdAnn, lower = 0, upper = 1, finite = TRUE)
    checkmate::reportAssertions(ac)
    
    labels <- prepareConsensusLabels(obj, ..., labels = labels)
    
    assertConsCommonArgs(absMinAbundance, relMinAbundance, uniqueFrom, uniqueOuter, labels)
    
    cons <- doFeatAnnConsensusSets(allAnnObjs, labels, setThreshold, setThresholdAnn, rankWeights)
    combFormulas <- Reduce(modifyList, lapply(cons$setObjects, annotations, features = TRUE))
    
    ret <- formulasConsensusSet(setObjects = cons$setObjects, setThreshold = setThreshold,
                                setThresholdAnn = setThresholdAnn, origFGNames = cons$origFGNames,
                                groupAnnotations = cons$groupAnnotations, featureFormulas = combFormulas,
                                algorithm = cons$algorithm, mergedConsensusNames = cons$mergedConsensusNames)
    
    ret <- filterFeatAnnConsensus(ret, absMinAbundance, relMinAbundance, uniqueFrom, uniqueOuter, filterSets)
    
    return(ret)
})


generateFormulasSet <- function(fGroupsSet, MSPeakListsSet, adduct, generator, ..., setThreshold, setThresholdAnn)
{
    aapply(checkmate::assertNumber, . ~ setThreshold + setThresholdAnn, lower = 0, upper = 1, finite = TRUE)
    msplArgs <- assertAndGetMSPLSetsArgs(fGroupsSet, MSPeakListsSet)
    verifyNoAdductIonizationArg(adduct)
    
    unsetFGroupsList <- sapply(sets(fGroupsSet), unset, obj = fGroupsSet, simplify = FALSE)
    setObjects <- Map(unsetFGroupsList, msplArgs,
                      f = function(fg, mspl) generator(fGroups = fg, MSPeakLists = mspl[[1]], adduct = NULL, ...))
    setObjects <- initSetFragInfos(setObjects, MSPeakListsSet)
    
    combFormulas <- Reduce(modifyList, lapply(setObjects, annotations, features = TRUE))
    
    cons <- makeFeatAnnSetConsensus(setObjects, names(fGroupsSet), setThreshold, setThresholdAnn, NULL)

    return(formulasSet(setObjects = setObjects, origFGNames = names(fGroupsSet), setThreshold = setThreshold,
                       setThresholdAnn = setThresholdAnn, groupAnnotations = cons, featureFormulas = combFormulas,
                       algorithm = makeSetAlgorithm(setObjects)))
}

#' @rdname formulas-class
#' @export
formulasUnset <- setClass("formulasUnset", contains = "formulas")

#' @rdname formulas-class
#' @export
setMethod("unset", "formulasSet", function(obj, set)
{
    assertSets(obj, set, FALSE)
    uann <- doFeatAnnUnset(obj, set)
    return(formulasUnset(groupAnnotations = uann, featureFormulas = annotations(obj, features = TRUE),
                         algorithm = paste0(algorithm(obj), "_unset")))
})

#' @rdname formulas-class
#' @export
setMethod("unset", "formulasConsensusSet", function(obj, set)
{
    # get rid of overall consensus cols, as they interfere when set specific are renamed in the parent unset method
    obj@groupAnnotations <- lapply(obj@groupAnnotations, function(annTable)
    {
        annTable <- copy(annTable)
        annTable[, c("coverage", "mergedBy") := NULL]
        return(annTable)
    })
    
    return(callNextMethod(obj, set))
})
