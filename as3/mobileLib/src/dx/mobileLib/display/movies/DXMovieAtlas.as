package dx.mobileLib.display.movies
{
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	
	public class DXMovieAtlas extends EventDispatcher
	{
		protected var _url:String;
		protected var _loader:Loader;

		protected var _movies:Dictionary;
		protected static var _nameReg:RegExp = new RegExp("MC_(.*)");
		
		public var generatCostTime:int;
		public function DXMovieAtlas(assetURL:String="")
		{
			_url = assetURL;
			_movies = new Dictionary();
			
		}
		public function load(assetURL:String=""):void {
			if (assetURL != ""){
				_url = assetURL;
			}
			_loader = new Loader();
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
			_loader.load(new URLRequest(_url));
			
		}
		
		protected function onComplete(event:Event):void
		{
			var container:MovieClip = _loader.content as MovieClip;
			var t:int = flash.utils.getTimer();
			for (var i:int=0;i<container.numChildren;i++){
				var child:MovieClip = container.getChildAt(i) as MovieClip;
				if (child){
					var matches:Array = child.name.match(_nameReg);
					if (matches && matches.length){
						var movieName:String = matches[1];
						_movies[movieName] = new DXMovie(null, child, true);
					}
				}
			}
			generatCostTime = flash.utils.getTimer() - t;
			disposeLoader();
			
			this.dispatchEvent(new Event(Event.COMPLETE));
		}
		
		public function getMovie(movieName:String):DXMovie {
			return _movies[movieName];
		}
		
		public function getMovieNameList():Vector.<String> {
			var vt:Vector.<String> = new Vector.<String>;
			for (var k:String in _movies){
				vt.push(k);
			}
			return vt;
		}
		
		protected function disposeLoader():void {
			_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onComplete);
			_loader.unloadAndStop(false);
			_loader = null;
		}
		
		public function dispose():void {
			if (_loader){
				disposeLoader();
			}
		}
	}
}