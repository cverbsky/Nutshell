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
%}

%union {char *string;}

%start cmd_line
%token <string> BYE LS CD PRINTENV SETENV UNSETENV STRING ALIAS UNALIAS END

%%
cmd_line    :
	BYE END 		                { exit(1); return 1; }
	| CD STRING END        			{ runCD($2); return 1; }
	| LS END				{ runLS(varTable.word[0]); return 1; }
	| LS STRING END				{ runLS($2); return 1; }
	| SETENV STRING STRING END		{ runSetEnv($2, $3); return 1; }
	| PRINTENV END				{ runPrintEnv(); return 1; }
	| UNSETENV STRING END			{ runUnsetEnv($2); return 1; }
	| ALIAS STRING STRING END		{ runSetAlias($2, $3); return 1; }
	| ALIAS END				{ runAlias(); return 1; }
	| UNALIAS STRING END			{ runUnsetAlias($2); return 1; } 

%%

int yyerror(char *s) {
  printf("%s is an unknown command\n",s);
  return 0;
  }

int runCD(char* arg) {
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

int runSetAlias(char *name, char *word) {
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
