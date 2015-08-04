package
{
	import flash.display.Sprite;
	import fl.controls.Label;
	import flash.utils.Timer;
    import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	public class Chart extends Sprite
	{
		private var txtArea:TextField = new TextField();
		//private var LAG:int = 5000;
		//public  var txtArea1:TextField = new TextField();
		private var msg:Array = new Array("", "", "", "", "", "", "", "", "", "", "", "", "", "", "");
		public var nMsg:int;
		private var allText:String;
		var format1: TextFormat = new TextFormat();
		public function Chart()
		{
			trace("constructor");
			nMsg = 0;
			//this.width = 850;
			//this.height = 100;
			txtArea.x = 0;
			txtArea.y = 0;
			//txtArea1.x = 0;
			//txtArea1.y = -20;
			txtArea.width = 250;
			txtArea.height = 480;
			format1.font = "Verdana";
			format1.underline = false;
			format1.align = "left";
			txtArea.selectable = false;
			txtArea.mouseEnabled = false;
			txtArea.setTextFormat(format1);
			//txtArea1.selectable = false;
			//txtArea1.mouseEnabled = false;
			//txtArea1.setTextFormat(format1);
			//setMsg('12345678','01234567890123456789012345678901234567890123456789012345','ff0000');
			//txtArea.text = "Label";
			//txtArea.htmlText = "";
			txtArea.alpha = 0.6;
			//txtArea1.text = "Label1";
			addChild(txtArea);
			//addChild(txtArea1);
			//var a:int = 1024;
			//trace(a.toString(16))
			
		}
		
		private function _setMsg(_msgText:String)
		{
			if (nMsg < 15){
				msg[14 - nMsg] = _msgText;
				nMsg += 1;
			}
			else{
				for(var i:int = 0; i < 14; i += 1){
					msg[14 - i] = msg[14 - i - 1];
				}
				msg[msg.length - 1] = _msgText;
			}

			//allText = msg[0] + "\n" + msg[1] + "\n" + 
			//				  msg[2] + "\n" + msg[3] + "\n" + 
			//				  msg[4] + "\n" + msg[5] + "\n" + msg[6] ;
			
			allText = "";
			for (var i:int = 0; i < 15; i += 1){
				allText = allText + msg[14 - i] + "\n"
			}
					txtArea.htmlText = allText;
		}
		
		//private function timerHandler(e:TimerEvent)
		//{
		//	if (nMsg > 0)
		//	{
		//		//trace("in handler")
		//		timer1 = timer2;
		//		timer2 = timer3;
		//		timer3 = timer4;
		//		timer4 = timer5;
		//		timer5 = new Timer(LAG,1);
		//		msg[0] = msg[1];
		//		msg[1] = msg[2];
		//		msg[2] = msg[3];
		//		msg[3] = msg[4];
		//		msg[4] = "";
		//		nMsg -= 1;
		//		timer5.addEventListener("timer", timerHandler);
		//		timer5.start();
		//		allText = msg[0] + "\n\n" + msg[1] + "\n\n" + 
		//						  msg[2] + "\n\n" + msg[3] + "\n\n" + 
		//						  msg[4];
		//				txtArea.htmlText = allText;
		//	}
		//}
		
		public function setMsg(nickName:String, _msg:String, color:String)
		{
			var textM:String = "<font color=\"#" + color + '">' + nickName + ":</font> " + _msg;
			if (textM.length > 70)
			{
				textM = textM.substr(0,65) + '\n' + textM.substring(65,textM.length);
			}
			_setMsg(textM);
		}
	}
}
