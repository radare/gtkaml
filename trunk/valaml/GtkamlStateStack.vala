using GLib;
using Gee;

public class Gtkaml.StateStack : Gee.ArrayList<State>
{
	public void push (State element) {
		add (element);
	}
	
	public State peek() {
		State element = null;
		int size = (this as Gee.List).size;
		if (size != 0) {
			element = base.get (size - 1);
		}
		return element;
	}		
	
	public State pop() {
		State element = peek();
		if (element) {
			remove(element);
			return element;
		} else {
			return null;
		}
	}
}
