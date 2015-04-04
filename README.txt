Xin He
Matthew Weingarten
README
-------------------
Features NOT Implemented
1. File name completion    
2. Other commands (piping)
3. Alias commands (more YACC handling)
4. Tilde expansion, external matching, and explicit matching for other commands

Features Implemented
1. Built-in commands
2. I/O redirection base case
3. Environment variable expansion
4. Tilde expansion with built-in commands
5. Aliasing
6. Error messages 
7. Re-parsing with PATH (need to include cases of explicit matching)
8. Explicit matching for built-in commands
9. External matching base case
10. Piping base case
11. Infinite alias expansion detection
12. Quotes being interpreted as one word
13. Metacharacters
14. Shell never crashes
15. I/O redirection with other commands

Questions
1. Metacharacters and \
