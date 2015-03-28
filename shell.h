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
  #include <regex.h>
  #define STRINGIFY(x) #x
  #define TOSTRING(x) STRINGIFY(x)
  #define AT __FILE__ ":" TOSTRING(__LINE__)
  void unsetenv_function(char *text);
  void unalias_function (char *text);
  void setenv_function (char *text, char *text2);
  void alias_function(char *text, char *text2);
  void cd_function(void);
  void printenv_function(void);
  void cd_function2(char *text);
  void standard_error_redirect_function (char *text, char *text2);
  void standard_error_redirect_function2 (char *text, char *text2);
  void write_to_function (char *text);
  void read_from_function (char *text);
  void word_function (char *text);
  void alias_function2(void);
  void pipe_function(char *text);
  int getWords(void);
  int getAliasCount(void);
  int getNumberOfDirectories(void);
  char** getDirectories(char *text);
  char** textArray; //words
  char** directories; //contains directories matching the pattern
  #endif
