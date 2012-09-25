package
{
	import flash.events.Event;
	
	public class XLSEvent extends Event
	{
		public static const NO_SHEET:String = "NO_SHEET";
		public static const NO_FIRST_DATA:String = "NO_FIRST_DATA";
		public static const NOT_HEADER:String = "NOT_HEADER";

		public function XLSEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}