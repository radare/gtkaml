/* gtkamlmarkupnamespace.vala
 *
 * Copyright (C) 2011 Vlad Grecescu
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
using Vala;

/**
 * A Vala unresolved symbol that will be parsed as a namespace. 
 */
public class Gtkaml.MarkupNamespace : Vala.UnresolvedSymbol {

	/**
	 * weather at XML parsing time, there was a prefix on this tag or it was the implicit one
	 */
	public bool explicit_prefix {get; set;}
	
	public MarkupNamespace (Vala.UnresolvedSymbol? inner, string name, Vala.SourceReference? source_reference = null)
	{
		base (inner, name, source_reference);
	}
	
}
