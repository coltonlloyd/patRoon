checkHasNames <- function(x, n, subset = FALSE, type = "unique")
{
    if (subset)
        return(checkmate::checkNames(names(x), subset.of = n, type = type))
    return(checkmate::checkNames(names(x), must.include = n, type = type))
}
assertHasNames <- checkmate::makeAssertionFunction(checkHasNames)

checkRange <- function(x, null.ok = FALSE)
{
    ret <- checkmate::checkNumeric(x, any.missing = FALSE, lower = 0, len = 2, null.ok = null.ok)
    if (isTRUE(ret) && !is.null(x) && x[1] > x[2])
        ret <- paste0("lower range (", x[1], ") higher than upper (", x[2], ")")
    return(ret)
}
assertRange <- checkmate::makeAssertionFunction(checkRange)

assertScoreRange <- function(x, scNames, .var.name = checkmate::vname(x), add = NULL)
{
    checkmate::assertList(x, null.ok = TRUE, types = "numeric", .var.name = .var.name, add = add)
    if (!is.null(x))
    {
        checkmate::assertNames(names(x), type = "unique", subset.of = scNames, .var.name = .var.name,
                               add = add)
        checkmate::qassertr(x, "N2", .var.name = .var.name)
    }
}

checkS4 <- function(x, null.ok = FALSE)
{
    if (is.null(x))
    {
        if (null.ok)
            return(TRUE)
        return("object is NULL")
    }
    if (!isS4(x))
        return("object is not an S4 object")
    return(TRUE)
}
assertS4 <- checkmate::makeAssertionFunction(checkS4)

checkChoiceSilent <- function(x, ch)
{
    ret <- checkmate::checkString(x, min.chars = 1)
    if (isTRUE(ret) && !x %in% ch)
        ret <- paste("Must be element of", getStrListWithMax(ch, 6, ", "))
    return(ret)
}
assertChoiceSilent <- checkmate::makeAssertionFunction(checkChoiceSilent)

assertListVal <- function(x, field, assertFunc, ..., .var.name = checkmate::vname(x))
{
    assertFunc(x[[field]], ..., .var.name = sprintf("%s[[\"%s\"]]", .var.name, field))
}

assertCharOrFactor <- function(x, empty.ok = FALSE, null.ok = FALSE, ..., .var.name = .var.name)
{
    checkmate::assert(
        checkmate::checkFactor(x, empty.levels.ok = empty.ok, any.missing = empty.ok, null.ok = null.ok),
        checkmate::checkCharacter(x, min.chars = if (empty.ok) 0 else 1, any.missing = empty.ok, null.ok = null.ok),
        .var.name = .var.name
    )
}

assertAnalysisInfo <- function(x, allowedFormats = NULL, null.ok = FALSE, .var.name = checkmate::vname(x), add = NULL)
{
    if (is.null(x) && null.ok)
        return(TRUE)

    if (!is.null(add))
        mc <- length(add$getMessages())

    checkmate::assertDataFrame(x, min.rows = 1, .var.name = .var.name, add = add)
    assertHasNames(x, c("path", "analysis", "group", "blank"), .var.name = .var.name, add = add)

    assertListVal(x, "path", checkmate::assertCharacter, any.missing = FALSE, add = add)
    assertListVal(x, "analysis", checkmate::assertCharacter, any.missing = FALSE, add = add)
    assertListVal(x, "group", checkmate::assertCharacter, any.missing = FALSE, add = add)
    assertListVal(x, "blank", checkmate::assertCharacter, any.missing = FALSE, add = add)
    
    checkmate::assert(
        checkmate::checkNull(x[["conc"]]),
        checkmate::checkCharacter(x[["conc"]]),
        checkmate::checkNumeric(x[["conc"]]),
        .var.name = sprintf("%s[[\"conc\"]]", .var.name)
    )

    # only continue if previous assertions didn't fail: x needs to be used as list which otherwise gives error
    # NOTE: this is only applicable if add != NULL, otherwise previous assertions will throw errors
    if (is.null(add) || length(add$getMessages()) == mc)
    {
        checkmate::assertDirectoryExists(x$path, .var.name = .var.name, add = add)

        # UNDONE: more extensions? (e.g. mzData)
        if (is.null(allowedFormats))
            allowedFormats <- MSFileFormats()

        exts <- unique(unlist(MSFileExtensions()[allowedFormats]))

        existFiles <- mapply(x$path, x$analysis, FUN = function(path, ana)
        {
            for (f in allowedFormats)
            {
                exts <- MSFileExtensions()[[f]]
                for (e in exts)
                {
                    p <- file.path(path, paste0(ana, ".", e))
                    if (file.exists(p) && file.info(p, extra_cols = FALSE)$isdir == MSFileFormatIsDir(f, e))
                        return(TRUE)
                }
            }
            message(sprintf("Analysis does not exist: %s (in %s)", ana, path))
            return(FALSE)
        })
        
        if (any(!existFiles))
            checkmate::makeAssertion(x, sprintf("No analyses found with correct data format (valid: %s)",
                                                paste0(allowedFormats, collapse = ", ")),
                                     var.name = .var.name, collection = add)
    }

    invisible(NULL)
}

