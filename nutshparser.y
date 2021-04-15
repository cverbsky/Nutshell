%{
// This is ONLY a demo micro-shell whose purpose is to illustrate the need for and how to handle nested alias substitutions and how to use Flex start conditions.
// This is to help students learn these specific capabilities, the code is by far not a complete nutshell by any means.
// Only "alias name word", "cd word", and "bye" run.
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include "global.h"
#include <dirent.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>


int yylex(void);
int yyerror(char *s);
int runCD(char* arg);
int runSetAlias(char *name, char *word);
int runAlias(void);
int runUnsetAlias(char *name);
int runLS(char* arg);
int runSetEnv(char* name, char *word);
int runPrintEnv(void);
int runUnsetEnv(char* name);
int initializeCommand(void); 
int pipeToNext(void); 
int addToArgList(char *word);
int inputFileExists(char *word);
int outputFileExists(char *word);
int errorFileRedirect(char *word);
int errorRedirect(void);
int operateInBack(void);
%}

%union {char *string;}

%start cmd_line
%token <string> BYE LS CD PRINTENV SETENV UNSETENV STRING ALIAS UNALIAS END PIPE INSTREAM ERRSTREAM OUTSTREAM ERROUT BGIND

%%
	
cmd_line    :
	BYE END 		                		{ exit(1); return 1; }
	| CD STRING END        			{ runCD($2); return 1; }
	| LS END					{ runLS(varTable.word[0]); return 1; }
	| LS STRING END				{ runLS($2); return 1; }
	| SETENV STRING STRING END		{ runSetEnv($2, $3); return 1; }
	| PRINTENV END				{ runPrintEnv(); return 1; }
	| UNSETENV STRING END			{ runUnsetEnv($2); return 1; }
	| ALIAS STRING STRING END			{ runSetAlias($2, $3); return 1; }
	| ALIAS END				{ runAlias(); return 1; }
	| UNALIAS STRING END			{ runUnsetAlias($2); return 1; } 
	| nonbuiltin_command			{return 1;}


// something other than a builtin command:	

nonbuiltin_command		:
	| pipestream END					{return 1; } // command or piped series of commands
	| pipestream io_stream END			{return 1; } // piped series of commands with file IO
	| pipestream background_indicator END		{return 1; } // execute in BG (w/o IO)
	| pipestream io_stream background_indicator END 	{return 1; } // execute in BG (w IO)

pipestream	:
	command			{initializeCommand();}
	| command PIPE command	{initializeCommand(); pipeToNext();} //allows infinitely chained piped commands

command  :
	command STRING		{printf("Made it here"); addToArgList($2);}
	| STRING			{addToArgList($1);}

io_stream	:
	input_stream output_stream error_stream		{}
	| input_stream	output_stream			{}
	| input_stream error_stream			{} 
	| output_stream error_stream			{}
	| input_stream					{}
	| output_stream					{}
	| error_stream					{}

input_stream	:
	INSTREAM STRING		{inputFileExists($2);} 

output_stream	:
	OUTSTREAM STRING			{outputFileExists($2);} //case where there is one >
	| OUTSTREAM OUTSTREAM STRING	{outputFileExists($3);} //case where there are two >

error_stream:
	ERRSTREAM STRING		{errorFileRedirect($2);} //case where error is redirected to a file
	| ERRSTREAM ERROUT	{errorRedirect();} //case where error is redirected to console

background_indicator:
	BGIND				{operateInBack();}


%%

int yyerror(char *s) 
{
  printf("%s is an unknown command\n",s);
  return 0;
 }

int runCD(char* arg) 
{
	if (arg[0] != '/') { // arg is relative path
		strcat(varTable.word[0], "/");
		strcat(varTable.word[0], arg);

		if(chdir(varTable.word[0]) == 0) {
			return 1;
		}
		else {
			getcwd(cwd, sizeof(cwd));
			strcpy(varTable.word[0], cwd);
			printf("Directory not found\n");
			return 1;
		}
	}
	else { // arg is absolute path
		if(chdir(arg) == 0){
			strcpy(varTable.word[0], arg);
			return 1;
		}
		else {
			printf("Directory not found\n");
                       	return 1;
		}
	}
}

int runSetAlias(char *name, char *word) 
{
	for (int i = 0; i < aliasIndex; i++) {
		if(strcmp(name, word) == 0){
			printf("Error, expansion of \"%s\" would create a loop.\n", name);
			return 1;
		}
		else if((strcmp(aliasTable.name[i], name) == 0) && (strcmp(aliasTable.word[i], word) == 0)){
			printf("Error, expansion of \"%s\" would create a loop.\n", name);
			return 1;
		}
		else if(strcmp(aliasTable.name[i], name) == 0) {
			strcpy(aliasTable.word[i], word);
			return 1;
		}
	}
	strcpy(aliasTable.name[aliasIndex], name);
	strcpy(aliasTable.word[aliasIndex], word);
	aliasIndex++;

	return 1;
}

