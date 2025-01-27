makeFGroupName <- function(id, ret, mz) sprintf("M%.0f_R%.0f_%d", mz, ret, id)

showAnaInfo <- function(anaInfo)
{
    rGroups <- unique(anaInfo$group)
    blGroups <- unique(anaInfo$blank)
    printf("Analyses: %s (%d total)\n", getStrListWithMax(anaInfo$analysis, 6, ", "), nrow(anaInfo))
    printf("Replicate groups: %s (%d total)\n", getStrListWithMax(rGroups, 8, ", "), length(rGroups))
    printf("Replicate groups used as blank: %s (%d total)\n", getStrListWithMax(blGroups, 8, ", "), length(blGroups))
}

reGenerateFTIndex <- function(fGroups)
{
    gNames <- names(fGroups)
    fGroups@ftindex <- setnames(rbindlist(lapply(featureTable(fGroups),
                                                 function(ft) as.list(chmatch(gNames, ft$group, 0)))), gNames)
    return(fGroups)
}
isFGSet <- function(fGroups) inherits(fGroups, "featureGroupsSet")

featureQualities <- function()
{
    list(ApexBoundaryRatio = list(func = MetaClean::calculateApexMaxBoundaryRatio, HQ = "LV", range = c(0, 1)),
         FWHM2Base = list(func = MetaClean::calculateFWHM, HQ = "HV", range = c(0, 1)),
         Jaggedness = list(func = MetaClean::calculateJaggedness, HQ = "LV", range = Inf),
         Modality = list(func = MetaClean::calculateModality, HQ = "LV", range = Inf),
         Symmetry = list(func = MetaClean::calculateSymmetry, HQ = "HV", range = c(-1, 1)),
         GaussianSimilarity = list(func = MetaClean::calculateGaussianSimilarity, HQ = "HV", range = c(0, 1)),
         Sharpness = list(func = MetaClean::calculateSharpness, HQ = "HV", range = Inf),
         TPASR = list(func = MetaClean::calculateTPASR, HQ = "LV", range = Inf),
         ZigZag = list(func = MetaClean::calculateZigZagIndex, HQ = "LV", range = Inf))
}

featureGroupQualities <- function()
{
    list(
        ElutionShift = list(func = MetaClean::calculateElutionShift, HQ = "LV", range = Inf),
        RetentionTimeCorrelation = list(func = MetaClean::calculateRetentionTimeConsistency, HQ = "LV", range = Inf)
    )
}

# normalize, invert if necessary to get low (worst) to high (best) order
scoreFeatQuality <- function(quality, values)
{
    if (all(is.finite(quality$range)))
    {
        if (!isTRUE(all.equal(quality$range, c(0, 1)))) # no need to normalize 0-1
            values <- normalize(values, minMax = quality$range[1] < 0, xrange = quality$range)
    }
    else
        values <- normalize(values, TRUE)
    
    if (quality$HQ == "LV")
        values <- 1 - values
    
    return(values)
}

hasFGroupScores <- function(fGroups) nrow(groupScores(fGroups)) > 0

doFGroupsFilter <- function(fGroups, what, hashParam, func, cacheCateg = what, verbose = TRUE)
{
    if (verbose)
    {
        printf("Applying %s filter... ", what)
        oldFCount <- length(getFeatures(fGroups)); oldGCount <- length(fGroups)
    }
    
    cacheName <- sprintf("filterFGroups_%s", cacheCateg)
    hash <- makeHash(fGroups, what, hashParam)
    ret <- loadCacheData(cacheName, hash)
    if (is.null(ret))
    {
        ret <- if (length(fGroups) > 0) func(fGroups) else fGroups
        saveCacheData(cacheName, ret, hash)
    }
    
    if (verbose)
    {
        newFCount <- length(getFeatures(ret)); newGCount <- length(ret)
        newn <- length(ret)
        printf("Done! Filtered %d (%.2f%%) features and %d (%.2f%%) feature groups. Remaining: %d features in %d groups.\n",
               oldFCount - newFCount, if (oldFCount > 0) (1 - (newFCount / oldFCount)) * 100,
               oldGCount - newGCount, if (oldGCount > 0) (1 - (newGCount / oldGCount)) * 100,
               newFCount, newGCount)
    }
    
    return(ret)
}

# used by adducts()<- methods
updateAnnAdducts <- function(annTable, gInfo, adducts)
{
    if (nrow(annTable) > 0)
    {
        # only consider changed
        adducts <- adducts[adducts != annTable$adduct]
        
        if (length(adducts) == 0)
            return(annTable) # nothing changed
    }
    
    adducts <- sapply(adducts, checkAndToAdduct, .var.name = "value", simplify = FALSE)
    adductsChr <- sapply(adducts, as.character) # re-make characters: standardize format
    nm <- calculateMasses(gInfo[names(adducts), "mzs"], adducts, type = "neutral")
    
    if (nrow(annTable) > 0)
    {
        # update table
        annTable <- copy(annTable)
        annTable[match(names(adducts), group), c("adduct", "neutralMass") := .(adductsChr, nm)][]
    }
    else # initialize table
        annTable <- data.table(group = names(adducts), adduct = adductsChr, neutralMass = nm)
    
    return(annTable)
}

unSetAnaInfo <- function(anaInfo) anaInfo[, setdiff(names(anaInfo), "set")]
