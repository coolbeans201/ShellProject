Xin He
Matthew Weingarten
README
-------------------
Features NOT Implemented
1. Wildcard matching (system call to handle this case?)
2. Quotes being interpreted as one word (recursive YACC)
3. Re-parsing with PATH (recursive YACC)
4. File name completion (using the ESC character in Lex/YACC)
5. Metacharacters       (recursive YACC)
6. Piping               
7. Special commands     (recirsive YACC)
8. Tilde expansion (not completely)
9. Alias commands/infinite alias expansion (more YACC handling)
10. Other commands (executing)

Features Implemented
1. Built-in commands (with I/O redirection)
2. I/O redirection
3. Environment variable expansion
4. Tilde expansion (some)
5. Aliasing
6. Error messages (are we handling them correctly?)

Questions
1. How to use YACC recursively?
2. How to integrate shell.c file into YACC and Lex? (if necessary)
3. Writing Makefile to accomplish this (if necessary)
4. System calls to handle wildcard matching
5. Executing other commands
