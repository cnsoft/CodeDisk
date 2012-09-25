package
{

	
	import com.adobe.crypto.MD5;
	
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	
	import flashx.textLayout.events.DamageEvent;
	
	import model.FrameData;
	import model.MovieData;
	
	import mx.core.Application;
	import mx.graphics.codec.PNGEncoder;

	public class ParseJob extends EventDispatcher
	{
		private var loader:Loader;
		private var context:LoaderContext;
		private var ba:ByteArray;
		private var file:String;
		private var ignoreBlank:Boolean;
		private var regCares:RegExp;
		public var name:String;
		public function ParseJob(pba:ByteArray, pfile:String,  pignoreBlank:Boolean, pCares:String)
		{
			ba = pba;
			file = pfile;
			ignoreBlank = pignoreBlank;
			context = new LoaderContext;
			context.allowCodeImport = true;
			name = file.replace(".swf", "");
			regCares = new RegExp(pCares);
		}
		
		public function run():void {
			loader = new Loader();
			loader.loadBytes(ba, context);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onOK);
		}
		
		protected function onOK(event:Event):void
		{
			//分析SWF里有什么链接类
			var symbols:Vector.<String> = context.applicationDomain.getQualifiedDefinitionNames();

			var movieDataList:Array = [];
			var classNames:Array = [];
			for each (var className:String in symbols) {
				//过滤不要的链接类
				className = className.replace("::", ".");
				if(!className.match(regCares) || className.match(regCares).length == 0){
					continue;
				}
				var cl:Class = context.applicationDomain.getDefinition(className) as Class;
				var d:MovieClip = new cl() as MovieClip;
				if (d){
					var sp:MovieClip = new MovieClip;	
					sp.addChild(d);
					sp['mc'] = d;
					
					
					var data:MovieData = this.getMovieData(sp);
					
				
					data.className = className;
					movieDataList.push(data);
					//同时把影片对应的原点坐标保存下来
					//origins.push({className: className, rect:data.drawRect, frameLables:data.frameLables});
				}
			}
			
			//完成
			var e:MergeEvent = new MergeEvent(MergeEvent.MERGE);
			e.name = this.name;
			e.movieDataList = movieDataList;
			this.dispatchEvent(e);
		}
		
	
		

		
		
		/**
		 * 一帧一帧对movieclip进行拍照，保存到movieData 
		 * @param sp
		 * @return 
		 * 
		 */		
		private function getMovieData(sp:MovieClip):MovieData
		{
			var i:int;
			var mc:MovieClip = sp['mc'];

			var totalFrames:int = mc.totalFrames;
			var data:MovieData = new MovieData();
			for (i=0;i<totalFrames;i++){
				
				//mc.gotoAndStop(i+1);
				
				var label:String = mc.currentFrameLabel;
				if (label && !data.frameLables[i]){
					data.frameLables[i] = label;
				}
		
				var rc:Rectangle = mc.getBounds(mc);
				var bitmapdata:BitmapData;
				
				if (rc.width == 0 || rc.height == 0){
					if (!ignoreBlank){
						bitmapdata = new BitmapData(1,1,true, 0x000000);
						data.bitmaps.push(bitmapdata);
						data.offsets.push(new Point(0, 0));
					}
				
				} else {
						
					rc.x = Math.floor(rc.left);
					rc.y = Math.floor(rc.y);
					rc.width = Math.ceil(rc.width);
					rc.height= Math.ceil(rc.height);
				
					bitmapdata = new BitmapData(rc.width, rc.height,true, 0x000000);
					bitmapdata.draw(sp, new Matrix(1,0,0,1, -rc.left, -rc.top));
					data.offsets.push(new Point(rc.left, rc.top));
					data.bitmaps.push(bitmapdata);
					data.drawRect = data.drawRect.union(rc);
		
					
				}
				
				nextFrame(mc);
				
				
			}
			
			return data;
		}		
	
		private function nextFrame(mc:MovieClip):void {
			if (mc.currentFrame < mc.totalFrames){
				mc.gotoAndStop(mc.currentFrame+1);
			} else {
				mc.gotoAndStop(1);
			}
			
			//sub movieclips
			//同时支持子影片循环播放
			for(var j:int=0;j < mc.numChildren;j++) {
				var ch:DisplayObject = mc.getChildAt(j);
				if (ch is MovieClip && MovieClip(ch).totalFrames > 1) {
					nextFrame(ch as MovieClip);
				}
			}
			
		}
	}
}