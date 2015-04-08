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
  struct command
  {
      char **argv;
  };
  void unsetenv_function(char *text, int flag);
  void unalias_function (char *text, int flag);
  void setenv_function (char *text, char *text2, int flag);
  void alias_function(char *text, char *text2);
  void cd_function(void);
  void printenv_function(void);
  void cd_function2(char *text);
  int standard_error_redirect_function ();
  int standard_error_redirect_function2 (char *text);
  int write_to_function (char *text);
  int read_from_function (char *text);
  void word_function (char *text);
  void alias_function2(void);
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
  void shell_init(void);
  void changeGroupedSpacesIntoOneSpace(char* string);
  int append_function(char* text);
  void reset(void);
  void execute(void);
  void word3_function(char* text, int position);
  void printTextArray();
  char *fixText(char *orig, char *rep, char *with);
  void textArrayAliasExpansion(char* text, int position);
  int spawn_proc(int in, int out, struct command *cmd);
  int fork_pipes (int n, struct command *cmd);
  char** textArray; //words
  #endif
