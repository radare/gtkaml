#include "GtkamlParser.h"
#include <stdio.h>

extern void yyrestart (FILE *input_file  );
extern FILE * yyin;
extern int yylineno;



void gtkaml_parser_resume_parsing (GtkamlParser * self, const char * buffer, gulong length)
{
	yyin = fopen ("/dev/null", "r");
	
	if (yyin == NULL) {
		printf ("Couldn't open source file: %s.\n", "/dev/null");
		return;
	}
	setvbuf (yyin, buffer, _IOFBF, length);
	
	/* restart line counter on each file */
	//yylineno = 1;
	
	yyrestart (yyin);
	fclose (yyin);
	yyin = NULL;	
}
