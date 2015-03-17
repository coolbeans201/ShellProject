%{#include <stdio.h>
  #include <string.h>
  void yyerror(const char *str){fprintf(stderr,"error: %s\n", str);}
  int yywrap(){return 1;}
  main(){yyparse();}
%}
%token CD PRINTENV UNSETENV SETENV NEWLINE ALIAS UNALIAS BYE WORD WORDWITHMETA MATCHER COLON TILDE QUOTES ENVIRONMENTSTART ENVIRONMENTEND 
%%
commands: 
		| commands command NEWLINE;
command:
		cd2_case|cd_case|printenv_case|unsetenv_case|setenv_case|alias2_case|alias_case|unalias_case|bye_case|quote_case|environment_variable|word_case;
cd2_case:
		CD {printf("Second CD command entered\n");};
cd_case:
	    CD WORD {printf("CD command entered\n");};
printenv_case:
	    PRINTENV {printf("Printenv command entered\n");};
unsetenv_case:
		UNSETENV WORD {printf("Unsetenv command entered\n");};
setenv_case:
		SETENV WORD WORD   {printf("Setenv command entered\n");};
alias2_case:
		ALIAS	{printf("Second alias command entered\n");};
alias_case:
		ALIAS  WORD  WORD    {printf("Alias command entered\n");};
unalias_case:
		UNALIAS WORD       {printf("Unalias command entered\n");};
bye_case:
		BYE				   {printf("Bye command entered\n"); return 0;};
quote_case:
		QUOTES				{printf("Quotes entered\n");};
environment_variable:
		ENVIRONMENTSTART WORD ENVIRONMENTEND {printf("Environment variable entered\n");};
word_case:
		WORD				{printf("Word entered\n");};
