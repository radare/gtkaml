using GLib;
using Gee;

public class Gtkaml.StateStack : GLib.Object
{
	private Gee.ArrayList<State> array_list {get;set;}
	
	public StateStack() {
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
	
	public State pop() {
		State element = peek();
		if (element != null) {
			array_list.remove(element);
			return element;
		} else {
			return null;
		}
	}
	
}
