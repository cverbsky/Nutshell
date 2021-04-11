#include <stdlib.h>
#include <stdio.h>

void shell_init();
void printPrompt();
int getCommand();
void handle_errors();
void processCommand();

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
            exit(0);
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


}
void printPrompt()
{
    printf("$ or something");
}
int getCommand()
{
    // init_scanner-and_parser();
    int yyParseReturn = yyparse();
    if (yyParseReturn == 0)
        return 1;
    else if (yyParseReturn == 1)
        printf("Parsing failed: Invalid input");
    else if (yyParseReturn == 2)
        printf("Parsing failed: Memory exhaustion").

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
    // if builtin do one thing
    //otherwise execute command
}
