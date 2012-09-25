package  dx.mobileLib.display.movies.data
{
	import dx.mobileLib.display.movies.interfaces.IMovieData;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	
	
	public class BitmapMovieData implements IMovieData
	{
	
		
		protected var bitmapdatas:Vector.<BitmapData>;
		public var offsets:Vector.<Point> ;
		public var maxWidth:int=1;
		public var maxHeight:int = 1;
		public var totalFrames:int = 0;
		
		public var mc:MovieClip;
		public var generatedBitmapsCount:int = 0;
		
		protected var frameLables:Object = {};
		/**
		 * 
		 * @param movie
		 * @param pRasterAtNeed 是否马上draw所有帧
		 * 
		 */		
		public function BitmapMovieData(movie:MovieClip, pRasterAtNeed:Boolean=true)
		{
			totalFrames  = movie.totalFrames;
			bitmapdatas = new Vector.<BitmapData>(totalFrames);
			offsets = new Vector.<Point>(totalFrames);
			mc = movie;
			
			if (!pRasterAtNeed){
				drawAll();	
			}
		}
		
		public function drawAll():void {
			var i:int;
			for (i=0;i<totalFrames;i++){
				getBitmapdata(i);
			}
		}
		
		public function render(bitmap:Bitmap, index:int):void {
			var src:BitmapData = getBitmapdata(index);
			//_canvas.fillRect(_clearRect, 0);
			//_canvas.copyPixels(src, src.rect, new Point(0, 0));
			bitmap.bitmapData = src;
			
			bitmap.x = this.offsets[index].x;
			bitmap.y =  this.offsets[index].y;
		}

		public function getMovieOffsetX(index:int):int {
			return this.offsets[index].x;
		}
		
		public function getMovieOffsetY(index:int):int {
			return this.offsets[index].y;

		}
		
		public function getTotalFrames():int {
			return totalFrames;
		}
		

		public function getFrameIndexByLable(lable:String):int {
			if (frameLables[lable] == null){
				return -1;
			}
			return frameLables[lable];
		}


		
		public function getBitmapdata(index:int):BitmapData {
			
			if (bitmapdatas[index] == null){                                
				mc.gotoAndStop(index+1);
				
				var label:String = mc.currentFrameLabel;
				if (label && !frameLables[label]){
					frameLables[label] = index+1;
				}
				
				var rc:Rectangle = mc.getBounds(mc);
				var bitmapdata:BitmapData;
				if (rc.width == 0 || rc.height == 0){
					bitmapdata = new BitmapData(1,1,true, 0x000000);
					bitmapdatas[index] = bitmapdata;
					offsets[index] = new Point(0, 0);
				} else {
					rc.x = Math.floor(rc.x);
					rc.y = Math.floor(rc.y);
					rc.width = Math.ceil(rc.width);
					rc.height= Math.ceil(rc.height);
					
					bitmapdata = new BitmapData(rc.width, rc.height,true, 0x000000);
					bitmapdata.draw(mc, new Matrix(1,0,0,1, -rc.left, -rc.top));
					offsets[index] = new Point(rc.left, rc.top);
					bitmapdatas[index] = bitmapdata;
					
					if (bitmapdata.width > maxWidth){
						maxWidth = bitmapdata.width;
					}
					
					if (bitmapdata.height > maxHeight){
						maxHeight = bitmapdata.height;
					}
				}
				generatedBitmapsCount++;
				if (generatedBitmapsCount >= bitmapdatas.length){
					//全部生成完毕，释放MC
					mc = null;
				}
			}
			return bitmapdatas[index];
		}
		public function destroy():void {
			for (var i:int=0;i<bitmapdatas.length;i++){
				if(bitmapdatas[i]){
					bitmapdatas[i].dispose();
				}
				
			}
			bitmapdatas = null;
			offsets = null;
			mc = null;
			totalFrames = 0;
		}
	}
}