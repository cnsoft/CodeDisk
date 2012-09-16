package 
{

	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.ByteArray;
	

	
	public class TestMovie extends Sprite
	{
		[Embed('anitest.swf', symbol='BMP1')]
		private static var BMP1:Class;
		
		[Embed('anitest.swf', symbol='BMP2')]
		private static var BMP2:Class;
		
		[Embed(source='test.xml', mimeType="application/octet-stream")]
		public static var XML_TEST:Class;
		
		
		protected var bitmap1:Bitmap;
		protected var bitmap2:Bitmap;
		
		protected var animation:XMLAnimation;
		public function TestMovie()
		{
			super();
			bitmap1 = new BMP1() as Bitmap;
			bitmap2 = new BMP2() as Bitmap;
			this.addChild(bitmap1);
			this.addChild(bitmap2);
			var str:String = (new XML_TEST() as ByteArray).toString();
			var originXml:XML =  new XML( str);
			animation = new XMLAnimation(originXml);
			animation.gotoAndStop({mc: bitmap1, mc2:bitmap2}, 1);
		}
		
		public function play():void {
			this.addEventListener(Event.ENTER_FRAME, onFrame);
		}
		
		private function onFrame(e:Event):void
		{
			if (animation.ended) {
				animation.reset();
			}
			animation.play({mc: bitmap1, mc2:bitmap2}, 1);
			
			
		}
		
		public function destroy():void {
			this.removeEventListener(Event.ENTER_FRAME, onFrame);


		}
	}
}