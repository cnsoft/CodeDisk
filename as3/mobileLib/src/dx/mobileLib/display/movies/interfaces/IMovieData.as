package dx.mobileLib.display.movies.interfaces
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;

	public interface IMovieData
	{
		function getTotalFrames():int;
		function render(bitmap:Bitmap, index:int):void;
		function getFrameIndexByLable(lable:String):int;

	}
}