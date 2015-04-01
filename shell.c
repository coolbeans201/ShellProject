#include "shell.h"
char** newTextArray; //copied words
int words = 0; //number of words
extern char** environ; //environment variables
char** aliases; //alias names and values
char** newAliases; //copied aliases
int aliasCount = 0; //number of aliases
struct passwd* pwd; //contains result of getpwnam
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
		if(path == (char *) NULL)
		{
			perror("Error with memory allocation.");
			printf("Error at line %d\n", __LINE__);
			return;
		}
		while (pch != NULL) //still have tokens
		{
				if(strncmp(pch, ".", 1) == 0) //first character is a dot, so explicitly match
				{
						char *directory = malloc(300 * sizeof(char));
						if(directory == (char *) NULL)
						{
							perror("Error with memory allocation.");
							printf("Error at line %d\n", __LINE__);
							return;
						}
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
						if(directory == (char *) NULL)
						{
							perror("Error with memory allocation.");
							printf("Error at line %d\n", __LINE__);
							return;
						}
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
							if(directory == (char *) NULL)
							{
								perror("Error with memory allocation.");
								printf("Error at line %d\n", __LINE__);
								return;
							}
							strcpy(directory, pwd->pw_dir); 
							strcat(path, directory); //set to home directory
							strcat(path, ":"); //colon-separate
						}
						else //string continues, go up until /
						{
							char *directory = malloc(300 * sizeof(char));
							if(directory == (char *) NULL)
							{
								perror("Error with memory allocation.");
								printf("Error at line %d\n", __LINE__);
								return;
							}
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
							if(toadd == (char *) NULL)
							{
								perror("Error with memory allocation.");
								printf("Error at line %d\n", __LINE__);
								return;
							}
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
						if(toadd == (char *) NULL)
						{
							perror("Error with memory allocation.");
							printf("Error at line %d\n", __LINE__);
							return;
						}
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
	if(strcmp(text, "cd") == 0 || strcmp(text, "alias") == 0 || strcmp(text, "unalias") == 0 || strcmp(text, "setenv") == 0 || strcmp(text, "printenv") == 0 || strcmp(text, "unsetenv") == 0) //error
	{
		perror("Trying to make an alias out of a built-in command");
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
	changeGroupedSlashesIntoOneSlash(text); //alters the text so all grouped slashes now become one slash. ex. ////home///usr -> /home/usr
	printf("CD command entered\n");
	char *directory = malloc(300 * sizeof(char));
	if (directory == (char *) NULL) //error
	{
		perror("Error with memory allocation.");
		printf("Error at line %d\n", __LINE__);
		return;
	}
	strcpy(directory, getenv("PWD")); //start with current directory and see if it's relative or absolute
	if(directory[strlen(directory) - 1] != '/') //last character is not a slash
	{
		strcat(directory, "/"); //adds a slash
	}
	if(text[0] == '.')
	{
		if(strlen(text) == 1) //just a dot
		{
			strcpy(text, ""); //blank it
		}
		else if(strlen(text) == 2 && text[1] == '/') //just a dot-slash
		{
			strcpy(text, ""); //blank it
		}
		else if(strlen(text) > 2 && text[1] == '/')
		{
			strcpy(text, &text[2]);
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
			if(lastSlashIndex != 0)
			{ //if .. does not return to the root directory
				directory[lastSlashIndex] = '\0';//sets the second to last slash to a null character
			}
			else if(lastSlashIndex == 0)
			{//if .. is returning up to the root directory
				directory[1] = '\0';//sets index 1 to null so the directory sets to the root
			}
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
		else if(strcmp(directory, "/") == 0)
		{//if it is in root
			strcpy(text,""); //change text to empty string so ".." is not concatenated to the directory later on
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
			if(text2 == (char *) NULL)
			{
				perror("Error with memory allocation.");
				printf("Error at line %d\n", __LINE__);
				return;
			}
			strncpy(text2, text, strlen(text)); //copy everything after slash
			strcpy(text, text2); //copy back into text
			strcpy(directory, "");
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
	if(strncmp(&directory[strlen(directory) - 1], "/", 1) == 0 && strlen(directory) != 1) //last character is a slash and directory isn't just "/"
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
	//printf("Resolved alias: %s\n",aliasResolve(text));
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
void printenv_function()
{
	printf("Printenv command entered\n");
	char ** ep;
	for(ep = environ; *ep!= NULL; ep++)
	{
		printf("%s\n", *ep); //print everything line by line
	}
}
void alias_function2()
{
	printf("Second alias command entered\n");
	int i;
	for(i = 0; i < aliasCount; i++)
	{
		printf("%s\n", aliases[i]); //print each alias line by line
	}
}
int getAliasCount()
{
	return aliasCount;
}
int getWords()
{
	return words;
}
void getDirectories(char* text)
{
	int i;
	int flags = 0;
	glob_t results;
	int ret;
	DIR *dir;
	struct dirent *ent;
	if ((dir = opendir (getenv("PWD"))) != NULL) 
	{
		/* print all the files and directories within directory */
		while ((ent = readdir (dir)) != NULL) 
		{
			flags |= (i > 1 ? GLOB_APPEND : 0);
			ret = glob(text, flags, globerr, & results); //glob expression
			if (ret != 0) //error
			{
				printf("Error with globbing");
				printf("Error at line %d\n", __LINE__);
				return;
			}
		}
		for (i = 0; i < results.gl_pathc; i++) //print out results
		{
			printf("%s\n", results.gl_pathv[i]);
		}
		globfree(& results); //free glob expression
		closedir (dir); //close directory 
	}
	else 
	{
		/* could not open directory */
		perror ("Cannot open directory");
		printf("Error at line %d\n", __LINE__);
		return;
	}
}
void pipe_function(char *text)
{
	printf("Ey guy, you piped!\n");
	int   pid_1,               /* will be process id of first child - who */
	      pid_2,               /* will be process id of second child - wc */
	      pfd[2];              /* pipe file descriptor table.             */
	if (pipe(pfd) == -1 )              /* create a pipe  */
	{                                 /* must do before a fork */
	    perror ("Error with creating a pipe");
		printf ("Error at line %d\n", __LINE__);
	    return;
	}
	if ((pid_1 = fork ()) == -1)        /* create 1st child   */
	{
	    perror ("Error with forking first child");
		printf ("Error at line %d\n", __LINE__);
	    return;
	}
	if (pid_1 != 0 )                      /* in parent  */
	{
	    if ((pid_2 = fork ()) == -1)     /* create 2nd child  */
	    {
	        perror ("Error with forking second child");
			printf ("Error at line %d\n", __LINE__);
	        return;
	    }
	    if (pid_2 != 0)                   /* still in parent  */
	    {
	        int result = close (pfd [0]);         /* close pipe in parent */
			if(result == -1) //error
			{
				perror ("Error with closing read end of pipe");
				printf ("Error at line %d\n", __LINE__);
				return;
			}
	        result = close (pfd [1]);        /* conserve file descriptors */
			if(result == -1) //error
			{
				perror ("Error with closing write end of pipe");
				printf ("Error at line %d\n", __LINE__);
				return;
			}
	        result = wait ((int *) 0);           /* wait for children to die */
			if(result == -1) //error
			{
				perror ("Error with waiting");
				printf ("Error at line %d\n", __LINE__);
				return;
			}
	        result = wait ((int *) 0);
			if(result == -1) //error
			{
				perror ("Error with waiting");
				printf ("Error at line %d\n", __LINE__);
				return;
			}
	    }
	    else                                /* in 2nd child   */
	    {
			int result = close (0);           /* close standard input */
			if(result == -1) //error
			{
				perror ("Error with closing standard input");
				printf ("Error at line %d\n", __LINE__);
				return;
			}
	        result = dup (pfd [0]);      /* read end of pipe becomes stdin */
			if(result == -1) //error
			{
				perror ("Error with making read end of pipe standard input");
				printf ("Error at line %d\n", __LINE__);
				return;
			}
	        result = close (pfd [0]);            /* close unneeded I/O  */
			if(result == -1) //error
			{
				perror ("Error with closing read end of pipe");
				printf ("Error at line %d\n", __LINE__);
				return;
			}
	        result = close (pfd [1]);           /* close unneeded I/O   */
			if(result == -1) //error
			{
				perror ("Error with closing write end of pipe");
				printf ("Error at line %d\n", __LINE__);
				return;
			}
	        result = execl ("/usr/bin/wc", "wc", "-l", (char *) NULL); //execute second child
			if(result == -1) //error
			{
				perror ("Error with executing");
				printf ("Error at line %d\n", __LINE__);
				return;
			}
	    }	
	}
	else                                      /* in 1st child   */
	{
	    int result = close (1);            /* close standard out	 */
		if(result == -1) //error
		{
			perror ("Error with closing standard output");
			printf ("Error at line %d\n", __LINE__);
			return;
		}
	    result = dup (pfd [1]);       /* write end of pipes becomes stdout */
		if(result == -1) //error
		{
			perror ("Error with setting write end of pipe to standard output");
			printf ("Error at line %d\n", __LINE__);
			return;
		}
	    result = close (pfd [0]);                 /* close unneeded I/O */
		if(result == -1) //error
		{
			perror ("Error with closing read end of pipe");
			printf ("Error at line %d\n", __LINE__);
			return;
		}
	    result = close (pfd [1]);                /* close unneeded I/O */
		if(result == -1) //error
		{
			perror ("Error with closing write end of pipe");
			printf ("Error at line %d\n", __LINE__);
			return;
		}
	    result = execl ("/usr/bin/who", "who", (char *) NULL); //execute 1st child
		if(result == -1) //error
		{
			perror ("Error with executing");
			printf ("Error at line %d\n", __LINE__);
			return;
		}
	}
}
int globerr(const char *path, int eerrno) //error
{
	perror ("Error with globbing.");
	printf ("Error with path %s at line %d\n", path, __LINE__);
	return 0;	/* let glob() keep going */
}

void changeGroupedSlashesIntoOneSlash(char* string){ //removes extra slashes in the beginning of a string so ////home -> /home, ./////home -> ./home
	int i = 0;
	int size = strlen(string);
	for(i = 0; i < size;){
		if(string[i] == '/' && string[i+1] == '/'){
			int j = i + 1;
			for(j = i; j <=size; j++){
				string[j] = string[j+1];
			}
			size--;
		}
		else
			i++;
	}
}

char* aliasResolve(char* alias){//takes in name of alias and returns the final resolved value of that alias name or <LOOP> if it loops infinitely,
	//if string passed in argument is not an alias then it returns empty string
	char* name = malloc(300*sizeof(char)); //declares name and value strings used to resolve
	char* value;
	char* nameTracker[100]; //keeps track of alias names already encountered in order to detect infinite loops
	int trackSize = 0; //keeps track of size of names in the tracker
	strcpy(name, alias); //copies initial name into name string
	nameTracker[trackSize] = name;
	trackSize++;
	value = getAliasValue(name);//gets initial value
	if(strcmp(value, "") == 0)//if initial alias name does not resolve to anything(resolves to empty string), return empty string
		return value;
	while(value[0] != '\0'){ //loop runs until value cannot be further resolved into an additional alias
		int i;
		for(i = 0; i < trackSize; i++){
			if(strcmp(value, nameTracker[i]) == 0){ //returns "<LOOP>" if the alias generates an infinite loop
				strcpy(value, "<LOOP>");
				return value;
			}
		}
		nameTracker[trackSize] = value;//the alias value gets added to the tracking array if it's not in the array already
		trackSize++;
		name = value; //name now becomes the previous value
		value = getAliasValue(name); //get alias value connected to alias name
	}
	strcpy(value, name);
	free(name);
	return value;
}

char* getAliasValue(char* aliasName){//returns the value of an alias when given the name as an argument,returns empty string if the alias name does not exist
	int i = 0;
	char* value = malloc(300*sizeof(char));
	value[0] = '\0';
	for(i = 0; i < aliasCount; i++){//goes through aliases arary
		int j = 0;
		int eqindex = strlen(aliases[i]);
		for(j = 0; j < eqindex; j++){
			if(aliases[i][j] == '='){//finds the = character which separates name and value
				eqindex = j;
			}
		}
		char* possibleNameMatch = malloc(300*sizeof(char));
		strncpy(possibleNameMatch, aliases[i], eqindex);//copies everything up to the = value into possibleNameMatch
		if(strcmp(aliasName, possibleNameMatch) == 0){//if name is possibleNameMatch then copies everything after the = into the return value
			strcpy(value, &aliases[i][eqindex+1]);
			return value;
		}
		free(possibleNameMatch); //frees memory
	}
	return value;
}

void quoteFunction(char* text)
{
	changeGroupedSpacesIntoOneSpace(text);
	char* actualText = malloc(300 * sizeof(char));
	if(actualText == (char*) NULL) //error
	{
		perror ("Error with memory allocation.");
		printf ("Error at line %d\n", __LINE__);
		return;
	}
	strncpy(actualText, &text[1], strlen(text) - 2); //everything between quotes
	char* actualText2 = malloc(300 * sizeof(char));
	if(actualText2 == (char*) NULL) //error
	{
		perror ("Error with memory allocation.");
		printf ("Error at line %d\n", __LINE__);
		return;
	}
	char* result = malloc(300 * sizeof(char));
	if (result == (char*) NULL) //error
	{
		perror ("Error with memory allocation.");
		printf ("Error at line %d\n", __LINE__);
		return;
	}
	strcpy(actualText2, "");
	char* pch = strtok(actualText, " "); //parse by space to analyze each "word" for presence of alias
	while(pch != NULL)
	{
		int i;
		int j;
		int index = 0;
		int match = 0;
		for(i = 0; i < aliasCount; i++) //iterate over alias table
		{
			for(j = 0; j < strlen(aliases[i]); j++) //get name
			{
				if(aliases[i][j] == '=') //everything beforehand is a name
				{
					index = j;
					break;
				}
			}
			if(index == 0)
			{
				//do nothing
			}
			else if(strncmp(pch, aliases[i], index) == 0 && index > 0) //equal to an alias name
			{
				match = 1;
				strcpy(result, aliasResolve(pch)); //get result of alias detection
				if(strcmp(result, "<LOOP>") == 0) //infinite loop
				{
					perror ("Attempting to perform infinite alias expansion.");
					printf ("Error at line %d\n", __LINE__);
					return;
				}
				break;
			}
			else
			{
				//do nothing
			}
		}
		if(match) //have a match
		{
			strcat(actualText2, result); 
			strcat(actualText2, " "); //convert back to original text
		}
		else //no match
		{
			strcat(actualText2, pch);
			strcat(actualText2, " "); //convert back to original text
		}
		pch = strtok(NULL, " ");
	}
	actualText2[strlen(actualText2) - 1] = '\0'; //null terminate and remove last space
	strcpy(actualText, actualText2);
	int index = 0;
	int i;
	int* results = malloc(300 * sizeof(int));
	int resultCount = 0;
	int opens = 0;
	int ends = 0;
	if (results == (int*) NULL) //error
	{
		perror ("Error with memory allocation.");
		printf ("Error at line %d\n", __LINE__);
		return;
	}
	for(i = 0; i < strlen(actualText); i ++)
	{
		if(actualText[i] == '$' && actualText[i + 1] == '{') //opener
		{
			index = i;
			results[resultCount] = index;
			resultCount++;
			opens++;
		}
		if(actualText[i] == '}') //closer
		{
			index = i;
			results[resultCount] = index;
			resultCount++;
			ends++;
		}
		if(ends > opens) //incorrect input
		{
			perror ("Error with input.");
			printf ("Error at line %d\n", __LINE__);
			return;
		}
	}
	if(opens != ends) //not balanced
	{
		perror ("Syntax error");
		printf ("Error at line %d\n", __LINE__);
		return;
	}
	char *result2 = malloc(300 * sizeof(char));
	if(result2 == (char*) NULL) //error
	{
		perror ("Error with memory allocation.");
		printf ("Error at line %d\n", __LINE__);
		return;
	}
	if(resultCount == 0) //no opens or ends
	{
		word_function(actualText);
	}
	else //opens and ends
	{
		strcpy(result2, "");
		char* result3 = malloc(300 * sizeof(char));
		if(result3 == (char*) NULL) //error
		{
			perror ("Error with memory allocation.");
			printf ("Error at line %d\n", __LINE__);
			return;
		}
		for(i = 0; i < resultCount; i++)
		{
			if(i == 0) //first open
			{
				strncat(result2, &actualText[0], results[0]); //add the beginning
				memcpy(result3, &actualText[results[0] + 2], (results[1] - results[0] - 2) * sizeof(char));
				if(getenv(result3) == NULL) //invalid environment variable
				{
					perror ("Entered an invalid environment variable.");
					printf ("Error at line %d\n", __LINE__);
					return;
				}
				strcpy(result3, getenv(result3));
				strcat(result2, result3);
				memset(result3, 0, sizeof(result3)); //clear buffer
			}
			else if(i % 2 == 0 && i != 0) //other opens
			{
				strncat(result2, &actualText[results[i - 1] + 1], results[i] - results[i - 1] - 1);
				strncpy(result3, &actualText[results[i] + 2], (results[i + 1] - results[i] - 2) * sizeof(char));
				if(getenv(result3) == NULL)
				{
					perror ("Entered an invalid environment variable.");
					printf ("Error at line %d\n", __LINE__);
					return;
				}
				strcpy(result3,getenv(result3));
				strcat(result2, result3);
				memset(result3, 0, sizeof(result3)); //clear buffer
			}
			else
			{
				//do nothing
			}
		}
		if(results[resultCount - 1] != strlen(actualText) - 1) //more left
		{
			strcat(result2, &actualText[results[resultCount - 1] + 1]); //add all the leftovers
			word_function(result2);
		}
		else
		{
			word_function(result2);
		}
	}
}
void word2Function(char* text)
{
	char* result = malloc(300 * sizeof(char));
	if(result == (char*) NULL) //error with memory allocation
	{
		perror ("Entered an invalid environment variable.");
		printf ("Error at line %d\n", __LINE__);
		return;
	}
	strcpy(result, tildeExpansion(text)); //get result of tilde expansion and reset
	word_function(result);
}
char* tildeExpansion(char* text)
{
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
			return getenv("HOME");
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
				return pwd->pw_dir; //username
			}
			else //string continues
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
				if(toadd == (char *) NULL)
				{
					perror("Error with memory allocation.");
					printf("Error at line %d\n", __LINE__);
					return;
				}
				strcpy(toadd, &text[index + 1]); //add everything after /
				strcat(directory, "/"); //add slash
				strcat(directory, toadd); //append
				return directory;
			}
		}
	}
	else //no tilde
	{
		return text;
	}
}
void changeGroupedSpacesIntoOneSpace(char* string){ //removes extra spaces in the word so that each word has one space between it
	int i = 0;
	int size = strlen(string);
	for(i = 0; i < size;){
		if(string[i] == ' ' && string[i+1] == ' '){
			int j = i + 1;
			for(j = i; j <=size; j++){
				string[j] = string[j+1];
			}
			size--;
		}
		else
			i++;
	}
}
