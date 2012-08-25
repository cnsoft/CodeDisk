package ;

import format.swf.Reader;
import format.swf.Tools;
import format.swf.Writer;
import haxe.io.Bytes;
import haxe.io.BytesBuffer;
import haxe.io.BytesData;
import haxe.io.BytesInput;
import haxe.io.BytesOutput;
import haxe.io.Input;
import neko.io.FileInput;
import neko.io.FileOutput;
import neko.Lib;
import format.abc.Data;
import format.swf.Data;
import neko.Sys;
import neko.zip.Uncompress;

/**
 * ...
 * @author ldx,www.swfdiy.com
 * dump bin Tag from swf
 */

class Main 
{
	
	static function main() 
	{
		var file:String = "new3.swf";
		
		
		//read swf
		var fin:FileInput = neko.io.File.read(file, true);
		if (fin == null) {
			Lib.println("open file error:" + file);
			Sys.exit(1);
		}
		var reader:Reader = new Reader(fin);
		var swf:SWF = reader.read();
		var header:SWFHeader = swf.header;
		var tags : Array<SWFTag> = swf.tags;
		
		Lib.println(file);
	
		

		Lib.println("SWF version:" + header.version);
		Lib.println("FPS:" + header.fps);
		Lib.println("Size:" + header.width + "x" + header.height);
		
		
		//fixed names in abc tags and symbol tags
		var t = 1;
		for ( i in 0...tags.length ) {
			var tag:SWFTag = tags[i];
			
			switch (tag) {
				case TBinaryData( id , data  ):
					//var bytes = format.tools.Deflate.run(data);
					//Lib.println(bytes.length);			
					//decrypt(data);
					var output:FileOutput = neko.io.File.write(file + ".o.bytes", true);
					output.writeBytes(data,0, data.length);
				default:
				
			}
		
		}
	
	
	}
	
	
	
	
}