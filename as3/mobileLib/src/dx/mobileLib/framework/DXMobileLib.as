package dx.mobileLib.framework
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	public class DXMobileLib extends EventDispatcher
	{
		public static var frameManager:FrameManager;
		
		protected static var _root:DisplayObject;
		
		public static function init(root:DisplayObject):void
		{
			_root = root;
			
			_root.stage.align = StageAlign.TOP_LEFT;
			_root.stage.scaleMode = StageScaleMode.NO_SCALE;
			
			frameManager = new FrameManager(_root);
		}
	}
}