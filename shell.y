%{#include <stdio.h>
  #include <string.h>
  #include <errno.h>
  #include <unistd.h>
  #include <stdlib.h>
  #include <fcntl.h>
  #include <sys/ioctl.h>
  #include <sys/types.h>
  #include <sys/stat.h>
  #include <sys/wait.h>
  #include <pwd.h>
  #include <fnmatch.h>
  void yyerror(const char *str){fprintf(stderr,"error: %s\n", str);}
  int yywrap(){
				return 1;
			  }
  void unsetenv_function(char *text);
  void unalias_function (char *text);
  char** textArray; //words
  char** newTextArray; //copied words
  int words = 0; //number of words
  extern char** environ; //environment variables
  extern char* yytext; //text from user
  char** aliases; //alias names and values
  char** newAliases; //copied aliases
  int aliasCount = 0; //number of aliases
  struct passwd* pwd; //contains result of getpwnam
  main(){
		 yyparse();}
%}
%token CD PRINTENV UNSETENV SETENV NEWLINE ALIAS UNALIAS BYE WORD MATCHER QUOTES ENVIRONMENTSTART ENVIRONMENTEND SLASH READFROM WRITETO PIPE AMPERSAND
%%
commands: 
		| commands command NEWLINE;
command:
		cd2_case|cd_case|printenv_case|unsetenv_case|setenv_case|alias2_case|alias_case|unalias_case|bye_case|quote_case|word_case|slash_case|read_from_case|write_to_case|pipe_case|ampersand_case|matcher_case|setenv_environment_case|unsetenv_environment_case;
cd2_case:
		CD {
				printf("Second CD command entered\n");
				int result = chdir(getenv("HOME")); //get home directory and move to it
				int fd = open("datafile.dat", O_RDWR | O_CREAT | O_EXCL, S_IREAD | S_IWRITE); //create a file so that we can see that this actually works with ls
				if(fd == -1) //error
				{
					perror("File not opened.\n");
				}
				if(result == -1) //error
				{
					perror("Directory not changed.\n");
				}
			};
cd_case:
	    CD WORD {
				printf("CD command entered\n");
				if(strncmp(yytext, "~", 1) == 0) //tilde expansion
				{
					int length = strlen(&yytext[1]); 
					if(length == 0) //empty afterwards
					{
						int result = chdir(getenv("HOME")); //get home directory and move to it
						int fd = open("datafile2.dat", O_RDWR | O_CREAT | O_EXCL, S_IREAD | S_IWRITE); //create a file so that we can see that this actually works with ls
						if(fd == -1) //error
						{
							//perror("File not opened.\n");
						}
						if(result == -1) //error
						{
							perror("Directory not changed.\n");
						}
					}
					else //actual expansion
					{
					   pwd = getpwnam(&yytext[1]);
					   if (pwd == NULL) 
					   {
							perror("Error with getting struct.\n");
					   }
					   int result = chdir(pwd->pw_dir); //get home directory and move to it
					   int fd = open("datafile4.dat", O_RDWR | O_CREAT | O_EXCL, S_IREAD | S_IWRITE); //create a file so that we can see that this actually works with ls
					   if(fd == -1) //error
					   {
							perror("File not opened.\n");
					   }
					   if(result == -1) //error
					   {
							perror("Directory not changed.\n");
					   }
					}
				}
				else
				{
					int result = chdir(yytext); //move directory
					if (result == -1) //error
					{
						perror("Directory not changed.\n");
					}
					int fd = open("datafile.dat", O_RDWR | O_CREAT | O_EXCL, S_IREAD | S_IWRITE); //create a file so that we can see that this actually works with ls
					if(fd == -1) //error
					{
						perror("File not opened.\n");
					}
				}
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
						unsetenv_function(yytext);
					};
setenv_case:
		SETENV word_case word_case   {
										printf("Setenv command entered\n");
										char *es;
										if (textArray[words - 2] == NULL || textArray[words - 2][0] == '\0' || strchr(textArray[words - 2], '=') != NULL || textArray[words - 1] == NULL) //check to see if valid
										{
											perror("Invalid argument.\n");
										}
										unsetenv_function(textArray[words - 2]);             /* Remove all occurrences */
										es = malloc(strlen(textArray[words - 2]) + strlen(textArray[words - 1]) + 2);
																	/* +2 for '=' and null terminator */
										if (es == NULL) //error
										{
											perror("Error with memory allocation.\n");
										}
										strcpy(es, textArray[words - 2]); //copy variable
										strcat(es, "="); //copy =
										strcat(es, textArray[words - 1]); //copy value
										int result = putenv(es); //put into array
										if(result == -1) //error
										{
											perror("Error inserting element into environment variable array.\n");
										}
									 };
alias2_case:
		ALIAS	{
					printf("Second alias command entered\n");
					int i;
					for(i = 0; i < aliasCount; i++)
					{
						printf("%s\n", aliases[i]); //print each alias line by line
					}
				};
