package 
{
	import flash.display.DisplayObject;
	import flash.geom.Matrix;
	import flash.utils.Dictionary;

	public class XMLAnimation
	{
		protected var name2idMap:Dictionary;
		
		private var frameIndex:int = 0;
		public var ended:Boolean = false;
		protected var frames:Dictionary;
		protected var totalFrames:int;
		public function XMLAnimation(xml:XML)
		{
			name2idMap = new Dictionary;
			var childrenList:XMLList = xml.Children.elements("Child");
			for each (var ch:XML in childrenList){
				var name:String = ch.@name;
				var id:String = ch.@id;
				name2idMap[name] = id;
			}
			
			frames = new Dictionary;
			var framesList:XMLList = xml.Frames.elements("Frame");
			totalFrames = framesList.length();
			for each (var f:XML in framesList){
				var index:int = f.@index;
				var frameChildList:XMLList = f.elements("Matrix");
				var dict:Dictionary = new Dictionary;
				for each (var fc:XML in frameChildList){
					var fcID:String = fc.@id;
					var tx:Number = Number(fc.@tx);
					var ty:Number = Number(fc.@ty);
					var a:Number = Number(fc.@a);
					var b:Number = Number(fc.@b);
					var c:Number = Number(fc.@c);
					var d:Number = Number(fc.@d);
					var alpha:Number = Number(fc.@alpha);
					dict[fcID] = {matrix:new Matrix(a, b, c, d, tx,ty), alpha:alpha};
				}

				frames[index] = dict;
			}
		}
		
	

		public function play(targets:Object, fames:int=1):void {
			
			frameIndex+=fames;
			
			if (frameIndex >= totalFrames){
				frameIndex = totalFrames-1;
				ended = true;
			}
			
			
			gotoAndStop(targets, frameIndex);
		}
		
		public function reset():void {
			frameIndex = 0;
			ended = false;
		}
		
		public function gotoAndStop(targets:Object, n:int):void {
			var frameData:Object = frames[n];
			if (!frameData){
				return;
			}
			for (var name:String in targets){
				var target:DisplayObject = targets[name];
				if (!target){
					continue;
				}
				var fcID:String = name2idMap[name];
				if (!fcID){
					continue;
				}
				if (!frameData[fcID]){
					target.visible = false;
				} else {
					target.visible = true;
					target.alpha = frameData[fcID]['alpha'];
					target.transform.matrix = frameData[fcID]['matrix'];
				}
			}
		}
		
	}
}