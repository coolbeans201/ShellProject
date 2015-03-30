Xin He
Matthew Weingarten
README
-------------------
Features NOT Implemented
1. File name completion (using the ESC character in Lex/YACC)    
2. Other commands (recirsive YACC, with I/O redirection and piping)
3. Alias commands (more YACC handling)
4. Tilde expansion, external matching, and explicit matching for other commands
5. Explicit matching for built-in commands
6. I/O redirection for built-in commands
7. Piping for built-in commands

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
12. Quotes being interpreted as one word
13. Metacharacters

Questions
1. Executing other commands
