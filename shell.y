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
  #define STRINGIFY(x) #x
  #define TOSTRING(x) STRINGIFY(x)
  #define AT __FILE__ ":" TOSTRING(__LINE__)
  void yyerror(const char *str)
  {
	fprintf(stderr,"error: %s\n", str);
  }
  int yywrap()
  {
	return 1;
  }
  void unsetenv_function(char *text);
  void unalias_function (char *text);
  void setenv_function (char *text, char *text2);
  void alias_function(char *text, char *text2);
  void cd_function();
  void cd_function2(char *text);
  void standard_error_redirect_function (char *text, char *text2);
  void standard_error_redirect_function2 (char *text, char *text2);
  void write_to_function (char *text);
  void read_from_function (char *text);
  void word_function (char *text);
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
		 yyparse();
		}
%}
%token CD PRINTENV UNSETENV SETENV NEWLINE ALIAS UNALIAS BYE WORD MATCHER QUOTES ENVIRONMENTSTART ENVIRONMENTEND SLASH READFROM WRITETO PIPE AMPERSAND
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
		|setenv_environment_case
		|unsetenv_environment_case
		|cd_environment_case
		|unalias_environment_case
		|setenv_environment_case2
		|setenv_environment_case3
		|alias_environment_case
		|alias_environment_case2
		|alias_environment_case3
		|standard_error_redirect_case
		|standard_error_redirect_case2;
cd2_case:
		CD 
							{
								cd_function();
							};
cd_case:
	    CD WORD 
							{
								cd_function2(yytext);
							};
printenv_case:
	    PRINTENV 
							{
								printf("Printenv command entered\n");
								char ** ep;
								for(ep = environ; *ep!= NULL; ep++)
								{
									printf("%s\n", *ep); //print everything line by line
								}
							};
unsetenv_case:
		UNSETENV WORD 
							{
								unsetenv_function(yytext);
							};
setenv_case:
		SETENV word_case word_case   
							{
								setenv_function(textArray[words - 2], textArray [words - 1]);		
							};
alias2_case:
		ALIAS	
							{
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
								alias_function(textArray[words - 2], textArray[words - 1]);
							};
