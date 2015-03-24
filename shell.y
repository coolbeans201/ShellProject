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
		perror("Invalid argument.\n");
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
	if(strcmp(text, "PATH") == 0) //setting path
	{
		char *pch = strtok(text2, ":");
		while (pch != NULL)
		{
				if(strncmp(pch, "~", 1) == 0) //tilde
				{
					int length = strlen(&pch[1]); 
					if(length == 0) //empty afterwards
					{
						char *directory = getenv("HOME"); //get home directory
					}
					else //actual expansion
					{
						char *result = strchr(&pch[1], '/');
						if (result == NULL) //end of string
						{
							pwd = getpwnam(&pch[1]); //gets user info
							if (pwd == NULL) //error
							{
								perror("Error with getting struct.\n");
								printf("Error at line %d\n", __LINE__);
								return;
							}
							char *directory = pwd->pw_dir; //get home directory
						}
						else //string continues
						{
							char* directory = getenv("HOME"); //get home directory
							strcat(directory, &pch[1]); //add on text afterwards
						}
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
	int fd = open("datafile.dat", O_RDWR | S_IREAD | S_IWRITE); //create a file so that we can see that this actually works with ls
	if(fd == -1) //error
	{
		perror("File not opened");
		printf("Error at line %d\n", __LINE__);
		return;
	}
	if(result == -1) //error
	{
		perror("Directory not changed");
		printf("Error at line %d\n", __LINE__);
		return;
	}
	setenv_function("PWD", getenv("HOME")); //change PWD
}
void cd_function2(char *text)
{
	printf("CD command entered\n");
	if(strncmp(text, "~", 1) == 0) //tilde expansion
	{
		int length = strlen(&text[1]); 
		if(length == 0) //empty afterwards
		{
			int result = chdir(getenv("HOME")); //get home directory and move to it
			int fd = open("datafile2.dat", O_RDWR | S_IREAD | S_IWRITE); //create a file so that we can see that this actually works with ls
			if(fd == -1) //error
			{
				perror("File not opened");
				printf("Error at line %d\n", __LINE__);
				return;
			}
			if(result == -1) //error
			{
				perror("Directory not changed");
				printf("Error at line %d\n", __LINE__);
				return;
			}
			setenv_function("PWD", getenv("HOME")); //change PWD
		}
		else //actual expansion
		{
			char *result = strchr(&text[1], '/');
			if (result == NULL) //end of string
			{
				pwd = getpwnam(&text[1]); //gets user info
				if (pwd == NULL) //error
				{
					perror("Error with getting struct.\n");
					printf("Error at line %d\n", __LINE__);
					return;
				}
				int result = chdir(pwd->pw_dir); //get home directory and move to it
				int fd = open("datafile4.dat", O_RDWR | S_IREAD | S_IWRITE); //create a file so that we can see that this actually works with ls
				if(fd == -1) //error
				{
					perror("File not opened");
					printf("Error at line %d\n", __LINE__);
					return;
				}
				if(result == -1) //error
				{
					perror("Directory not changed");
					printf("Error at line %d\n", __LINE__);
					return;
				}
				setenv_function("PWD", pwd->pw_dir); //change PWD
			}
			else //string continues
			{
				char* directory = getenv("HOME"); //get home directory
				strcat(directory, &text[1]); //add on to it
				int result = chdir(directory); //move to it
				int fd = open("datafile4.dat", O_RDWR |S_IREAD | S_IWRITE); //create a file so that we can see that this actually works with ls
				if(fd == -1) //error
				{
					perror("File not opened");
					printf("Error at line %d\n", __LINE__);
					return;
				}
				if(result == -1) //error
				{
					perror("Directory not changed");
					printf("Error at line %d\n", __LINE__);
					return;
				}
				setenv_function("PWD", directory); //change PWD
			}
		}
	}
	else
	{
		int result = chdir(text); //move directory
		if (result == -1) //error
		{
			perror("Directory not changed");
			printf("Error at line %d\n", __LINE__);
			return;
		}
		int fd = open("datafile.dat", O_RDWR | S_IREAD | S_IWRITE); //create a file so that we can see that this actually works with ls
		if(fd == -1) //error
		{
			perror("File not opened");
			printf("Error at line %d\n", __LINE__);
			return;
		}
		setenv_function("PWD", text); //change PWD
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
		int result = dup2(1, 2);
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
		int result = dup2(out, 2);
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
	int result = dup2(out, 1);
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
		int result = dup2(in, 0); //connect
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
