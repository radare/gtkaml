/* GtkamlStateStack.vala
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
using Gee;

/** 
 * Simple, specialized, stack implementation using a Gee.List
 */
public class Gtkaml.StateStack : GLib.Object
{
	private Gee.ArrayList<State> array_list {get;set;}
	
	construct {
		array_list = new ArrayList<State>();
	}
		
	
	public void push (State element) {
		array_list.add (element);
	}
	
	public State peek (int backtrack = 0) {
		State element = null;
		int size = (array_list as Gee.List).size;
		if (size != 0) {
			element = array_list.get (size - 1 - backtrack);
		}
		return element;
	}		
	
	public State? pop() {
		State element = peek();
		if (element != null) {
			array_list.remove(element);
			return element;
		} else {
			return null;
		}
	}
	
}
