#include "stdbool.h"
#include <limits.h>

struct evTable {
   char var[128][100];
   char word[128][100];
};

struct aTable {
	char name[128][100];
	char word[128][100];
};

char cwd[PATH_MAX];

struct evTable varTable;

struct aTable aliasTable;

int aliasIndex, varIndex;

char* subAliases(char* name);

struct argList {
        char* string;
        struct argList* next;
};

struct cTable {
    struct argList* args;
    int argCount;
    char argTable[128][100];
};

int tblIndex;
struct cTable commandTable[100];

char* inputFileName;
char* outputFileName;
bool inputFile;
bool outputFile;
bool inBackground;

bool processForked;
