%{
	#include <stdio.h>
	#include <string.h>
	#include <stdlib.h>
	#include "y.tab.h"
%}
%%
cd return CD;
printenv return PRINTENV;
unsetenv return UNSETENV;
setenv return SETENV;
alias return ALIAS;
unalias return UNALIAS;
bye return BYE;
[-*?@!#%',=~_.:/:A-Za-z0-9]+ return WORD;
"\""[-*? \\<>&\|${},_\"@!#%'=~.:/:A-Za-z0-9]+"\"" return QUOTES;
\n return NEWLINE;
[ \t]+ /* ignore end of line */;
"${"[-*?@!#%,'=~._:/:AAN-Za-z0-9]+"}" return ENVIRONMENTVARIABLE; 
"<" return READFROM;
">" return WRITETO;
"|" return PIPE;
"&" return AMPERSAND;
">>" return APPEND;
"2>"[*?@!#%',=~.:/:A-Za-z0-9]+ return STANDARDERROR1;
"2>&1" return STANDARDERROR2;
<<EOF>>	{exit(0);}
. {yyerror("Unrecognized character");}
%%
