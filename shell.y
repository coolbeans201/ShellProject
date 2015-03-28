%{
  #include "shell.h"
  extern char *yytext;
  void yyerror(const char *str)
  {
	fprintf(stderr,"error: %s\n", str);
  }
  int yywrap()
  {
	return 1;
  }
  main()
  {
		 yyparse();
  }
%}
%token CD PRINTENV UNSETENV SETENV NEWLINE ALIAS UNALIAS BYE WORD MATCHER QUOTES ENVIRONMENTSTART ENVIRONMENTEND SLASH READFROM WRITETO PIPE AMPERSAND REGEX
%%
commands: 
		| commands command NEWLINE;
command:
		cd2_case
		|cd_case
		|printenv_case
		|unsetenv_case
		|setenv_case
		|alias2_case
		|alias_case
		|unalias_case
		|bye_case
		|quote_case
		|word_case
		|slash_case
		|read_from_case
		|write_to_case
		|pipe_case
		|ampersand_case
		|matcher_case
		|standard_error_redirect_case
		|standard_error_redirect_case2
		|error_case
		|regex_case;
cd2_case:
		CD 
							{
								cd_function();
							};
cd_case:
	    CD WORD 
							{
								cd_function2(yytext);
							}
	|	CD ENVIRONMENTSTART word_case ENVIRONMENTEND
							{
								cd_function2(textArray[getWords() - 1]);
							};
printenv_case:
	    PRINTENV 
							{
								printenv_function();
							};
unsetenv_case:
		UNSETENV WORD 
							{
								unsetenv_function(yytext);
							}
	|	UNSETENV ENVIRONMENTSTART word_case ENVIRONMENTEND
							{
								unsetenv_function(textArray[getWords() - 1]);
							};
setenv_case:
		SETENV word_case word_case   
							{
								setenv_function(textArray[getWords() - 2], textArray [getWords() - 1]);		
							}
	|	SETENV ENVIRONMENTSTART word_case ENVIRONMENTEND ENVIRONMENTSTART word_case ENVIRONMENTEND
							{
								setenv_function(textArray[getWords() - 2], textArray[getWords() - 1]);
							}
	|	SETENV word_case ENVIRONMENTSTART word_case ENVIRONMENTEND
							{
								setenv_function(textArray[getWords() - 2], textArray[getWords() - 1]);
							}
	|	SETENV ENVIRONMENTSTART word_case ENVIRONMENTEND word_case
							{
								setenv_function(textArray[getWords() - 2], textArray[getWords() - 1]);
							};
alias2_case:
		ALIAS	
							{
								alias_function2();
							};
alias_case:
		ALIAS  word_case  word_case    
							{
								alias_function(textArray[getWords() - 2], textArray[getWords() - 1]);
							}
	|	ALIAS ENVIRONMENTSTART word_case ENVIRONMENTEND ENVIRONMENTSTART word_case ENVIRONMENTEND
							{
								alias_function(textArray[getWords() - 2], textArray[getWords() - 1]);
							}
	|	ALIAS word_case ENVIRONMENTSTART word_case ENVIRONMENTEND
							{
								alias_function(textArray[getWords() - 2], textArray[getWords() - 1]);
							}
	|	ALIAS ENVIRONMENTSTART word_case ENVIRONMENTEND word_case
							{
								alias_function(textArray[getWords() - 2], textArray[getWords() - 1]);
							};
unalias_case:
		UNALIAS WORD       
							{
								unalias_function(yytext);
							}
	|	UNALIAS ENVIRONMENTSTART word_case ENVIRONMENTEND
							{
								unalias_function(textArray[getWords() - 1]);
							};
bye_case:
		BYE				   
							{
								printf("Bye command entered\n"); 
								exit(0); //exit shell
							};
quote_case:
		QUOTES				
							{
								printf("Quotes entered\n");
							};
word_case:
		WORD				
							{
								word_function(yytext);
							};
slash_case:
		SLASH				
							{
								printf("Slash entered\n");
							};
read_from_case:
		READFROM WORD			
							{
								read_from_function(yytext);
							};
write_to_case:
		WRITETO	WORD		{
								write_to_function(yytext);
							};
pipe_case:
		PIPE word_case			
							{
								pipe_function(textArray[getWords() - 1]);
							};
ampersand_case:
		AMPERSAND			
							{
								printf("Ampersand entered\n");
							};
matcher_case:
		MATCHER				
							{
								printf("Matcher entered\n");
							};
standard_error_redirect_case:
			word_case WRITETO AMPERSAND word_case
							{
								standard_error_redirect_function(textArray[getWords() - 2], textArray[getWords() - 1]);
							};
standard_error_redirect_case2:
		word_case WRITETO word_case
							{
								standard_error_redirect_function2(textArray[getWords() - 2], textArray[getWords() - 1]);
							};
error_case:
	error
							{
								printf("Syntax error.\n");
							};
regex_case:
	REGEX WORD				{
								int i;
								char** directories2 = malloc(300 * sizeof(char *));
								memcpy((char *)directories2, (char *)(getDirectories(yytext)), getNumberOfDirectories() * sizeof(char *));
								for(i = 0; i < getNumberOfDirectories(); i++)
								{
									printf("%s\n", directories2[i]);
								}
							};
