package
{

	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	
	
	public class SampleMc2xml extends Sprite
	{
		
	
		
		
		[Embed('anitest.swf', symbol='test')]
		private static var MC_TEST:Class;
		
		
		
		private var canvasNative:Sprite;
		private var canvasXML:Sprite;

		public function SampleMc2xml()
		{
			
			
			canvasNative = new Sprite;
			this.addChild(canvasNative);
			
			canvasXML = new Sprite;
			//this.addChild(canvasXML);
			
			this.mouseChildren = false;
			stage.addEventListener(MouseEvent.CLICK, onClick);
			
			nativeScene();
			xmlScene();
			
	
			var txt:TextField = ViewUtils.getTextField(12, 0x00ffff, "click to next");
			txt.x = 100;
			txt.y = 100;
			this.addChild(txt);
		
		}
		
		protected function onClick(event:MouseEvent):void
		{
			if (canvasNative.parent){
				canvasNative.parent.removeChild(canvasNative);
				this.addChild(canvasXML);
			} else {
				canvasXML.parent.removeChild(canvasXML);
				this.addChild(canvasNative);
			}
		}
		
		private function nativeScene():void
		{
			var txtTitle:TextField = ViewUtils.getTextField(15, 0x0000ff, "Native MovieClip");
			txtTitle.x = 50;
			txtTitle.y = 50;
			canvasNative.addChild(txtTitle);
			
			var mc:MovieClip = new MC_TEST() as MovieClip;
			mc.x = 100;
			mc.y = 300;
			canvasNative.addChild(mc);
			
		
		}		
		
		private function xmlScene():void
		{
			var txtTitle:TextField = ViewUtils.getTextField(15, 0x0000ff, "use XML movie");
			txtTitle.x = 50;
			txtTitle.y = 50;
			canvasXML.addChild(txtTitle);
			
			var mc:TestMovie = new TestMovie;
			mc.x = 100;
			mc.y = 300;
			mc.play();
			canvasXML.addChild(mc);
		}	
		
	}
}