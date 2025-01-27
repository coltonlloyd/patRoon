% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/feature_groups.R, R/feature_groups-set.R,
%   R/feature_groups-bruker.R, R/feature_groups-envimass.R,
%   R/feature_groups-kpic2.R, R/feature_groups-openms.R,
%   R/feature_groups-sirius.R, R/feature_groups-xcms.R, R/feature_groups-xcms3.R
\docType{class}
\name{featureGroups-class}
\alias{featureGroups-class}
\alias{featureGroups}
\alias{names,featureGroups-method}
\alias{analyses,featureGroups-method}
\alias{replicateGroups,featureGroups-method}
\alias{groupNames,featureGroups-method}
\alias{length,featureGroups-method}
\alias{show,featureGroups-method}
\alias{groupTable,featureGroups-method}
\alias{groupTable}
\alias{analysisInfo,featureGroups-method}
\alias{groupInfo,featureGroups-method}
\alias{groupInfo}
\alias{featureTable,featureGroups-method}
\alias{getFeatures,featureGroups-method}
\alias{groupFeatIndex,featureGroups-method}
\alias{groupFeatIndex}
\alias{groupQualities,featureGroups-method}
\alias{groupQualities}
\alias{groupScores,featureGroups-method}
\alias{groupScores}
\alias{annotations,featureGroups-method}
\alias{adducts,featureGroups-method}
\alias{adducts<-,featureGroups-method}
\alias{[,featureGroups,ANY,ANY,missing-method}
\alias{[[,featureGroups,ANY,ANY-method}
\alias{$,featureGroups-method}
\alias{delete,featureGroups-method}
\alias{export,featureGroups-method}
\alias{getFCParams}
\alias{as.data.table,featureGroups-method}
\alias{plot,featureGroups,missing-method}
\alias{plotInt,featureGroups-method}
\alias{plotChord,featureGroups-method}
\alias{plotChroms,featureGroups-method}
\alias{plotVenn,featureGroups-method}
\alias{plotUpSet,featureGroups-method}
\alias{plotVolcano,featureGroups-method}
\alias{unique,featureGroups-method}
\alias{overlap,featureGroups-method}
\alias{overlap}
\alias{calculatePeakQualities,featureGroups-method}
\alias{selectIons,featureGroups-method}
\alias{selectIons}
\alias{featureGroupsSet-class}
\alias{featureGroupsSet}
\alias{sets,featureGroupsSet-method}
\alias{adducts,featureGroupsSet-method}
\alias{adducts<-,featureGroupsSet-method}
\alias{delete,featureGroupsSet-method}
\alias{show,featureGroupsSet-method}
\alias{featureTable,featureGroupsSet-method}
\alias{[,featureGroupsSet,ANY,ANY,missing-method}
\alias{export,featureGroupsSet-method}
\alias{as.data.table,featureGroupsSet-method}
\alias{filter,featureGroupsSet-method}
\alias{plotInt,featureGroupsSet-method}
\alias{plotVenn,featureGroupsSet-method}
\alias{unique,featureGroupsSet-method}
\alias{overlap,featureGroupsSet-method}
\alias{selectIons,featureGroupsSet-method}
\alias{featureGroupsUnset-class}
\alias{featureGroupsUnset}
\alias{unset,featureGroupsSet-method}
\alias{featureGroupsBruker-class}
\alias{featureGroupsBruker}
\alias{featureGroupsEnviMass-class}
\alias{featureGroupsEnviMass}
\alias{featureGroupsKPIC2-class}
\alias{featureGroupsKPIC2}
\alias{featureGroupsOpenMS-class}
\alias{featureGroupsOpenMS}
\alias{featureGroupsSIRIUS-class}
\alias{featureGroupsSIRIUS}
\alias{featureGroupsXCMS-class}
\alias{featureGroupsXCMS}
\alias{featureGroupsXCMS3-class}
\alias{featureGroupsXCMS3}
\title{Base class for grouped features.}
\usage{
\S4method{names}{featureGroups}(x)

\S4method{analyses}{featureGroups}(obj)

\S4method{replicateGroups}{featureGroups}(obj)

\S4method{groupNames}{featureGroups}(obj)

\S4method{length}{featureGroups}(x)

\S4method{show}{featureGroups}(object)

\S4method{groupTable}{featureGroups}(object, areas = FALSE)

\S4method{analysisInfo}{featureGroups}(obj)

\S4method{groupInfo}{featureGroups}(fGroups)

\S4method{featureTable}{featureGroups}(obj)

\S4method{getFeatures}{featureGroups}(obj)

\S4method{groupFeatIndex}{featureGroups}(fGroups)

\S4method{groupQualities}{featureGroups}(fGroups)

\S4method{groupScores}{featureGroups}(fGroups)

\S4method{annotations}{featureGroups}(obj)

\S4method{adducts}{featureGroups}(obj)

\S4method{adducts}{featureGroups}(obj) <- value

\S4method{[}{featureGroups,ANY,ANY,missing}(x, i, j, ..., rGroups, results, drop = TRUE)

\S4method{[[}{featureGroups,ANY,ANY}(x, i, j)

\S4method{$}{featureGroups}(x, name)

\S4method{delete}{featureGroups}(obj, i = NULL, j = NULL, ...)

\S4method{export}{featureGroups}(obj, type, out)

getFCParams(rGroups, ...)

\S4method{as.data.table}{featureGroups}(
  x,
  average = FALSE,
  areas = FALSE,
  features = FALSE,
  qualities = FALSE,
  regression = FALSE,
  averageFunc = mean,
  normFunc = NULL,
  FCParams = NULL
)

\S4method{plot}{featureGroups,missing}(
  x,
  colourBy = c("none", "rGroups", "fGroups"),
  onlyUnique = FALSE,
  retMin = FALSE,
  showLegend = TRUE,
  col = NULL,
  pch = NULL,
  ...
)

\S4method{plotInt}{featureGroups}(
  obj,
  average = FALSE,
  normFunc = NULL,
  xnames = TRUE,
  showLegend = FALSE,
  pch = 20,
  type = "b",
  lty = 3,
  col = NULL,
  ...
)

\S4method{plotChord}{featureGroups}(
  obj,
  addSelfLinks = FALSE,
  addRetMzPlots = TRUE,
  average = FALSE,
  outerGroups = NULL,
  addIntraOuterGroupLinks = FALSE,
  ...
)

\S4method{plotChroms}{featureGroups}(
  obj,
  rtWindow = 30,
  mzExpWindow = 0.001,
  retMin = FALSE,
  topMost = NULL,
  topMostByRGroup = FALSE,
  EICs = NULL,
  showPeakArea = FALSE,
  showFGroupRect = TRUE,
  title = NULL,
  colourBy = c("none", "rGroups", "fGroups"),
  showLegend = TRUE,
  onlyPresent = TRUE,
  annotate = c("none", "ret", "mz"),
  showProgress = FALSE,
  xlim = NULL,
  ylim = NULL,
  ...
)

\S4method{plotVenn}{featureGroups}(obj, which = NULL, ...)

\S4method{plotUpSet}{featureGroups}(obj, which = NULL, nsets = length(which), nintersects = NA, ...)

\S4method{plotVolcano}{featureGroups}(
  obj,
  FCParams,
  showLegend = TRUE,
  averageFunc = mean,
  col = NULL,
  pch = 19,
  ...
)

\S4method{unique}{featureGroups}(x, which, relativeTo = NULL, outer = FALSE)

\S4method{overlap}{featureGroups}(fGroups, which, exclusive)

\S4method{calculatePeakQualities}{featureGroups}(
  obj,
  weights,
  flatnessFactor,
  avgFunc = mean,
  parallel = TRUE
)

\S4method{selectIons}{featureGroups}(
  fGroups,
  components,
  prefAdduct,
  onlyMonoIso = TRUE,
  chargeMismatch = "adduct"
)

\S4method{sets}{featureGroupsSet}(obj)

\S4method{adducts}{featureGroupsSet}(obj, set, ...)

\S4method{adducts}{featureGroupsSet}(obj, set, reGroup = TRUE) <- value

\S4method{delete}{featureGroupsSet}(obj, i = NULL, j = NULL, ...)

\S4method{show}{featureGroupsSet}(object)

\S4method{featureTable}{featureGroupsSet}(obj)

\S4method{[}{featureGroupsSet,ANY,ANY,missing}(x, i, j, ..., rGroups, sets = NULL, drop = TRUE)

\S4method{export}{featureGroupsSet}(obj, type, out, set)

\S4method{as.data.table}{featureGroupsSet}(
  x,
  average = FALSE,
  areas = FALSE,
  features = FALSE,
  qualities = FALSE,
  regression = FALSE,
  averageFunc = mean,
  normFunc = NULL,
  FCParams = NULL
)

\S4method{filter}{featureGroupsSet}(
  obj,
  ...,
  negate = FALSE,
  sets = NULL,
  absMinSets = NULL,
  relMinSets = NULL
)

\S4method{plotInt}{featureGroupsSet}(
  obj,
  average = FALSE,
  normFunc = NULL,
  xnames = !sets,
  showLegend = sets,
  pch = 20,
  type = "b",
  lty = 3,
  col = NULL,
  ...,
  sets = FALSE
)

\S4method{plotVenn}{featureGroupsSet}(obj, which = NULL, ..., sets = FALSE)

\S4method{unique}{featureGroupsSet}(x, which, ..., sets = FALSE)

\S4method{overlap}{featureGroupsSet}(fGroups, which, exclusive, sets = FALSE)

\S4method{selectIons}{featureGroupsSet}(fGroups, components, prefAdduct, ...)

\S4method{unset}{featureGroupsSet}(obj, set)
}
\arguments{
\item{areas}{If set to \code{TRUE} then areas are considered instead of peak intensities.

  For \code{as.data.table}: ignored if \code{features=TRUE}, as areas of features are always reported.}

\item{fGroups, obj, x, object}{\code{featureGroups} object to be accessed.}

\item{value}{For \code{adducts<-}: A \code{character} with adduct annotations assigned to each feature group. The
length should equal the number of feature groups. Can be named with feature group names to customize the assignment
order.}

\item{i, j}{For \code{[}/\code{[[}: A numeric or character value which is used to select analyses/feature groups by
their index or name, respectively (for the order/names see \code{analyses()/names()}).\cr\cr For \code{[}: Can also be logical to perform logical selection
(similar to regular vectors). If missing all analyses/feature groups are selected.\cr\cr For \code{[[}: should be a scalar value. If \code{j} is not specified, \code{i} selects by feature groups instead.\cr\cr For \code{delete}: The data to remove from. \code{i} are the
analyses as numeric index, logical or character, \code{j} the feature groups as numeric index, logical or character. If either is
\code{NULL} then data for all is removed. \code{j} may also be a function: it will be called for each 
feature group, with a vector of the group intensities as first argument, the group name as second argument, and any other arguments passed as
\code{\dots} to \code{delete}. The return value of this function specifies the analyses of the features in the group to be removed (same format as \code{i}).}

\item{\dots}{For the \code{"["} operator: ignored.

  For \code{delete}: passed to the function specified as \code{j}.

  For \code{getFCParams}: optional named arguments that override defaults.
  
  \setsPassedArgs1{featureGroups}

  Otherwise passed to \code{\link[graphics]{plot}} (\code{plot} and \code{plotChroms}), \code{\link[graphics]{lines}}
  (\code{plotInt}), \pkg{\link{VennDiagram}} plotting functions (\code{plotVenn}), \code{\link{chordDiagram}}
  (\code{plotChord}) or \code{\link[UpSetR]{upset}} (\code{plotUpSet}).}

\item{rGroups}{For \code{[}: An optional \code{character} vector: if specified only keep results for the given
  replicate groups (equivalent to the \code{rGroups} argument to \code{\link[=filter,featureGroups-method]{filter}}).

  For \code{getFCParams}: a \code{character} vector with the names of the two replicate groups to be compared.}

\item{results}{Optional argument. If specified only feature groups with results in the specified object are kept. The
class of \code{results} should be \code{\link{featureAnnotations}} or \code{\link{components}}. Multiple objects
can be specified in a \code{list}: in this case a feature group is kept if it has a result in \emph{any} of the
objects (equivalent to the \code{results} argument to \code{\link[=filter,featureGroups-method]{filter}}).}

\item{drop}{ignored.}

\item{name}{The feature group name (partially matched).}

\item{out}{The destination file for the exported data.}

\item{average}{If \code{TRUE} then data within replicate groups are averaged.

  For \code{as.data.table}: if \code{features=TRUE} other feature properties are also averaged.}

\item{features}{If \code{TRUE} then feature specific data will be added. If \code{average=TRUE} this data will be
averaged for each feature group.}

\item{qualities}{Adds feature (group) qualities (\code{qualities="quality"}), scores (\code{qualities="score"}) or
both (\code{qualities="both"}), if this data is available (\emph{i.e.} from \code{calculatePeakQualities}). If
\code{qualities=FALSE} then nothing is reported.}

\item{regression}{Set to \code{TRUE} to add regression data for each feature group. For this a linear model is
created (intensity/area [depending on \code{areas} argument] \emph{vs} concentration). The model concentrations
(e.g. of a set of standards) is derived from the \code{conc} column of the \link[=analysis-information]{analysis
information}. From this model the intercept, slope and R2 is added to the output. In addition, when
\code{features=TRUE}, concentrations for each feature are added. Note that no regression information is added when
no \code{conc} column is present in the analysis information or when less than two concentrations are specified
(\emph{i.e.} the minimum amount).}

\item{averageFunc}{Function used for averaging.

for \code{as.data.table}: only used when \code{average=TRUE} or \code{FCParams != NULL}.}

\item{normFunc}{Function that should be used for normalization of data. The function is called for all
intensities/areas of a feature group and these quantities are divided by the result of the function call. For
example, when \code{\link{max}} is used normalized intensities will be between zero and one. If all quantities are
zero then the function will not be called. Set to \code{NULL} to perform no normalization.}

\item{FCParams}{A parameter list to calculate Fold change data (see \code{getFCParams} and the
\verb{Fold change calculation} section).

For \code{as.data.table}: set to \code{NULL} to not perform FC calculations.}

\item{colourBy}{Sets the automatic colour selection: \code{"none"} for a single colour or
\code{"rGroups"}/\code{"fGroups"} for a distinct colour per replicate/feature group.}

\item{onlyUnique}{If \code{TRUE} and \code{colourBy="rGroups"} then only
feature groups that are unique to a replicate group are plotted.}

\item{retMin}{Plot retention time in minutes (instead of seconds).}

\item{showLegend}{Plot a legend if \code{TRUE}.}

\item{col}{Colour(s) used. If \code{col=NULL} then colours are automatically generated.}

\item{pch, type, lty}{Common plotting parameters passed to \emph{e.g.} \code{\link[graphics]{plot}}. For \code{plot}:
if \code{pch=NULL} then values are automatically assigned.}

\item{xnames}{Plot analysis (or replicate group if \code{average=TRUE}) names on the x axis.}

\item{addSelfLinks}{If \code{TRUE} then 'self-links' are added which
represent non-shared data.}

\item{addRetMzPlots}{Set to \code{TRUE} to enable \emph{m/z} \emph{vs}
retention time scatter plots.}

\item{outerGroups}{Character vector of names to be used as outer groups. The
values in the specified vector should be named by analysis names
(\code{average} set to \code{FALSE}) or replicate group names
(\code{average} set to \code{TRUE}), for instance: \code{c(analysis1 =
"group1", analysis2 = "group1", analysis3 = "group2")}. Set to \code{NULL}
to disable outer groups.}

\item{addIntraOuterGroupLinks}{If \code{TRUE} then links will be added within
outer groups.}

\item{rtWindow}{Retention time (in seconds) that will be subtracted/added to respectively the minimum and maximum
retention time of the plotted feature groups. Thus, setting this value to a positive value will 'zoom out' on the
retention time axis.}

\item{mzExpWindow}{In case the \emph{m/z} window to plot an EIC for a particular analysis is not known (\emph{i.e.}
no feature was detected of the feature group to be plot and \code{onlyPresent=FALSE}) then the EIC \emph{m/z} range
is estimated from the range for the complete feature group and expanded by the offset defined by
\code{mzExpWindow}.}

\item{topMost}{Only plot EICs from features within this number of top most intense analyses. If \code{NULL} then all
analyses are used for plotted.}

\item{topMostByRGroup}{If set to \code{TRUE} and \code{topMost} is set: only plot EICs for the top most features in
each replicate group. For instance, when \code{topMost=1} and \code{topMostByRGroup=TRUE}, then EICs will be
plotted for the most intense feature of each replicate group.}

\item{EICs}{Internal parameter for now and should be kept at \code{NULL} (default).}

\item{showPeakArea}{Set to \code{TRUE} to display integrated chromatographic peak ranges by filling (shading) their
areas.}

\item{showFGroupRect}{Set to \code{TRUE} to mark the full retention/intensity range of all features within a feature
group by drawing a rectangle around it.}

\item{title}{Character string used for title of the plot. If \code{NULL} a title will be automatically generated.}

\item{onlyPresent}{If \code{TRUE} then EICs will only be generated for analyses in which a particular feature group
was detected. Disabling this option might be useful to see if any features were 'missed'.}

\item{annotate}{If set to \code{"ret"} and/or \code{"mz"} then retention and/or \emph{m/z} values will be drawn for
each plotted feature group.}

\item{showProgress}{if set to \code{TRUE} then a text progressbar will be displayed when all EICs are being plot. Set
to \code{"none"} to disable any annotation.}

\item{xlim, ylim}{Sets the plot size limits used by
\code{\link[graphics]{plot}}. Set to \code{NULL} for automatic plot sizing.}

\item{which}{A character vector with replicate groups used for comparison.

  For plotting functions: set to \code{NULL} for all replicate groups.

  For \code{plotVenn}: alternatively a named \code{list} containing elements of \code{character} vectors with
  replicate groups to compare. For instance, \code{which=list(infl = c("influent-A", "influent-B"), effl =
  c("effluent-A", "effluent-B"))}, will compare the features in replicate groups \samp{"influent-A/B"} against those
  in \samp{"effluent-A/B"}. The names of the list are used for labelling in the plot, and will be made automatically
  if not specified.}

\item{nsets, nintersects}{See \code{\link[UpSetR]{upset}}.}

\item{relativeTo}{A character vector with replicate groups that should be
used for unique comparison. If \code{NULL} then all replicate groups are
used for comparison. Replicate groups specified in \code{which} are
ignored.}

\item{outer}{If \code{TRUE} then only feature groups are kept which do not
overlap between the specified replicate groups for the \code{which}
parameter.}

\item{exclusive}{If \code{TRUE} then all feature groups are removed that are
not unique to the given replicate groups.}

\item{weights}{A named \code{numeric} vector that defines the weight for each score to calculate the
\verb{totalScore}. The names of the vector follow the score names. Unspecified weights are defaulted to \samp{1}.
Example: \code{weights=c(ApexBoundaryRatioScore=0.5, GaussianSimilarityScore=2)}.}

\item{flatnessFactor}{Passed to \pkg{MetaClean} as the \code{flatness.factor} argument to
\code{\link[MetaClean]{calculateJaggedness}} and \code{\link[MetaClean]{calculateModality}}.}

\item{avgFunc}{The function used to average the peak qualities and scores for each feature group.}

\item{parallel}{If set to \code{TRUE} then code is executed in parallel through the \CRANpkg{futures} package. Please
see the parallelization section in the handbook for more details.}

\item{components}{The \code{components} object that was generated for the given \code{featureGroups} object.
Obviously, the components must be created with algorithms that support adduct/isotope annotations, such as those
from \pkg{RAMClustR} and \pkg{cliqueMS}.}

\item{prefAdduct}{The 'preferred adduct' (see method description). This is often \code{"[M+H]+"} or \code{"[M-H]-"}.}

\item{onlyMonoIso}{Set to \code{TRUE} to only keep feature groups that were annotated as monoisotopic. Feature groups
are never removed by this setting if no isotope annotations are available.}

\item{chargeMismatch}{Specifies how to deal with a mismatch in charge between adduct and isotope annotations. Valid
values are: \code{"adduct"} (ignore isotope annotation), \code{"isotope"} (ignore adduct annotation), \code{"none"}
(ignore both annotations) and \code{"ignore"} (don't check for charge mismatches). \emph{Important}: when
\command{OpenMS} is used to find features, it already removes any detected non-monoisotopic features by default.
Hence, in such case setting \code{chargeMismatch="adduct"} is more appropriate.}

\item{set}{\setsWF The name of the set.}

\item{reGroup}{Set to \code{TRUE} to re-group the features after the adduct annotations are changed. See the
\verb{Sets workflow} section for more details.}

\item{sets}{\setsWF For \code{[} and \code{filter}: a \code{character} with name(s) of the sets to keep (or remove if
  \code{negate=TRUE}).

  For \code{plotInt}: if \code{TRUE} then feature intensities are plot per set (order follows the
  \link[=analysis-information]{analysis information}).

  For \code{plotVenn}, \code{overlap} and \code{unique}: If \code{TRUE} then the \code{which} argument changes its
  meaning and is used to specify the names of the sets to be compared.}

\item{negate}{If set to \code{TRUE} then filtering operations are performed in opposite manner.}

\item{absMinSets, relMinSets}{\setsWF Feature groups are only kept when they contain data for at least this (absolute
or relative) amount of sets. Set to \code{NULL} to ignore.}
}
\value{
\code{delete} returns the object for which the specified data was removed.

\code{plotVenn} (invisibly) returns a list with the following fields: \itemize{
\item \code{gList} the \code{gList} object that was returned by
  the utilized \pkg{\link{VennDiagram}} plotting function.
\item \code{areas} The total area for each plotted group.
\item \code{intersectionCounts} The number of intersections between groups.
}

The order for the \code{areas} and \code{intersectionCounts} fields is the same as the parameter order
from the used plotting function (see \emph{e.g.} \code{\link{draw.pairwise.venn}} and
\code{\link{draw.triple.venn}}).

\code{calculatePeakQualities} returns a modified object amended with peak qualities and scores.

\code{selectIons} returns a \code{featureGroups} object with only the selected feature groups and amended
  with adduct annotations.
}
\description{
This class holds all the information for grouped features.
}
\details{
The \code{featureGroup} class is the workhorse of \pkg{patRoon}: almost all functionality operate on its instantiated
objects. The class holds all information from grouped features (obtained from \code{\link{features}}). This class
itself is \code{virtual}, hence, objects are not created directly from it. Instead, 'feature groupers' such as
\code{\link{groupFeaturesXCMS}} return a \code{featureGroups} derived object after performing the actual grouping of
features across analyses.

\code{getFCParams} creates a parameter \code{list} to calculate Fold changes (see the
  \verb{Fold change calculation} section).
}
\section{Methods (by generic)}{
\itemize{
\item \code{names}: Obtain feature group names.

\item \code{analyses}: returns a \code{character} vector with the names of the
analyses for which data is present in this object.

\item \code{replicateGroups}: returns a \code{character} vector with the names of the
replicate groups for which data is present in this object.

\item \code{groupNames}: Same as \code{names}. Provided for consistency to other classes.

\item \code{length}: Obtain number of feature groups.

\item \code{show}: Shows summary information for this object.

\item \code{groupTable}: Accessor for \code{groups} slot.

\item \code{analysisInfo}: Obtain analysisInfo (see analysisInfo slot in \code{\link{features}}).

\item \code{groupInfo}: Accessor for \code{groupInfo} slot.

\item \code{featureTable}: Obtain feature information (see \code{\link{features}}).

\item \code{getFeatures}: Accessor for \code{features} slot.

\item \code{groupFeatIndex}: Accessor for \code{ftindex} slot.

\item \code{groupQualities}: Accessor for \code{groupQualities} slot.

\item \code{groupScores}: Accessor for \code{groupScores} slot.

\item \code{annotations}: Accessor for \code{annotations} slot.

\item \code{adducts}: Returns a named \code{character} with adduct annotations assigned to each feature group (if
available).

\item \code{adducts<-}: Sets adduct annotations for feature groups.

\item \code{[}: Subset on analyses/feature groups.

\item \code{[[}: Extract intensity values.

\item \code{$}: Extract intensity values for a feature group.

\item \code{delete}: Completely deletes specified feature groups.

\item \code{export}: Exports feature groups to a \file{.csv} file that
is readable to Bruker ProfileAnalysis (a 'bucket table'), Bruker TASQ (an
analyte database) or that is suitable as input for the \verb{Targeted peak
detection} functionality of \href{http://mzmine.github.io/}{MZmine}.

\item \code{as.data.table}: Obtain a summary table (a \code{\link{data.table}}) with retention, \emph{m/z}, intensity
and optionally other feature data.

\item \code{plot}: Generates an \emph{m/z} \emph{vs} retention time
plot for all featue groups. Optionally highlights unique/overlapping
presence amongst replicate groups.

\item \code{plotInt}: Generates a line plot for the (averaged) intensity
of feature groups within all analyses

\item \code{plotChord}: Generates a chord diagram which can be used to
visualize shared presence of feature groups between analyses or replicate
groups. In addition, analyses/replicates sharing similar properties
(\emph{e.g.} location, age, type) may be grouped to enhance visualization
between these 'outer groups'.

\item \code{plotChroms}: Plots extracted ion chromatograms (EICs) of feature groups.

\item \code{plotVenn}: plots a Venn diagram (using
\pkg{\link{VennDiagram}}) outlining unique and shared feature groups
between up to five replicate groups.

\item \code{plotUpSet}: plots an UpSet diagram (using the
\code{\link[UpSetR]{upset}} function) outlining unique and shared feature
groups between given replicate groups.

\item \code{plotVolcano}: Plots Fold change data in a 'Volcano plot'.

\item \code{unique}: Obtain a subset with unique feature groups
present in one or more specified replicate group(s).

\item \code{overlap}: Obtain a subset with feature groups that overlap
between a set of specified replicate group(s).

\item \code{calculatePeakQualities}: Calculates peak and group qualities for all features and feature groups. The peak qualities
(and scores) are calculated with the \link[=calculatePeakQualities,features-method]{features method of this
function}, and subsequently averaged per feature group. Then, \pkg{MetaClean} is used to calculate the
\verb{Elution Shift} and \verb{Retention Time Consistency} group quality metrics (see the \pkg{MetaClean}
publication cited below for more details). Similarly to the \code{\link{features}} method, these metrics are scored
by normalizing qualities among all groups and scaling them from \samp{0} (worst) to \samp{1} (best). The
\verb{totalScore} for each group is then calculated as the weighted sum from all feature (group) scores. The
\code{\link{getMCTrainData}} and \code{\link{predictCheckFeaturesSession}} functions can be used to train and apply
Pass/Fail ML models from \pkg{MetaClean}.

\item \code{selectIons}: uses \link[=component-generation]{componentization} results to select feature groups with
preferred adduct ion and/or isotope annotation. Typically, this means that only feature groups are kept if they are
(de-)protonated adducts and are monoisotopic. The adduct annotation assignments for the selected feature groups are
copied from the components to the \code{annotations} slot. If the adduct for a feature group is unknown, its
annotation is defaulted to the 'preferred' adduct, and hence, the feature group will never be removed. Furthermore,
if a component does not contain an annotation with the preferred adduct, the most intense feature group is selected
instead. Similarly, if no isotope annotation is available, the feature group is assumed to be monoisotopic and thus
not removed. An important advantage of \code{selectIons} is that it may considerably simplify your dataset.
Furthermore, the adduct assignments allow formula/compound annotation steps later in the workflow to improve their
annotation accuracy. On the other hand, it is important the componentization results are reliable. Hence, it is
highly recommended that, prior to calling \code{selectIons}, the settings to \code{\link{generateComponents}} are
optimized and its results are reviewed with \code{\link{checkComponents}}. Finally, the \code{adducts<-} method can
be used to manually correct adduct assignments afterwards if necessary.
}}

\section{Slots}{

\describe{
\item{\code{groups}}{Matrix (\code{\link{data.table}}) with intensities for each feature group (columns) per analysis (rows).
Access with \code{groups} method.}

\item{\code{analysisInfo,features}}{\link[=analysis-information]{Analysis info} and \code{\link{features}} class associated
with this object. Access with \code{analysisInfo} and \code{featureTable} methods, respectively.}

\item{\code{groupInfo}}{\code{data.frame} with retention time (\code{rts} column, in seconds) and \emph{m/z} (\code{mzs}
column) for each feature group. Access with \code{groupInfo} method.}

\item{\code{ftindex}}{Matrix (\code{\link{data.table}}) with feature indices for each feature group (columns) per analysis
(rows). Each index corresponds to the row within the feature table of the analysis (see
\code{\link{featureTable}}).}

\item{\code{groupQualities,groupScores}}{A \code{\link{data.table}} with qualities/scores for each feature group (see the
\code{calculatePeakQualities} method).}

\item{\code{annotations}}{A \code{\link{data.table}} with adduct annotations for each group (see the \code{selectIons}
method).}

\item{\code{groupAlgo,groupArgs,groupVerbose}}{\setsWF Grouping parameters that were used when this object was created. Used
by \code{adducts<-} and \code{selectIons} when these methods perform a re-grouping of features.}

\item{\code{annotations}}{\setsWF As the \code{featureGroups} slot, but contains the annotation data per set.}
}}

\section{Fold change calculation}{
 the \code{as.data.table} and \code{plotVolcano} methods can be used to
  calculate/plot (log2) Fold changes (FC) between two replicate groups to easily identify significant changes. The
  calculation process is configured through a pramater list, which can be constructed with the \code{getFCParams}
  function. The parameter list has the following entries: \itemize{

  \item \code{rGroups} the name of the two replicate groups to compare (taken from the \code{rGroups} argument to
  \code{getFCParams}).

  \item \code{thresholdFC}: the threshold log FC for a feature group to be classified as increasing/decreasing.

  \item \code{thresholdPV}: the threshold log P for a feature group to be significantly different.

  \item \code{zeroMethod},\code{zeroValue}: how to handle zero values when calculating the FC: \code{add} adds an
  offset to zero values, \code{"fixed"} sets zero values to a fixed number and \code{"omit"} removes zero data. The
  number that is added/set by the former two options is defined by \code{zeroValue}.

  \item \code{PVTestFunc}: a function that is used to calculate P values (usually using \code{\link{t.test}}).
  
  \item \code{PVAdjFunc}: a function that is used to adjust P values (usually using \code{\link{p.adjust}})

  }
}

\section{S4 class hierarchy}{
 \itemize{   \item{\code{\link{workflowStep}}}   \itemize{     \item{\strong{\code{\link{featureGroups}}}}     \itemize{       \item{\code{\link{featureGroupsSet}}}       \itemize{         \item{\code{\link{featureGroupsScreeningSet}}}       }       \item{\code{\link{featureGroupsUnset}}}       \item{\code{\link{featureGroupsScreening}}}       \itemize{         \item{\code{\link{featureGroupsSetScreeningUnset}}}       }       \item{\code{\link{featureGroupsBruker}}}       \item{\code{\link{featureGroupsConsensus}}}       \item{\code{\link{featureGroupsEnviMass}}}       \item{\code{\link{featureGroupsKPIC2}}}       \item{\code{\link{featureGroupsOpenMS}}}       \item{\code{\link{featureGroupsSIRIUS}}}       \item{\code{\link{featureGroupsBrukerTASQ}}}       \item{\code{\link{featureGroupsXCMS}}}       \item{\code{\link{featureGroupsXCMS3}}}     }   } }
}

\section{Sets workflows}{
 \setsWFClass{featureGroupsSet}{featureGroups}

  \setsWFNewMethodsFeat{featureGroupsUnset}{The adduct annotations for the selected set are used to convert all
  feature (group) masses to ionic \emph{m/z} values. The annotations persist in the converted object. }

  \setsWFChangedMethods{

  \item \code{adducts}, \code{adducts<-} require the \code{set} argument. The order of the data that is
  returned/changed follows that of the \code{annotations} slot. Furthermore, \code{adducts<-} will perform a
  re-grouping of features when its \code{reGroup} parameter is set to \code{TRUE}. The implications for this are
  discussed below.

  \item \code{filter} and the subset operator (\code{[}) have specific arguments to choose/filter by (feature
  presence in) sets. See the argument descriptions.

  \item \code{as.data.table}: normalization of intensities is performed per set.

  \item \code{export} Only allows to export data from one set. The \code{unset} method is used prior to exporting the
  data.

  \item \code{overlap}, \code{unique}, \code{plotVenn}, \code{plotInt} allow to handle data per set. See the
  \code{sets} argument description.

  \item \code{selectIons} Will perform a re-grouping of features. The implications of this are discussed below.

  }

  A re-grouping of features occurs if \code{selectIons} is called or \code{adducts<-} is used with
  \code{reGroup=TRUE}. Afterwards, it is very likely that feature group names are changed. Since data generated later
  in the workflow (\emph{e.g.} annotation steps) rely on feature group names, these objects are \strong{not valid}
  anymore, and \strong{must} be re-generated.
}

\references{
\addCitations{circlize}{1}

\insertRef{Conway2017}{patRoon} \cr\cr
  \insertRef{Lex2014}{patRoon}

\insertRef{Chetnik2020}{patRoon}
}
\author{
The code to calculate and plot Fold change data was created by Bas van de Velde.
}