assertAndPrepareAnaInfo <- function(x, ..., add = NULL)
{
    if (!is.null(x))
        x <- unFactorDF(x)

    if (!is.null(add))
        mc <- length(add$getMessages())

    if (!is.null(x) && checkmate::testDataFrame(x) && is.null(x[["blank"]]) && !is.null(x[["ref"]]))
    {
        warning("The usage of a 'ref' column in the analysis information is deprecated. Please re-name this column to 'blank'.")
        setnames(x, "ref", "blank")
    }

    assertAnalysisInfo(x, ..., add = add)

    if ((is.null(add) || length(add$getMessages()) == mc) &&
        (!is.null(x) && !is.null(x[["conc"]])))
        x[["conc"]] <- as.numeric(x[["conc"]])

    return(x)
}

assertSuspectList <- function(x, needsAdduct, skipInvalid, .var.name = checkmate::vname(x), add = NULL)
{
    mzCols <- c("mz", "neutralMass", "SMILES", "InChI", "formula")
    allCols <- c("name", "adduct", "rt", mzCols)
    
    # this seems necessary for proper naming in subsequent assertions (why??)
    .var.name <- force(.var.name)
    
    # subset with relevant columns: avoid checking others in subsequent assertDataFrame call
    if (checkmate::testDataFrame(x))
    {
        if (is.data.table(x))
            x <- x[, intersect(names(x), allCols), with = FALSE]
        else
            x <- x[, intersect(names(x), allCols)]
    }
    
    checkmate::assertDataFrame(x, any.missing = TRUE, min.rows = 1, .var.name = .var.name, add = add)
    assertHasNames(x, "name", .var.name = .var.name, add = add)

    checkmate::assertNames(intersect(names(x), mzCols), subset.of = mzCols,
                           .var.name = paste0("names(", .var.name, ")"), add = add)

    needsAdduct <- needsAdduct && (is.null(x[["mz"]]) || any(is.na(x$mz)))
    if (needsAdduct)
    {
        msg <- "Adduct information is required to calculate ionized suspect masses. "
        
        if (is.null(x[["adduct"]]))
            stop(msg, "Please either set the adduct argument or add an adduct column in the suspect list.")
        if (any(is.na(x[["adduct"]]) & (is.null(x[["mz"]]) | is.na(x[["mz"]]))))
            stop(msg, "Please either set the adduct argument or make sure that suspects without mz information have data in the adduct column.")
    }
    
    for (col in c("name", "SMILES", "InChI", "formula", "InChIKey", "adduct", "fragments_mz", "fragments_formula"))
    {
        emptyOK <- col != "name" && (col != "adduct" || !needsAdduct)
        assertListVal(x, col, assertCharOrFactor, empty.ok = emptyOK, null.ok = emptyOK, add = add)
    }

    for (col in c("mz", "neutralMass", "rt"))
        assertListVal(x, col, checkmate::assertNumeric, any.missing = TRUE, null.ok = TRUE,
                      lower = if (col != "rt") 0 else -Inf, finite = TRUE, add = add)

    if (!skipInvalid)
    {
        cx <- copy(x)
        cx[, OK := any(!sapply(.SD, is.na)), by = seq_len(nrow(cx)), .SDcols = intersect(names(x), mzCols)]
        if (all(!cx$OK))
            stop("Suspect list does not contain any (data to calculate) suspect masses", call. = FALSE)
        else if (any(!cx$OK))
            stop("Suspect list does not contain any (data to calculate) suspect masses for row(s): ",
                 paste0(which(!cx$OK), collapse = ", "), call. = FALSE)
    }
    
    invisible(NULL)
}

