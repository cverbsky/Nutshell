#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "global.h"
#include <unistd.h>
#include<fcntl.h>

void shell_init();
void printPrompt();
int getCommand();
void handle_errors();
void processCommand();
char *getcwd(char *buf, size_t size);

int yyparse();

int main()
{
    shell_init();

    while(1)
    {
        printPrompt();
        // command = -1 for ERROR, 0 for BYE and 1 for OK
        int command = getCommand();
        if (command == -1)
            handle_errors();
        else if (command == 1)
            processCommand();
        else if (command == 0)
            exit(0); // redundant, exit likely handled in parser
    }
}

void shell_init()
{
    /* TAKEN FROM LECTURE 23 POWERPOINT */
    // init all variables.
    // define (allocate storage) for some var/tables
    // init all tables (e.g., alias table, command table)
    // get PATH environment variable (use getenv())
    // get HOME env variable (also use getenv())
    // disable anything that can kill your shell.
    // (the shell should never die; only can be exit)
    // do anything you feel should be done as init

    aliasIndex = 0;
    varIndex = 0;

    getcwd(cwd, sizeof(cwd));

    strcpy(varTable.var[varIndex], "PWD");
    strcpy(varTable.word[varIndex], cwd);
    varIndex++;
    strcpy(varTable.var[varIndex], "HOME");
    strcpy(varTable.word[varIndex], cwd);
    varIndex++;
    strcpy(varTable.var[varIndex], "PROMPT");
    strcpy(varTable.word[varIndex], "nutshell");
    varIndex++;
    strcpy(varTable.var[varIndex], "PATH");
    strcpy(varTable.word[varIndex], ".:/bin");
    varIndex++;

    // initialize command table
    commandTable.argCount = 0;

    inputFile = false;
    outputFile = false;
    inBackground = false;

    system("clear");
}
void printPrompt()
{
    printf("[%s]>> ", varTable.word[2]);;
}
int getCommand()
{
    // init_scanner-and_parser();
    int yyParseReturn = yyparse();
    if (yyParseReturn == 1)
        return 1;
    else
        printf("Parsing failed");
    return -1;
}
void handle_errors()
{
    /* TAKEN FROM LECTURE 23 POWERPOINT */
    // Find out if error occurred in middle of command,
    // that is, the command still has a “tail”
    // In this case you have to recover by “eating”
    // the rest of the command.
    // To do this: you may want to use yylex() directly, or
    // handle clear things up in any other way.

}
void processCommand()
{
    // builtins handled within parser

}
