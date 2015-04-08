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
%token CD PRINTENV UNSETENV SETENV NEWLINE ALIAS UNALIAS BYE WORD QUOTES ENVIRONMENTVARIABLE READFROM WRITETO PIPE AMPERSAND APPEND STANDARDERROR1 STANDARDERROR2
%%
commands: 
		| commands command NEWLINE
		| commands command3
		| commands command4;
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
		|read_from_case
		|write_to_case
		|pipe_case
		|ampersand_case
		|append_case
		|standard_error_redirect_case
		|standard_error_redirect_case2
		|error_case        
		|words
		|pipes
		|pipe2_case
		|command2
		|read_from_case2
		|write_to_case2
		|append_case2;
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
								unsetenv_function(textArray[getWords() - 1], 1);
							};
setenv_case:             
		SETENV word_case word_case   
							{
								setenv_function(textArray[getWords() - 2], textArray [getWords() - 1], 1);		
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
								unalias_function(textArray[getWords() - 1], 1);                              
							}
bye_case:
		BYE				   
							{ 
								exit(0); //exit shell
							};
read_from_case2:
		READFROM
							{
								word_function("<");
							};
write_to_case2:
		WRITETO
							{
								word_function(">");
							};
read_from_case:
		read_from_case2 word_case			
							{
							};
write_to_case:
		write_to_case2	word_case	
							{
							};
pipe2_case:
		PIPE
							{
								word_function("|");
							};
pipe_case:
		pipe2_case words			
							{
								//printf("PIPE words\n");
								//pipe with a command name and more than one argument
							}
	|	pipe2_case word_case
							{
								//printf("PIPE word_case\n");
								//pipe with a command name and no arguments
							};
ampersand_case:
		AMPERSAND			
							{
								word_function("&");
							};
standard_error_redirect_case:
		STANDARDERROR1
							{
								word_function("2>&1");
							};
standard_error_redirect_case2:
		STANDARDERROR2		
							{
								word_function(yytext);
							};
error_case:
		error
							{
								printf ("Syntax error.\n");
							};
append_case2:
		APPEND				{
								word_function(">>");
							};
append_case:
		append_case2	word_case
							{
								
							};
words:
		word_case word_case
							{
								//printf("word_case word_case\n");
							}
	|	words	word_case
							{
								//printf("words word_case\n");
							};
pipes:
		pipe_case	pipe_case
							{
								//printf("pipe_case pipe_case\n");
							}
	|	pipes 		pipe_case
							{
								//printf("pipes pipe_case\n");
							};
