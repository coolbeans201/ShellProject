#include "shell.h"
char** newTextArray; //copied words
int words = 0; //number of words
extern char** environ; //environment variables
char** aliases; //alias names and values
char** newAliases; //copied aliases
int aliasCount = 0; //number of aliases
struct passwd* pwd; //contains result of getpwnam
char* myPath;
char* myHome;
int savedOutput; //output channel
int savedInput; //input channel
int savedError; //error channel
void shell_init()
{
	myPath = malloc(500 * sizeof(char));
	if(myPath == (char *) NULL) //error
	{
		perror("Error with memory allocation.");
		printf("Error at line %d\n", __LINE__);
		return;
	}
	strcpy(myPath, getenv("PATH")); //get path directory so it stays constant
	myHome = malloc(500 * sizeof(char));
	if(myHome == (char *) NULL) //error
	{
		perror("Error with 																																																														memory allocation.");
		printf("Error at line %d\n", __LINE__);
		return;
	}
	strcpy(myHome, getenv("HOME")); //get home directory so that it stays constant
	//printf("%s\n", myHome);
	signal(SIGINT, SIG_IGN); //prevent crash from ctrl-c
	signal(SIGTSTP, SIG_IGN); //prevent crash from ctrl-z
	signal(SIGQUIT, SIG_IGN); //prevent crash from ctrl-/
}
void unsetenv_function(char *text, int flag)
{
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
	if(flag)
	{
		reset();
	}
}
void unalias_function(char *text)
{
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
	reset();
}
void setenv_function (char *text, char *text2, int flag)
{
	changeGroupedSlashesIntoOneSlash(text2); //switch it to actual correct text
	char *es;
	if (text == NULL || text[0] == '\0' || strchr(text, '=') != NULL || text2 == NULL) //check to see if valid
	{
		perror("Invalid argument.");
		printf("Error at line %d\n", __LINE__);
		return;
	}
	//printf("Here\n");
	unsetenv_function(text, 0);             /* Remove all occurrences */
	es = malloc(strlen(text) + strlen(text2) + 2);
	/* +2 for '=' and null terminator */
	if (es == NULL) //error
	{
		perror("Error with memory allocation");
		printf("Error at line %d\n", __LINE__);
		return;
	}
	//printf("There\n");
	if(strcmp(text, "PATH") == 0 || strcmp(text, "ARGPATH") == 0) //setting path
	{
		char *pch = strtok(text2, ":"); //split on colons
		char *path = malloc(500 * sizeof(char));
		if(path == (char *) NULL) //error
		{
			perror("Error with memory allocation.");
			printf("Error at line %d\n", __LINE__);
			return;
		}
		strcpy(path, "");
		while (pch != NULL) //still have tokens
		{
			char* directory = malloc(300 * sizeof(char));
			if(directory == (char*) NULL) //error
			{
				perror("Error with memory allocation.");
				printf("Error at line %d\n", __LINE__);
				return;
			}
			strcpy(directory, getenv("PWD"));
			if(pch[0] == '.')
			{
				if(strlen(pch) == 1) //just a dot
				{
					strcat(path, directory); //get current directory
					strcat(path, ":");
				}
				else if(strlen(pch) == 2 && pch[1] == '/') //just a dot-slash
				{
					strcat(path, directory); //get current directory
					strcat(path, ":");
				}
				else if(strlen(pch) > 2 && pch[1] == '/')
				{
					strcat(path, directory);
					strcat(path, &pch[2]);
					strcat(path, ":");
				}
				else if(pch[1] != '.') //append text after dot
				{
					strcat(path, directory);
					strcat(path, &pch[1]);
					strcat(path, ":");
				}
				else if(pch[1] == '.' && strcmp(directory, "/") != 0)//go up a level (not in the root)
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
						strncat(path, directory, lastSlashIndex);
					}
					else if(lastSlashIndex == 0)
					{//if .. is returning up to the root directory
						directory[1] = '\0';//sets index 1 to null so the directory sets to the root
						strcat(path, "/");
					}
					if(strlen(pch) > 2)
					{
						strcat(path, "/"); //add slash
						strcat(path, &pch[3]); //take everything after the slash
						strcat(path, ":");
					}
					else //nothing
					{
						strcat(path, "/"); //blank it
						strcat(path, ":");
					}
				}
				else if(strcmp(directory, "/") == 0)
				{//if it is in root
					strcat(path,"/"); //change text to empty string so ".." is not concatenated to the directory later on
					strcat(path, ":");
				}
			}
			if(pch[0] == '/') //first character is slash
			{
				if(strlen(pch) == 1 || (strlen(pch) == 2 && pch[1] == '.')) //just a slash or slash-dot
				{
					strcat(path, "/");
					strcat(path, ":");
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
					strcat(path, &pch[1]);
					strcat(path, ":");
				}
			}
			pch = strtok(NULL, ":");
		}
		path[strlen(path) - 1] = '\0'; //get rid of colon at the end
		strcpy(text2, path);
	}
	strcpy(es, text); //copy variable
	strcat(es, "="); //copy =
	strcat(es, text2); //copy value
	//printf("Here2\n");
	int result = putenv(es); //put into array
	//printf("There2\n");
	if(result == -1) //error
	{
		perror("Error inserting element into environment variable array");
		printf("Error at line %d\n", __LINE__);
		return;
	}
	if(flag)
	{
		reset();
	}
}
void alias_function(char *text, char *text2)
{
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
	reset();
}
void cd_function()
{
	int result = chdir(myHome); //get home directory and move to it
	if(result == -1) //error
	{
		perror("Directory not changed");
		printf("Error at line %d\n", __LINE__);
		return;
	}
	//printf("%s\n", myHome);
	setenv_function("PWD", myHome, 0); //change PWD
	//reset();
}
void cd_function2(char *text)
{
	changeGroupedSlashesIntoOneSlash(text); //alters the text so all grouped slashes now become one slash. ex. ////home///usr -> /home/usr
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
			setenv_function("PWD", "/", 0); //set to slash
			//printf("%s\n", getenv("PWD"));
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
		setenv_function("PWD", text, 0); //change PWD to absolute
		return;
	}
	if(strncmp(&directory[strlen(directory) - 1], "/", 1) == 0 && strlen(directory) != 1) //last character is a slash and directory isn't just "/"
	{
		directory[strlen(directory) - 1] = '\0'; //remove slash
		setenv_function("PWD", directory, 0); //change PWD to absolute
	}
	else
	{
		setenv_function("PWD", directory, 0); //change PWD to absolute
	}
	reset();
}
void standard_error_redirect_function()
{
	savedError = dup(2);
	int result = dup2(1, 2); //redirect output to standard error
	if (result == -1) //error
	{
		perror("Standard error not redirected to output");
		printf("Error at line %d\n", __LINE__);
		return;
	}
}
void standard_error_redirect_function2(char *text)
{
	char* text2 = malloc(300 * sizeof(char));
	if (text2 == (char *)NULL) //error
	{
		perror("Error with memory allocation.");
		printf("Error at line %d\n", __LINE__);
		return;
	}
	strcpy(text2, &text[2]); //get everything after >
	int out = open(text2, O_WRONLY | O_CREAT | O_TRUNC | S_IRUSR | S_IRGRP | S_IWGRP | S_IWUSR); //open file
	if(out == -1) //error
	{
		perror("File not created");
		printf("Error at line %d\n", __LINE__);
		return;
	}
	savedError = dup(2);
	int result = dup2(out, 2); //redirect standard error to output file
	if (result == -1) //error
	{
		perror("Standard error not redirected");
		printf("Error at line %d\n", __LINE__);
		return;
	}
}
void write_to_function(char *text)
{
	int out = open(text, O_WRONLY | O_CREAT | O_TRUNC | S_IRUSR | S_IRGRP | S_IWGRP | S_IWUSR); //open file
	if(out == -1) //error
	{
		perror("File not created");
		printf("Error at line %d\n", __LINE__);
		return;
	}
	savedOutput = dup(1);
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
	int in = open(text, O_RDONLY); //open file
	if(in == -1) //error
	{
		perror("File not opened");
		printf("Error at line %d\n", __LINE__);
		return;
	}
	savedInput = dup(0);
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
void printenv_function()
{
	char ** ep;
	for(ep = environ; *ep!= NULL; ep++)
	{
		printf("%s\n", *ep); //print everything line by line
	}
}
void alias_function2()
{
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
char* getDirectories(char* textmatch)
{
	int i;
	int flags = 0;
	glob_t *results;
	int ret;
	DIR *dir;
	struct dirent *ent;
	results = malloc(10 * sizeof(glob_t));
	if(results == (glob_t*) NULL) //error
	{
		perror("Error with memory allocation.");
		printf("Error at line %d\n", __LINE__);
		return;
	}
	if ((dir = opendir(getenv("PWD"))) != NULL) 
	{
		//printf("Opening %s\n", getenv("PWD"));
		/* print all the files and directories within directory */
		while ((ent = readdir (dir)) != NULL) 
		{
			flags |= (i > 1 ? GLOB_APPEND : 0);
			ret = glob(textmatch, flags, globerr, results); //glob expression
			if (ret != 0) //error
			{
				printf("Error with globbing\n");
				printf("Error at line %d\n", __LINE__);
				return "";
			}
		}
		int size = 0;
		//printf("%d\n", results->gl_pathc);
		for(i = 0; i < results->gl_pathc; i++)
		{
			//printf("%s\n", results->gl_pathv[i]);
			size += strlen(results->gl_pathv[i]) + 1;
		}
		char* result = malloc(size * sizeof(char));
		if(result == (char*) NULL) //error
		{
			perror("Error with memory allocation.");
			printf("Error at line %d\n", __LINE__);
			return;
		}
		strcpy(result, "");
		for(i = 0; i < results->gl_pathc; i++)
		{
			strcat(result, results->gl_pathv[i]);
			strcat(result, "$");
		}
		result[strlen(result) - 1] = '\0'; //null terminate
		globfree(results); //free glob expression
		closedir(dir); //close directory 
		return result;
	}
	else 
	{
		/* could not open directory */
		perror ("Cannot open directory");
		printf("Error at line %d\n", __LINE__);
		return "";
	}
	return "";
}
void pipe_function(int numberOfPipes, int* pipes, int endOfCommand)
{
	pid_t pid[numberOfPipes];
	int** myPipes = malloc(numberOfPipes * sizeof(int *));
	if (myPipes == (int**) NULL) //error
	{
		perror ("Error with memory allocation.");
		printf ("Error at line %d\n", __LINE__);
		return;
	}
	int i;
	for(i = 0; i < numberOfPipes; i++)
	{
		myPipes[i] = malloc(2 * sizeof(int));
		if (myPipes[i] == (int*) NULL) //error
		{
			perror ("Error with memory allocation.");
			printf ("Error at line %d\n", __LINE__);
			return;
		}
		int result = pipe(myPipes[i]);
		if(result == -1) //error
		{
			perror ("Error piping.");
			printf ("Error at line %d\n", __LINE__);
			return;
		}
	}
	int j;
	for(j = 0; j < numberOfPipes; j++)
	{
		pid[j] = fork();
		if(pid[j] == 0 && j == 0)
		{
			int k;
			int l;
			for(k = 0; k < numberOfPipes; k++)
			{
				for(l = 0; l < 2; l++)
				{
					int result = close(myPipes[k][l]); //close everything
					if(result == -1) //error
					{
						perror ("Error closing pipe end.");
						printf ("Error at line %d\n", __LINE__);
						return;
					}
				}
			}
			if(strcmp(aliasResolve(textArray[0]), "") != 0 && strcmp(aliasResolve(textArray[0]), "<LOOP>") != 0) //alias value associated with command name
			{
				//printf("Here\n");
				int numberOfSpaces = -1;
				char* result3 = malloc((strlen(aliasResolve(textArray[0])) + 1) * sizeof(char));
				if(result3 == (char*)NULL) //error
				{
					perror ("Error with memory allocation.");
					printf ("Error at line %d\n", __LINE__);
					return;
				}
				strcpy(result3, aliasResolve(textArray[0])); //replace command name with alias value
				char* result2 = malloc(300 * sizeof(char));
				if(result2 == (char*) NULL) //error
				{
					perror("Error with memory allocation.");
					printf("Error at line %d\n", __LINE__);
					return;
				}
				strcpy(result2, result3);
				//printf("%s\n", result);
				char* saved;
				char* pch = strtok_r(result3, " ", &saved); //parse by spaces for arguments
				while(pch != NULL)
				{
					numberOfSpaces++; //increment number of spaces
					pch = strtok_r(NULL, " ", &saved); 
				}
				//printf("%d\n", numberOfSpaces);
				char* arguments[pipes[0] + numberOfSpaces + 1]; //arguments for that specific process
				int i = 0;
				char* saved2;
				char* pch2 = strtok_r(result2, " ", &saved2); //parse by spaces for arguments
				//printf("%s\n", result);
				while(pch2 != NULL)
				{
					arguments[i] = pch2; //set argument equal to token
					//printf("%s\n", arguments[i]);
					i++;
					pch2 = strtok_r(NULL, " ", &saved2); 
				}
				int j;
				for(j = i; j < pipes[0] + numberOfSpaces; j++)
				{
					arguments[j] = textArray[j]; //take rest normally
				}
				arguments[pipes[0] + numberOfSpaces] = (char *)0; //null terminator
				int result = execvp(arguments[0], arguments); //execute
				if(result == -1) //error
				{
					perror("Error executing.");
					printf("Error at line %d\n", __LINE__);
					return;
				}
			}
			else if(strcmp(aliasResolve(textArray[0]), "") == 0) //no alias, so proceed as normal
			{
				//printf("Here\n");
				char* arguments[pipes[0] + 1];
				int i;
				for(i = 0; i < pipes[0]; i++)
				{
					arguments[i] = textArray[i]; //copy arguments
				}
				arguments[pipes[0]] = (char *)0; //null terminator
				//printf("There\n");
				int result = execvp(textArray[0], arguments);
				if(result == -1) //error
				{
					perror("Error executing.");
					printf("Error at line %d\n", __LINE__);
					return;
				}
			}
			else //infinite alias expansion
			{
				printf("Attempting to perform infinite alias expansion.\n");
				return;
			}
		}
		else if(pid[j] == 0 && j == numberOfPipes)
		{
			int result = dup2(myPipes[j - 1][0], STDIN_FILENO); //read from previous process
			if(result == -1) //error
			{
				perror ("Error reading from previous process.");
				printf ("Error at line %d\n", __LINE__);
				return;
			}
			result = dup2(myPipes[j][1], STDOUT_FILENO); //write to parent
			if(result == -1) //error
			{
				perror ("Error write to first process.");
				printf ("Error at line %d\n", __LINE__);
				return;
			}
			int k;
			int l;
			for(k = 0; k < numberOfPipes; k++)
			{
				for(l = 0; l < 2; l++)
				{
					int result = close(myPipes[k][l]); //close everything
					if(result == -1) //error
					{
						perror ("Error closing pipe end.");
						printf ("Error at line %d\n", __LINE__);
						return;
					}
				}
			}
			if(strcmp(aliasResolve(textArray[pipes[j] + 1]), "") != 0 && strcmp(aliasResolve(textArray[pipes[j] + 1]), "<LOOP>") != 0) //alias value associated with command name
			{
				char* result3 = malloc((strlen(aliasResolve(textArray[pipes[j] + 1])) + 1) * sizeof(char));
				if(result3 == (char*)NULL) //error
				{
					perror ("Error with memory allocation.");
					printf ("Error at line %d\n", __LINE__);
					return;
				}
				//printf("Here\n");
				int numberOfSpaces = -1;
				strcpy(result3, aliasResolve(textArray[pipes[j] + 1])); //replace command name with alias value
				char* result2 = malloc(300 * sizeof(char));
				if(result2 == (char*) NULL) //error
				{
					perror("Error with memory allocation.");
					printf("Error at line %d\n", __LINE__);
					return;
				}
				strcpy(result2, result3);
				//printf("%s\n", result);
				char* saved;
				char * pch = strtok_r(result3, " ", &saved); //parse by spaces for arguments
				while(pch != NULL)
				{
					numberOfSpaces++; //increment number of spaces
					pch = strtok_r(NULL, " ", &saved); 
				}
				//printf("%d\n", numberOfSpaces);
				char* arguments[endOfCommand - pipes[j] + numberOfSpaces];
				int i = pipes[j];
				char* saved2;
				char* pch2 = strtok_r(result2, " ", &saved2); //parse by spaces for arguments
				//printf("%s\n", result);
				while(pch2 != NULL)
				{
					arguments[i] = pch2; //set argument equal to token
					printf("%s\n", arguments[i]);
					i++;
					pch2 = strtok_r(NULL, " ", &saved2); 
				}
				int p;
				for(p = i; p < endOfCommand + numberOfSpaces; p++)
				{
					arguments[p] = textArray[p]; //take rest normally
				}
				arguments[endOfCommand + numberOfSpaces] = (char *)0; //null terminator
				int result = execvp(arguments[0], arguments); //execute
				if(result == -1) //error
				{
					perror("Error executing.");
					printf("Error at line %d\n", __LINE__);
					return;
				}
			}
			else if(strcmp(aliasResolve(textArray[pipes[j] + 1]), "") == 0) //no alias, so proceed as normal
			{
				char* arguments[endOfCommand - pipes[j]];
				int i;
				for(i = pipes[j] + 1; i < endOfCommand; i++)
				{
					arguments[i] = textArray[i]; //copy arguments
				}
				arguments[endOfCommand - pipes[j] - 1] = (char *)0; //null terminator
				int result = execvp(textArray[pipes[j] + 1], arguments);
				if(result == -1) //error
				{
					perror("Error executing.");
					printf("Error at line %d\n", __LINE__);
					return;
				}
			}
			else //infinite alias expansion
			{
				printf("Attempting to perform infinite alias expansion.\n");
				return;
			}
			exit(0);
		}
		else
		{
			int result = dup2(myPipes[j - 1][0], STDIN_FILENO);
			if(result == -1) //error
			{
				perror ("Error reading from previous process.");
				printf ("Error at line %d\n", __LINE__);
				return;
			}
			result = dup2(myPipes[j][1], STDOUT_FILENO);
			if(result == -1) //error
			{
				perror ("Error write to first process.");
				printf ("Error at line %d\n", __LINE__);
				return;
			}
			int k;
			int l;
			for(k = 0; k < numberOfPipes; k++)
			{
				for(l = 0; l < 2; l++)
				{
					int result = close(myPipes[k][l]); //close everything
					if(result == -1) //error
					{
						perror ("Error closing pipe end.");
						printf ("Error at line %d\n", __LINE__);
						return;
					}
				}
			}
			if(strcmp(aliasResolve(textArray[pipes[j] + 1]), "") != 0 && strcmp(aliasResolve(textArray[pipes[j] + 1]), "<LOOP>") != 0) //alias value associated with command name
			{
				char* result3 = malloc((strlen(aliasResolve(textArray[0])) + 1) * sizeof(char));
				if(result3 == (char*)NULL) //error
				{
					perror ("Error with memory allocation.");
					printf ("Error at line %d\n", __LINE__);
					return;
				}
				//printf("Here\n");
				int numberOfSpaces = -1;
				strcpy(result3, aliasResolve(textArray[pipes[j] + 1])); //replace command name with alias value
				char* result2 = malloc(300 * sizeof(char));
				if(result2 == (char*) NULL) //error
				{
					perror("Error with memory allocation.");
					printf("Error at line %d\n", __LINE__);
					return;
				}
				strcpy(result2, result3);
				//printf("%s\n", result);
				char* saved;
				char * pch = strtok_r(result3, " ", &saved); //parse by spaces for arguments
				while(pch != NULL)
				{
					numberOfSpaces++; //increment number of spaces
					pch = strtok_r(NULL, " ", &saved); 
				}
				//printf("%d\n", numberOfSpaces);
				char* arguments[pipes[j] - pipes[j - 1] + numberOfSpaces + 1];
				int i = pipes[j - 1];
				char* saved2;
				char* pch2 = strtok_r(result2, " ", &saved2); //parse by spaces for arguments
				//printf("%s\n", result);
				while(pch2 != NULL)
				{
					arguments[i] = pch2; //set argument equal to token
					printf("%s\n", arguments[i]);
					i++;
					pch2 = strtok_r(NULL, " ", &saved2); 
				}
				int p;
				for(p = i; p < pipes[j] - pipes[j - 1] + numberOfSpaces; p++)
				{
					arguments[p] = textArray[p]; //take rest normally
				}
				arguments[pipes[j] + pipes[j - 1] + numberOfSpaces] = (char *)0; //null terminator
				int result = execvp(arguments[0], arguments); //execute
				if(result == -1) //error
				{
					perror("Error executing.");
					printf("Error at line %d\n", __LINE__);
					return;
				}
			}
			else if(strcmp(aliasResolve(textArray[pipes[j]]), "") == 0) //no alias, so proceed as normal
			{
				char* arguments[pipes[0] + 1];
				int i;
				for(i = pipes[j] + 1; i < pipes[j] + 1; i++)
				{
					arguments[i] = textArray[i]; //copy arguments
				}
				arguments[endOfCommand] = (char *)0;
				int result = execvp(textArray[pipes[j] + 1], arguments);
				if(result == -1) //error
				{
					perror("Error executing.");
					printf("Error at line %d\n", __LINE__);
					return;
				}
			}
			else
			{
				printf("Attempting to perform infinite alias expansion.\n");
				return;
			}
			exit(0);
		}
	}
	int m;
	int n;
	for(m = 0; m < numberOfPipes; m++)
	{
		for(n = 0; n < 2; n++)
		{
			int result = close(myPipes[m][n]);
			if(result == -1) //error
			{
				perror ("Error closing pipe end.");
				printf ("Error at line %d\n", __LINE__);
				return;
			}
		}
		wait((int *) 0);
	}
}
int globerr(const char *path, int eerrno) //error
{
	perror ("Error with globbing\n");
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
	char* result = malloc(300 * sizeof(char));
	if (result == (char*) NULL) //error
	{
		perror ("Error with memory allocation.");
		printf ("Error at line %d\n", __LINE__);
		return;
	}
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
	char* result2 = malloc(300 * sizeof(char));
	if(result2 == (char*) NULL) //error with memory allocation
	{
		perror ("Error with memory allocation.");
		printf ("Error at line %d\n", __LINE__);
		return;
	}
	char* pch = strtok(text, ":"); //colon-separate
	strcpy(result2, "");
	while(pch != NULL) 
	{
		char* result = malloc(300 * sizeof(char));
		if(result == (char*) NULL) //error with memory allocation
		{
			perror ("Error with memory allocation.");
			printf ("Error at line %d\n", __LINE__);
			return;
		}
		strcpy(result, tildeExpansion(pch)); //get result of tilde expansion and reset
		strcat(result2, result);
		strcat(result2, ":"); //add colon
		pch = strtok(NULL, ":");
	}
	result2[strlen(result2) - 1] = '\0'; //remove last colon
	word_function(result2);
}
char* tildeExpansion(char* text)
{
	if(strncmp(text, "~", 1) == 0) //tilde expansion
	{
		int length = strlen(&text[1]); 
		if(length == 0) //empty afterwards, so get home directory
		{
			int result = chdir(myHome); //get home directory and move to it
			if(result == -1) //error
			{
				perror("Directory not changed");
				printf("Error at line %d\n", __LINE__);
				return;
			}
			return myHome;
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
				strcpy(directory, myHome); //start with home directory
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
int checkForExecutableOrAlias(char* string)
{
	char* result = malloc(300 * sizeof(char));
	if(result == (char *) NULL) //error
	{
		perror("Error with memory allocation.");
		printf("Error at line %d\n", __LINE__);
		return;
	}
	if(strcmp(getAliasValue(string), "") == 0) //does it have an alias?
	{
		printf("You don't have an alias.\n");
		printf("%s\n", myPath);
		char* saved;
		char* pch = strtok_r(myPath, ":", &saved);
		char* directory = malloc(300 * sizeof(char));
		if(directory == (char *) NULL) //error
		{
			perror("Error with memory allocation.");
			printf("Error at line %d\n", __LINE__);
			return;
		}
		strcpy(directory, getenv("PWD"));
		while(pch != NULL)
		{
			printf("%s\n", pch);
			char* result2 = malloc(500 * sizeof(char));
			if(result2 == (char *) NULL) //error
			{
				perror("Error with memory allocation.");
				printf("Error at line %d\n", __LINE__);
				return;
			}
			char* files = malloc(500*sizeof(char));
			cd_function2(pch);
			strcpy(files, getDirectories("*"));
			strcpy(result2, files);
			cd_function2(directory);
			printf("%s\n", result2);
			char* saved2;
			char* pch2 = strtok_r(result2, "$", &saved2);
			while(pch2 != NULL)
			{
				printf("%s\n", pch2);
				if(strcmp(string, pch2) == 0) //they are the same
				{
					return 1;
				}
				pch2 = strtok_r(NULL, "$", &saved2);
			}
			pch = strtok_r(NULL, ":", &saved);
		}
		return 0;
	}
	else
	{
		return 1;
	}
}
void append_function(char* text)
{
	int out = open(text, O_RDWR | O_APPEND | S_IRUSR | S_IRGRP | S_IWGRP | S_IWUSR); //open file
	if(out == -1) //error
	{
		perror("File not created");
		printf("Error at line %d\n", __LINE__);
		return;
	}
	savedOutput = dup(1);
	//printf("%d\n", SEEK_END);
	//lseek(out, 0, SEEK_END);
	int result = dup2(out, 1); //redirect output to file
	if (result == -1) //error
	{
		perror("Output not redirected");
		printf("Error at line %d\n", __LINE__);
		return;
	}
}
void reset()
{
	int result = dup2(savedInput, 0);
	if(result == -1) //error
	{
		perror("Input not redirected");
		printf("Error at line %d\n", __LINE__);
		return;
	}
	result = dup2(savedOutput, 1);
	if(result == -1) //error
	{
		perror("Output not redirected");
		printf("Error at line %d\n", __LINE__);
		return;
	}
	result = dup2(savedError, 2);
	if(result == -1) //error
	{
		perror("Error not redirected");
		printf("Error at line %d\n", __LINE__);
		return;
	}
	words = 0;
	memset(textArray, 0, sizeof(textArray));
}
void execute()
{
	//pipe_function("lol");
	int numberOfPipes = 0;
	int numberOfCommands = 0;
	int i;
	int indexOfRead = 0;
	int indexOfWrite = 0;
	int indexOfAppend = 0;
	int indexOfStandardError1 = 0;
	int indexOfStandardError2 = 0;
	int indexOfAmpersand = 0; 
	int endOfCommand = 0;
	int numberOfGlobs = 0;
	int* pipes = malloc(300 * sizeof(int));
	if(pipes == (int*) NULL) //error
	{
		perror("Error with memory allocation.");
		printf("Error at line %d\n", __LINE__);
		return;
	}
	int* globs = malloc(300 * sizeof(int));
	if(globs == (int*) NULL) //error
	{
		perror("Error with memory allocation.");
		printf("Error at line %d\n", __LINE__);
		return;
	}
	for(i = 0; i < words; i++)
	{
		if(strncmp(textArray[i], "*", 1) == 0 || strncmp(textArray[i], "?", 1) == 0) //begins with an * or ?
		{
			globs[numberOfGlobs] = i;
			numberOfGlobs++;
		}
		if(strcmp(textArray[i], "|") == 0) //it's a pipe
		{
			pipes[numberOfPipes] = i;
			numberOfPipes++;
		}
		if(strcmp(textArray[i], "<") == 0) //read in
		{
			indexOfRead = i;
		}
		if(strcmp(textArray[i], ">") == 0) //write to
		{
			indexOfWrite = i;
		}
		if(strcmp(textArray[i], ">>") == 0) //append
		{
			indexOfAppend = i;
		}
		if(strcmp(textArray[i], "2>&1") == 0) //standard error redirect 2
		{
			indexOfStandardError2 = i;
		}
		else if(strcmp(textArray[i], "2>") == 0) //standard error redirect 1
		{
			indexOfStandardError1 = i;
		}
		if(strcmp(textArray[i], "&") == 0)
		{
			indexOfAmpersand = i;
		}
	}
	//printf("%d\n", numberOfGlobs);
	char* saved3;
	for(i = 0; i < numberOfGlobs; i++)
	{
		char* result = malloc(strlen(getDirectories(textArray[globs[i]])) * sizeof(char));
		if(result == (char*) NULL) //error
		{
			perror("Error with memory allocation.");
			printf("Error at line %d\n", __LINE__);
			return;
		}
		strcpy(result, getDirectories(textArray[globs[i]]));
		printf("%s\n", result);
		char* pch = strtok_r(result, "$", &saved3); //parse to get each indiviual file
		int j = 0;
		while(pch != NULL)
		{
			word3_function(pch, globs[i] + j); //insert it a specified position
			printf("%s\n", textArray[globs[i] + j]);
			j++; //increment to move to next position in array
			pch = strtok_r(NULL, "$", &saved3);
		}
	}
	numberOfCommands = numberOfPipes + 1;
	int child;
	if((child = fork()) == -1) //error
	{
		perror("Error forking");
		printf("Error at line %d\n", __LINE__);
		return;
	}	
	if(child != 0) //in parent
	{
		if(indexOfAmpersand != 0) //there's an ampersand present
		{
			wait((int *) 0);
		}
	}
	else //in child
	{
		if(indexOfRead != 0) //there's a read present
		{
			read_from_function(textArray[indexOfRead + 1]); 
		}
		if(indexOfWrite != 0) //there's a write to present
		{
			write_to_function(textArray[indexOfWrite + 1]);
		}
		if (indexOfAppend != 0) //there's an append present
		{
			append_function(textArray[indexOfAppend + 1]);
		}
		if(indexOfStandardError2 != 0) //second standard error case present
		{
			standard_error_redirect_function();
		}
		if(indexOfStandardError1 != 0) //first standard error case present
		{
			standard_error_redirect_function2(textArray[indexOfStandardError2]);
		}
		if(numberOfPipes == 0) //no pipes, just this command
		{
			if(indexOfRead != 0) //take everything up until this 
			{
				endOfCommand = indexOfRead;
			}
			else if(indexOfWrite != 0) //no read from
			{
				endOfCommand = indexOfWrite;
			}
			else if(indexOfAppend != 0) //no read from
			{
				endOfCommand = indexOfAppend;
			}
			else if(indexOfStandardError2 != 0) //no other I/O redirection
			{
				endOfCommand = indexOfStandardError2;
			}
			else if(indexOfStandardError1 != 0) //no other I/O redirection
			{
				endOfCommand = indexOfStandardError1;
			}
			else if(indexOfAmpersand != 0) //no I/O redirection
			{
				endOfCommand = indexOfAmpersand;
			}
			else //just a command with no special components
			{ 
				endOfCommand = words;
			}
			char* result = malloc(300 * sizeof(char));
			if(result == (char*) NULL) //error
			{
				perror("Error with memory allocation.");
				printf("Error at line %d\n", __LINE__);
				return;
			}
			if(strcmp(aliasResolve(textArray[0]), "") != 0 && strcmp(aliasResolve(textArray[0]), "<LOOP>") != 0) //alias value associated with command name
			{
				//printf("Here\n");
				int numberOfSpaces = -1;
				strcpy(result, aliasResolve(textArray[0])); //replace command name with alias value
				char* result2 = malloc(300 * sizeof(char));
				if(result2 == (char*) NULL) //error
				{
					perror("Error with memory allocation.");
					printf("Error at line %d\n", __LINE__);
					return;
				}
				strcpy(result2, result);
				//printf("%s\n", result);
				char* saved;
				char * pch = strtok_r(result, " ", &saved); //parse by spaces for arguments
				while(pch != NULL)
				{
					numberOfSpaces++; //increment number of spaces
					pch = strtok_r(NULL, " ", &saved); 
				}
				//printf("%d\n", numberOfSpaces);
				char* arguments[endOfCommand + numberOfSpaces + 1];
				int i = 0;
				char* saved2;
				char* pch2 = strtok_r(result2, " ", &saved2); //parse by spaces for arguments
				//printf("%s\n", result);
				while(pch2 != NULL)
				{
					arguments[i] = pch2; //set argument equal to token
					//printf("%s\n", arguments[i]);
					i++;
					pch2 = strtok_r(NULL, " ", &saved2); 
				}
				int j;
				for(j = i; j < endOfCommand + numberOfSpaces; j++)
				{
					arguments[j] = textArray[j]; //take rest normally
				}
				arguments[endOfCommand + numberOfSpaces] = (char *)0; //null terminator
				int result = execvp(arguments[0], arguments); //execute
				if(result == -1) //error
				{
					perror("Error executing.");
					printf("Error at line %d\n", __LINE__);
					return;
				}
			}
			else if(strcmp(aliasResolve(textArray[0]), "") == 0) //no alias, so proceed as normal
			{
				char* arguments[endOfCommand + 1];
				int i;
				for(i = 0; i < endOfCommand; i++)
				{
					arguments[i] = textArray[i]; //copy arguments
				}
				arguments[endOfCommand] = (char *)0; //null terminator
				int result = execvp(textArray[0], arguments);
				if(result == -1) //error
				{
					perror("Error executing.");
					printf("Error at line %d\n", __LINE__);
					return;
				}
			}
			else
			{
				printf("Attempting to perform infinite alias expansion.\n");
				return;
			}
		}
		else //perform piping
		{
			pipe_function(numberOfPipes, pipes, endOfCommand);
		}
	}
	reset();
}
void word3_function(char* text, int position)
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
	printf("Here\n");
	memcpy ((char *) newTextArray, (char *) textArray, words*sizeof(char *)); //copy all entries from textArray into newTextArray
	int i;
	for(i = position; i < words - 1; i++) //shift everything afterwards to the right
	{
		memset(newTextArray[i + 1], '\0', sizeof(newTextArray[i + 1]));
		strcpy(newTextArray[i + 1], newTextArray[i]);
	}
	printf("There\n");
	newTextArray[position] = es; //word
	newTextArray[words+1] = NULL; //null entry
	textArray = newTextArray;
	words++; //increment index
}
