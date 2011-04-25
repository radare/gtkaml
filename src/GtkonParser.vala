/* gtkon parser -- Copyleft 2010-2011 -- author: pancake<nopcode.org> */

public enum GtkonTokenType {
	CODE,
	CLASS,
	COMMENT_LINE,
	COMMENT_BLOCK,
	ATTRIBUTE,
	BEGIN,
	END,
	INVALID
}

// TODO: those vars must be private. but vala does not support outside class private vars
int tok_idx;
string tokens[64];
bool mustclose;
GtkonTokenType last_type;
bool first_class = true;
bool has_version = false;
string? rootclass = null;
char nextchar = 0;

private static void pushtoken (string token) {
	if (tok_idx>=tokens.length)
		error ("Cannot push more tokens");
	//print (">> [%d]=%s\n", tok_idx, token);
	tokens[tok_idx++] = token;
}

private static string poptoken () {
	if (tok_idx == 0)
		return "";
	//print ("<< [%d]=%s\n", tok_idx-1, tokens[tok_idx-1]);
	return tokens[--tok_idx];
}

public bool genie_mode = true; //false;
public int genie_indent = 1;
private bool genie_closetag = false;
public bool nextiscode = false;

public int spaces = 0;
public bool newkeyword = true;
public int ospaces = 0;
public bool checkforindent = false;
GtkonToken? next_token;

[Compact]
public class GtkonToken {
	public uchar quoted;
	public string str;
	public GtkonTokenType type;
	public DataInputStream? dis;

	private bool is_separator (uchar ch) {
		if (genie_mode) {
			if (nextiscode) {
				type= GtkonTokenType.CODE;
				return false;
			}
			switch (ch) {
			case ' ':
			case '\t':
				print ("is_space\n");
				if (newkeyword)
					spaces++;
				return true;
			case '\r':
			case '\n':
				print ("-------> is_newline and new keyword\n");
				newkeyword = true;
				ospaces = spaces;
				spaces = 0;
				return true;
			case ',':
			case '\0':
				return true;
			}
			if (newkeyword) {
				if (ospaces >= spaces) {
	//				genie_closetag = true;
newkeyword=true;
ospaces=spaces; // this hack fixes the H\nb\no\nx issue
					print ("==== CLOSE TAG\n");
				}
			}
			print ("  %d %d is_char (%c)\n", (int)newkeyword, spaces, ch);
			newkeyword = false;
			return false;
		} else {
			switch (ch) {
			case ' ':
			case '\t':
			case '\r':
			case '\n':
			case ',':
			case '\0':
				return true;
			}
			return false;
		}
	}

	private uchar readchar() throws Error {
		uchar ch = nextchar;
		if (ch != 0) nextchar = 0;
		else ch = dis.read_byte ();
		return ch;
	}

	private bool skip_spaces() throws Error {
		var ch = 0;
		do { ch = readchar ();
		} while (is_separator (ch));
		return update (ch);
	}

	public GtkonToken.copy(GtkonToken src) {
		str = src.str;
		type = src.type;
		quoted = src.quoted;
		dis = src.dis;
	}

	public GtkonToken(DataInputStream dis) throws Error {
		if (next_token != null) {
			str = next_token.str;
			type = next_token.type;
			quoted = next_token.quoted;
			next_token = null;
		} else {
			str = "";
			quoted = 0;
			bracket = 0;
			this.dis = dis;
			type = GtkonTokenType.CLASS;
			skip_spaces ();
			if (genie_mode) {
				print ("TOKEN IS (%s)\n", str);
				if (type == GtkonTokenType.CLASS) {
					if (checkforindent) {
						print ("============ SPACES ==== %d %d\n", spaces, ospaces);
						if (ospaces>spaces) {
							next_token=new GtkonToken.copy (this);
							type = GtkonTokenType.END;
							return;
						}
						checkforindent = false;
					}
				}
				try {
					while (update (readchar ()));
				} catch (Error err) {
					/* do nothing.. just ignore */
				}
			} else while (update (readchar ()));
		}
	}

