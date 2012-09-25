package
{
	import com.childoftv.xlsxreader.Worksheet;
	import com.childoftv.xlsxreader.XLSXLoader;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.utils.ByteArray;
	
	import u3.io.file.U3SimpleFile;
	
	public class XMLConvertJob extends EventDispatcher
	{
		public var fileName:String;
		private var sheetName:String;
		private var data:ByteArray;
		private var rowsCount:int=0;
		private var colsCount:int = 0;
		private var dataRowsCount:int = 0;
		private var xlsLoader:XLSXLoader;
		private var headers:Vector.<String>;
		private var headersCN:Vector.<String>;

		private var isExports:Vector.<String>;
		private var datas:Vector.<Vector.<String>>;
		public function XMLConvertJob(pData:ByteArray, pFileName:String)
		{
			super();
			data = pData;
			fileName = pFileName;
			xlsLoader = new XLSXLoader();
			xlsLoader.addEventListener(Event.COMPLETE, onLoaded);
		}
		
		public function start():void {
			xlsLoader.loadFromByteArray(data);
		}
		protected function onLoaded(event:Event):void
		{
			var sheetsName:Vector.<String> = xlsLoader.getSheetNames();
			if (sheetsName.length == 0){
				this.dispatchEvent(new XLSEvent(XLSEvent.NO_SHEET));
				return;
			}
			
			sheetName = sheetsName[0];
			
			var sheet:Worksheet = xlsLoader.worksheet(sheetName);
			
			//第一行： 中文注释
			//第2行： Both/Excluded/Client/Server 是否需要这个字段
			//第3行: 英文注释
			
			//需要判断一共有多少行，多少列
			var i:int;
			var j:int;
			var v:String;
			for (i=1;i<=20000;i++){
				v = sheet.getCellValue("A" + i);
				if (v == ""){
					rowsCount = i -1;
					dataRowsCount = rowsCount - 3;
					break;
				}
			}
			if (rowsCount < 3){
				this.dispatchEvent(new XLSEvent(XLSEvent.NOT_HEADER));
				return;
			}
			//假设最多26*26列数据
			var maxCols:int = 26*26;
			for (i=1;i<=maxCols;i++){
				var colA:String = n2A(i);
				v = sheet.getCellValue(colA + 2);
				if (v == ""){
					colsCount = i - 1;
					break;
				}
			}
			trace("rows=" + rowsCount + ",cols=" + colsCount);
			//初始化
			headers = new Vector.<String>(colsCount);
			headersCN = new Vector.<String>(colsCount);

			isExports = new Vector.<String>(colsCount);
			datas = new Vector.<Vector.<String>>(dataRowsCount);
			for (i=0;i<dataRowsCount;i++){
				datas[i] = new Vector.<String>(colsCount);
			}
			
			for (i=0;i<colsCount;i++){
				isExports[i] = sheet.getCellValue(n2A(i+1) + 2);
			}
			for (i=0;i<colsCount;i++){
				headers[i] = sheet.getCellValue(n2A(i+1) + 3);
				headersCN[i] = sheet.getCellValue(n2A(i+1) + 1);
			}
			for (i=0;i<dataRowsCount;i++){
				for (j=0;j<colsCount;j++){
					datas[i][j] = sheet.getCellValue(n2A(j+1) + (i+4));

				}
			}
	
			
			//搞定，
			//开始保存文件
			var xmlClient:String = '<?xml version="1.0" encoding="UTF-8"?>' + "\n";
			var xmlServer:String = '<?xml version="1.0" encoding="UTF-8"?>' + "\n";
			
			//加上注释
			xmlClient += "<!--";
			xmlServer += "<!--";

			for (j=0;j<colsCount;j++){
				if (isExports[j] == "Both"){
					xmlClient += headers[j] + "=" + headersCN[j] + "  ";
					xmlServer += headers[j] + "=" + headersCN[j] + "  ";
				} else if (isExports[j] == "Client"){
					xmlClient += headers[j] + "=" + headersCN[j] + "  ";
					
				} else if (isExports[j] == "Server"){
					xmlServer += headers[j] + "=" + headersCN[j] + "  ";
					
				}
				

			}
			xmlClient += "-->" + "\n";
			xmlServer += "-->" + "\n";

			
			xmlClient += "<root>" + "\n";
			xmlServer += "<root>" + "\n";

			for (i=0;i<dataRowsCount;i++){
				var clientRowStr:String = "\t" + "<data ";
				var serverRowStr:String = "\t" + "<data ";

				for (j=0;j<colsCount;j++){
					var headerName:String = headers[j];
					var value:String = escape(datas[i][j]);
					if (isExports[j] == "Both"){
						clientRowStr += headerName + '="' + value + '" ' ; 
						serverRowStr += headerName + '="' + value + '" ' ; 
					} else if (isExports[j] == "Client"){
						clientRowStr += headerName + '="' + value + '" ' ; 

					} else if (isExports[j] == "Server"){
						serverRowStr += headerName + '="' + value + '" ' ; 
						
					}
					
				}
				clientRowStr += "/>" ;
				serverRowStr += "/>" ;

				xmlClient += clientRowStr + "\n";
				xmlServer += serverRowStr + "\n";

			}
			xmlClient += "</root>";
			xmlServer += "</root>";
			
			var pName:String = fileName.replace(".xlsx", "");

			U3SimpleFile.saveStringToDesktopFile("Client/" + pName + ".xml", xmlClient);
			U3SimpleFile.saveStringToDesktopFile("Server/" + pName + ".xml", xmlServer);

			
			this.dispatchEvent(new Event(Event.COMPLETE));
		}
		
		
		private static function escape(str:String):String {
			str = str.replace(/>/g, '&gt;');
			str = str.replace(/</g, '&lt;');
			str = str.replace(/"/g, '&quote;');
			return str;
		}
		
		//数字-> 字母转换， 1-> A
		private static function n2A(n:int):String {
			var ar:Array = ['A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z'];
			
			var r:int = (n-1) % 26 + 1;
			var l:int = (n-1) / 26;
			var colA:String = "";
			if (l){
				colA += ar[l-1];
			}
			colA += ar[r-1];
			
			
			return colA;
		}
		
		
	}
}