#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
void performLoop();
void setenv (char * variable, char * word);
void printenv();
void unsetenv(char * variable);
void cd(char * directory);
int searchEnvNames(char * variable);
int searchAliasNames(char * firstWord);
void alias();
void alias(char * name, char * word);
void unalias(char * name);
char ** envValues;
char ** envNames;
char ** aliasNames;
char ** aliasValues;
int aliasNamesIndex = 0;
int aliasNamesSize = 0;
int aliasValuesIndex = 0;
int aliasValuesSize = 0;
int envNameSize = 0;
int envNameIndex = 0;
int envValueSize = 0;
int envValueIndex = 0;
int main(int argc, char **argv, char** envp)
{
  char** env;
  for (env = envp; *env != 0; env++)
  {
    envNames [envNamesIndex] = *env;
	envValues [valueIndex] = getenv(*env);
	envValueSize++;
	envValueIndex++;
	envNameSize ++;
	envNameIndex ++;
  }
	performLoop();
	return 0;
}
void performLoop()
{
	char string[100];
	printf("Please enter a command: \n");
	gets(string);
	while(strcmp(string, "bye") != 0)
	{
		//parse and get first word
		int result = searchAliasNames(firstWord);
		if(result == -1)
		{
			if(strcmp(firstWord, "setenv") == 0)
			{
				setenv(variable, word);
			}
			else if(strcmp(firstWord, "printenv") == 0)
			{
				printenv();
			}
			else if(strcmp(firstWord, "unsetenv") == 0)
			{
				unsetenv(variable);
			}
			else if(strcmp(firstWord, "cd") == 0)
			{
				//if there is second word
				cd(directory);
				//no second word
				cd("HOME");
			}
			else if(strcmp(firstWord, "alias") == 0)
			{
				//if there is second word
				alias(name, word);
				//no second word
				alias();
			}
			else if(strcmp(firstWord, "unalias") == 0)
			{
				unalias(name);
			}
			else
			{
				exit();
			}
		}
		else
		{
				//a lot of work needs to be done
		}
		printf("Please enter a command: \n");
		gets(string);
	}
}
int searchEnvNames(char * variable)
{
	int i = 0;
	while(i < envValueSize)
	{
		if(strcmp(envNames[i], variable) == 0)
		{
			return i;
		}
	}
	return -1;
}
void setenv(char * variable, char * word)
{
	int i = 0;
	int result = searchEnvNames(variable);
	if(result == -1)
	{
		perror("Error: variable is not an environment variable\n");
	}
	else
	{
		strcpy(envValues[result],word);
	}
}
void printenv ()
{
	int i = 0;
	while(i < envValueSize)
	{
		printf("%s = %s\n", envNames[i], envValues[i]);
		i++;
	}
}
void unsetenv(char * variable)
{
	int result = searchEnvNames(variable);
	if(result == -1)
	{
		return;
	}
	//fully remove, give back original value, ??
	values[result] = ?
}
void cd(char * directory)
{
	chdir(directory);
}
int searchAliasNames (char * firstWord)
{
	int i = 0;
	while(i < aliasNamesSize)
	{
		if(strcmp(aliasNames[i], firstWord) == 0)
		{
			return i;
		}
	}
	return -1;
}
void alias()
{
	int i = 0;
	while(i < aliasNameSize)
	{
		printf("%s\n", aliasNames[i]);
		i++;
	}
}
void alias(char * name, char * word)
{
	int result = searchAliasNames(name);
	if(result != -1)
	{
		strcpy(aliasValues[i],word);
	}
	else
	{
		aliasNames[aliasNamesIndex++] = name;
		aliasValues[aliasValuesIndex++] = word;
		aliasNamesSize++;
		aliasValuesSize++;
	}
}
void unalias(char * name)
{
	int result = searchAliasNames(name);
	if(result == -1)
	{
		perror("Cannot destroy alias that doesn't exist.\n");
	}
	else
	{
		int i = result;
		while (i < aliasNamesSize)
		{
			aliasNames[i - 1] = aliasNames[i];
			aliasValues[i - 1] = aliasValues[i];
		}
		aliasNamesSize--;
		aliasValuesSize--;
	}
}
