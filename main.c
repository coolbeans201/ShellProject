#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
void performLoop();
void setenv1(char * variable, char * word);
void printenv1();
void unsetenv1(char * variable);
void cd1(char * directory);
int searchEnvNames(char * variable);
int searchaliasNames(char * string);
void alias2();
void alias1(char * name, char * word);
void unalias1(char * name);
char envValues [100][300];
char envNames [100][300];
char aliasNames [100][300];
char aliasValues [100][300];
int aliasNamesIndex = 0;
int aliasNamesSize = 0;
int aliasValuesIndex = 0;
int aliasValuesSize = 0;
int envNameSize = 0;
int envNameIndex = 0;
int envValueSize = 0;
int envValueIndex = 0;
int main(int argc, char **argv, char **envp)
{
  char ** env;
  //for (env = envp; *env != 0; env++)
  //{
    //strcpy(envNames [envNameIndex],*env);
	//strcpy(envValues [envValueIndex],getenv(*env));
	//envValueSize++;
	//envValueIndex++;
	//envNameSize ++;
	//envNameIndex ++;
  //}
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
		int result = searchaliasNames(string);
		if(result == -1)
		{
			if(strcmp(string, "setenv") == 0)
			{
				char variable [100];
				printf("Please enter a variable: \n");
				gets(variable);
				char word [100];
				printf("Please enter a word: \n");
				gets(word);
				if(strcmp(variable, "") != 0 && strcmp(word, "") != 0)
				{
					setenv1(variable, word);
				}
				else
				{
					perror("Invalid input.\n");
				}
			}
			else if(strcmp(string, "printenv") == 0)
			{
				printenv1();
			}
			else if(strcmp(string, "unsetenv") == 0)
			{
				char variable [100];
				printf("Please enter a variable: \n");
				gets(variable);
				if(strcmp(variable, "") != 0)
				{
					(variable);
				}
				else
				{
					perror("Invalid input.\n");
				}
			}
			else if(strcmp(string, "cd") == 0)
			{
				char directory [100];
				printf("Please enter a directory: \n");
				gets(directory);
				//if there is second word
				if(strcmp(directory, "") != 0)
				{
					cd1(directory);
				}
				//no second word
				else
				{
					cd1("HOME");
				}
			}
			else if(strcmp(string, "alias") == 0)
			{
				char name [100];
				printf("Please enter a name: \n");
				gets(name);
				char word [100];
				printf("Please enter a word: \n");
				gets(word);
				if(strcmp(name, "") == 0 && strcmp(word, "") == 0)
				{
					alias2();
				}
				else if(strcmp(name, "") != 0 && strcmp(word, "") != 0)
				{
					alias1(name, word);
				}
				else
				{
					perror("Invalid input.\n");
				}
			}
			else if(strcmp(string, "unalias") == 0)
			{
				char name [100];
				printf("Please enter a name: \n");
				gets(name);
				if(strcmp(name, "") != 0)
				{
					unalias1(name);
				}
				else
				{
					perror("Invalid input.\n");
				}
			}
			else if(strcmp(string, "bye") == 0)
			{
				exit(0);
			}
			else
			{
				perror("Invalid input.\n");
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
void setenv1(char * variable, char * word)
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
void printenv1 ()
{
	int i = 0;
	while(i < envValueSize)
	{
		printf("%s = %s\n", envNames[i], envValues[i]);
		i++;
	}
}
void unsetenv1(char * variable)
{
	int result = searchEnvNames(variable);
	if(result == -1)
	{
		return;
	}
	//fully remove, give back original value, ??
	strcpy(envValues[result],"");
}
void cd1(char * directory)
{
	if(chdir(directory) == 1)
	{
		perror("Directory does not exist.\n");
	}
}
int searchaliasNames (char * string)
{
	int i = 0;
	while(i < aliasNamesSize)
	{
		if(strcmp(aliasNames[i], string) == 0)
		{
			return i;
		}
	}
	return -1;
}
void alias2()
{
	int i = 0;
	while(i < aliasNamesSize)
	{
		printf("%s\n", aliasNames[i]);
		i++;
	}
}
void alias1(char * name, char * word)
{
	int result = searchaliasNames(name);
	if(result != -1)
	{
		strcpy(aliasValues[result],word);
	}
	else
	{
		strcpy(aliasNames[aliasNamesIndex++],name);
		strcpy(aliasValues[aliasValuesIndex++],word);
		aliasNamesSize++;
		aliasValuesSize++;
	}
}
void unalias1(char * name)
{
	int result = searchaliasNames(name);
	if(result == -1)
	{
		perror("Cannot destroy alias that doesn't exist.\n");
	}
	else
	{
		int i = result;
		while (i < aliasNamesSize)
		{
			strcpy(aliasNames[i - 1],aliasNames[i]);
			strcpy(aliasValues[i - 1],aliasValues[i]);
		}
		aliasNamesSize--;
		aliasValuesSize--;
	}
}
