Xin He
Matthew Weingarten
README
-------------------
Features NOT Implemented
1. Quotes being interpreted as one word (recursive YACC)
2. File name completion (using the ESC character in Lex/YACC)
3. Metacharacters (recursive YACC)    
4. Other commands (recirsive YACC, with I/O redirection and piping)
5. Alias commands (more YACC handling)
6. Tilde expansion, external matching, and explicit matching for other commands
7. Explicit matching for built-in commands
8. I/O redirection for built-in commands
9. Piping for built-in commands

Features Implemented
1. Built-in commands
2. I/O redirection base case
3. Environment variable expansion
4. Tilde expansion with built-in commands
5. Aliasing
6. Error messages 
7. Re-parsing with PATH (need to include cases of explicit matching)
8. External matching for built-in commands
9. Explicit matching base case
10. Piping base case
11. Infinite alias expansion detection

Questions
1. How to use YACC recursively?
2. Executing other commands
