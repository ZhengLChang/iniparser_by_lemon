%include{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <assert.h>
#include "iniparser.h"
}
%token_prefix INI_
%name iniparser
%extra_argument {char *current_section}
%token_type {char *}
//%default_type {char *}
%type key {char *}
//%default_destructor {
//	fprintf(stderr, "default_destructor, will destructor: %s\n", $$);
//	free($$);
//}
%token_destructor{
	if($$)
	{
//		fprintf(stderr, "token_destructor, will destructor: %s(%x)\n", $$, $$);
//		free($$);
	}
}
%default_destructor {
//	fprintf(stderr, "default_destructor, will destructor: %s\n", $$);
//	free($$);
}
/*
%destructor main {
	fprintf(stderr, "destructor main, will destructor: %s\n", $$);
//	free($$);
}
%destructor in {
	fprintf(stderr, "destructor in, will destructor: %s\n", $$);
//	free($$);
}
%destructor input {
	fprintf(stderr, "destructor input, will destructor: %s\n", $$);
	free($$);
}
%destructor section {
	fprintf(stderr, "destructor section, will destructor: %s\n", $$);
	free($$);
}
%destructor expr {
	fprintf(stderr, "destructor expr, will destructor: %s\n", $$);
//	free($$);
}
%destructor key {
	fprintf(stderr, "destructor key, will destructor: %s\n", $$);
//	free($$);
}
*/
%syntax_error{
	fprintf(stderr, "Synatax Error!!!\n");
	exit(1);
}
/*
main ::= in.
in ::= .
in ::= eol.
in ::= section.
in ::= expr.
*/
input ::= section.
input ::= expr.
input ::= .
input ::= eol.
eol ::= CR LF.
eol ::= LF.
section ::= LMIDDLEPARENT key(A) RMIDDLEPARENT eol.{
	strcpy(current_section, A);
	free(A);
	//fprintf(stderr, "%s\n", current_section);
}
expr ::= key(A) EQ eol.{
	if(current_section == NULL || current_section[0] == '\0')
	{
		fprintf(stderr, ":%s = \n", A);
		free(A);
	}
	else
	{
		fprintf(stderr, "%s:%s = \n", current_section, A);
		free(A);
	}
}
expr ::= key(A) EQ key(B) eol.{
	if(current_section == NULL || current_section[0] == '\0')
	{
		fprintf(stderr, ":%s = %s\n", A, B);
		free(A);
		free(B);
	}
	else
	{
		fprintf(stderr, "%s:%s = %s\n", current_section, A, B);
		free(A);
		free(B);
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
}




