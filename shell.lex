%{
	#include <stdio.h>
	#include "y.tab.h"
%}
%%
cd	return CD;
printenv return PRINTENV;
unsetenv return UNSETENV;
setenv return SETENV;
alias return ALIAS;
unalias return UNALIAS;
bye return BYE;
[@!#%'=~./:A-Za-z0-9]+ return WORD;
[*?] return MATCHER;
"\"" return QUOTES;
\n return NEWLINE;
[ \t]+ /* ignore end of line */;
"${"	return ENVIRONMENTSTART;
"}"	return ENVIRONMENTEND;
\\ return SLASH;
"<" return READFROM;
">" return WRITETO;
"|" return PIPE;
"&" return AMPERSAND;
. {yyerror("Unrecognized character"); return 0;}
%%
