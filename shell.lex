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
[a-zA-Z]+ return WORD;
. {yyerror("Unrecognized character"); return 0;}
%%
