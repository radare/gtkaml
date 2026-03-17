/* gtkamldatatypeparent.vala
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
using GLib;
using Vala;

/**
 * this class here only to make visit_data_type work
 */
class Gtkaml.DataTypeParent : Symbol {
	private DataType _data_type;
	public DataType data_type {
		get {
			return _data_type;
		}
		private set {
			_data_type = value;
			_data_type.parent_node = this;
		}	
	}
	
	public DataTypeParent (DataType data_type) {
		base (data_type.to_string () + "_parent_workaround", null);
		this.data_type = data_type;
	}
	
	public override void replace_type (DataType old_type, DataType new_type) {
		assert (data_type == old_type);
		assert (data_type != new_type);
		data_type = new_type;
	}
}
