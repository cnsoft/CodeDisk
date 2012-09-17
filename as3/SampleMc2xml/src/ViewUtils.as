package 
{
	import flash.text.TextField;
	import flash.text.TextFormat;

	public class ViewUtils
	{
		public static function getTextField(size:int, color:int, str:String):TextField {
			var txt:TextField = new TextField;
			var tf:TextFormat = new TextFormat;
			tf.size = 25;
			tf.color = color;
			txt.defaultTextFormat = tf;
			txt.text = str;
			txt.width = txt.textWidth + 20;
			return txt;
			
		}
	}
}