assertLogicTransformations <- function(x, null.ok = FALSE, .var.name = checkmate::vname(x), add = NULL)
{
    if (null.ok && is.null(x))
        return(NULL)
    
    checkmate::assertDataFrame(x, min.rows = 1, any.missing = FALSE, col.names = "unique", .var.name = .var.name,
                               add = add)
    checkmate::assertNames(colnames(x), permutation.of = c("transformation", "add", "sub", "retDir"), what = "colnames",
                           add = add)

    assertListVal(x, "transformation", checkmate::assertCharacter, min.chars = 1, any.missing = FALSE, unique = TRUE,
                  add = add)
    assertListVal(x, "add", checkmate::assertCharacter, add = add)
    assertListVal(x, "sub", checkmate::assertCharacter, add = add)
    assertListVal(x, "retDir", checkmate::assertSubset, c(-1, 0, 1), add = add)
}

assertCanCreateDir <- function(x, .var.name = checkmate::vname(x), add = NULL)
{
    if (!is.null(add))
        mc <- length(add$getMessages())

    checkmate::assertString(x, min.chars = 1, .var.name = .var.name, add = add)

    # only continue if previous assertions didn't fail: x needs to be a valid path for next assertions
    # NOTE: this is only applicable if add != NULL, otherwise previous assertions will throw errors
    if (is.null(add) || length(add$getMessages()) == mc)
    {
        # find first existing directory and see if it's writable
        x <- normalizePath(x, mustWork = FALSE)
        repeat
        {
            if (file.exists(x))
            {
                checkmate::assertDirectoryExists(x, "w", .var.name = .var.name, add = add)
                break
            }
            x <- normalizePath(dirname(x), mustWork = FALSE)
        }
    }
    invisible(NULL)
}

assertCanCreateDirs <- function(x, .var.name = checkmate::vname(x), add = NULL)
{
    for (ana in x)
        assertCanCreateDir(ana, .var.name, add)
}

assertDACloseSaveArgs <- function(x, save, .var.name = checkmate::vname(x), add = NULL)
{
    checkmate::assertFlag(x, .var.name = .var.name, add = add)
    checkmate::assertFlag(save, .var.name = "save", add = add)
}

assertXYLim <- function(x, ylim, .var.name = checkmate::vname(x), add = NULL)
{
    checkmate::assertNumeric(x, finite = TRUE, .var.name = .var.name, len = 2, null.ok = TRUE, add = add)
    checkmate::assertNumeric(ylim, finite = TRUE, .var.name = "ylim", len = 2, null.ok = TRUE, add = add)
}

assertConsCommonArgs <- function(absMinAbundance, relMinAbundance, uniqueFrom, uniqueOuter, objNames, add = NULL)
{
    checkmate::assertNumber(absMinAbundance, .var.name = "absMinAbundance", null.ok = TRUE, add = ac)
    checkmate::assertNumber(relMinAbundance, .var.name = "relMinAbundance", null.ok = TRUE, add = ac)
    checkmate::assert(checkmate::checkLogical(uniqueFrom, min.len = 1, max.len = length(objNames), any.missing = FALSE, null.ok = TRUE),
                      checkmate::checkIntegerish(uniqueFrom, lower = 1, upper = length(objNames), any.missing = FALSE),
                      checkmate::checkSubset(uniqueFrom, objNames, empty.ok = FALSE),
                      .var.name = "uniqueFrom")
    checkmate::assertFlag(uniqueOuter, .var.name = "uniqueOuter", add = add)

    if (!is.null(uniqueFrom) && (!is.null(absMinAbundance) || !is.null(relMinAbundance)))
        stop("Cannot apply both unique and abundance filters simultaneously.")
}

checkCSVFile <- function(x, cols)
{
    ret <- checkmate::checkFileExists(x, "r")
    if (isTRUE(ret))
    {
        t <- fread(x, nrows = 1) # nrows=0 doesn't always bug (may give internal error)
        missingc <- setdiff(cols, names(t))
        if (length(missingc) > 0)
            ret <- paste0("Missing columns: ", paste0(missingc, collapse = ", "))
    }
    return(ret)
}
assertCSVFile <- checkmate::makeAssertionFunction(checkCSVFile)

# used for "[" methods
checkSubsetArg <- function(x)
{
    ret <- checkmate::checkIntegerish(x)
    if (!isTRUE(ret))
        ret <- checkmate::checkCharacter(x)
    if (!isTRUE(ret))
        ret <- checkmate::checkLogical(x)
    if (!isTRUE(ret))
        ret <- "Should be valid numeric, character or logical"
    return(ret)
}
assertSubsetArg <- checkmate::makeAssertionFunction(checkSubsetArg)

assertSubsetArgAndToChr <- function(x, choices, .var.name = checkmate::vname(x), add = NULL)
{
    assertSubsetArg(x, .var.name = .var.name, add = add)
    if (!is.character(x))
        x <- choices[x]
    x <- intersect(x, choices)
    return(x)
}

