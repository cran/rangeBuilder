// Generated by using Rcpp::compileAttributes() -> do not edit by hand
// Generator token: 10BE3573-1514-4C36-9D1C-5A225CD40393

#include <Rcpp.h>

using namespace Rcpp;

// shortDistInd
IntegerVector shortDistInd(NumericMatrix mat1, NumericMatrix mat2);
RcppExport SEXP rangeBuilder_shortDistInd(SEXP mat1SEXP, SEXP mat2SEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::traits::input_parameter< NumericMatrix >::type mat1(mat1SEXP);
    Rcpp::traits::input_parameter< NumericMatrix >::type mat2(mat2SEXP);
    rcpp_result_gen = Rcpp::wrap(shortDistInd(mat1, mat2));
    return rcpp_result_gen;
END_RCPP
}
