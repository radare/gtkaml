/* GtkamlMethod.vala
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

using GLib;
using Vala;

/**
 * a constructor or an add method
 */
public abstract class Gtkaml.Method : GLib.Object {
	public string name {get;set;}
	public Vala.List<Gtkaml.Attribute> parameter_attributes{get;set;}
	construct
	{
		parameter_attributes = new Vala.ArrayList<Gtkaml.Attribute> ();
	}
}

/** useless specialization */
public class Gtkaml.AddMethod : Gtkaml.Method 
{
}

/** useless specialization */
public class Gtkaml.ConstructMethod : Gtkaml.Method 
{
}