command2:
		word_case words pipes read_from_case write_to_case standard_error_redirect_case ampersand_case
		{
			execute();
		}
	|	word_case words pipes read_from_case write_to_case standard_error_redirect_case
		{
			execute();
		}
	|	word_case words pipes read_from_case write_to_case ampersand_case
		{
			execute();
		}
	|	word_case words pipes read_from_case standard_error_redirect_case ampersand_case
		{
			execute();
		}
	|	word_case words pipes write_to_case standard_error_redirect_case ampersand_case
		{
			execute();
		}
	|	word_case words read_from_case write_to_case standard_error_redirect_case ampersand_case
		{
			execute();
		}
	|	word_case pipes read_from_case write_to_case standard_error_redirect_case ampersand_case
		{
			execute();
		}
	|	word_case words pipes read_from_case write_to_case
		{
			execute();
		}
	|	word_case words pipes read_from_case standard_error_redirect_case
		{
			execute();
		}
	|	word_case words pipes read_from_case ampersand_case
		{
			execute();
		}
	|	word_case words pipes write_to_case standard_error_redirect_case
		{
			execute();
		}
	|	word_case words pipes write_to_case ampersand_case
		{
			execute();
		}
	|	word_case words pipes standard_error_redirect_case ampersand_case
		{
			execute();
		}
	|	word_case words read_from_case write_to_case standard_error_redirect_case
		{
			execute();
		}
	|	word_case words read_from_case write_to_case ampersand_case
		{
			execute();
		}
	|	word_case words read_from_case standard_error_redirect_case ampersand_case
		{
			execute();
		}
	|	word_case words write_to_case standard_error_redirect_case ampersand_case
		{
			execute();
		}
	|	word_case pipes read_from_case write_to_case standard_error_redirect_case
		{
			execute();
		}
	|	word_case pipes read_from_case write_to_case ampersand_case
		{
			execute();
		}
	|	word_case pipes read_from_case standard_error_redirect_case ampersand_case
		{
			execute();
		}
	|	word_case pipes write_to_case standard_error_redirect_case ampersand_case
		{
			execute();
		}
	|	word_case read_from_case write_to_case standard_error_redirect_case ampersand_case
		{
			execute();
		}
	|	word_case words pipes read_from_case
		{
			execute();
		}
	|	word_case words pipes write_to_case
		{
			execute();
		}
	|	word_case words pipes standard_error_redirect_case
		{
			execute();
		}
	|	word_case words pipes ampersand_case
		{
			execute();
		}
	|	word_case words read_from_case write_to_case
		{
			execute();
		}
	|	word_case words read_from_case standard_error_redirect_case
		{
			execute();
		}
	|	word_case words read_from_case ampersand_case
		{
			execute();
		}
	|	word_case words write_to_case standard_error_redirect_case
		{
			execute();
		}
	|	word_case words write_to_case ampersand_case
		{
			execute();
		}
	|	word_case words standard_error_redirect_case ampersand_case
		{
			execute();
		}
	|	word_case pipes read_from_case write_to_case
		{
			execute();
		}
	|	word_case pipes read_from_case standard_error_redirect_case
		{
			execute();
		}
	|	word_case pipes read_from_case ampersand_case
		{
			execute();
		}
	|	word_case pipes write_to_case standard_error_redirect_case
		{
			execute();
		}
	|	word_case pipes write_to_case ampersand_case
		{
			execute();
		}
	|	word_case pipes standard_error_redirect_case ampersand_case
		{
			execute();
		}
	|	word_case read_from_case write_to_case standard_error_redirect_case
		{
			execute();
		}
	|	word_case read_from_case write_to_case ampersand_case
		{
			execute();
		}
	|	word_case read_from_case standard_error_redirect_case ampersand_case
		{
			execute();
		}
	|	word_case write_to_case standard_error_redirect_case ampersand_case
		{
			execute();
		}
	|	word_case words pipes
		{
			execute();
		}
	|	word_case words read_from_case
		{
			execute();
		}
	|	word_case words write_to_case
		{
			execute();
		}
	|	word_case words standard_error_redirect_case
		{
			execute();
		}
	|	word_case words ampersand_case
		{
			execute();
		}
	|	word_case pipes read_from_case
		{
			execute();
		}
	|	word_case pipes write_to_case
		{
			execute();
		}
	|	word_case pipes standard_error_redirect_case
		{
			execute();
		}
	|	word_case pipes ampersand_case
		{
			execute();
		}
	|	word_case read_from_case write_to_case
		{
			execute();
		}
	|	word_case read_from_case standard_error_redirect_case
		{
			execute();
		}
	|	word_case read_from_case ampersand_case
		{
			execute();
		}
	|	word_case write_to_case standard_error_redirect_case
		{
			execute();
		}
	|	word_case write_to_case ampersand_case
		{
			execute();
		}
	|	word_case standard_error_redirect_case ampersand_case
		{
			execute();
		}
	|	word_case words
		{
			execute();
		}
	|	word_case pipes
		{
			execute();
		}
	|	word_case read_from_case
		{
			execute();
		}
	|	word_case write_to_case
		{
			execute();
		}
	|	word_case standard_error_redirect_case
		{
			execute();
		}
	|	word_case ampersand_case
		{
			execute();
		}
	|	word_case words pipes read_from_case write_to_case standard_error_redirect_case2 ampersand_case
		{
			execute();
		}
	|	word_case words pipes read_from_case write_to_case standard_error_redirect_case2
		{
			execute();
		}
	|	word_case words pipes read_from_case standard_error_redirect_case2 ampersand_case
		{
			execute();
		}
	|	word_case words pipes write_to_case standard_error_redirect_case2 ampersand_case
		{
			execute();
		}
	|	word_case words read_from_case write_to_case standard_error_redirect_case2 ampersand_case
		{
			execute();
		}
	|	word_case pipes read_from_case write_to_case standard_error_redirect_case2 ampersand_case
		{
			execute();
		}
	|	word_case words pipes read_from_case standard_error_redirect_case2
		{
			execute();
		}
	|	word_case words pipes write_to_case standard_error_redirect_case2
		{
			execute();
		}
	|	word_case words pipes standard_error_redirect_case2 ampersand_case
		{
			execute();
		}
	|	word_case words read_from_case write_to_case standard_error_redirect_case2
		{
			execute();
		}
	|	word_case words read_from_case standard_error_redirect_case2 ampersand_case
		{
			execute();
		}
	|	word_case words write_to_case standard_error_redirect_case2 ampersand_case
		{
			execute();
		}
	|	word_case pipes read_from_case write_to_case standard_error_redirect_case2
		{
			execute();
		}
	|	word_case pipes read_from_case standard_error_redirect_case2 ampersand_case
		{
			execute();
		}
	|	word_case pipes write_to_case standard_error_redirect_case2 ampersand_case
		{
			execute();
		}
	|	word_case read_from_case write_to_case standard_error_redirect_case2 ampersand_case
		{
			execute();
		}
	|	word_case words pipes standard_error_redirect_case2
		{
			execute();
		}
	|	word_case words read_from_case standard_error_redirect_case2
		{
			execute();
		}
	|	word_case words write_to_case standard_error_redirect_case2
		{
			execute();
		}
	|	word_case words standard_error_redirect_case2 ampersand_case
		{
			execute();
		}
	|	word_case pipes read_from_case standard_error_redirect_case2
		{
			execute();
		}
	|	word_case pipes write_to_case standard_error_redirect_case2
		{
			execute();
		}
	|	word_case pipes standard_error_redirect_case2 ampersand_case
		{
			execute();
		}
	|	word_case read_from_case write_to_case standard_error_redirect_case2
		{
			execute();
		}
	|	word_case read_from_case standard_error_redirect_case2 ampersand_case
		{
			execute();
		}
	|	word_case write_to_case standard_error_redirect_case2 ampersand_case
		{
			execute();
		}
	|	word_case words standard_error_redirect_case2
		{
			execute();
		}
	|	word_case pipes standard_error_redirect_case2
		{
			execute();
		}
	|	word_case read_from_case standard_error_redirect_case2
		{
			execute();
		}
	|	word_case write_to_case standard_error_redirect_case2
		{
			execute();
		}
	|	word_case standard_error_redirect_case2 ampersand_case
		{
			execute();
		}
	|	word_case standard_error_redirect_case2
		{
			execute();
		}
	|	word_case words pipes read_from_case append_case standard_error_redirect_case ampersand_case
		{
			execute();
		}
	|	word_case words pipes read_from_case append_case standard_error_redirect_case
		{
			execute();
		}
	|	word_case words pipes read_from_case append_case ampersand_case
		{
			execute();
		}
	|	word_case words pipes append_case standard_error_redirect_case ampersand_case
		{
			execute();
		}
	|	word_case words read_from_case append_case standard_error_redirect_case ampersand_case
		{
			execute();
		}
	|	word_case pipes read_from_case append_case standard_error_redirect_case ampersand_case
		{
			execute();
		}
	|	word_case words pipes read_from_case append_case
		{
			execute();
		}
	|	word_case words pipes append_case standard_error_redirect_case
		{
			execute();
		}
	|	word_case words pipes append_case ampersand_case
		{
			execute();
		}
	|	word_case words read_from_case append_case standard_error_redirect_case
		{
			execute();
		}
	|	word_case words read_from_case append_case ampersand_case
		{
			execute();
		}
	|	word_case words append_case standard_error_redirect_case ampersand_case
		{
			execute();
		}
	|	word_case pipes read_from_case append_case standard_error_redirect_case
		{
			execute();
		}
	|	word_case pipes read_from_case append_case ampersand_case
		{
			execute();
		}
	|	word_case pipes append_case standard_error_redirect_case ampersand_case
		{
			execute();
		}
	|	word_case read_from_case append_case standard_error_redirect_case ampersand_case
		{
			execute();
		}
	|	word_case words pipes append_case
		{
			execute();
		}
	|	word_case words read_from_case append_case
		{
			execute();
		}
	|	word_case words append_case standard_error_redirect_case
		{
			execute();
		}
	|	word_case words append_case ampersand_case
		{
			execute();
		}
	|	word_case pipes read_from_case append_case
		{
			execute();
		}
	|	word_case pipes append_case standard_error_redirect_case
		{
			execute();
		}
	|	word_case pipes append_case ampersand_case
		{
			execute();
		}
	|	word_case read_from_case append_case standard_error_redirect_case
		{
			execute();
		}
	|	word_case read_from_case append_case ampersand_case
		{
			execute();
		}
	|	word_case append_case standard_error_redirect_case ampersand_case
		{
			execute();
		}
	|	word_case words append_case
		{
			execute();
		}
	|	word_case pipes append_case
		{
			execute();
		}
	|	word_case read_from_case append_case
		{
			execute();
		}
	|	word_case append_case standard_error_redirect_case
		{
			execute();
		}
	|	word_case append_case ampersand_case
		{
			execute();
		}
	|	word_case append_case
		{
			execute();
		}
	|	word_case words pipes read_from_case append_case standard_error_redirect_case2 ampersand_case
		{
			execute();
		}
	|	word_case words pipes read_from_case append_case standard_error_redirect_case2
		{
			execute();
		}
	|	word_case words pipes append_case standard_error_redirect_case2 ampersand_case
		{
			execute();
		}
	|	word_case words read_from_case append_case standard_error_redirect_case2 ampersand_case
		{
			execute();
		}
	|	word_case pipes read_from_case append_case standard_error_redirect_case2 ampersand_case
		{
			execute();
		}
	|	word_case words pipes append_case standard_error_redirect_case2
		{
			execute();
		}
	|	word_case words read_from_case append_case standard_error_redirect_case2
		{
			execute();
		}
	|	word_case words append_case standard_error_redirect_case2 ampersand_case
		{
			execute();
		}
	|	word_case pipes read_from_case append_case standard_error_redirect_case2
		{
			execute();
		}
	|	word_case pipes append_case standard_error_redirect_case2 ampersand_case
		{
			execute();
		}
	|	word_case read_from_case append_case standard_error_redirect_case2 ampersand_case
		{
			execute();
		}
	|	word_case words append_case standard_error_redirect_case2
		{
			execute();
		}
	|	word_case pipes append_case standard_error_redirect_case2
		{
			execute();
		}
	|	word_case read_from_case append_case standard_error_redirect_case2
		{
			execute();
		}
	|	word_case append_case standard_error_redirect_case2 ampersand_case
		{
			execute();
		}
	|	word_case append_case standard_error_redirect_case2
		{
			execute();
		}
	|	word_case word_case pipes read_from_case write_to_case standard_error_redirect_case ampersand_case
		{
			execute();
		}
	|	word_case word_case pipes read_from_case write_to_case standard_error_redirect_case
		{
			execute();
		}
	|	word_case word_case pipes read_from_case write_to_case ampersand_case
		{
			execute();
		}
	|	word_case word_case pipes read_from_case standard_error_redirect_case ampersand_case
		{
			execute();
		}
	|	word_case word_case pipes write_to_case standard_error_redirect_case ampersand_case
		{
			execute();
		}
	|	word_case word_case read_from_case write_to_case standard_error_redirect_case ampersand_case
		{
			execute();
		}
	|	word_case word_case pipes read_from_case write_to_case
		{
			execute();
		}
	|	word_case word_case pipes read_from_case standard_error_redirect_case
		{
			execute();
		}
	|	word_case word_case pipes read_from_case ampersand_case
		{
			execute();
		}
	|	word_case word_case pipes write_to_case standard_error_redirect_case
		{
			execute();
		}
	|	word_case word_case pipes write_to_case ampersand_case
		{
			execute();
		}
	|	word_case word_case pipes standard_error_redirect_case ampersand_case
		{
			execute();
		}
	|	word_case word_case read_from_case write_to_case standard_error_redirect_case
		{
			execute();
		}
	|	word_case word_case read_from_case write_to_case ampersand_case
		{
			execute();
		}
	|	word_case word_case read_from_case standard_error_redirect_case ampersand_case
		{
			execute();
		}
	|	word_case word_case write_to_case standard_error_redirect_case ampersand_case
		{
			execute();
		}
	|	word_case word_case pipes read_from_case
		{
			execute();
		}
	|	word_case word_case pipes write_to_case
		{
			execute();
		}
	|	word_case word_case pipes standard_error_redirect_case
		{
			execute();
		}
	|	word_case word_case pipes ampersand_case
		{
			execute();
		}
	|	word_case word_case read_from_case write_to_case
		{
			execute();
		}
	|	word_case word_case read_from_case standard_error_redirect_case
		{
			execute();
		}
	|	word_case word_case read_from_case ampersand_case
		{
			execute();
		}
	|	word_case word_case write_to_case standard_error_redirect_case
		{
			execute();
		}
	|	word_case word_case write_to_case ampersand_case
		{
			execute();
		}
	|	word_case word_case standard_error_redirect_case ampersand_case
		{
			execute();
		}
	|	word_case word_case pipes
		{
			execute();
		}
	|	word_case word_case read_from_case
		{
			execute();
		}
	|	word_case word_case write_to_case
		{
			execute();
		}
	|	word_case word_case standard_error_redirect_case
		{
			execute();
		}
	|	word_case word_case ampersand_case
		{
			execute();
		} 
	|	word_case word_case pipes read_from_case write_to_case standard_error_redirect_case2 ampersand_case
		{
			execute();
		}
	|	word_case word_case pipes read_from_case write_to_case standard_error_redirect_case2
		{
			execute();
		}
	|	word_case word_case pipes read_from_case standard_error_redirect_case2 ampersand_case
		{
			execute();
		}
	|	word_case word_case pipes write_to_case standard_error_redirect_case2 ampersand_case
		{
			execute();
		}
	|	word_case word_case read_from_case write_to_case standard_error_redirect_case2 ampersand_case
		{
			execute();
		}
	|	word_case word_case pipes read_from_case standard_error_redirect_case2
		{
			execute();
		}
	|	word_case word_case pipes write_to_case standard_error_redirect_case2
		{
			execute();
		}
	|	word_case word_case pipes standard_error_redirect_case2 ampersand_case
		{
			execute();
		}
	|	word_case word_case read_from_case write_to_case standard_error_redirect_case2
		{
			execute();
		}
	|	word_case word_case read_from_case standard_error_redirect_case2 ampersand_case
		{
			execute();
		}
	|	word_case word_case write_to_case standard_error_redirect_case2 ampersand_case
		{
			execute();
		}
	|	word_case word_case pipes standard_error_redirect_case2
		{
			execute();
		}
	|	word_case word_case read_from_case standard_error_redirect_case2
		{
			execute();
		}
	|	word_case word_case write_to_case standard_error_redirect_case2
		{
			execute();
		}
	|	word_case word_case standard_error_redirect_case2 ampersand_case
		{
			execute();
		}
	|	word_case word_case standard_error_redirect_case2
		{
			execute();
		}
	|	word_case word_case pipes read_from_case append_case standard_error_redirect_case ampersand_case
		{
			execute();
		}
	|	word_case word_case pipes read_from_case append_case standard_error_redirect_case
		{
			execute();
		}
	|	word_case word_case pipes read_from_case append_case ampersand_case
		{
			execute();
		}
	|	word_case word_case pipes append_case standard_error_redirect_case ampersand_case
		{
			execute();
		}
	|	word_case word_case read_from_case append_case standard_error_redirect_case ampersand_case
		{
			execute();
		}
	|	word_case word_case pipes read_from_case append_case
		{
			execute();
		}
	|	word_case word_case pipes append_case standard_error_redirect_case
		{
			execute();
		}
	|	word_case word_case pipes append_case ampersand_case
		{
			execute();
		}
	|	word_case word_case read_from_case append_case standard_error_redirect_case
		{
			execute();
		}
	|	word_case word_case read_from_case append_case ampersand_case
		{
			execute();
		}
	|	word_case word_case append_case standard_error_redirect_case ampersand_case
		{
			execute();
		}
	|	word_case word_case pipes append_case
		{
			execute();
		}
	|	word_case word_case read_from_case append_case
		{
			execute();
		}
	|	word_case word_case append_case standard_error_redirect_case
		{
			execute();
		}
	|	word_case word_case append_case ampersand_case
		{
			execute();
		}
	|	word_case word_case append_case
		{
			execute();
		}
	|	word_case word_case pipes read_from_case append_case standard_error_redirect_case2 ampersand_case
		{
			execute();
		}
	|	word_case word_case pipes read_from_case append_case standard_error_redirect_case2
		{
			execute();
		}
	|	word_case word_case pipes append_case standard_error_redirect_case2 ampersand_case
		{
			execute();
		}
	|	word_case word_case read_from_case append_case standard_error_redirect_case2 ampersand_case
		{
			execute();
		}
	|	word_case word_case pipes append_case standard_error_redirect_case2
		{
			execute();
		}
	|	word_case word_case read_from_case append_case standard_error_redirect_case2
		{
			execute();
		}
	|	word_case word_case append_case standard_error_redirect_case2 ampersand_case
		{
			execute();
		}
	|	word_case word_case append_case standard_error_redirect_case2
		{
			execute();
		}
	|	word_case words pipe_case read_from_case write_to_case standard_error_redirect_case ampersand_case
		{
			execute();
		}
	|	word_case words pipe_case read_from_case write_to_case standard_error_redirect_case
		{
			execute();
		}
	|	word_case words pipe_case read_from_case write_to_case ampersand_case
		{
			execute();
		}
	|	word_case words pipe_case read_from_case standard_error_redirect_case ampersand_case
		{
			execute();
		}
	|	word_case words pipe_case write_to_case standard_error_redirect_case ampersand_case
		{
			execute();
		}
	|	word_case pipe_case read_from_case write_to_case standard_error_redirect_case ampersand_case
		{
			execute();
		}
	|	word_case words pipe_case read_from_case write_to_case
		{
			execute();
		}
	|	word_case words pipe_case read_from_case standard_error_redirect_case
		{
			execute();
		}
	|	word_case words pipe_case read_from_case ampersand_case
		{
			execute();
		}
	|	word_case words pipe_case write_to_case standard_error_redirect_case
		{
			execute();
		}
	|	word_case words pipe_case write_to_case ampersand_case
		{
			execute();
		}
	|	word_case words pipe_case standard_error_redirect_case ampersand_case
		{
			execute();
		}
	|	word_case pipe_case read_from_case write_to_case standard_error_redirect_case
		{
			execute();
		}
	|	word_case pipe_case read_from_case write_to_case ampersand_case
		{
			execute();
		}
	|	word_case pipe_case read_from_case standard_error_redirect_case ampersand_case
		{
			execute();
		}
	|	word_case pipe_case write_to_case standard_error_redirect_case ampersand_case
		{
			execute();
		}
	|	word_case words pipe_case read_from_case
		{
			execute();
		}
	|	word_case words pipe_case write_to_case
		{
			execute();
		}
	|	word_case words pipe_case standard_error_redirect_case
		{
			execute();
		}
	|	word_case words pipe_case ampersand_case
		{
			execute();
		}
	|	word_case pipe_case read_from_case write_to_case
		{
			execute();
		}
	|	word_case pipe_case read_from_case standard_error_redirect_case
		{
			execute();
		}
	|	word_case pipe_case read_from_case ampersand_case
		{
			execute();
		}
	|	word_case pipe_case write_to_case standard_error_redirect_case
		{
			execute();
		}
	|	word_case pipe_case write_to_case ampersand_case
		{
			execute();
		}
	|	word_case pipe_case standard_error_redirect_case ampersand_case
		{
			execute();
		}
	|	word_case words pipe_case
		{
			execute();
		}
	|	word_case pipe_case read_from_case
		{
			execute();
		}
	|	word_case pipe_case write_to_case
		{
			execute();
		}
	|	word_case pipe_case standard_error_redirect_case
		{
			execute();
		}
	|	word_case pipe_case ampersand_case
		{
			execute();
		}
	|	word_case pipe_case
		{
			execute();
		}
	|	word_case words pipe_case read_from_case write_to_case standard_error_redirect_case2 ampersand_case
		{
			execute();
		}
	|	word_case words pipe_case read_from_case write_to_case standard_error_redirect_case2
		{
			execute();
		}
	|	word_case words pipe_case read_from_case standard_error_redirect_case2 ampersand_case
		{
			execute();
		}
	|	word_case words pipe_case write_to_case standard_error_redirect_case2 ampersand_case
		{
			execute();
		}
	|	word_case pipe_case read_from_case write_to_case standard_error_redirect_case2 ampersand_case
		{
			execute();
		}
	|	word_case words pipe_case read_from_case standard_error_redirect_case2
		{
			execute();
		}
	|	word_case words pipe_case write_to_case standard_error_redirect_case2
		{
			execute();
		}
	|	word_case words pipe_case standard_error_redirect_case2 ampersand_case
		{
			execute();
		}
	|	word_case pipe_case read_from_case write_to_case standard_error_redirect_case2
		{
			execute();
		}
	|	word_case pipe_case read_from_case standard_error_redirect_case2 ampersand_case
		{
			execute();
		}
	|	word_case pipe_case write_to_case standard_error_redirect_case2 ampersand_case
		{
			execute();
		}
	|	word_case words pipe_case standard_error_redirect_case2
		{
			execute();
		}
	|	word_case pipe_case read_from_case standard_error_redirect_case2
		{
			execute();
		}
	|	word_case pipe_case write_to_case standard_error_redirect_case2
		{
			execute();
		}
	|	word_case pipe_case standard_error_redirect_case2 ampersand_case
		{
			execute();
		}
	|	word_case pipe_case standard_error_redirect_case2
		{
			execute();
		}
	|	word_case words pipe_case read_from_case append_case standard_error_redirect_case ampersand_case
		{
			execute();
		}
	|	word_case words pipe_case read_from_case append_case standard_error_redirect_case
		{
			execute();
		}
	|	word_case words pipe_case read_from_case append_case ampersand_case
		{
			execute();
		}
	|	word_case words pipe_case append_case standard_error_redirect_case ampersand_case
		{
			execute();
		}
	|	word_case pipe_case read_from_case append_case standard_error_redirect_case ampersand_case
		{
			execute();
		}
	|	word_case words pipe_case read_from_case append_case
		{
			execute();
		}
	|	word_case words pipe_case append_case standard_error_redirect_case
		{
			execute();
		}
	|	word_case words pipe_case append_case ampersand_case
		{
			execute();
		}
	|	word_case pipe_case read_from_case append_case standard_error_redirect_case
		{
			execute();
		}
	|	word_case pipe_case read_from_case append_case ampersand_case
		{
			execute();
		}
	|	word_case pipe_case append_case standard_error_redirect_case ampersand_case
		{
			execute();
		}
	|	word_case words pipe_case append_case
		{
			execute();
		}
	|	word_case pipe_case read_from_case append_case
		{
			execute();
		}
	|	word_case pipe_case append_case standard_error_redirect_case
		{
			execute();
		}
	|	word_case pipe_case append_case ampersand_case
		{
			execute();
		}
	|	word_case pipe_case append_case
		{
			execute();
		}
	|	word_case words pipe_case read_from_case append_case standard_error_redirect_case2 ampersand_case
		{
			execute();
		}
	|	word_case words pipe_case read_from_case append_case standard_error_redirect_case2
		{
			execute();
		}
	|	word_case words pipe_case append_case standard_error_redirect_case2 ampersand_case
		{
			execute();
		}
	|	word_case pipe_case read_from_case append_case standard_error_redirect_case2 ampersand_case
		{
			execute();
		}
	|	word_case words pipe_case append_case standard_error_redirect_case2
		{
			execute();
		}
	|	word_case pipe_case read_from_case append_case standard_error_redirect_case2
		{
			execute();
		}
	|	word_case pipe_case append_case standard_error_redirect_case2 ampersand_case
		{
			execute();
		}
	|	word_case pipe_case append_case standard_error_redirect_case2
		{
			execute();
		}
	|	word_case word_case pipe_case read_from_case write_to_case standard_error_redirect_case ampersand_case
		{
			execute();
		}
	|	word_case word_case pipe_case read_from_case write_to_case standard_error_redirect_case
		{
			execute();
		}
	|	word_case word_case pipe_case read_from_case write_to_case ampersand_case
		{
			execute();
		}
	|	word_case word_case pipe_case read_from_case standard_error_redirect_case ampersand_case
		{
			execute();
		}
	|	word_case word_case pipe_case write_to_case standard_error_redirect_case ampersand_case
		{
			execute();
		}
	|	word_case word_case pipe_case read_from_case write_to_case
		{
			execute();
		}
	|	word_case word_case pipe_case read_from_case standard_error_redirect_case
		{
			execute();
		}
	|	word_case word_case pipe_case read_from_case ampersand_case
		{
			execute();
		}
	|	word_case word_case pipe_case write_to_case standard_error_redirect_case
		{
			execute();
		}
	|	word_case word_case pipe_case write_to_case ampersand_case
		{
			execute();
		}
	|	word_case word_case pipe_case standard_error_redirect_case ampersand_case
		{
			execute();
		}
	|	word_case word_case pipe_case read_from_case
		{
			execute();
		}
	|	word_case word_case pipe_case write_to_case
		{
			execute();
		}
	|	word_case word_case pipe_case standard_error_redirect_case
		{
			execute();
		}
	|	word_case word_case pipe_case ampersand_case
		{
			execute();
		}
	|	word_case word_case pipe_case
		{
			execute();
		}
	|	word_case word_case pipe_case read_from_case write_to_case standard_error_redirect_case2 ampersand_case
		{
			execute();
		}
	|	word_case word_case pipe_case read_from_case write_to_case standard_error_redirect_case2
		{
			execute();
		}
	|	word_case word_case pipe_case read_from_case standard_error_redirect_case2 ampersand_case
		{
			execute();
		}
	|	word_case word_case pipe_case write_to_case standard_error_redirect_case2 ampersand_case
		{
			execute();
		}
	|	word_case word_case pipe_case read_from_case standard_error_redirect_case2
		{
			execute();
		}
	|	word_case word_case pipe_case write_to_case standard_error_redirect_case2
		{
			execute();
		}
	|	word_case word_case pipe_case standard_error_redirect_case2 ampersand_case
		{
			execute();
		}
	|	word_case word_case pipe_case standard_error_redirect_case2
		{
			execute();
		}
	|	word_case word_case pipe_case read_from_case append_case standard_error_redirect_case ampersand_case
		{
			execute();
		}
	|	word_case word_case pipe_case read_from_case append_case standard_error_redirect_case
		{
			execute();
		}
	|	word_case word_case pipe_case read_from_case append_case ampersand_case
		{
			execute();
		}
	|	word_case word_case pipe_case append_case standard_error_redirect_case ampersand_case
		{
			execute();
		}
	|	word_case word_case pipe_case read_from_case append_case
		{
			execute();
		}
	|	word_case word_case pipe_case append_case standard_error_redirect_case
		{
			execute();
		}
	|	word_case word_case pipe_case append_case ampersand_case
		{
			execute();
		}
	|	word_case word_case pipe_case append_case
		{
			execute();
		}
	|	word_case word_case pipe_case read_from_case append_case standard_error_redirect_case2 ampersand_case
		{
			execute();
		}
	|	word_case word_case pipe_case read_from_case append_case standard_error_redirect_case2
		{
			execute();
		}
	|	word_case word_case pipe_case append_case standard_error_redirect_case2 ampersand_case
		{
			execute();
		}
	|	word_case word_case pipe_case append_case standard_error_redirect_case2
		{
			execute();
		};
command3:
	word_case	word_case	NEWLINE
		{
			execute();
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
command4:
	word_case	NEWLINE
		{
			execute();
		};
%%
