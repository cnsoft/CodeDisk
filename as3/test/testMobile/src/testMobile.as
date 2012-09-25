package
{
	import dx.mobileLib.debug.Stats;
	import dx.mobileLib.display.movies.DXMovie;
	import dx.mobileLib.display.movies.DXMovieAtlas;
	import dx.mobileLib.framework.DXMobileLib;
	
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.text.TextField;
	
	public class testMobile extends Sprite
	{
		public var atlas:DXMovieAtlas;
		protected var txt:TextField;
		public function testMobile()
		{
			super();
		
			DXMobileLib.init(this);
			
			txt = new TextField;
			txt.x = 300;
			this.addChild(txt);
			
			this.addChild(new Stats());
			
			stage.frameRate = 30;
			
			
			atlas = new DXMovieAtlas();
			atlas.addEventListener(Event.COMPLETE, onComplete);

			atlas.load("panda.swf");
			
		}
		
		protected function onComplete(event:Event):void
		{
			txt.text = "cost:" + atlas.generatCostTime.toString();
			var nameList:Vector.<String> = atlas.getMovieNameList();
			for  (var i:int=0;i<nameList.length;i++){
				var movie:DXMovie = atlas.getMovie(nameList[i]);
				movie.x = 200 + (i % 3)*150;
				movie.y = 300 +  (i/3)*300;
				movie.play();
				this.addChild(movie);				
				
			}
		}
	}
}