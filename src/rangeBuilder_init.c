#include <R.h>
#include <Rinternals.h>
#include <stdlib.h> // for NULL
#include <R_ext/Rdynload.h>

/* FIXME: 
   Check these declarations against the C/Fortran source code.
*/

/* .Call calls */
extern SEXP rangeBuilder_shortDistInd(SEXP, SEXP);

static const R_CallMethodDef CallEntries[] = {
    {"rangeBuilder_shortDistInd", (DL_FUNC) &rangeBuilder_shortDistInd, 2},
    {NULL, NULL, 0}
};

void R_init_rangeBuilder(DllInfo *dll)
{
    R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
    R_useDynamicSymbols(dll, FALSE);
}
