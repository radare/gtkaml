/* GtkamlParser_resume_parsing.c
 * 
 * Copyright (C) 2008 Vlad Grecescu
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public
 * License along with main.c; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor Boston, MA 02110-1301,  USA
 *
 * Author:
 *        Vlad Grecescu (b100dian@gmail.com)
 */
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
