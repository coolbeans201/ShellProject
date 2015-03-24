Xin He
Matthew Weingarten
README
-------------------
Features NOT Implemented
1. Wildcard matching (system call to handle this case?)
2. Quotes being interpreted as one word (recursive YACC)
3. Re-parsing with PATH (some implementation, unsure what to do next)
4. File name completion (using the ESC character in Lex/YACC)
5. Metacharacters       (recursive YACC)
6. Piping               
7. Other commands     (recirsive YACC, with I/O redirection and piping)
8. Alias commands/infinite alias expansion (more YACC handling)

Features Implemented
1. Built-in commands
2. I/O redirection
3. Environment variable expansion
4. Tilde expansion with built-in commands
5. Aliasing
6. Error messages 
7. Re-parsing with PATH (need to include cases of explicit matching)

Questions
1. How to use YACC recursively?
2. How to integrate shell.c file into YACC and Lex? (if necessary)
3. Writing Makefile to accomplish this (if necessary)
4. System calls to handle wildcard matching
5. Executing other commands
