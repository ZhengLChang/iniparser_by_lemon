#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <assert.h>
#include "iniparser.h"

static int getToken(const char *z, int *token);
int main(int argc, char **argv)
{
	void *pParser = NULL;
	int tokenType = 0, n = -1;
	char line[1024] = "", *p = NULL;
	char context[1024] = "";
	FILE *fp = NULL;
	int i = 0;
	if(argc != 2)
	{
		fprintf(stderr, "usage: %s inifileName\n", argv[0]);
		return -1;
	}
	if((fp = fopen(argv[1], "r")) == NULL)
	{
		fprintf(stderr, "%s %d, fopen error\n", __func__, __LINE__);
		return -1;
	}
	pParser = (void *)iniparserAlloc(malloc);
	while(fgets(line, sizeof(line), fp) != NULL)
	{
		char *str = NULL;
		n = 0;
		p = line;
		while(p[i] != '\0')
		{
			n = getToken(p, &tokenType);
			if(tokenType == INI_STRING)
			{
				str = strndup(p, n);
				str[n] = '\0';
			}
			if(tokenType > 0)
			{
				iniparser(pParser, tokenType, str, context);
				p += n;
			}
			else
			{
				p++;
			}
			if(tokenType == INI_LF)
			{
				iniparser(pParser, 0, NULL, context);
			}
		}
	}
	iniparserFree(pParser, free);
	fclose(fp);
	return 0;
}
static int getToken(const char *z, int *token)
{
	int i = 0;
	switch(*z)
	{
		case '\r':
			*token = INI_CR;
			return 1;
			break;
		case '\n':
			*token = INI_LF;
			return 1;
			break;
		case '=':
			*token = INI_EQ;
			return 1;
			break;
		case '[':
			*token = INI_LMIDDLEPARENT;
			return 1;
			break;
		case ']':
			*token = INI_RMIDDLEPARENT;
			return 1;
			break;
		case ' ':
		case '\t':
		{
			*token = -1;
			return 1;
		}
		default:
		{
			for(i = 1; z[i] != ']' && z[i] != '=' &&
					z[i] != '\0' && z[i] != '\r' &&
					z[i] != '\n'; i++)
			{}
			*token = INI_STRING;
			return i;
		}
	}
}

