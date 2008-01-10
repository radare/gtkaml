/* -*- Mode: C; indent-tabs-mode: t; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * gtkaml
 * Copyright (C) Vlad Grecescu 2007 <b100dian@gmail.com>
 * 
 * gtkaml is free software.
 * 
 * You may redistribute it and/or modify it under the terms of the
 * GNU General Public License, as published by the Free Software
 * Foundation; either version 2 of the License, or (at your option)
 * any later version.
 * 
 * main.c is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with main.c.  If not, write to:
 * 	The Free Software Foundation, Inc.,
 * 	51 Franklin Street, Fifth Floor
 * 	Boston, MA  02110-1301, USA.
 */

#include <stdio.h>
#include <string.h>

#include "gtkaml-saxparser.h"

int main()
{
	char buffer[] = "\
<Gtk:Window xmlns='http://gtkaml.org/0.1/glib-2.0' xmlns:Gtk='gtk+-2.0'>\
	<![CDATA[\
		ala bala = portocala;\
	]]>\
	<Gtk:Label text='gogu' id='gigel&lt;'/>\
	<Gtk:Label text='gigel'/>\
	<![CDATA[\
		ala2 bala2 = portocala2;\
	]]>\
</Gtk:Window>";
	
	GString * result = gtkaml_parse_sax2_test( buffer, strlen(buffer) );
	
	printf("%s", result->str );
	
	g_string_free( result, TRUE );
	
	return (0);
}
