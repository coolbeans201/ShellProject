Xin He
Matthew Weingarten
README
-------------------
Features NOT Implemented
1. Wildcard matching (system call to handle this case?)
2. Quotes being interpreted as one word (recursive YACC)
3. File name completion (using the ESC character in Lex/YACC)
4. Metacharacters       (recursive YACC)
5. Piping               
6. Other commands     (recirsive YACC, with I/O redirection and piping)
7. Alias commands/infinite alias expansion (more YACC handling)
8. Tilde expansion and external matching for other commands

Features Implemented
1. Built-in commands
2. I/O redirection
3. Environment variable expansion
4. Tilde expansion with built-in commands
5. Aliasing
6. Error messages 
7. Re-parsing with PATH (need to include cases of explicit matching)
8. External matching for built-in commands

Questions
1. How to use YACC recursively?
2. How to integrate shell.c file into YACC and Lex? (if necessary)
3. System calls to handle wildcard matching?
4. Executing other commands
