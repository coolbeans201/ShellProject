%{#include <stdio.h>
  #include <string.h>
  #include <errno.h>
  #include <unistd.h>
  #include <stdlib.h>
  void yyerror(const char *str){fprintf(stderr,"error: %s\n", str);}
  int yywrap(){return 1;}
  extern char** environ; //environment variables
  extern char* yytext; //text from user
  char** aliases; //alias names and values
  main(){execl("/bin/ls","ls", "ls", "-l", "/usr", (char *) 0);
		 yyparse();}
%}
%token CD PRINTENV UNSETENV SETENV NEWLINE ALIAS UNALIAS BYE WORD MATCHER QUOTES ENVIRONMENTSTART ENVIRONMENTEND SLASH READFROM WRITETO PIPE AMPERSAND
%%
commands: 
		| commands command NEWLINE;
command:
		cd2_case|cd_case|printenv_case|unsetenv_case|setenv_case|alias2_case|alias_case|unalias_case|bye_case|quote_case|environment_variable|word_case|slash_case|read_from_case|write_to_case|pipe_case|ampersand_case|matcher_case;
cd2_case:
		CD {
				printf("Second CD command entered\n");
				chdir(getenv("HOME")); //get home directory and move to it
			};
cd_case:
	    CD WORD {
				printf("CD command entered\n");
				char* current = getenv("PWD"); //get current directory
				current = strcat(current, "/"); //add slash
				current = strcat(current, yytext); //add user text
				chdir(current); //move directory
		};
printenv_case:
	    PRINTENV {printf("Printenv command entered\n");
				char ** ep;
				for(ep = environ; *ep!= NULL; ep++)
				{
					printf("%s\n", *ep); //print everything line by line
				}
				};
unsetenv_case:
		UNSETENV WORD {
						printf("Unsetenv command entered\n");
						char **envVariableNames, **rightEnvVariableNames;
						size_t length;
						if (yytext == NULL || yytext == '\0' || strchr(yytext, '=') != NULL) {
							perror("Entered an invalid name!\n");
						}

						length = strlen(yytext);
						for (envVariableNames = environ; *envVariableNames != NULL; )
						{
							if (strncmp(*envVariableNames, yytext, length) == 0 && (*envVariableNames)[length] == '=') { //found a match
								for (rightEnvVariableNames = envVariableNames; *rightEnvVariableNames != NULL; rightEnvVariableNames++)
								{
										*rightEnvVariableNames = *(rightEnvVariableNames + 1); //shift over
								}
								/* Continue around the loop to further instances of 'name' */
							} 
							else {
								envVariableNames++;
							}
						}
					};
setenv_case:
		SETENV WORD WORD   {printf("Setenv command entered\n");};
alias2_case:
		ALIAS	{
					printf("Second alias command entered\n");
					char ** a;
					for(a = aliases; *a!= NULL; a++)
					{
						printf("%s\n", *a); //print each alias line by line
					}
				};
alias_case:
		ALIAS  WORD  WORD    {printf("Alias command entered\n");};
unalias_case:
		UNALIAS WORD       {
								printf("Unalias command entered\n");
								char **aliasNames, **rightAliasNames;
								size_t length;
								if (yytext == NULL || yytext == '\0' || strchr(yytext, '=') != NULL) {
									perror("Entered an invalid alias!\n");
								}
								length = strlen(yytext);
								for (aliasNames = aliases; *aliasNames != NULL; )
								{
									if (strncmp(*aliasNames, yytext, length) == 0 && (*aliasNames)[length] == '=') { //found match
									for (rightAliasNames = aliasNames; *rightAliasNames != NULL; rightAliasNames++)
									{
											*rightAliasNames = *(rightAliasNames + 1); //shift over
									}
									/* Continue around the loop to further instances of 'name' */
								} 
								else {
									aliasNames++;
								}
							}
							};
bye_case:
		BYE				   {printf("Bye command entered\n"); return 0;};
quote_case:
		QUOTES				{printf("Quotes entered\n");};
environment_variable:
		ENVIRONMENTSTART WORD ENVIRONMENTEND {printf("Environment variable entered\n");};
word_case:
		WORD				{printf("Word entered\n");};
slash_case:
		SLASH				{printf("Slash entered\n");};
read_from_case:
		READFROM			{printf("Read from entered\n");};
write_to_case:
		WRITETO				{printf("Write to entered\n");};
pipe_case:
		PIPE				{printf("Pipe entered\n");};
ampersand_case:
		AMPERSAND			{printf("Ampersand entered\n");};
matcher_case:
		MATCHER				{printf("Matcher entered\n");};
