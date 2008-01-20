using GLib;
using Vala;

public class Gtkaml.Dummy : Vala.Parser {
	public virtual void visit_source_file (SourceFile! source_file) {
		base.visit_source_file (source_file);
	}
}
