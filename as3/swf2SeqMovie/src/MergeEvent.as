package
{
	import flash.events.Event;
	
	public class MergeEvent extends Event
	{
		public static const MERGE:String = "merge";
		public var movieDataList:Array = [];
		public var name:String;
		public function MergeEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}