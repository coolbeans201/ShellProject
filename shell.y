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
	shell_init();
	yyparse();
  }
%}
%token CD PRINTENV UNSETENV SETENV NEWLINE ALIAS UNALIAS BYE WORD MATCHER QUOTES ENVIRONMENTVARIABLE SLASH READFROM WRITETO PIPE AMPERSAND APPEND STANDARDERROR1 STANDARDERROR2	COMMANDNAME
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
		|word_case
		|slash_case
		|io_redirect_case
		|pipe_case
		|ampersand_case
		|standard_error_redirect_case
		|error_case
		|words
		|pipes;
cd2_case:
		CD 
							{
								cd_function();
							};
cd_case:
	    CD word_case 
							{
								cd_function2(textArray[getWords() - 1]);
							}
printenv_case:
	    PRINTENV 
							{
								printenv_function();
							};
unsetenv_case:
		UNSETENV word_case 
							{
								unsetenv_function(textArray[getWords() - 1]);
							};
setenv_case:
		SETENV word_case word_case   
							{
								setenv_function(textArray[getWords() - 2], textArray [getWords() - 1]);		
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
							};
unalias_case:
		UNALIAS word_case       
							{
								unalias_function(textArray[getWords() - 1]);
							}
bye_case:
		BYE				   
							{
								printf ("Bye command entered\n"); 
								exit(0); //exit shell
							};
word_case:
		WORD				
							{
								word2Function(yytext);
							}
	|	ENVIRONMENTVARIABLE
							{
								char* actualText = malloc(300 * sizeof(char));
								if(actualText == (char*) NULL) //error
								{
										perror ("Error with memory allocation.");
										printf ("Error at line %d\n", __LINE__);
								}
								else
								{
									strncpy(actualText, &yytext[2], strlen(yytext) - 3); //take everything between ${ and }
									char* result = malloc(300 * sizeof(char));
									if(result == (char*) NULL) //error
									{
										perror ("Error with memory allocation.");
										printf ("Error at line %d\n", __LINE__);
									}
									else
									{
										if(getenv(actualText) == NULL) //invalid environment variable
										{
											perror ("Entered an invalid environment variable.");
											printf ("Error at line %d\n", __LINE__);
										}
										else
										{
											strcpy(result, getenv(actualText)); //get value, if any
											word_function(result);
										}
									}
								}		
							}
	|	QUOTES				{
								quoteFunction(yytext);
							};
slash_case:
		SLASH				
							{
								printf ("Slash entered\n");
							};
io_redirect_case:
		READFROM word_case	
							{
								printf("Reading\n");
							}
	|	WRITETO	word_case	
							{
								printf("Writing\n");
							}
	|	APPEND	word_case
							{
								printf("Appending\n");
							}
	|	READFROM	word_case	WRITETO	word_case
							{
								printf("Reading and writing\n");
							}
	|	READFROM	word_case	APPEND	word_case
							{
							printf("Reading and appending\n");
							};
pipe_case:
		PIPE word_case words			
							{
								//pipe with a command name and more than one argument
							}
	|	PIPE word_case		{
								//pipe with a command name and no arguments
							}
	|	PIPE word_case word_case
							{
								//pipe with a command name and only one argument
							};
ampersand_case:
		AMPERSAND			
							{
								printf ("Ampersand entered\n");
							};
standard_error_redirect_case:
		STANDARDERROR1
							{
								standard_error_redirect_function();
							}
	|	STANDARDERROR2
							{
								standard_error_redirect_function2(yytext);
							};
error_case:
		error
							{
								printf ("Syntax error.\n");
							};
words:
		word_case word_case
							{
								printf("Dank\n");
							}
	|	words	word_case
							{
								printf("Meme\n");
							};
pipes:
		pipe_case	pipe_case
	|	pipes 		pipe_case
							{
								printf("Pipes for days\n");
							};
command:
		
%%
