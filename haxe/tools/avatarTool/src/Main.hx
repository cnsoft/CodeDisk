package ;

import format.swf.Reader;
import format.swf.Tools;
import format.swf.Writer;
import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.io.BytesOutput;
import haxe.io.Input;
import neko.FileSystem;
import neko.io.FileInput;
import neko.io.FileOutput;
import neko.Lib;
import format.abc.Data;
import format.swf.Data;
import neko.Sys;
/**
 * ...
 * @author ldx, www.swfdiy.com
 */

class Main 
{


	static function main() 
	{
		
	/*
		
		var args:Array<String> = Sys.args();
		if (args.length <= 0) {
			Lib.println(" avatarTool \\d+.swf");
			Sys.exit(1);
		} 
	
		var file:String = args[0];
		var r = new EReg("(\\d+)\\.swf$", "");
		var dest:String = "";
		if (r.match(file)) {
			dest = r.matched(1);
		}  else {
			Lib.println(" avatarTool \\d+.swf");
			Sys.exit(1);
		}*/
	
		//create dir
		if (!FileSystem.exists("o") ){
			FileSystem.createDirectory("o");
		}
		
		var ar = FileSystem.readDirectory('./');
		var dest:String = "";
		for (file in ar) {
			var rf = new EReg("(\\w+)\\.swf$", "");
			var dest:String = "";
			if (rf.match(file)) {
				dest = rf.matched(1);
			} else {
				//Lib.println(file + " is not correct file");
				continue;
			}
			
			
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
		
			var dir = "";
			//fixed names in abc tags and symbol tags
			var r2 = new EReg("(avatar\\.comps\\.(\\w+)\\..*?)(AVID)$", "");
			for ( i in 0...tags.length ) {
				var tag:SWFTag = tags[i];
				switch (tag) {
					case TSymbolClass(symbols): 
						for (s in symbols) {
							var nstr:String = s.className;
							if (r2.match(nstr) ) {
								var p = r2.matched(1);
								s.className = p + dest ;
								dir = r2.matched(2);
								
							} 
		
						}
					case TActionScript3(data, context): 
						
						var inputabc:BytesInput = new BytesInput(data);
						var r:format.abc.Reader = new format.abc.Reader (inputabc);
						var abcData:ABCData = r.read();
					
						
						replaceString(abcData, "AVID",  dest);
						
						
						var outputabc:BytesOutput = new BytesOutput();
						var w:format.abc.Writer = new format.abc.Writer(outputabc);
						w.write(abcData);
						
						tags[i] = TActionScript3(outputabc.getBytes(), context);
						
					
					default:
					
				}
			
			}
			if (dir != "") {
				if (!FileSystem.exists("o/" + dir) ){
					FileSystem.createDirectory("o/" + dir);
				}
				
				//write
				var output:FileOutput = neko.io.File.write("o/" + dir + "/"  + file , true);
				var writer:Writer = new Writer(output);
				writer.write(swf);
				Lib.println(file + " saved");
			}
			
		}
		
	}
	
	
	
	static function replaceString(abcData:ABCData, ori_pack:String, dest_pack:String):Void {
		for (i in 0...abcData.strings.length - 1) {
			var nstr:String = abcData.strings[i];
			if (ori_pack == nstr) {
				abcData.strings[i] = dest_pack;
			} else {
				if (nstr.length > ori_pack.length ) {
					var index:Int = nstr.indexOf(ori_pack);
					
					if (index != -1) {
						
						abcData.strings[i]  = nstr.substr(0, index) + dest_pack + nstr.substr(index +ori_pack.length);
					}
				}
			}
		}
	}
	
	/**
	 * 取得枚举Index<T>的Int值，坑爹的haxe枚举值
	 */
	static function getEnumValue<T>(e:Index<T>):Int {
		switch(e) {
			case Idx(v):
				return v;
			default:
		}
		return 0;
	}
	/**
	 * index of value
	 */
	static function iov(i:Int):Int {
		
		return i-1;
	}
	
	/**
	 * index of enum value
	 */
	static function ioev<T>(e:Index<T>):Int {
		return getEnumValue(e)-1;
	}
	/**
	 * 取得枚举实例值MName的内部成员name
	 */
	static function getNameOfMName(name:Name):Int {
		switch(name) {
			case  NName( name, ns  ):
				return getEnumValue(name);
			default:
		}
		return 0;
	}
	/**
	 * 取得枚举实例值MName的内部成员ns
	 */
	static function getNsOfMName(name:Name):Int {
		switch(name) {
			case  NName( name, ns  ):
				return getEnumValue(ns);
			default:
		}
		return 0;
	}
	/**
	 * 取得枚举实例值NPublic的内部成员ns
	 */
	static function getValueOfNs(ns:Namespace):Int {
		switch(ns) {
			case  NPublic( ns  ):
				return getEnumValue(ns);
			default:
		}
		return 0;
	}	
	
}

					