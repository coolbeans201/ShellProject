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
[A-Za-z0-9]+ return WORD;
\[<>\"|&]+ | [<>\"|&]+ return WORDWITHMETA;
[*?] return MATCHER;
"." | "/." | "/" return EXPLICITMATCHER;
":" return COLON;
"~" return TILDE;
\n return NEWLINE;
[ \t]+ /*ignore whitespace*/;
. {yyerror("Unrecognized character"); return 0;}
%%