# used for "[[" methods
checkExtractArg <- function(x)
{
    ret <- checkmate::checkInt(x, lower = 0)
    if (!isTRUE(ret))
        ret <- checkmate::checkString(x)
    if (!isTRUE(ret))
        ret <- "Should be valid numeric or character scalar"
    return(ret)
}
assertExtractArg <- checkmate::makeAssertionFunction(checkExtractArg)

checkDeleteArg <- function(x)
{
    ret <- checkmate::checkNull(x)
    if (!isTRUE(ret))
        ret <- checkmate::checkIntegerish(x, any.missing = FALSE)
    if (!isTRUE(ret))
        ret <- checkmate::checkCharacter(x, any.missing = FALSE)
    if (!isTRUE(ret))
        ret <- checkmate::checkLogical(x, any.missing = FALSE)
    if (!isTRUE(ret))
        ret <- "Should be NULL, valid numeric, character or logical"
    return(ret)
}
assertDeleteArg <- checkmate::makeAssertionFunction(checkDeleteArg)

assertDeleteArgAndToChr <- function(x, choices, .var.name = checkmate::vname(x), add = NULL)
{
    if (!is.null(add))
        mc <- length(add$getMessages())
    
    assertDeleteArg(x, .var.name = .var.name, add = add)
    
    if (!is.null(add) && length(add$getMessages()) != mc)
        return(x) # assert failed

    if (is.null(x))
        x <- choices
    else
    {
        if (!is.character(x))
            x <- choices[x]
        x <- intersect(x, choices)
    }
    
    return(x)
}

assertNormalizationMethod <- function(x, withNone = TRUE, .var.name = checkmate::vname(x), add = NULL)
{
    ch <- c("max", "minmax")
    if (withNone)
        ch <- c(ch, "none")
    checkmate::assertChoice(x, ch, .var.name = .var.name, add = add)
}

assertFCParams <- function(x, fGroups, null.ok = FALSE, .var.name = checkmate::vname(x), add = NULL)
{
    if (null.ok && is.null(x))
        return(NULL)
    
    checkmate::assertList(x, names = "unique", .var.name = .var.name) # no add: should fail
    
    assertListVal(x, "rGroups", checkmate::assertCharacter, any.missing = FALSE, len = 2, add = add)
    assertListVal(x, "rGroups", checkmate::assertSubset, choices = replicateGroups(fGroups), add = add)
    assertListVal(x, "thresholdFC", checkmate::assertNumber, lower = 0, finite = TRUE, add = add)
    assertListVal(x, "thresholdPV", checkmate::assertNumber, lower = 0, finite = TRUE, add = add)
    assertListVal(x, "zeroValue", checkmate::assertNumber, lower = 0, finite = TRUE, add = add)
    assertListVal(x, "zeroMethod", checkmate::assertChoice, choices = c("add", "fixed", "omit"), add = add)
    assertListVal(x, "PVTestFunc", checkmate::assertFunction, add = add)
    assertListVal(x, "PVAdjFunc", checkmate::assertFunction, add = add)
}

assertAvgPListParams <- function(x, .var.name = checkmate::vname(x), add = NULL)
{
    checkmate::assertList(x, names = "unique", .var.name = .var.name) # no add: should fail

    assertListVal(x, "clusterMzWindow", checkmate::assertNumber, lower = 0, finite = TRUE, add = add)
    assertListVal(x, "topMost", checkmate::assertCount, positive = TRUE, add = add)
    assertListVal(x, "minIntensityPre", checkmate::assertNumber, lower = 0, finite = TRUE, add = add)
    assertListVal(x, "minIntensityPost", checkmate::assertNumber, lower = 0, finite = TRUE, add = add)
    assertListVal(x, "avgFun", checkmate::assertFunction, add = add)
    assertListVal(x, "method", checkmate::assertChoice, choices = c("distance", "hclust"), add = add)
    assertListVal(x, "retainPrecursorMSMS", checkmate::assertFlag, add = add)
}

assertPListIsolatePrecParams <- function(x, .var.name = checkmate::vname(x), add = NULL)
{
    if (is.null(x))
        return(NULL)

    checkmate::assertList(x, names = "unique", .var.name = .var.name) # no add: should fail

    assertListVal(x, "maxIsotopes", checkmate::assertCount, add = add)
    assertListVal(x, "mzDefectRange", checkmate::assertNumeric, any.missing = FALSE, len = 2, finite = TRUE, add = add)
    assertListVal(x, "intRange", checkmate::assertNumeric, any.missing = FALSE, len = 2, finite = TRUE, add = add)
    assertListVal(x, "z", checkmate::assertCount, positive = TRUE, add = add)
    assertListVal(x, "maxGap", checkmate::assertCount, positive = TRUE, add = add)
}

