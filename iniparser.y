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
//	UNUSED_PARAMETER(yymajor);  /* Silence some compiler warnings */

	if( TOKEN ){
		fprintf(stderr, "near \"%s\", type %d: syntax error\n", TOKEN, yymajor);
	}
	else
	{
		fprintf(stderr, "type %d: syntax error\n", yymajor);
	}
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