	public int bracket = 0;

	/* MORE ON : http://www.utexas.edu/learn/html/spchar.html */
	private string xmlfilteredchar (uchar ch) {
		// TODO: Use Html.
		switch (ch) {
/*
		case '\'': return "&apos;";
		case '"': return "&quot;";
*/
		//case '·': return "&middot;";
		case '<': return "&lt;";
		case '>': return "&gt;";
		case '&': return "&amp;";
		}
		return "%c".printf (ch);
	}

	public bool update (uchar ch) {
		if (quoted != 0) {
			type = GtkonTokenType.ATTRIBUTE;
			str += xmlfilteredchar (ch);
			if (quoted == '{') {
				if (ch=='{') bracket++;
				if (ch=='}') bracket--;
				if (bracket <0 && ch == '}') {
					str += "'";
					return false;
				}
			} else
			if (quoted == '\'') {
				if (ch == '\'')
					return false;
			} else {
				if (str.has_suffix ("\"") && !str.has_suffix ("\\\""))
					return false;
			}
			return true;
		}
		switch (type) {
		case GtkonTokenType.COMMENT_LINE:
			if (ch == '\n' || ch == '\r') 
				return false;
			str += "%c".printf (ch);
			return true;
		case GtkonTokenType.COMMENT_BLOCK:
			str += "%c".printf (ch);
			if (str.has_suffix ("*/")) {
				str = str[0:str.length-2];
				return false;
			}
			return true;
		case GtkonTokenType.CODE:
			str += "%c".printf (ch);
			if (str.has_suffix ("}-")) {
				str = str[0:str.length-2];
				return false;
			}
			return true;
		default:
			/* do nothing here */
			break;
		}
		if (is_separator (ch)) {
			if (genie_mode) {
print ("typs=NEW %s %d \n", str, type);
				if (!nextiscode && str[0]>'A' && type==GtkonTokenType.CLASS) {
					checkforindent = true;
					mustclose = true;
					print ("NEWKEYWORLD (%s) (%d %d)\n", str, ospaces, spaces);
					next_token = new GtkonToken.copy (this);
					if (ospaces>=spaces) {
						type = GtkonTokenType.END;
print ("NEW -- END ((%s))\n", str);
					} else type = GtkonTokenType.BEGIN;
					str = "";
					return false;
				}
/*
				if (genie_closetag) {
					type = GtkonTokenType.END;
					mustclose = true;
genie_closetag = false;
					return false;
				}
*/
			}
			if (type == GtkonTokenType.ATTRIBUTE && (str.index_of ("=%c".printf (ch)) != -1)) {
				if (str.has_suffix ("%c".printf (ch)) && !str.has_suffix ("\\\""))
					return false;
			} else return false;
		}
		switch (ch) {
		case '"':
		case '\'':
			quoted = ch;
			break;
		case '$':
			type = GtkonTokenType.ATTRIBUTE;
			break;
		case ':':
			if (str.index_of ("=") == -1)
				type = GtkonTokenType.CLASS;
			if (last_type == GtkonTokenType.CLASS)
				type = GtkonTokenType.ATTRIBUTE;
			break;
		case '=':
			type = GtkonTokenType.ATTRIBUTE;
			//mustclose = true;
			break;
		case '{':
			if (str.has_suffix ("=") ) {
				str += "'{";
				quoted = ch;
				return true;
			}
			if (str == "-") {
				type = GtkonTokenType.CODE;
				str = "";
				return true;
			}
			if (str == "") {
				mustclose = true;
				type = GtkonTokenType.BEGIN;
				return false;
			}
			nextchar = '{';
			return false;
		case ';':
			if (str == "") {
				type = GtkonTokenType.END;
				mustclose = true;
				return false;
			}
			nextchar = ';';
			return false;
		case '}':
			type = GtkonTokenType.END;
			return false;
		}
		str += "%c".printf (ch);
		if (str == "//" || str == "#") {
			type = GtkonTokenType.COMMENT_LINE;
			str = "";
		} else
		if (str == "/*") {
			type = GtkonTokenType.COMMENT_BLOCK;
			str = "";
		}
		return true;
	}

