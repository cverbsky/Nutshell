# Nutshell

Ashlyn Comiskey and Christa Verbsky

## Description



## Design 

Within this shell, we have implemented all the builtin commands outlined in the project specifications, as well as handling of non-builtin commands, file I/O redirection, piping, alias expansion, and running commands in the background. The user input is lexed and parsed through Flex/Bison, and the main nutshell interface is written in C. The builtin commands are treated generally as individual tokens, with different functionality depending on the builtin given by the user. Alias expansion is handled within this builtin functionality as well. 

## Verification


