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

		private var msg:Array = new Array("", "", "", "", "", "", "", "", "", "", "", "", "", "", "");
		public var nMsg:int;
		private var allText:String;
		var format1: TextFormat = new TextFormat();
		public function Chart()
		{
			trace("constructor");
			nMsg = 0;
			txtArea.x = 0;
			txtArea.y = 0;
			txtArea.width = 250;
			txtArea.height = 480;
			format1.font = "Verdana";
			format1.underline = false;
			format1.align = "left";
			txtArea.selectable = false;
			txtArea.mouseEnabled = false;
			txtArea.setTextFormat(format1);
			txtArea.alpha = 0.6;
			addChild(txtArea);
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
