// Generated by using Rcpp::compileAttributes() -> do not edit by hand
// Generator token: 10BE3573-1514-4C36-9D1C-5A225CD40393

#include <Rcpp.h>

using namespace Rcpp;

// parseFeatureXMLFile
Rcpp::DataFrame parseFeatureXMLFile(Rcpp::CharacterVector file);
RcppExport SEXP _patRoon_parseFeatureXMLFile(SEXP fileSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< Rcpp::CharacterVector >::type file(fileSEXP);
    rcpp_result_gen = Rcpp::wrap(parseFeatureXMLFile(file));
    return rcpp_result_gen;
END_RCPP
}
// parseFeatConsXMLFile
Rcpp::List parseFeatConsXMLFile(Rcpp::CharacterVector file, Rcpp::IntegerVector anaCount);
RcppExport SEXP _patRoon_parseFeatConsXMLFile(SEXP fileSEXP, SEXP anaCountSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< Rcpp::CharacterVector >::type file(fileSEXP);
    Rcpp::traits::input_parameter< Rcpp::IntegerVector >::type anaCount(anaCountSEXP);
    rcpp_result_gen = Rcpp::wrap(parseFeatConsXMLFile(file, anaCount));
    return rcpp_result_gen;
END_RCPP
}
// writeFeatureXML
void writeFeatureXML(Rcpp::DataFrame featList, Rcpp::CharacterVector out);
RcppExport SEXP _patRoon_writeFeatureXML(SEXP featListSEXP, SEXP outSEXP) {
BEGIN_RCPP
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< Rcpp::DataFrame >::type featList(featListSEXP);
    Rcpp::traits::input_parameter< Rcpp::CharacterVector >::type out(outSEXP);
    writeFeatureXML(featList, out);
    return R_NilValue;
END_RCPP
}
// loadEICIntensities
Rcpp::NumericVector loadEICIntensities(Rcpp::List spectra, Rcpp::DataFrame featList, Rcpp::NumericVector rtWindow);
RcppExport SEXP _patRoon_loadEICIntensities(SEXP spectraSEXP, SEXP featListSEXP, SEXP rtWindowSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< Rcpp::List >::type spectra(spectraSEXP);
    Rcpp::traits::input_parameter< Rcpp::DataFrame >::type featList(featListSEXP);
    Rcpp::traits::input_parameter< Rcpp::NumericVector >::type rtWindow(rtWindowSEXP);
    rcpp_result_gen = Rcpp::wrap(loadEICIntensities(spectra, featList, rtWindow));
    return rcpp_result_gen;
END_RCPP
}
// loadEICs
Rcpp::List loadEICs(Rcpp::List spectra, Rcpp::List rtRanges, Rcpp::List mzRanges);
RcppExport SEXP _patRoon_loadEICs(SEXP spectraSEXP, SEXP rtRangesSEXP, SEXP mzRangesSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< Rcpp::List >::type spectra(spectraSEXP);
    Rcpp::traits::input_parameter< Rcpp::List >::type rtRanges(rtRangesSEXP);
    Rcpp::traits::input_parameter< Rcpp::List >::type mzRanges(mzRangesSEXP);
    rcpp_result_gen = Rcpp::wrap(loadEICs(spectra, rtRanges, mzRanges));
    return rcpp_result_gen;
END_RCPP
}
// makeSAFDInput
Rcpp::List makeSAFDInput(Rcpp::List spectra);
RcppExport SEXP _patRoon_makeSAFDInput(SEXP spectraSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< Rcpp::List >::type spectra(spectraSEXP);
    rcpp_result_gen = Rcpp::wrap(makeSAFDInput(spectra));
    return rcpp_result_gen;
END_RCPP
}

static const R_CallMethodDef CallEntries[] = {
    {"_patRoon_parseFeatureXMLFile", (DL_FUNC) &_patRoon_parseFeatureXMLFile, 1},
    {"_patRoon_parseFeatConsXMLFile", (DL_FUNC) &_patRoon_parseFeatConsXMLFile, 2},
    {"_patRoon_writeFeatureXML", (DL_FUNC) &_patRoon_writeFeatureXML, 2},
    {"_patRoon_loadEICIntensities", (DL_FUNC) &_patRoon_loadEICIntensities, 3},
    {"_patRoon_loadEICs", (DL_FUNC) &_patRoon_loadEICs, 3},
    {"_patRoon_makeSAFDInput", (DL_FUNC) &_patRoon_makeSAFDInput, 1},
    {NULL, NULL, 0}
};

RcppExport void R_init_patRoon(DllInfo *dll) {
    R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
    R_useDynamicSymbols(dll, FALSE);
}
