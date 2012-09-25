package dx.mobileLib.display.movies
{
	import dx.mobileLib.display.movies.data.BitmapMovieData;
	import dx.mobileLib.display.movies.data.BitmapSeqData;
	import dx.mobileLib.display.movies.interfaces.IMovieData;
	import dx.mobileLib.framework.DXMobileLib;
	import dx.mobileLib.framework.FrameManager;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.utils.Dictionary;
	
	

	
	/**
	 * 
	 * @author ADong
	 * 
	 * 这是一个基本动画类，类似与movieclip，只是内部使用了位图渲染
	 * 
	 * 它的IU3MovieData决定了它的位图来源
	 * 
	 * 比如如果movieData是U3AtlasMovieData,那么位图来源与Altas包里的一个movie,  movieData由外部控制生成，U3Movie本身不控制销毁
	 * 比如如果movieData是U3BitmapMovieData, 那么位图来源于一个movieclip draw/copy pixel出来的数据,  movieData由外部控制生成，U3Movie本身不控制销毁
	 * 
	 *
	 * 
	 */	
	
	public class DXMovie extends Sprite
	{
		/**
		 * 
		 * @param pMovieData  movie对应的位图数据
		 * @param movieClip    如果没有pMovieData,需要传入movielip
		 * @param movieClipIsBitmapSeq   movieclip是否位图序列，是的话使用bitmapda赋值，否则使用draw
		 * @param movieClipRasterAtNeed  是否对movielip每一帧在需要时才渲染，false表示马上全部渲染
		 * 
		 */		
		public function DXMovie(pMovieData:IMovieData=null, movieClip:MovieClip=null, movieClipIsBitmapSeq:Boolean=false, movieClipRasterAtNeed:Boolean=false)
		{
			super();
			this.mouseChildren = false;
			this.mouseEnabled = false;
			if (pMovieData != null){
				setMovieData(pMovieData);
			} else if (movieClip != null){
				if (movieClipIsBitmapSeq){
					ownMovieData = new BitmapSeqData(movieClip, movieClipRasterAtNeed);
				} else {
					ownMovieData = new BitmapMovieData(movieClip, movieClipRasterAtNeed);
				}
				this.setMovieData(ownMovieData);
			}
		}
		
		protected var _currentFrame:int=0;
		
		protected var canvasBmp:Bitmap;
		
		protected var movieData:IMovieData;
		
		protected var ownMovieData:BitmapMovieData;
		
		public var totalFrames:int;
		
		protected var framesScript:Dictionary = new Dictionary;
		
		public function setMovieData(data:IMovieData):void {
			movieData = data;
			totalFrames = movieData.getTotalFrames();
			init();
		}
		
		
		public function gotoAndPlay(n:int):void {
			gotoAndStop(n);
			if (!DXMobileLib.frameManager.hasEnterFrame(nextFrame)){
				DXMobileLib.frameManager.addEnterFrame(nextFrame);
			}
		}
		
		public function play():void {
			
			stop();
			DXMobileLib.frameManager.addEnterFrame(nextFrame);
			
		}
		
		
		public function reversePlay():void {
			stop();
			DXMobileLib.frameManager.addEnterFrame(preFrame);
			
		}
		
		public function get currentFrame():int {
			return _currentFrame;
		}
		
		
		public function stop():void {
			if (DXMobileLib.frameManager.hasEnterFrame(nextFrame)){
				DXMobileLib.frameManager.removeEnterFrame(nextFrame);
			}
			
			if (DXMobileLib.frameManager.hasEnterFrame(preFrame)){
				DXMobileLib.frameManager.removeEnterFrame(preFrame);
			}
		}
		
		
		/**
		 * 在某帧上添加回调函数 (如果该帧上已经有该回调函数不会再添加一次)
		 * @param scriptAt 如果是字符串则是frameLable,如果是数字则是帧的index(取0为第一帧)
		 * @param callback 
		 * 
		 */	
		public function addFrameScript(scriptAt:Object, callback:Function):void {
			if (scriptAt is String){
				//add to frame label
				var frameIndex:int = movieData.getFrameIndexByLable(String(scriptAt));
				if (frameIndex != -1){
					addFrameScriptAt(frameIndex, callback);
				}
			} else if (scriptAt is int){
				//add to frame index
				addFrameScriptAt(int(scriptAt), callback);
			}
			
		}
		
		
		/**
		 * 移除某帧上的回调函数 
		 * @param scriptAt 如果是字符串则是frameLable,如果是数字则是帧的index(取0为第一帧)
		 * @param callback 
		 * 
		 */		
		public function removeFrameScript(scriptAt:Object, callback:Function):void {
			if (scriptAt is String){
				//add to frame label
				var frameIndex:int = movieData.getFrameIndexByLable(String(scriptAt));
				if (frameIndex != -1){
					removeFrameScriptAt(frameIndex, callback);
				}
			} else if (scriptAt is int){
				//add to frame index
				removeFrameScriptAt(int(scriptAt), callback);
			}
		}
		
		protected function addFrameScriptAt(frameIndex:int, callback:Function):void {
			trace("add script:" + frameIndex);
			
			if (frameIndex < 0 || frameIndex > this.totalFrames - 1) {
				return;	
			}
			
			if (framesScript[frameIndex+1] == null){
				framesScript[frameIndex+1] = [];
			}
			var index:int = framesScript[frameIndex+1].indexOf(callback);
			if (index == -1){
				framesScript[frameIndex+1].push(callback);
				
			}
			
		}
		
		protected function removeFrameScriptAt(frameIndex:int, callback:Function):void {
			trace("remove script:" + frameIndex);
			if (frameIndex < 0 || frameIndex > this.totalFrames - 1) {
				return;	
			}
			
			if (framesScript[frameIndex+1] != null){
				var index:int = framesScript[frameIndex+1].indexOf(callback);
				if (index != -1){
					framesScript[frameIndex+1].splice(index, 1);
				}
				
			}
		}
		
		
		protected function init():void {
			canvasBmp = new Bitmap(null, "auto", true);
			this.addChild(canvasBmp);
			gotoAndStop(1);
		}
		
		
		
		public function gotoAndStop(n:int):void {
			
			if (!movieData){
				return;
				
			}
			
			var index:int = (n -1) % totalFrames;
			if (index < 0 ){
				index += totalFrames;
			}
			
			_currentFrame = index + 1;
			
			if (this.framesScript[_currentFrame]){
				for each  (var func:Function in this.framesScript[_currentFrame]){
					func.call(null, this);
					
				}
			}
			
			
			refresh();
		}
		
		
		protected function refresh():void
		{
			if (!movieData || ! totalFrames){
				return;
			}
			var index:int = _currentFrame-1;
			movieData.render(canvasBmp, index);
			
		}
		
		public function nextFrame(frames:int=1):void {
			gotoAndStop(_currentFrame+frames);
		}
		
		
		public function preFrame(frames:int=1):void {
			gotoAndStop(_currentFrame-frames);
		}
		
		public function reset():void {
			_currentFrame = 1;
			gotoAndStop(_currentFrame);
		}
		
		
		public function destroy():void {
			stop();
			
			if (ownMovieData){
				ownMovieData.destroy();
				ownMovieData = null;
			}
			
			movieData = null;
			framesScript = null;
		}
	}
}