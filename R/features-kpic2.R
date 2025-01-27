#' @include features.R
NULL

makeKPIC2PeakInfo <- function(ft)
{
    cols <- intersect(names(ft), c("ret", "retmin", "retmax", "mz", "mzmin", "mzmax", "intensity", "area", "sn"))
    ret <- ft[, cols, with = FALSE]
    setnames(ret,
             c("ret", "retmin", "retmax", "intensity"),
             c("rt", "rtmin", "rtmax", "maxo"))
    if (!is.null(ret[["sn"]]))
        setnames(ret, "sn", "snr")
    else
        ret[, snr := NA_real_]
    ret[, mzrsd := NA_real_]
    setcolorder(ret, c("rt", "rtmin", "rtmax", "mz", "mzmin", "mzmax", "mzrsd", "maxo", "area", "snr"))
    ret <- as.matrix(ret)
    return(ret)
}

updatePICSet <- function(old, new, analyses)
{
    new@picsList[analyses] <- Map(new@picsList[analyses], featureTable(old)[analyses], featureTable(new)[analyses], f = function(pics, oft, nft)
    {
        removed <- oft[!ID %in% nft$ID]$ID
        if (length(removed) > 0)
        {
            pics$pics <- pics$pics[-removed]
            pics$peaks <- pics$peaks[-removed]
            pics$peakinfo <- pics$peakinfo[-removed, ]
        }

        # update peakinfo
        pics$peakinfo <- makeKPIC2PeakInfo(nft)
        
        return(pics)
    })
    
    # ensure IDs are along rows in case features were removed
    new@features[analyses] <- lapply(new@features[analyses], function(ft)
    {
        if (nrow(ft) > 0 && nrow(ft) < last(ft$ID))
            set(ft, j = "ID", value = seq_len(nrow(ft)))
        return(ft)
    })
    
    return(new)
}

#' @rdname features-class
#' @export
featuresKPIC2 <- setClass("featuresKPIC2", slots = list(picsList = "ANY"), contains = "features")

setMethod("initialize", "featuresKPIC2",
          function(.Object, ...) callNextMethod(.Object, algorithm = "kpic2", ...))

#' @rdname features-class
#' @export
setMethod("delete", "featuresKPIC2", function(obj, i = NULL, j = NULL, ...)
{
    i <- assertDeleteArgAndToChr(i, analyses(obj))
    
    old <- obj
    obj <- callNextMethod()
    
    # simple ana subset
    if (is.null(j) && !setequal(analyses(old), analyses(obj)))
        obj@picsList <- obj@picsList[analyses(obj)]
    else if (!is.null(j)) # sync features
        obj <- updatePICSet(old, obj, i)
    
    return(obj)
})

#' @details \code{findFeaturesKPIC2} uses the
#'   \href{https://github.com/hcji/KPIC2}{KPIC2} \R package to extract features.
#'
#' @param kmeans If \code{TRUE} then \code{\link[KPIC]{getPIC.kmeans}} is used to
#'   obtain PICs, otherwise it is \code{\link[KPIC]{getPIC}}.
#' @param level Passed to \code{\link[KPIC]{getPIC}} or \code{\link[KPIC]{getPIC.kmeans}}
#' @param PICsplit If \code{TRUE} then \code{\link[KPIC]{PICsplit} is used to split peaks,
#'    if multiple exist in a mass trace
#'
#' @references \insertRef{Ji2017}{patRoon}
#'
#' @rdname feature-finding
#' @export
findfeaturesKPIC2 <- function(analysisInfo, kmeans = TRUE, level = 1000, PICsplit = TRUE, ..., parallel = TRUE, verbose = TRUE)
{
    # UNDONE: docs
    #   - mention that filter() doesn't alter KPIC object, but IDs can be used to retrace
    #       - or make function that gives synchronized object?
    
    checkPackage("KPIC", "https://github.com/hcji/KPIC2")
    
    ac <- checkmate::makeAssertCollection()
    analysisInfo <- assertAndPrepareAnaInfo(analysisInfo, c("mzXML", "mzML"), add = ac)
    aapply(checkmate::assertFlag, . ~ kmeans + parallel + verbose, fixed = list(add = ac))
    checkmate::reportAssertions(ac)

    anas <- analysisInfo$analysis
    filePaths <- mapply(getMzMLOrMzXMLAnalysisPath, anas, analysisInfo$path)
    baseHash <- makeHash(kmeans, level, list(...))
    hashes <- setNames(sapply(filePaths, function(fp) makeHash(baseHash, makeFileHash(fp))), anas)
    cachedData <- lapply(hashes, loadCacheData, category = "featuresKPIC2")
    cachedData <- pruneList(setNames(cachedData, anas))
    
    if (verbose)
        printf("Finding features with KPIC2 for %d analyses ...\n", nrow(analysisInfo))

    doKP <- function(inFile)
    {
        raw <- KPIC::LoadData(inFile)
        pics <- do.call(if (kmeans) KPIC::getPIC.kmeans else KPIC::getPIC,
                        c(list(raw = raw, level = level), ...), verbose)
	if (PICsplit) 
            pics <- KPIC::PICsplit(pics)
	pics <- KPIC::getPeaks(pics)
        
        patRoon:::doProgress()
        
        return(pics)
    }

    anasTBD <- setdiff(anas, names(cachedData))
    if (length(anasTBD) > 0)
    {
        if (parallel)
            allPics <- withProg(length(anasTBD), TRUE, future.apply::future_lapply(filePaths[anasTBD], doKP))
        else
            allPics <- withProg(length(anasTBD), FALSE, lapply(filePaths[anasTBD], doKP))
        
        for (a in anasTBD)
            saveCacheData("featuresKPIC2", allPics[[a]], hashes[[a]])
        
        if (length(cachedData) > 0)
            allPics <- c(allPics, cachedData)[anas] # merge and re-order
    }
    else
        allPics <- cachedData
    
    ret <- importfeaturesKPIC2(allPics, analysisInfo)

    if (verbose)
    {
        printf("Done!\n")
        printFeatStats(ret@features)
    }

    return(ret)
}

