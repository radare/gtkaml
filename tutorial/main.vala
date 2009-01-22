using GLib;
using Gtk;

public void main(string[] args)
{
	Gtk.init(ref args);
	var window = new Window(WindowType.TOPLEVEL);
	window.add (new Tutorial0());
	window.show_all();
	Gtk.main();
}
