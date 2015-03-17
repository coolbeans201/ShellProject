%{#include <stdio.h>
  #include <string.h>
  void yyerror(const char *str){fprintf(stderr,"error: %s\n", str);}
  int yywrap(){return 1;}
  main(){yyparse();}
%}
%token CD PRINTENV UNSETENV SETENV ALIAS UNALIAS BYE WORD
%%
commands: 
		| commands command;
command:
		cd_case|cd2_case|printenv_case|unsetenv_case|setenv_case|alias_case|alias2_case|unalias_case|bye_case;
cd2_case:
		CD		{printf("Second CD command entered\n");};
cd_case:
	    CD WORD {printf("CD command entered\n");};
printenv_case:
	    PRINTENV {printf("Printenv command entered\n");};
unsetenv_case:
		UNSETENV WORD {printf("Unsetenv command entered\n");};
setenv_case:
		SETENV WORD WORD   {printf("Setenv command entered\n");};
alias2_case:
		ALIAS			   {printf("Second alias command entered\n");};
alias_case:
		ALIAS WORD WORD    {printf("Alias command entered\n");};
unalias_case:
		UNALIAS WORD       {printf("Unalias command entered\n");};
bye_case:
		BYE				   {printf("Bye command entered\n");};
		
