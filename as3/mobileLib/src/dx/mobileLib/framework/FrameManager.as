
package  dx.mobileLib.framework
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	

	
	public class FrameManager
	{
		
		private  var _fun:Function;
		private  var _index:int;
		
		private  var _startTimer:int;
		private  var _pastFrames:int;
		private  var _curFrames:int;
		private  var _frames:int;
		
		private  var _updateFrameFunArr:Vector.<Function> = new Vector.<Function>; //EnterFrame每帧执行的数组
		private  var _updateRealFrameFunArr:Vector.<Function> = new Vector.<Function>; //EnterFrame每帧执行的数组（传送实际帧数）
		
		
		public  var frameRate:int = 24;
		public  function FrameManager(pRoot:DisplayObject):void
		{
			
			
			_startTimer = getTimer();
			pRoot.addEventListener(Event.ENTER_FRAME,onUpdateFrame);
		}
		
		private  function onUpdateFrame(e:Event):void
		{
			for each(_fun in _updateFrameFunArr)
			{
				_fun();
			}
			
			var curTimers:int = getTimer();
			_curFrames = int((curTimers - _startTimer) * frameRate / 1000);
			_frames = _curFrames - _pastFrames;
			
			
			if(_frames < 0)
			{
				//U3Cue.error("帧数出错：" + _frames);
			}
			_pastFrames = _curFrames;
			
			for each(_fun in _updateRealFrameFunArr)
			{
				_fun(_frames);
				
			}
			_fun = null;
		}
		
		/**
		 * 添加每帧事件
		 * fun：添加时间的方法
		 * isReturnRealFrames：是否返回真正的帧数（根据时间计算）
		 * */
		public  function addEnterFrame(fun:Function,isReturnRealFrames:Boolean = false):void
		{
			if(!isReturnRealFrames)
			{
				_updateFrameFunArr.push(fun);
			}
			else
			{
				_updateRealFrameFunArr.push(fun);
			}
		}
		
		/**移除每帧事件**/
		public  function removeEnterFrame(fun:Function):void
		{
			_index = _updateFrameFunArr.indexOf(fun);
			if(_index != -1)
			{
				_updateFrameFunArr.splice(_index,1);
			}
			
			_index = _updateRealFrameFunArr.indexOf(fun);
			if(_index != -1)
			{
				_updateRealFrameFunArr.splice(_index,1);
			}
		}
		
		/**检查是否有此帧事件**/
		public  function hasEnterFrame(fun:Function):Boolean
		{
			_index = _updateFrameFunArr.indexOf(fun);
			if(_index != -1)
			{
				return true;
			}
			
			_index = _updateRealFrameFunArr.indexOf(fun);
			if(_index != -1)
			{
				return true;
			}
			return false;
		}
		
	
		
	}
}