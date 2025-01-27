#' @include main.R
#' @include workflow-step.R
NULL

#' Base transformation products (TP) class
#'
#' Holds information for all TPs for a set of parents.
#'
#' This class holds all generated data for transformation products for a set of parents. The class is \code{virtual} and
#' derived objects are created by \link[=TP-generation]{TP generators}.
#'
#' The TP data in objects from this class include a \code{retDir} column. These are \code{numeric} values that hint what
#' the the chromatographic retention order of a TP might be compared to its parent: a value of \samp{-1} means it will
#' elute earlier, \samp{1} it will elute later and \samp{0} that there is no significant difference or the direction is
#' unknown. These values are based on a typical reversed phase separation. When \code{\link{generateTPsBioTransformer}}
#' or \code{\link{generateTPsLibrary}} was used to generate the data, the \code{retDir} values are based on calculated
#' \code{log P} values of the parent and its TPs.
#'
#' @param TPs,x,object \code{transformationProducts} object to be accessed
#'
#' @seealso Derived classes \code{\link{transformationProductsBT}} and \code{\link{transformationProductsLibrary}} for
#'   specific algorithm methods and \code{\link{TP-generation}}
#'
#' @slot parents A \code{\link{data.table}} with metadata for all parents that have TPs in this object. Use the
#'   \code{parents} method for access.
#' @slot products A \code{list} with \code{\link{data.table}} entries with TP information for each parent. Use the
#'   \code{products} method for access.
#'
#' @templateVar seli parents
#' @templateVar selOrderi names()
#' @templateVar dollarOpName parent
#' @template sub_sel_del-args
#'
#' @templateVar class transformationProducts
#' @template class-hierarchy
#'
#' @export
transformationProducts <- setClass("transformationProducts",
                          slots = c(parents = "data.table", products = "list"),
                          contains = c("VIRTUAL", "workflowStep"))

#' @describeIn transformationProducts Accessor method for the \code{parents} slot of a
#'   \code{transformationProducts} class.
#' @aliases parents
#' @export
setMethod("parents", "transformationProducts", function(TPs) TPs@parents)

#' @describeIn transformationProducts Accessor method for the \code{products} slot.
#' @aliases products
#' @export
setMethod("products", "transformationProducts", function(TPs) TPs@products)

#' @describeIn transformationProducts Obtain total number of transformation products.
#' @export
setMethod("length", "transformationProducts", function(x) if (length(products(x)) == 0) 0 else sum(sapply(products(x), nrow)))

#' @describeIn transformationProducts Obtain the names of all parents in this object.
#' @export
setMethod("names", "transformationProducts", function(x) parents(x)$name)

#' @describeIn transformationProducts Show summary information for this object.
#' @export
setMethod("show", "transformationProducts", function(object)
{
    callNextMethod()
    
    printf("Parents: %s (%d total)\n", getStrListWithMax(names(object), 6, ", "), nrow(parents(object)))
    printf("Total TPs: %d\n", length(object))
})

#' @describeIn transformationProducts Subset on parents.
#' @param \dots Unused.
#' @export
setMethod("[", c("transformationProducts", "ANY", "missing", "missing"), function(x, i, ...)
{
    if (!missing(i))
    {
        i <- assertSubsetArgAndToChr(i, names(x))
        x@products <- x@products[i]
        x@parents <- x@parents[name %in% i]
    }
    
    return(x)
})

#' @describeIn transformationProducts Extracts a table with TPs for a parent.
#' @export
setMethod("[[", c("transformationProducts", "ANY", "missing"), function(x, i, j)
{
    assertExtractArg(i)
    return(x@products[[i]])
})

#' @describeIn transformationProducts Extracts a table with TPs for a parent.
#' @export
setMethod("$", "transformationProducts", function(x, name)
{
    eval(substitute(x@products$NAME_ARG, list(NAME_ARG = name)))
})

# UNDONE: add more parent info?
#' @describeIn transformationProducts Returns all TP data in a table.
#' @export
setMethod("as.data.table", "transformationProducts", function(x) rbindlist(products(x), idcol = "parent"))

#' @describeIn transformationProducts Converts this object to a suspect list that can be used as input for
#'   \code{\link{screenSuspects}}.
#' @param includeParents If \code{TRUE} then parents are also included in the returned suspect list.
#' @export
setMethod("convertToSuspects", "transformationProducts", function(TPs, includeParents = FALSE)
{
    ac <- checkmate::makeAssertCollection()
    checkmate::assertFlag(includeParents, add = ac)
    checkmate::reportAssertions(ac)

    if (length(TPs) == 0)
        stop("Cannot create suspect list: no data", call. = FALSE)

    prodAll <- rbindlist(products(TPs))
    keepCols <- c("name", "SMILES", "InChI", "InChIKey", "formula", "neutralMass")
    prodAll <- prodAll[, intersect(keepCols, names(prodAll)), with = FALSE]
    prodAll <- prepareSuspectList(prodAll, NULL, FALSE, FALSE)
    
    if (includeParents)
        prodAll <- rbind(parents(TPs), prodAll, fill = TRUE)

    return(prodAll)
})

setMethod("needsScreening", "transformationProducts", function(TPs) TRUE)

setMethod("linkTPsToFGroups", "transformationProducts", function(TPs, fGroups)
{
    TPNames <- as.data.table(TPs)$name
    ret <- screenInfo(fGroups)[name %in% TPNames, c("group", "name"), with = FALSE]
    setnames(ret, "name", "TP_name")
    return(ret)
})


#' @templateVar func generateTPs
#' @templateVar what generate transformation products
#' @templateVar ex1 generateTPsBioTransformer
#' @templateVar ex2 generateTPsLogic
#' @templateVar algos biotransformer,logic,library
#' @template generic-algo
#'
#' @param ... Any parameters to be passed to the selected TP generation algorithm.
#'
#' @rdname TP-generation
#' @aliases generateTPs
#' @export
generateTPs <- function(algorithm, ...)
{
    checkmate::assertChoice(algorithm, c("biotransformer", "logic", "library"))
    
    f <- switch(algorithm,
                biotransformer = generateTPsBioTransformer,
                logic = generateTPsLogic,
                library = generateTPsLibrary)
    
    f(...)
}