int runAlias(void)
{
	printf("Current aliases:\n");
	for(int c = 0; c < 128; c++)
	{
		if(aliasTable.name[c][0] != '\0')
			printf("%s: %s\n", aliasTable.name[c], aliasTable.word[c]);
	}
	return 1;
}

int runUnsetAlias(char* name)
{
	char removedname[100];
	for(int c = 0; c < 128; c++)
	{
		if(strcmp(name, aliasTable.word[c]) == 0)
		{
			strcpy(removedname, aliasTable.name[c]);
			aliasTable.name[c][0] = '\0';
			printf("Successfully removed %s from the alias table.\n", removedname);
			return 1;
		} 
	}

	printf("Could not find %s in the alias table.\n", name);
	return 1;	
}

int runLS(char* arg)
{
	DIR *dir;
	struct dirent *entry;
	int count;
	//char filename[1025];
	if((dir = opendir(arg)) == NULL)
	{
		fprintf(stderr, "error opening directory %s", arg);
		return 1;
	}
	else
	{
		while((entry = readdir(dir)) != NULL)
		{
			if(entry->d_name[0] != '.')
			{
				//strcpy(filename, entry->d_name);
				printf("%s\n", entry->d_name);
			}
		}
	}
	return 1;
}

int runSetEnv(char* name, char* word)
{
	if(strcmp(name, word) == 0)
	{
		printf("Error: setting %s to itself would create a loop during expansion.\n", name);
		return 1;
	}

	//bool set = false;
	for(int c = 0; c < 128; c++)
	{
		if(strcmp(name, varTable.var[c]) == 0 && strcmp(word, varTable.word[c]) == 0)
		{
			printf("Error: this expansion would cause a loop.\n");
			return 1;
		}
		if(strcmp(name, varTable.var[c]) == 0)
		{
			printf("Reset %s from %s to %s.\n", name, varTable.word[c], word);
			strcpy(varTable.word[c], word);
			return 1;
		}
	}
	strcpy(varTable.var[varIndex], name);
	strcpy(varTable.word[varIndex], word);
	varIndex++;
	return 1;
}

int runPrintEnv(void)
{
	printf("Current environmental variables:\n");
	for(int c = 0; c < 128; c++)
	{
		if(varTable.var[c][0] != '\0')
			printf("%s=%s\n", varTable.var[c], varTable.word[c]);
	}

	return 1;
}

int runUnsetEnv(char* name)
{
	for(int c = 0; c <= varIndex; c++)
	{
		if(strcmp(name, varTable.var[c]) == 0)
		{
			if (c < 4)
			{
				printf("%s is a protected environment variable and cannot be unset.\n", name);
				return 1;
			}

			printf("Removed %s from the environmental variable table.\n", name);
			varTable.var[c][0] = '\0';
			return 1;
		}
	}
	printf("Could not find a variable named %s in the environmental variable table.\n", name);
	return 1;
}


/*** Command Functions ***/

int addToArgList(char *word) 
{
	strcpy(commandTable.argTable[commandTable.argCount], word);	
	commandTable.argCount++;
	
	return 1;
}

int initializeCommand()
{
	char* thisArgs[commandTable.argCount+1];

	if (commandTable.argTable[0][0] != '/') { // arg is relative path
		char* path = (char*) malloc(2 + strlen(varTable.word[1]) + strlen(commandTable.argTable[0]));
		strcpy(path, varTable.word[1]);
		strcat(path, "/");
		strcat(path, commandTable.argTable[0]);
		printf("%s", path);
	
		strcpy(thisArgs[0], path);
		for (int i = 1; i < commandTable.argCount; i++)
			strcpy(thisArgs[i], commandTable.argTable[i]);
		
		thisArgs[commandTable.argCount] = NULL;

		if(execv(path, thisArgs) != 0)
			return 1;
		else {
			printf("Unable to execute command.\n");
                       	return 1;
		}
	}
	else { // arg is absolute path
		for (int i = 0; i < commandTable.argCount; i++)
			strcpy(thisArgs[i], commandTable.argTable[i]);
		
		thisArgs[commandTable.argCount] = NULL;

		if(execv(thisArgs[0], thisArgs)  != 0)
			return 1;
		else {
			printf("Unable to execute command.\n");
                       	return 1;
		}
	}

	return 1;
}
int pipeToNext()
{
	// pipe here
	int fd[2];
	if (pipe(fd) == -1)
	{
		printf("Pipe Failed\n");
                 return 1;
	}

	
	

	return 1;
}

int inputFileExists(char *word)
{
	commandTable.inputFileName = word;
	return 1;
}
int outputFileExists(char *word)
{
	commandTable.outputFileName = word;
	return 1;
}

int errorFileRedirect(char *word)
{
	int file = open(word, O_WRONLY);
         dup2(file, 2);
	return 1;
}
int errorRedirect()
{
	dup2(1, 2);
	return 1;
}

int operateInBack() {
	inBackground = true;
	return 1;
}
