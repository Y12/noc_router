%{

#include "booksim.hpp"
#include <stdlib.h>
#include <string>
#include <cstring>

#include "config_tab.hpp"
#include "config_utils.hpp"

static unsigned int lineno = 1;

void configerror(string msg);
extern "C" int configwrap() { return 1; }

extern int config_input(char *, int);
#undef YY_INPUT
#define YY_INPUT(b, r, ms) (r = config_input(b, ms))

%}

Digit [0-9]
Exponent [eE][+-]?{Digit}+
DblConst ({Digit}*\.)?{Digit}+{Exponent}?
StrConst [A-Za-z_\-/\.][A-Za-z0-9_\-/\.\+(\{\,)\}]*

%%

   /* Ignore comments and all spaces */

\/\/[^\n]* ;
[ \t\r]*   ;

\n         { lineno++; }

   /* Commands */

{StrConst} { configlval.name = strdup( yytext ); return STR; }

\{[A-Za-z0-9_\-\.(\{\,)\}]+(\,[A-Za-z0-9_\-\.(\{\,)\}]+)*\} { configlval.name = strdup( yytext ); return STR; }

-?[0-9]+     { configlval.num = atoi( yytext ); return NUM; }

-?[0-9]*\.[0-9]+ { configlval.fnum = atof( yytext ); return FNUM; }

-?{DblConst}  { configlval.fnum = atof( yytext ); return FNUM;}

.          { return yytext[0]; }

%%

void configerror( string msg )
{
  Configuration::GetTheConfig( )->ParseError( msg, lineno );
}


