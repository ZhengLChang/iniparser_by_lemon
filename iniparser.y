%include{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include "iniparser.h"
}
%token_prefix INI_
%name iniparser
%extra_argument {char *current_section}
%token_type {char *}
%default_type {char *}
%syntax_error{
	fprintf(stderr, "Synatax Error!!!\n");
	exit(1);
}
main ::= in.
in ::= .
in ::= eol.
in ::= section.
in ::= expr.
eol ::= CR LF.
eol ::= LF.
section ::= LMIDDLEPARENT key(A) RMIDDLEPARENT eol.{
	strcpy(current_section, A);
	fprintf(stderr, "%s", current_section);
}
expr ::= key(A) EQ eol.{
	if(current_section == NULL)
	{
		fprintf(stderr, ":%s = \n", A);
	}
	else
	{
		fprintf(stderr, "%s:%s = \n", current_section, A);
	}
}
expr ::= key(A) EQ key(B) eol.{
	if(current_section == NULL || current_section[0] == '\0')
	{
		fprintf(stderr, ":%s = %s\n", A, B);
	}
	else
	{
		fprintf(stderr, "%s:%s = %s\n", current_section, A, B);
	}
}
key(A) ::= STRING(B).{
	A = B;
}

%code{
static int getToken(const char *z, int *token);
int main(int argc, char **argv)
{
	void *pParser = NULL;
	int tokenType = -1, n = -1;
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
	pParser = iniparserAlloc(malloc);
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
}




