using Stk;

public class TestApplication : Application {
	public TestApplication() {
		this.add_view (typeof (TestView), "main");
		this.set_default_view ("main");
	}
}

public Application stk_application_startup() {
	return new TestApplication ();
}
