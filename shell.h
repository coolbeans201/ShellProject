  #ifndef SHELL_H
  #define SHELL_H
  #include <stdio.h>
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
  #include <dirent.h>
  #include <glob.h>
  #define STRINGIFY(x) #x
  #define TOSTRING(x) STRINGIFY(x)
  #define AT __FILE__ ":" TOSTRING(__LINE__)
  #define TRUE 1
  #define FALSE 0
  void unsetenv_function(char *text, int flag);
  void unalias_function (char *text);
  void setenv_function (char *text, char *text2, int flag);
  void alias_function(char *text, char *text2);
  void cd_function(void);
  void printenv_function(void);
  void cd_function2(char *text);
  void standard_error_redirect_function ();
  void standard_error_redirect_function2 (char *text);
  void write_to_function (char *text);
  void read_from_function (char *text);
  void word_function (char *text);
  void alias_function2(void);
  void pipe_function(int numberOfPipes, int* pipes, int endOfCommand);
  int getWords(void);
  int getAliasCount(void);
  int globerr(const char* path, int eerrno);
  char* getDirectories(char *textmatch);
  void changeGroupedSlashesIntoOneSlash(char* string);
  void quoteFunction(char* text);
  void word2Function(char* text);
  char* tildeExpansion(char* text);
  char* aliasResolve(char* string);
  char* getAliasValue(char* aliasName);
  int checkForExecutableOrAlias(char* string);
  void shell_init(void);
  void changeGroupedSpacesIntoOneSpace(char* string);
  void append_function(char* text);
  void reset(void);
  void execute(void);
  void word3_function(char* text, int position);
  void printTextArray();
  void textArrayAliasExpansion(char* text, int position);
  char** textArray; //words
  #endif
