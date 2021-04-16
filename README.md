# Nutshell

Ashlyn Comiskey and Christa Verbsky

## Description



## Design 

Within this shell, we have implemented all the builtin commands outlined in the project specifications, as well as handling of non-builtin commands, file I/O redirection, alias expansion, and running commands in the background. The user input is lexed and parsed through Flex/Bison, and the main nutshell interface is written in C. The builtin commands are treated generally as individual tokens, with different functionality depending on the builtin given by the user. Alias expansion is handled within this builtin functionality as well. All other commands are handled through parsing the input to determine what actions should be taken. The commands that are accepted can either be relative or absolute paths, and will have any number of arguments. The majority of the work done by the shell is handled in the parser, and, the shell is initilaized and run through nutshell.c.

## Verification


