package model
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class MovieData
	{
		public var className:String;
		public var bitmaps:Vector.<BitmapData> = new Vector.<BitmapData>;
		public var offsets:Vector.<Point> = new Vector.<Point>;
		public var drawRect:Rectangle = new Rectangle;
		public var frameLables:Object = {};
		public var bitmapIndices:Array = [];
		
	}
}