unalias_case:
		UNALIAS WORD       
							{
								unalias_function(yytext);
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
								printf("Pipe entered\n");
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
setenv_environment_case:
		SETENV ENVIRONMENTSTART word_case ENVIRONMENTEND word_case
							{
								setenv_function(textArray[words - 2], textArray[words - 1]);
							};
unsetenv_environment_case:
		UNSETENV ENVIRONMENTSTART word_case ENVIRONMENTEND
							{
								unsetenv_function(textArray[words - 1]);
							};
cd_environment_case:
		CD ENVIRONMENTSTART word_case ENVIRONMENTEND
							{
								cd_function2(textArray[words - 1]);
							};
unalias_environment_case:
		UNALIAS ENVIRONMENTSTART word_case ENVIRONMENTEND
							{
								unalias_function(textArray[words - 1]);
							};
setenv_environment_case2:
		SETENV word_case ENVIRONMENTSTART word_case ENVIRONMENTEND
							{
								setenv_function(textArray[words - 2], textArray[words - 1]);
							};
setenv_environment_case3:
		SETENV ENVIRONMENTSTART word_case ENVIRONMENTEND ENVIRONMENTSTART word_case ENVIRONMENTEND
							{
								setenv_function(textArray[words - 2], textArray[words - 1]);
							};
alias_environment_case:
		ALIAS ENVIRONMENTSTART word_case ENVIRONMENTEND word_case
							{
								alias_function(textArray[words - 2], textArray[words - 1]);
							};
alias_environment_case2:
		ALIAS word_case ENVIRONMENTSTART word_case ENVIRONMENTEND
							{
								alias_function(textArray[words - 2], textArray[words - 1]);
							};
alias_environment_case3:
		ALIAS ENVIRONMENTSTART word_case ENVIRONMENTEND ENVIRONMENTSTART word_case ENVIRONMENTEND
							{
								alias_function(textArray[words - 2], textArray[words - 1]);
							};
standard_error_redirect_case:
			word_case WRITETO AMPERSAND word_case
							{
								standard_error_redirect_function(textArray[words - 2], textArray[words - 1]);
							};
standard_error_redirect_case2:
		word_case WRITETO word_case
							{
								standard_error_redirect_function2(textArray[words - 2], textArray[words - 1]);
							};
%%
void unsetenv_function(char *text)
{
	printf("Unsetenv command entered\n");
	char **envVariableNames, **rightEnvVariableNames;
	size_t length;
	if (text == NULL || text == '\0' || strchr(text, '=') != NULL) { //error
		perror("Entered an invalid name");
		printf("Error at line %d\n", __LINE__);
		return;
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
		perror("Entered an invalid alias");
		printf("Error at line %d\n", __LINE__);
		return;
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
void setenv_function (char *text, char *text2)
{
	printf("Setenv command entered\n");
	char *es;
	if (text == NULL || text[0] == '\0' || strchr(text, '=') != NULL || text2 == NULL) //check to see if valid
	{
		perror("Invalid argument.");
		printf("Error at line %d\n", __LINE__);
		return;
	}
	unsetenv_function(text);             /* Remove all occurrences */
	es = malloc(strlen(text) + strlen(text2) + 2);
	/* +2 for '=' and null terminator */
	if (es == NULL) //error
	{
		perror("Error with memory allocation");
		printf("Error at line %d\n", __LINE__);
		return;
	}
	if(strcmp(text, "PATH") == 0 || strcmp(text, "ARGPATH") == 0) //setting path
	{
		char *pch = strtok(text2, ":"); //split on colons
		char *path = malloc(500 * sizeof(char));
		while (pch != NULL) //still have tokens
		{
				if(strncmp(pch, ".", 1) == 0) //first character is a dot, so explicitly match
				{
						char *directory = malloc(300 * sizeof(char));
						strcpy(directory, getenv("PWD")); //get current directory
						strcat(directory, &pch[1]); //take everything after dot
						strcat(path, directory);
						strcat(path, ":"); //colon-separate
				}
				else if(strncmp(pch, "/.", 2) == 0) //first two characters are /., so get root
				{
					strcpy(path, "/"); //root directory
					strcat(path, &pch[2]); //take everything after dot
					strcat(path, ":"); //colon-separate
				}
				else if (strncmp(pch, "/", 1) == 0) //also the root directory
				{
					strcpy(path, "/"); //root directory
					strcat(path, &pch[1]); //take everything after slash
					strcat(path, ":"); //colon-separate
				}
				else if(strncmp(pch, "~", 1) == 0) //tilde
				{
					int length = strlen(&pch[1]); 
					if(length == 0) //empty afterwards, so get home directory
					{
						char *directory = malloc(300 * sizeof(char));
						strcpy(directory, getenv("HOME")); //get home directory
						strcat(path, directory); //set to home directory
						strcat(path, ":"); //colon-separate
					}
					else //actual expansion
					{
						char *result = strchr(&pch[1], '/');
						if (result == NULL) //end of string, so can only be username
						{
							pwd = getpwnam(&pch[1]); //gets user info
							if (pwd == NULL) //error
							{
								perror("Error with getting struct.\n");
								printf("Error at line %d\n", __LINE__);
								return;
							}
							char *directory = malloc(300 * sizeof(char));
							strcpy(directory, pwd->pw_dir); 
							strcat(path, directory); //set to home directory
							strcat(path, ":"); //colon-separate
						}
						else //string continues, go up until /
						{
							char *directory = malloc(300 * sizeof(char));
							strcpy(directory, "/home/"); //start with home directory
							int index = length - 1;
							int i;
							for(i = 0; i < strlen(pch); i++)
							{
								if(pch[i] == '/') //get everything to slash
								{
									index = i;
									break;
								}
							}
							char *toadd = malloc(300 * sizeof(char));
							strncpy(toadd, &pch[1], index - 1);
							strcat(toadd, "/"); //slash at end
							strcat(directory, toadd); //copy over
							strcat(path, directory); //copy over
							strcat(path, ":"); //colon-separate
						}
					}
				}
				else
				{
					strcat(path, pch); //no tilde
					strcat(path, ":"); //colon-separate
				}
				pch = strtok(NULL, ":"); //keep parsing
		}
		path[strlen(path) - 1] = '\0'; //get rid of colon at the end
		strcpy(text2, path);
	}
	else
	{
			if(strncmp(text2, "~", 1) == 0) //tilde expansion
			{
				int length = strlen(&text2[1]); 
				if(length == 0) //empty afterwards, so get home directory
				{
					strcpy(text2, getenv("HOME")); //get home directory and move to it
				}
				else //actual expansion
				{
					char *result = strchr(&text2[1], '/');
					if (result == NULL) //end of string, so has to be a username
					{
						pwd = getpwnam(&text2[1]); //gets user info
						if (pwd == NULL) //error
						{
							perror("Error with getting struct.\n");
							printf("Error at line %d\n", __LINE__);
							return;
						}
						strcpy(text2, pwd->pw_dir); //set to home directory
					}
					else //string continues, go until slash
					{
						char *directory = malloc(300 * sizeof(char));
						strcpy(directory, "/home/"); //start with home
						int index = length - 1;
						int i;
						for(i = 0; i < length; i++)
						{
							if(text2[i] == '/') //find slash
							{
								index = i;
								break;
							}
						}
						char *toadd = malloc(300 * sizeof(char));
						strncpy(toadd, &text2[1], index - 1); //copy over
						strcat(toadd, "/"); //add slash
						strcat(directory, toadd); //copy over
						strcpy(text2, directory); //copy over
					}
				}
			}
	}
	strcpy(es, text); //copy variable
	strcat(es, "="); //copy =
	strcat(es, text2); //copy value
	int result = putenv(es); //put into array
	if(result == -1) //error
	{
		perror("Error inserting element into environment variable array");
		printf("Error at line %d\n", __LINE__);
		return;
	}
}
void alias_function(char *text, char *text2)
{
	printf("Alias command entered\n");
	char *es;
	if (text == NULL || text[0] == '\0' || strchr(text, '=') != NULL || text2 == NULL) //check to see if valid
	{
		perror("Invalid argument");
		printf("Error at line %d\n", __LINE__);
		return;
	}
	unalias_function(text);             /* Remove all occurrences */
	es = malloc(strlen(text) + strlen(text2) + 2);
	if (es == NULL) //error
	{
		perror("Error with memory allocation");
		printf("Error at line %d\n", __LINE__);
		return;
	}
	strcpy(es, text); //copy variable
	strcat(es, "="); //copy =
	strcat(es, text2); //copy value
	newAliases = (char **) malloc((aliasCount+2)*sizeof(char *)); //null entry and new word
	if ( newAliases == (char **) NULL ) //no array created
	{
		perror("Array not created.");
		printf("Error at line %d\n", __LINE__);
		return;
	}
	memcpy ((char *) newAliases, (char *) aliases, aliasCount*sizeof(char *)); //copy all entries from textArray into newTextArray
	newAliases[aliasCount] = es; //word
	newAliases[aliasCount + 1] = NULL; //null entry
	aliases = newAliases;
	aliasCount++; //increment index
}
void cd_function()
{
	printf("Second CD command entered\n");
	int result = chdir(getenv("HOME")); //get home directory and move to it
	if(result == -1) //error
	{
		perror("Directory not changed");
		printf("Error at line %d\n", __LINE__);
		return;
	}
	setenv_function("PWD", getenv("HOME")); //change PWD
	printf("%s\n", getenv("PWD"));
}
void cd_function2(char *text)
{
	printf("CD command entered\n");
	if(strncmp(text, "~", 1) == 0) //tilde expansion
	{
		int length = strlen(&text[1]); 
		if(length == 0) //empty afterwards, so get home directory
		{
			int result = chdir(getenv("HOME")); //get home directory and move to it
			if(result == -1) //error
			{
				perror("Directory not changed");
				printf("Error at line %d\n", __LINE__);
				return;
			}
			setenv_function("PWD", getenv("HOME")); //change PWD
			printf("%s\n", getenv("PWD"));
		}
		else //actual expansion
		{
			char *result = strchr(&text[1], '/');
			if (result == NULL) //end of string, so must be username
			{
				pwd = getpwnam(&text[1]); //gets user info
				if (pwd == NULL) //error
				{
					perror("Error with getting struct.");
					printf("Error at line %d\n", __LINE__);
					return;
				}
				int result = chdir(pwd->pw_dir); //get home directory and move to it
				if(result == -1) //error
				{
					perror("Directory not changed");
					printf("Error at line %d\n", __LINE__);
					return;
				}
				setenv_function("PWD", pwd->pw_dir); //change PWD
				printf("%s\n", getenv("PWD"));
			}
			else //string continues, go until /
			{
				char *directory = malloc(300 * sizeof(char));
				strcpy(directory, getenv("HOME")); //start with home directory
				int index = length - 1;
				int i;
				for(i = 0; i < length; i++)
				{
					if(text[i] == '/') //find slash
					{
						index = i;
						break;
					}
				}
				char *toadd = malloc(300 * sizeof(char));
				strncpy(toadd, &text[1], index - 1); //copy everything up until slash
				strcat(toadd, "/");
				strcat(directory, toadd);
				int result = chdir(directory); //move to it
				if(result == -1) //error
				{
					perror("Directory not changed");
					printf("Error at line %d\n", __LINE__);
					return;
				}
				setenv_function("PWD", directory); //change PWD
				printf("%s\n", getenv("PWD"));
			}
		}
	}
	else //no tilde
	{
		char *directory = malloc(300 * sizeof(char));
		strcpy(directory, getenv("PWD")); //start with current directory and see if it's relative or absolute
		if(directory[strlen(directory) - 1] != '/') //last character is not a slash
		{
			strcat(directory, "/"); //adds a slash
		}
		if(text[0] == '.')
		{
			if(strlen(text) == 1 || (strlen(text) == 2 && text[1] == '/')) //just a dot or dot-slash
			{
				strcpy(text, ""); //blank it
			}
			else if(text[1] != '.') //append text after dot
			{
				strcpy(text, &text[1]);
			}
			else if(text[1] == '.' && strcmp(directory, "/") != 0)//go up a level (not in the root)
			{
				int i;
				int lastSlashIndex = 1;
				for(i = strlen(directory) - 2; i >= 0; i--) //find occurence of last slash
				{
					if(directory[i] == '/')
					{
						lastSlashIndex = i; //found last slash
						break;
					}
				}
				char *directory2 = malloc(300 * sizeof(char));
				strncpy(directory2, directory, lastSlashIndex); //get everything up to the slash
				strcpy(directory, directory2);
				if(strlen(text) > 2)
				{
					strcat(directory, "/"); //add slash
					strcpy(text, &text[3]); //take everything after the slash
				}
				else //nothing
				{
					strcpy(text, ""); //blank it
				}
			}
		}
		if(text[0] == '/') //first character is slash
		{
			if(strlen(text) == 1 || (strlen(text) == 2 && text[1] == '.')) //just a slash or slash-dot
			{
				int result = chdir("/"); //move to slash directory
				if(result == -1)
				{
					perror("Directory not changed");
					printf("Error at line %d\n", __LINE__);
					return;
				}
				setenv_function("PWD", "/"); //set to slash
				printf("%s\n", getenv("PWD"));
				return;
			}
			else
			{
				char* text2 = malloc(300 * sizeof(char));
				memcpy(text2, &text[1], strlen(&text[1]) * sizeof(char)); //copy everything after slash
				strcpy(text, text2); //copy back into text
			}
		}
		strcat(directory, text); //check if relative
		int result = chdir(directory); //move directory
		if (result == -1) //error, could be absolute, could be actual error
		{
			int result2 = chdir(text); //absolute
			if (result2 == -1) //error
			{
				perror("Directory not changed");
				printf("Error at line %d\n", __LINE__);
				return;
			}
			setenv_function("PWD", text); //change PWD to absolute
			printf("%s\n", getenv("PWD"));
			return;
		}
		if(strncmp(&directory[strlen(directory) - 1], "/", 1) == 0) //last character is a slash
		{
			directory[strlen(directory) - 1] = '\0'; //remove slash
			setenv_function("PWD", directory); //change PWD to absolute
			printf("%s\n", getenv("PWD"));
		}
		else
		{
			setenv_function("PWD", directory); //change PWD to absolute
			printf("%s\n", getenv("PWD"));
		}
	}
}
void standard_error_redirect_function(char *text, char *text2)
{
	if(strcmp(text, "2") != 0 || strcmp(text2, "1") != 0) //error
	{
		perror("Invalid input");
		printf("Error at line %d\n", __LINE__);
		return;
	}
	else
	{
		int result = dup2(1, 2); //redirect output to standard error
		if (result == -1) //error
		{
			perror("Standard error not redirected to output");
			printf("Error at line %d\n", __LINE__);
			return;
		}
	}
}
void standard_error_redirect_function2(char *text, char *text2)
{
	if(strcmp(text, "2") != 0) //error
	{
		perror("Invalid input");
		printf("Error at line %d\n", __LINE__);
		return;
	}
	else
	{
		int out = open(text2, O_WRONLY | O_CREAT | O_TRUNC | S_IRUSR | S_IRGRP | S_IWGRP | S_IWUSR); //open file
		if(out == -1) //error
		{
			perror("File not created");
			printf("Error at line %d\n", __LINE__);
			return;
		}
		int result = dup2(out, 2); //redirect standard error to output file
		if (result == -1) //error
		{
			perror("Standard error not redirected");
			printf("Error at line %d\n", __LINE__);
			return;
		}
	}
}
void write_to_function(char *text)
{
	printf("Write to entered\n");
	int out = open(text, O_WRONLY | O_CREAT | O_TRUNC | S_IRUSR | S_IRGRP | S_IWGRP | S_IWUSR); //open file
	if(out == -1) //error
	{
		perror("File not created");
		printf("Error at line %d\n", __LINE__);
		return;
	}
	int result = dup2(out, 1); //redirect output to file
	if (result == -1) //error
	{
		perror("Output not redirected");
		printf("Error at line %d\n", __LINE__);
		return;
	}
}
void read_from_function (char *text)
{
		printf("Read from entered\n");
		int in = open(text, O_RDONLY); //open file
		if(in == -1) //error
		{
			perror("File not opened");
			printf("Error at line %d\n", __LINE__);
			return;
		}
		int result = dup2(in, 0); //redirect input from file
		if (result == -1) //error
		{
			perror("Input not redirected");
			printf("Error at line %d\n", __LINE__);
			return;
		}
}
void word_function(char *text)
{
	char * es;
	es = malloc(strlen(text) + 1); //allocate space for word and terminating character
	if (es == NULL) //error
	{
		perror("Error with memory allocation.");
		printf("Error at line %d\n", __LINE__);
		return;
	}
	strcpy(es, text); //copy text into pointer
	newTextArray = (char **) malloc((words+2)*sizeof(char *)); //null entry and new word
	if ( newTextArray == (char **) NULL ) //no array created
	{
		perror("Array not created");
		printf("Error at line %d\n", __LINE__);
		return;
	}
	memcpy ((char *) newTextArray, (char *) textArray, words*sizeof(char *)); //copy all entries from textArray into newTextArray
	newTextArray[words]   = es; //word
	newTextArray[words+1] = NULL; //null entry
	textArray = newTextArray;
	words++; //increment index
}
