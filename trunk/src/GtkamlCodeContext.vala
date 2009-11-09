/* valacompiler.vala
 * 
 * Copyright (C) 2006-2009  Jürg Billeter
 * Copyright (C) 1996-2002, 2004, 2005, 2006 Free Software Foundation, Inc.
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.

 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.

 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301  USA
 *
 * Author:
 * 	Jürg Billeter <j@bitron.ch>
 * Adapted for Gtkaml:
 *	Vlad Grecescu <b100dian@gmail.com>
 */

using GLib;
using Vala;

public class Gtkaml.CodeContext : Vala.CodeContext {
	public Vala.List<string> generated_files = new Vala.ArrayList<string> ();	

	public void remove_generated_files () {
		if (!save_temps) {
			foreach (string filename in generated_files) {
				FileUtils.unlink (filename);
			}
		}
	}
}