#' @details \code{importfeaturesKPIC2} converts features obtained with with the
#'   \pkg{KPIC2} package to a new \code{\link{features}} object.
#'
#' @param picsList A \code{list} with a \code{pics} objects obtained with
#'   \code{\link[KPIC]{getPIC}} or \code{\link[KPIC]{getPIC.kmeans}} for each analysis.
#'
#' @rdname feature-finding
#' @export
importfeaturesKPIC2 <- function(picsList, analysisInfo)
{
    ac <- checkmate::makeAssertCollection()
    checkmate::assertList(picsList, "list", min.len = 1, add = ac)
    analysisInfo <- assertAndPrepareAnaInfo(analysisInfo, c("mzXML", "mzML"), add = ac)
    checkmate::reportAssertions(ac)
    
    if (length(picsList) != nrow(analysisInfo))
        stop("Length of picsList should be equal to number analyses")

    feat <- setNames(lapply(picsList, function(pics)
    {
        ret <- as.data.table(pics$peakinfo)
        setnames(ret, c("rt", "rtmin", "rtmax", "maxo", "snr"),
                 c("ret", "retmin", "retmax", "intensity", "sn"))
        ret[, ID := seq_len(.N)][]
        return(ret)
    }), analysisInfo$analysis)
    
    return(featuresKPIC2(picsList = picsList, features = feat, analysisInfo = analysisInfo))
}

#' Conversion to KPIC2 objects
#'
#' Converts a \code{\link{features}} object to an \pkg{KPIC} object.
#'
#' @param obj The \code{features} object that should be converted.
#' @template loadrawdata-arg
#' @param \dots Ignored
#' @rdname kpic2-conv
#' @aliases getPICSet
#' @export
setMethod("getPICSet", "features", function(obj, loadRawData = TRUE)
{
    checkmate::assertFlag(loadRawData)
    
    anaInfo <- analysisInfo(obj)
    fTable <- featureTable(obj)
    EICs <- if (loadRawData) getEICsForFeatures(obj) else NULL
    return(lapply(names(fTable), function(ana)
    {
        ret <- list()
        if (loadRawData)
        {
            anai <- match(ana, anaInfo$analysis)
            
            ret$path = getMzMLOrMzXMLAnalysisPath(ana, anaInfo$path[anai])
            ret$scantime <- loadSpectra(ret$path, verbose = FALSE)$header$retentionTime
            
            if (!is.null(EICs[[ana]]))
            {
                ret$pics <- Map(EICs[[ana]], fTable[[ana]]$mz, f = function(eic, mz)
                {
                    setDT(eic)
                    setnames(eic, "intensity", "int")
                    eic[, mz := mz] # UNDONE? Could add actual m/z for each scan...
                    eic[, scan := sapply(time, function(t) which.min(abs(t - ret$scantime)))]
                    return(as.matrix(eic[, c("scan", "int", "mz"), with = FALSE]))
                })
                ret$peaks <- Map(ret$pics, fTable[[ana]]$intensity, f = function(pic, int)
                {
                    # UNDONE: some dummy values here
                    return(list(peakIndex = which.min(abs(pic[, "int"] - int)),
                                snr = NA_real_,
                                signals = int,
                                peakScale = 10))
                })
            }
            else
                ret$pics <- ret$peaks <- list()
        }
        else
        {
            ret$path <- ana
            ret$scantime <- integer()
            ret$pics <- ret$peaks <- list()
        }
        
        ret$peakinfo <- makeKPIC2PeakInfo(fTable[[ana]])

        return(ret)
    }))
})

#' @rdname kpic2-conv
#' @export
setMethod("getPICSet", "featuresKPIC2", function(obj, ...)
{
    return(unname(obj@picsList))
})
