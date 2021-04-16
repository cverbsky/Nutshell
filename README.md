# Nutshell
Ashlyn Comiskey and Christa Verbsky

## Features Not Implemented
WILDCARD MATCHING: not implemented at any level
ENVIRONMENTAL VARIABLE EXPANSION: not implemented at any level
USING PIPES WITH NON-BUILT IN COMMANDS: not implemented at any level
USING FILE I/O WITH NON-BUILT IN COMMANDS: not implemented at any level
RUNNING NON-BUILT IN COMMANDS IN THE BACKGROUND: partly implemented; non-built in commands are forked, and run in the background by default
NON-BUILT IN COMMANDS (GENERAL): partly implemented; shell accepts and runs non-built-in commands, but output is not sent to the console correctly

## Features Implemented
BUILT-IN COMMANDS: fully implemented; all specified built-in commands work as intended except environmental variable expansion
NON-BUILT IN COMMANDS: partially implemented; shell accepts and runs non-built-in commands, by searching PATH variable and forking to execv(), but output is not sent to the console correctly
RUNNING NON-BUILT IN COMMANDS IN THE BACKGROUND: partially implemented; non-built in commands are forked, and run in the background by default
FILE I/O (GENERAL): nutshell accepts input from a file (using < filename) or a pipe (using command|./nutshell syntax) and sends output to a file or a pipe in turn
ALIAS EXPANSION: nutshell correctly expands aliases and checks for loops
SHELL ROBUSTNESS: no known case found where shell crashes before “bye” command sent

## Distribution of Work
Ashlyn wrote the built-in command functionality. As she has experience with lexers and parsers from Programming Language Concepts, she assisted Christa with the layout of tokenization for other commands. She handled and tested general file I/O, and assisted with developing forking for execution.

Christa wrote the non-built in command functionality. She wrote the functions that intake non-built in commands and their arguments and created a persistent data structure to store them. She wrote the functionality that searches directories stored in the PATH variable, and helped develop and test forking for execution.

## Design
Within the shell, we implemented all the builtin commands outlined in the project specifications, as well as handling of non-builtin commands, file I/O redirection, alias expansion, and running commands in the background. The user input is lexed and parsed through Flex/Bison, and the main nutshell interface is written in C. The builtin commands are treated generally as individual tokens, with different functionality depending on the builtin given by the user. Alias expansion is handled within this builtin functionality as well. All other commands are handled through parsing the input to determine what actions should be taken. The commands that are accepted can either be relative or absolute paths, and will have any number of arguments. The majority of the work done by the shell is handled in the parser, and the shell is initialized and run through nutshell.c.

## Verification
To verify that the shell is functioning correctly, run “make” and then “./nutshell.o”. When the shell starts it should clear and prompt the user with “[nutshell]>>”. It will accept any of the specified builtin commands, or any other command in the following format: 	 	 		
cmd [arg]* [|cmd [arg]*]* [< fn1] [ >[>] fn2 ] [ 2>fn3 || 2>&1 ] [&]
The shell should then perform these commands similar to how the same commands would operate in a Linux shell, though output will not be displayed. Note that the shell cannot correctly accept piping, and piped commands may generate unexpected behavior. 