	public string to_xml() {
		var eos = "";
		var bos = "";
		/* workaround to get attributes without value */
		if (type == GtkonTokenType.CLASS)
			if (last_type == GtkonTokenType.CLASS || last_type == GtkonTokenType.ATTRIBUTE)
				type = GtkonTokenType.ATTRIBUTE;
		if (mustclose) {
			eos = ">";
			mustclose = false;
		}
		int max = tok_idx;
		if (type == GtkonTokenType.END)
			max--;
		for (int i = 0; i<max; i++)
			bos += "  ";
		switch (type) {
		case GtkonTokenType.CLASS:
			str = str.replace (".", ":");
			if (str != "") {
				pushtoken (str);
				bos += "<";
			}
			return bos+str+eos;
		case GtkonTokenType.COMMENT_BLOCK:
		case GtkonTokenType.COMMENT_LINE:
			return eos; //bos+"<!-- "+str+" -->\n";
		case GtkonTokenType.BEGIN:
			if (first_class && !has_version) {
				first_class = false;
				return " xmlns:gtkaml=\"http://gtkaml.org/"+Config.PACKAGE_VERSION+"\">\n";
			}
			return ">\n";
		case GtkonTokenType.END:
			if (tok_idx>0)
				return eos+bos+"</"+poptoken ()+">\n";
			return "";
		case GtkonTokenType.ATTRIBUTE:
			if (str[0] == '&')
				return " gtkaml:existing=\"%s\"".printf (str[1:str.length]);
			if (str[0] == '$') {
				if (tok_idx==1)
					rootclass = str[1:str.length];
				if (str[1] == '.')
					return " gtkaml:private=\"%s\"".printf (str[2:str.length]);
				return " gtkaml:public=\"%s\"".printf (str[1:str.length]);
			}
			if (str.index_of ("=") == -1) {
				if (str[0] == '!')
					str = str[1:str.length] + "=false";
				else str += "=true";
			}
			var foo = str.split ("=", 2);
			if (foo[0][0] != '@') {
				var arg = foo[1].replace ("\"", "").replace ("'", "");
				if (foo.length != 2)
					error ("Missing value in attribute '%s'", str);
				if (foo[0] == "gtkon:version") {
					has_version = true;
					return " xmlns:gtkaml=\"http://gtkaml.org/"+arg+"\"";
				}
				if (foo[0] == "standalone")
					return " gtkaml:standalone=\""+arg+"\"";
				if (foo[0] == "construct")
					return " gtkaml:construct=\""+arg+"\"";
				if (foo[0] == "property")
					return " gtkaml:property=\""+arg+"\"";
				if (foo[0] == "name") {
					warning ("name= attribute is deprecated. use '$' prefix");
					return " gtkaml:name=\""+arg+"\"";
				}
				if (foo[0] == "using") {
					var ns = arg.split (":");
					var s = "";
					for (int i=0; i<ns.length; i++) {
						if (i==0) s += " xmlns=\""+ns[i]+"\"";
						else s += " xmlns:"+ns[i]+"=\""+ns[i]+"\"";
					}
					return s;
		//			return " xmlns=\""+arg+"\"";
				}
				if (foo[0].has_prefix ("using:"))
					return " xmlns:"+foo[0][6:foo[0].length]+"=\""+arg+"\"";
			} else foo[0] = foo[0][1:foo[0].length];
			var val = foo[1];
			if (val[0] == '\'') {
				if (val[val.length-1] != '\'')
					error ("Missing '\'' in attribute '%s'", str);
				val = val[1:val.length-1];
			} else
			if (val[0] == '"') {
				if (val[val.length-1] != '"')
					error ("Missing '\"' in attribute '%s'", str);
				val = val[1:val.length-1].replace ("\\\"", "\"");
			}
			return " "+foo[0]+"='"+val+"'"+eos;
		case GtkonTokenType.CODE:
			var prestr = "";
			if (genie_mode) {
				print ("MUST FREE ALL THAT SHIT\n");
				while (tok_idx>1)
					prestr += "</"+poptoken ()+">\n";
			}
			if (rootclass != null)
			switch (str) {
			case "gtkaml::gtk::main":
				str = "\tpublic static void main(string[] args) {\n"+
					"\t\tGtk.init (ref args);\n"+
					"\t\t(new %s ()).show_all ();\n".printf (rootclass)+
					"\t\tGtk.main ();\n"+
					"\t}\n";
				break;
			}
			return prestr+bos+"<![CDATA[\n"+str+"\n"+bos+"]]>\n"+eos;
		case GtkonTokenType.INVALID:
			error ("Invalid token!");
		}
		return ""+eos; //<!-- XXX ("+str+") -->";
	}
}

