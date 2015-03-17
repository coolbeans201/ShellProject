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
[a-zA-Z0-9]+ return WORD;
\[<>\"|&]+ | [<>\"|&]+ return WORDWITHMETA;
[ \t\n]+ return WHITESPACE;
[*?] return MATCHER;
"." | "/." | "/" return EXPLICITMATCHER;
":" return COLON;
"~" return TILDE;
. {yyerror("Unrecognized character"); return 0;}
%%

