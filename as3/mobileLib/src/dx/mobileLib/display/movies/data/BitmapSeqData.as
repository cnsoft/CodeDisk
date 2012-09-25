package dx.mobileLib.display.movies.data
{
	import dx.mobileLib.display.movies.data.BitmapMovieData;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	
	/**
	 * 
	 * 适合于每帧都只有一层，而且只有一张图片的movieclip, 直接bitmapdata赋值
	 * 
	 */	
	public class BitmapSeqData extends BitmapMovieData
	{
		public function BitmapSeqData(movie:MovieClip, pRasterAtNeed:Boolean=false)
		{
			super(movie, pRasterAtNeed);
		}
		override public function getBitmapdata(index:int):BitmapData {
			//trace("get bitmapdata:" + index);
			if (bitmapdatas[index] == null){                                
				mc.gotoAndStop(index+1);
				var label:String = mc.currentFrameLabel;
				if (label && !frameLables[label]){
					frameLables[label] = index+1;
				}
				var o:Object = mc.getChildAt(0);
				var child:Bitmap = mc.getChildAt(0) as Bitmap;
				var bitmapdata:BitmapData;
				if (child != null){
					var rc:Rectangle = child.getBounds(mc);
					rc.x = Math.floor(rc.x);
					rc.y = Math.floor(rc.y);
					rc.width = Math.ceil(rc.width);
					rc.height= Math.ceil(rc.height);
					
					//bitmapdata = new BitmapData(rc.width, rc.height, true, 0x000000);
					//bitmapdata.copyPixels(child.bitmapData, child.bitmapData.rect, new Point(0,0));
					
					
					bitmapdata = child.bitmapData;
					
					offsets[index] = new Point(rc.left, rc.top);
					bitmapdatas[index] = child.bitmapData;
					
					if (bitmapdata.width > maxWidth){
						maxWidth = bitmapdata.width;
					}
					
					if (bitmapdata.height > maxHeight){
						maxHeight = bitmapdata.height;
					}
				} else {
					bitmapdata = new BitmapData(1,1,true, 0x000000);
					bitmapdatas[index] = bitmapdata;
					offsets[index] = new Point(0, 0);
				}
			
				generatedBitmapsCount++;
				if (generatedBitmapsCount >= bitmapdatas.length){
					//全部生成完毕，释放MC
					mc = null;
				}
			}
			return bitmapdatas[index];
		}
		
	}
}