alias_case:
		ALIAS  word_case  word_case    
							 {
								printf("Alias command entered\n");
								char *es;
								if (textArray[words - 2] == NULL || textArray[words - 2][0] == '\0' || strchr(textArray[words - 2], '=') != NULL || textArray[words - 1] == NULL) //check to see if valid
								{
									perror("Invalid argument.\n");
								}
								unalias_function(textArray[words - 2]);             /* Remove all occurrences */
								es = malloc(strlen(textArray[words - 2]) + strlen(textArray[words - 1]) + 2);
								if (es == NULL) //error
								{
									perror("Error with memory allocation.\n");
								}
								strcpy(es, textArray[words - 2]); //copy variable
								strcat(es, "="); //copy =
								strcat(es, textArray[words - 1]); //copy value
								newAliases = (char **) malloc((aliasCount+2)*sizeof(char *)); //null entry and new word
								if ( newAliases == (char **) NULL ) //no array created
								{
									perror("Array not created.\n");
								}
								memcpy ((char *) newAliases, (char *) aliases, aliasCount*sizeof(char *)); //copy all entries from textArray into newTextArray
								newAliases[aliasCount] = es; //word
								newAliases[aliasCount + 1] = NULL; //null entry
								aliases = newAliases;
								aliasCount++; //increment index
							 };
unalias_case:
		UNALIAS WORD       {
								unalias_function(yytext);
							};
bye_case:
		BYE				   {printf("Bye command entered\n"); exit(0);};
quote_case:
		QUOTES				{printf("Quotes entered\n");};
word_case:
		WORD				{
								char * es;
								es = malloc(strlen(yytext) + 1); //allocate space for word and terminating character
								strcpy(es, yytext); //copy text into pointer
								newTextArray = (char **) malloc((words+2)*sizeof(char *)); //null entry and new word
								if ( newTextArray == (char **) NULL ) //no array created
								{
									perror("Array not created.\n");
								}
								memcpy ((char *) newTextArray, (char *) textArray, words*sizeof(char *)); //copy all entries from textArray into newTextArray
								newTextArray[words]   = es; //word
								newTextArray[words+1] = NULL; //null entry
								textArray = newTextArray;
								words++; //increment index
							};
slash_case:
		SLASH				{printf("Slash entered\n");};
read_from_case:
		READFROM WORD			{
								printf("Read from entered\n");
								int in = open(yytext, O_RDONLY);
								if(in == -1) //error
								{
									perror("File not opened.\n");
								}
								int result = dup2(in, 0); //connect
								if (result == -1) //error
								{
									perror("Input not redirected.\n");
								}
							};
write_to_case:
		WRITETO	WORD		{
								printf("Write to entered\n");
								int out = open(yytext, O_WRONLY | O_TRUNC | O_CREAT, S_IRUSR | S_IRGRP | S_IWGRP | S_IWUSR);
								if(out == -1) //error
								{
									perror("File not created.\n");
								}
								int result = dup2(out, 1);
								if (result == -1)
								{
									perror("Output not redirected.\n");
								}
							};
pipe_case:
		PIPE				{printf("Pipe entered\n");};
ampersand_case:
		AMPERSAND			{printf("Ampersand entered\n");};
matcher_case:
		MATCHER				{printf("Matcher entered\n");};
setenv_environment_case:
		SETENV ENVIRONMENTSTART word_case ENVIRONMENTEND word_case
							{
								printf("Setenv command entered\n");
								char *es;
								if (textArray[words - 2] == NULL || textArray[words - 2][0] == '\0' || strchr(textArray[words - 2], '=') != NULL || textArray[words - 1] == NULL) //check to see if valid
								{
									perror("Invalid argument.\n");
								}
								unsetenv_function(textArray[words - 2]);             /* Remove all occurrences */
								es = malloc(strlen(textArray[words - 2]) + strlen(textArray[words - 1]) + 2);
																	/* +2 for '=' and null terminator */
								if (es == NULL) //error
								{
									perror("Error with memory allocation.\n");
								}
								strcpy(es, textArray[words - 2]); //copy variable
								strcat(es, "="); //copy =
								strcat(es, textArray[words - 1]); //copy value
								int result = putenv(es); //put into array
								if(result == -1) //error
								{
									perror("Error inserting element into environment variable array.\n");
								}
							};
unsetenv_environment_case:
		UNSETENV ENVIRONMENTSTART word_case ENVIRONMENTEND
							{
								unsetenv_function(textArray[words - 1]);
							};
%%
void unsetenv_function(char *text)
{
	printf("Unsetenv command entered\n");
	char **envVariableNames, **rightEnvVariableNames;
	size_t length;
	if (text == NULL || text == '\0' || strchr(text, '=') != NULL) {
		perror("Entered an invalid name!\n");
	}
	length = strlen(text);
	for (envVariableNames = environ; *envVariableNames != NULL; )
	{
		if (strncmp(*envVariableNames, text, length) == 0 && (*envVariableNames)[length] == '=') { //found a match
			for (rightEnvVariableNames = envVariableNames; *rightEnvVariableNames != NULL; rightEnvVariableNames++)
			{
				*rightEnvVariableNames = *(rightEnvVariableNames + 1); //shift over
			}
			/* Continue around the loop to further instances of 'name' */
		} 
		else {
				envVariableNames++; //keep moving
		}
	}
}
void unalias_function(char *text)
{
	printf("Unalias command entered\n");
	size_t length;
	if (text == NULL || text == '\0' || strchr(text, '=') != NULL) { //invalid
		perror("Entered an invalid alias!\n");
	}
	length = strlen(text);
	int i;
	int j;
	for (i = 0; i < aliasCount; i++)
	{
		if (strncmp(aliases[i], text, length) == 0 && aliases[i][length] == '=') { //found match
			for (j = i; j < aliasCount; j++)
			{
				aliases[j] = aliases[j + 1]; //shift over
			}
			aliasCount--; //decrement count
		} 
	}
}