public class GtkonParser {
	StringBuilder xmlstr = null;

	public GtkonParser() {
		/* reset global vars -- hacky */
		tok_idx = 0;
		mustclose = false;
		first_class = true;
		has_version = false;
		last_type = GtkonTokenType.INVALID;
	}

	public void parse_format(string format) {
		genie_mode = (format == "genie");
	}

	public void use_genie (bool use) {
		genie_mode = use;
	}

	public void parse_file(string filename) {
		xmlstr = new StringBuilder ();
		var file = File.new_for_path (filename);

		if (!file.query_exists ())
			error ("File '%s' doesn't exist.", filename);

		GtkonToken? token = null;
		try {
			var dis = new DataInputStream (file.read ());
			for (;;) {
				token = new GtkonToken (dis);
				if (genie_mode) {
					if (nextiscode) {
						print ("-----------code---***********************************************\n");
				xmlstr.append ("</"+poptoken ()+">\n");
						last_type = token.type = GtkonTokenType.CODE;
					//	nextiscode = false;
					} else
					if (token.str[0] == '[') {
						/* parse preprocessing token */
						if (token.str[1:8] == "indent=") {
							genie_indent = int.parse (token.str[8:token.str.length]);
							print ("INDENT=%d\n", genie_indent);
							continue;
						} else
						if (token.str == "[code]") {
							nextiscode=true;
							continue;
						} else print ("WARNING: Unkwnown preprocessing token (%s)\n", token.str);
					}
				}
				xmlstr.append (token.to_xml ());
				last_type = token.type;
			}
		} catch (Error e) {
			if (e.code != 0)
				error ("%s", e.message);
		}

		// close remaining tags...
		if (genie_mode) {
			print ("last type: %d\n", last_type);
			//print ("OUTSTR (%s)\n", token.str);
			while (tok_idx>0) {
				print ("TOKID-----\n");
				string s = "</"+poptoken ()+">\n";
				xmlstr.append (s); 
				tok_idx--;
			}
		}
	}

	public void to_file(string filename) {
		if (xmlstr == null)
			error ("no file parsed");
		var file = File.new_for_path (filename);
		try {
			var dos = new DataOutputStream (file.create (FileCreateFlags.NONE));
			dos.put_string ("<!-- automatically generated by gtkon -->\n");
			dos.put_string (xmlstr.str);
		} catch (Error e) {
			error ("%s", e.message);
		}
	}

	public string to_string() {
		return (xmlstr!=null)? xmlstr.str: "";
	}
}

#if MAIN
void main(string[] args) {
	if (args.length>1) {
		var gt = new GtkonParser ();
		foreach (unowned string file in args[1:args.length]) {
			if (!file.has_suffix (".gtkon"))
				error ("Unsupported file format for "+file+"\n");
			var g = Environment.get_variable ("GENIE");
			if (g != null && g == "1")
				gt.use_genie (true);
			gt.parse_file (file);
			gt.to_file (file.replace (".gtkon", ".gtkaml"));
		}
	} else print ("gtkon [file.gtkon ...]   # export GENIE=1 to use GENIE syntax\n");
}
#endif
