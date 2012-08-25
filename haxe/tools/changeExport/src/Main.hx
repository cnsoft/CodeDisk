package ;

import format.swf.Reader;
import format.swf.Tools;
import format.swf.Writer;
import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.io.BytesOutput;
import haxe.io.Input;
import neko.io.FileInput;
import neko.io.FileOutput;
import neko.Lib;
import format.abc.Data;
import format.swf.Data;
import neko.Sys;

/**
 * ...
 * @author ldx
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
				case TSymbolClass(symbols): 
					for (s in symbols) {
						var nstr:String = s.className;
							s.className  = 'tt' + t ;
							t++;
						
					}
				
				
				default:
				
			}
		
		}
		
		//write
		var output:FileOutput = neko.io.File.write(file + ".o.swf", true);
		var writer:Writer = new Writer(output);
		writer.write(swf);
		Lib.println(file + ".o.swf saved");
	
	}
	
}