assertSpecSimParams <- function(x, .var.name = checkmate::vname(x), add = NULL)
{
    checkmate::assertList(x, names = "unique", .var.name = .var.name) # no add: should fail
    
    assertListVal(x, "method", checkmate::assertChoice, choices = c("cosine", "jaccard"), add = add)
    assertListVal(x, "removePrecursor", checkmate::assertFlag, add = add)
    assertListVal(x, "mzWeight", checkmate::assertNumber, lower = 0, finite = TRUE, add = add)
    assertListVal(x, "intWeight", checkmate::assertNumber, lower = 0, finite = TRUE, add = add)
    assertListVal(x, "absMzDev", checkmate::assertNumber, lower = 0, finite = TRUE, add = add)
    assertListVal(x, "relMinIntensity", checkmate::assertNumber, lower = 0, finite = TRUE, add = add)
    assertListVal(x, "minPeaks", checkmate::assertCount, positive = TRUE, add = add)
    assertListVal(x, "shift", checkmate::assertChoice, c("none", "precursor", "both"), add = ac)
    assertListVal(x, "setCombineMethod", checkmate::assertChoice, choices = c("mean", "min", "max"), add = add)
}

assertCheckSession <- function(x, mustExist, null.ok = FALSE, .var.name = checkmate::vname(x), add = NULL)
{
    if (null.ok && is.null(x))
        return(NULL)
    
    checkmate::assertString(x, min.chars = 1, .var.name = .var.name, add = add)
    if (mustExist)
        checkmate::assertFileExists(x, "r", .var.name = .var.name, add = add)
    else
        checkmate::assertPathForOutput(x, overwrite = TRUE, .var.name = .var.name, add = ac)
    
    # UNDONE: validate YAML?
}

checkSetLabels <- function(x, len)
{
    ret <- checkmate::checkCharacter(x, min.chars = 1, any.missing = FALSE, len = len, unique = TRUE)
    if (isTRUE(ret) && any(grepl(",", x, fixed = TRUE)))
        ret <- "Set labels cannot contain commas"
    if (isTRUE(ret) && any(grepl("-", x, fixed = TRUE)))
        ret <- "Set labels cannot contain minus signs (-)"
    if (isTRUE(ret) && any(grepl("genform|sirius|bruker|metfrag", x)))
        ret <- "Set labels cannot contain annotation algorithm names"
    return(ret)
}
assertSetLabels <- checkmate::makeAssertionFunction(checkSetLabels)

assertSets <- function(obj, s, multiple, null.ok = multiple, .var.name = checkmate::vname(s), add = NULL)
{
    if (multiple)
        checkmate::assertSubset(s, sets(obj), empty.ok = null.ok, .var.name = .var.name, add = add)
    else
        checkmate::assertChoice(s, sets(obj), null.ok = null.ok, .var.name = .var.name, add = add)
}

assertMakeSetArgs <- function(objects, class, adducts, adductNullOK, labels, add = NULL)
{
    checkmate::assertList(objects, types = class, any.missing = FALSE,
                          unique = TRUE, .var.name = "obj and ...", min.len = 1,
                          add = add)
    if (!adductNullOK || !is.null(adducts))
        checkmate::assert(checkmate::checkCharacter(adducts, any.missing = FALSE, min.len = 1,
                                                    max.len = length(objects)),
                          checkmate::checkList(adducts, types = c("adduct", "character"), any.missing = FALSE,
                                               min.len = 1, max.len = length(objects)),
                          .var.name = "adducts")
    checkmate::assertCharacter(labels, len = length(objects), min.chars = 1, unique = TRUE,
                               null.ok = !is.null(adducts), add = add)
}

assertDynamicTreeCutArgs <- function(maxTreeHeight, deepSplit, minModuleSize, add = NULL)
{
    checkmate::assertNumber(maxTreeHeight, 0, finite = TRUE, add = add)
    checkmate::assertFlag(deepSplit, add = add)
    checkmate::assertCount(minModuleSize, positive = TRUE, add = add)
}

# from https://github.com/mllg/checkmate/issues/115
aapply = function(fun, formula, ..., fixed = list())
{
    fun = match.fun(fun)
    terms = terms(formula)
    vnames = attr(terms, "term.labels")
    ee = attr(terms, ".Environment")

    dots = list(...)
    dots$.var.name = vnames
    dots$x = unname(mget(vnames, envir = ee))
    .mapply(fun, dots, MoreArgs = fixed)

    invisible(NULL)
}
