package {
	import playerio.*;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.display.Shape;
	import flash.events.MouseEvent;
	import flash.display.Shader;
	import flash.geom.Point;
	import flash.display.StageScaleMode;
	import flash.geom.Rectangle;
	import flash.events.KeyboardEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFieldType;
	import fl.controls.Label;
	import flash.utils.Dictionary;

	public class Game extends Sprite {
		//---------------------------------------
		// PUBLIC VARIABLES
		//---------------------------------------
		public var gameID: String = "cells2-5yrswumyieeskxfpoge6q";
		public var userID: String;
		public var connection: Connection;
		
		//Интерфейс для взаимодействия с меню(Menu.as)
		public var showMass: int = 0;
		public var showNick: int = 1;
		public var showSkins: int = 0;
		public var isFFA: int = 1;
		public var themeNo: int = 1;
		public var nickName: String = new String("Player");
		
		//Границы игрового поля в координатах клиента 
		//(С учетом масштаба и координаты центра экрана)
		public var ctb:Number = 0, clb:Number = 0, crb:Number = 5000, cbb:Number = 5000;
		
		//---------------------------------------
		// PRIVATE VARIABLES
		//---------------------------------------
		private var cl:Client;

		private const maxPlayers:int = 150;
		//TODO сделать на сервере так, чтобы id еды был меньше константы. 
		//Тогда можно заменить Dictionary здесь на Vector.<Feed>(const)
		private var _feed: Dictionary = new Dictionary();
		private var renderedCells:Vector.<BodiesDictionary> = new Vector.<BodiesDictionary>(maxPlayers);
		private var waitingCells:Vector.<BodiesDictionary> = new Vector.<BodiesDictionary>(maxPlayers);
		private var renderedVirAndPlasm:Dictionary = new Dictionary();
		private var waitingVirAndPlasm:Dictionary = new Dictionary();
		
		private var isMouseDown: Boolean = false;
		private var messageString: TextField = new TextField();
		
		private var lastX:Number = 0, lastY:Number = 0, nextX:Number = 100, nextY:Number = 100;
		private var xArea:Number = 274;
		private var yArea:Number = 214;
		private var lastxm:Number = 0;
		
		private var fsu:int = -1;
		
		private var sMBShowed: Boolean = false;
		
		private var bckg:Grid = null;
		private var world:Sprite = new Sprite();
		private var feedSpr:Sprite = new Sprite;
		private var playersCellsInstances:Sprite = new Sprite();
		private var msgBox:ShortMessageBox = new ShortMessageBox();
		private var menu:Menu;
		private var cScr:ConnectingScreen = new ConnectingScreen();
		
		private var nnArr:Array = new Array(maxPlayers);
		
		private var tb:int = 0, lb:int = 0, rb:int = 2505, bb:int = 2505;
		
		private var chartWindow:Chart = new Chart();
		
		private var vkapi:VkApi;
		private var nextMsg:Message;
		
		private var playersGotten:Boolean = false;
		
		private var koeff:Number = 8;
		
		//---------------------------------------
		// CONSTRUCTOR
		//---------------------------------------

		/**
		 * @constructor
		 */
		public function Game() {
			super();

			if (stage == null) {
				trace("null");
			} else {
				trace(stage.name);
			}
			
			(stage == null) ? addEventListener(Event.ADDED_TO_STAGE, init) : init(null);
			
			bckg = new Grid();
			//bckg.cacheAsBitmap = true;
			vkapi = new VkApi(stage);
			addChildAt(bckg,0);
			addChildAt(feedSpr,1);
			addChildAt(playersCellsInstances,2);
			addChildAt(world,3);
			addChildAt(msgBox,4);
			msgBox.visible = false;
			msgBox.y = stage.stageHeight - msgBox.height;
			chartWindow.visible = true;
			var myC:FPSMemCounter = new FPSMemCounter(0);
			addChildAt(myC,4);
			addChildAt(chartWindow,6);
			addChildAt(menu,7);
			chartWindow.y = stage.stageHeight - chartWindow.height- 50;
			addChild(vkapi);
			vkapi.y = stage.stageHeight - vkapi.height;
			PlayerIO.connect(stage, gameID, "public", userID, "", null, handleConnect, handleError);
			for (var i:int = 150; i>=0; i--){
				waitingCells[i] = new BodiesDictionary();
				renderedCells[i] = new BodiesDictionary();
			}
			addChild(cScr);
		}

		function buttonPressed(event: MouseEvent) {
			isMouseDown = true;
			messageString.setTextFormat(new TextFormat("Verdana",10,0xFFFFFF,false,false,false));
			stage.focus = messageString;
			messageString.type = TextFieldType.INPUT;
			if (messageString.text.length > 49){
				messageString.type = TextFieldType.DYNAMIC;
			}
		}

		function buttonReleased(event: MouseEvent) {
			isMouseDown = false;
			stage.focus = this;
			messageString.type = TextFieldType.INPUT;
			if (messageString.text != "" || messageString.text != " ") {
				connection.send("playerSaying", messageString.text);
				messageString.text = "";
			}
		}

		private function openSMBox():void{
			msgBox.visible = sMBShowed = true;
		}
		private function closeSMBox():void{
			msgBox.visible = sMBShowed = false;
		}
		
		private function checkMK(e:KeyboardEvent){
			if ((e.keyCode == 96) || (e.keyCode == 48)){
					closeSMBox();
			} else if ((48 < e.keyCode) && (e.keyCode < 58)){
				closeSMBox();
				connection.send("playerSaying", msgBox.messages[e.keyCode - 48]);
			} else if ((96 < e.keyCode) && (e.keyCode < 106)){
				closeSMBox();
				connection.send("playerSaying", msgBox.messages[e.keyCode - 96]);
			}
		}
		function displayKeyDown(e: KeyboardEvent) {

			if (!isMouseDown) {
				if (connection != null) {
					if (e.keyCode == 32) connection.send("split"); //отправка на сервер сообщения о нажатии пробела
					if (e.keyCode == 87) connection.send("throwpart"); // отправка на сервер сообщения о нажатии на "w"					
					if (sMBShowed){
						checkMK(e);
					} else {
						if (e.keyCode == 67) openSMBox();
						if (messageString.text.length > 49){
							messageString.type = TextFieldType.DYNAMIC;
							//stage.focus = this;
						}
					}
				}
			}
			if (messageString.text.length > 49){
					messageString.type = TextFieldType.DYNAMIC;
					//stage.focus = this;
				}
		}

		private function init(event: Event): void {
			if (event != null) {
				removeEventListener(Event.ADDED_TO_STAGE, init);
			}
/*
			for (var i: int = 0; i < 10; i++) {
				_feed[i] = new Vector.<Feed>();
				_feedPtr[i] = 0;
			}
*/

			userID = "User" + Math.floor(Math.random() * 1000).toString(); //генерация Айди для текущего игрока
			// TODO предусмотреть чтобы он не повторялся с другими игроками

			// соединение с сервером
			// gameID - идентификатор хостинг-сервера. Не трогать
			// userID - ID текущего игрока, запустившего данное приложение 
			// handleConnect - обработчик успешного соединения с сервером
			// handleError - обработчик ошибки соединения
			
			menu = new Menu(this);
			
			menu.x = (xArea/2)/xArea*stage.stageWidth;
			menu.y = (yArea/2)/yArea*stage.stageHeight;
			menu.width = 200;
			menu.height = 300;
			menu.alpha = 0.6;
			//addChild(menu);
			addChild(messageString);
			messageString.visible = true;
			messageString.x = 10;
			messageString.y = 100;
			messageString.alpha = 0.8;
			messageString.width = 200;
			messageString.type = TextFieldType.INPUT;
			//goPlay();
		}
		
		public function onRoomListGet(result):void{
			for each (var room in result){
				if (room.onlineUsers < 150){
					trace(room.id);
					cl.multiplayer.createJoinRoom(
					room.id, // Идентификатор комнаты. Если устаноить null то идентификатор будет присвоен случайный
					"MyCode", // Тип игры запускаемый на сервере (привязка к серверному коду)
					true, // Должна ли конмата видима в списке комнат? (client.multiplayer.listRooms)
					{}, // Какие-либо данные пользователя.
					{},
					handleJoin, // Указатель на метод который будет вызван при успешном подключении к комнате.
					handleError // Указатель на метод который будет вызван в случаее ошибки подключения
					);
					return;
				}
			}
			cl.multiplayer.createJoinRoom(null,  //Генерируем рандомный ID
									 "MyCode", // Тип игры запускаемый на сервере (привязка к серверному коду)
									  true, // Должна ли конмата видима в списке комнат? (client.multiplayer.listRooms)
									  {}, // Какие-либо данные. Эти данные будут возвращены в список комнат. Значения могут быть изменены на сервере.
									  {},
									  handleJoin, // Указатель на метод который будет вызван при успешном подключении к комнате.
									  handleError // Указатель на метод который будет вызван в случаее ошибки подключения
									  );
		}

		public function goPlay():void{
			menu.visible = false;
			vkapi.visible = false;
			playersGotten = false;
			fsu = 0;
			trace("goPlay()");
			//lastX = 0;
			//lastY = 0;
			//nextX = 0;
			//nextY = 0;
			// Создаем или подключаемся к игровой комнате "test"
			connection.disconnect();
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, buttonPressed);
			stage.removeEventListener(MouseEvent.MOUSE_UP, buttonReleased);

			stage.removeEventListener(KeyboardEvent.KEY_DOWN, displayKeyDown);

			connection.removeMessageHandler("mouseRequest", sendMouseXY); 

			connection.removeMessageHandler("currentState", update);
			connection.removeMessageHandler("food", addFood);
			connection.removeMessageHandler("*", messageHandler); 
			connection.removeMessageHandler("playersList", playersList);
			connection.removeMessageHandler("saying", onMessageGot);
			connection.removeMessageHandler("playerDead", playerDead);
			
			_feed = new Dictionary();
			if(cl!=null){
				cl.multiplayer.listRooms("MyCode", {}, 0, 0, onRoomListGet,  function(){trace("fail")});
			}/*if(cl!=null) // Если мы подсоединились к серверу
				cl.multiplayer.createJoinRoom(
					"test", // Идентификатор комнаты. Если устаноить null то идентификатор будет присвоен случайный
					"MyCode", // Тип игры запускаемый на сервере (привязка к серверному коду)
					true, // Должна ли конмата видима в списке комнат? (client.multiplayer.listRooms)
					{}, // Какие-либо данные. Эти данные будут возвращены в список комнат. Значения могут быть изменены на сервере.
					{}, // Какие-либо данные пользователя.
					handleJoin, // Указатель на метод который будет вызван при успешном подключении к комнате.
					handleError // Указатель на метод который будет вызван в случаее ошибки подключения
				);
				*/	
		}
		
		private function playerDead(m: Message):void{
			/*menu.visible = true;
			connection.removeMessageHandler("mouseRequest", sendMouseXY);
			connection.removeMessageHandler("currentState", playerDead);
			connection.removeMessageHandler("playerDead", playerDead);
			connection.disconnect();
			this.stopAllMovieClips();
			menu.startNew();*/
			goPlay();
		}


		/**
		 * @private
		 */
		// При успешном соединении:
		private function handleConnect(client: Client): void {
			trace("Connected to server!");
			cl = client;
			
			// Устанавливаем подключение к локальному серверу для отладки
			//client.multiplayer.developmentServer = "localhost:8184"; //Если закомментить эту строчку, то будет подключение на удаленный сервер
			cl.multiplayer.createJoinRoom(
				"test", // Идентификатор комнаты. Если устаноить null то идентификатор будет присвоен случайный
				"MyCode", // Тип игры запускаемый на сервере (привязка к серверному коду)
				true, // Должна ли конмата видима в списке комнат? (client.multiplayer.listRooms)
				{}, // Какие-либо данные. Эти данные будут возвращены в список комнат. Значения могут быть изменены на сервере.
				{Type:"Spectator"}, // Какие-либо данные пользователя.
				handleJoin, // Указатель на метод который будет вызван при успешном подключении к комнате.
				handleError // Указатель на метод который будет вызван в случаее ошибки подключения
			);
			// создаем новую клетку
			//var cell = new Cell();
			//var cell = new Cell();
			//cell.x = _display.width / 2;
			//cell.y = _display.height / 2;
			//_cells.push(cell);

			removeChild(cScr);
		}

		// отправка на сервер сообщения с текущими координатами мыши
		// срабатывает как ответ на запрос "mouseRequest" с сервера, который поступает каждые 30 мс
		function sendMouseXY(m: Message) {
			nextX = m.getNumber(0);
			nextY = m.getNumber(1);
			if (connection != null) {
				connection.send("currentMouse", lastX+(stage.mouseX-stage.stageWidth/2)/stage.stageWidth*xArea, lastY+(stage.mouseY-stage.stageHeight/2)/stage.stageHeight*yArea);
			}
			//trace("mouse");

		}

		/**
		 * @private
		 */
		private function handleJoin(connection: Connection): void {

			if (connection != null) this.connection = connection;
			stage.addEventListener(MouseEvent.MOUSE_DOWN, buttonPressed);
			stage.addEventListener(MouseEvent.MOUSE_UP, buttonReleased);

			stage.addEventListener(KeyboardEvent.KEY_DOWN, displayKeyDown);
			
			connection.addMessageHandler("mouseRequest", sendMouseXY); // Добавление обработчика сообщения-запроса текущих координат мыши

			connection.addMessageHandler("currentState", update);
			connection.addMessageHandler("food", addFood);
			connection.addMessageHandler("*", messageHandler); // Добавление обработчика прочих сообщений
			connection.addMessageHandler("playersList", playersList);
			connection.addMessageHandler("saying", onMessageGot);
			connection.addMessageHandler("playerDead", playerDead);
			
			//connection.send("playersListRequest");
			connection.send("setNickname", nickName);
		}
		
		private function onMessageGot(m: Message){
			var pid:int = m.getInt(0);
			var msg:String = m.getString(1);
			var nickName:String = nnArr[pid];
			var color:String = "00000000" + pid.toString(16);
			color = color.substring(color.length - 8,color.length);
			trace("----");
			trace(color);
			trace(pid);
			trace(nickName);
			trace(msg);
			trace("----");
			chartWindow.setMsg(nickName, msg, '0000ff');
		}		
		
		
		private function playersList(m: Message) {
			playersGotten = true;
			//trace(m);
			for (var k:int = 0, i: int = 0; i < m.length; k++,i += 2)
			{
				nnArr[m.getInt(i)] = m.getString(i+1);
			}
		}
		
		private function playerLeft(m: Message) {
			var pid:int = m.getInt(0);
			//var k:int = idArr.indexOf(pid);
			//idArr.splice(k,1);
			//nnArr.splice(k,1);
		}
		
		private function onEnterFrame(e: Event) {

			if(menu.visible){
				nextX = nextMsg.getNumber(1);
				nextY = nextMsg.getNumber(2);
			}
			var dx = nextX - lastX;
			var dy = nextY - lastY;

			if(playersGotten)
				drawWorld(nextMsg, dx, dy);
		}
		
		private function drawWorld(m:Message, dx:Number = 0, dy:Number = 0){
			world.removeChildren();
			feedSpr.removeChildren();
			world.graphics.clear();
			playersCellsInstances.removeChildren();
			xArea = m.getNumber(3);
			yArea = m.getNumber(4);
			var curX: Number = lastX + dx/koeff;
			var curY: Number = lastY + dy/koeff;
			var xm:Number = (stage.stageWidth as Number)/xArea;
			var ym:Number = xm;
			bckg.x = -(curX*xm)%(17*xm);
			bckg.y = -(curY*ym)%(17*ym);
			if (xm!=lastxm)
				bckg.drawWithSize(17*xm);//17.1 - это 45/startXm
			lastxm = xm;
			
			var xa:Number = xArea/2 - curX;
			var ya:Number = yArea/2 - curY;
			
			clb = (lb+xa)*xm;
			crb = (rb+xa)*xm;
			ctb = (tb+ya)*ym;
			cbb = (bb+ya)*ym;
			
			world.graphics.lineStyle(10,0);
			world.graphics.moveTo(clb,ctb);
			world.graphics.lineTo(crb,ctb);
			world.graphics.lineTo(crb,cbb);
			world.graphics.lineTo(clb,cbb);
			world.graphics.lineTo(clb,ctb);
		
			for (var i:uint = 5; i < m.length;) {
				var id:uint = m.getInt(i);
				var _gx:Number = m.getNumber(i+1);
				var _gy:Number = m.getNumber(i+2);
				var _x:Number = (_gx + xa)*xm;
				var _y:Number = (_gy + ya)*ym;
				var size:Number;			

				if(id < 1000000 && id != 1000000){
					var virus: Cell = waitingVirAndPlasm[id];
					size = m.getNumber(i + 3)*xm;
					if (virus == undefined){
						virus = new Cell(_x, _y, size, 0x00FF00, true);
						
					} else {
						delete waitingVirAndPlasm[id];
						//var ddx = ((_gx + xArea/2 - m.getNumber(1))*xm-virus.x)/koeff;
						//var ddy = ((_gy + yArea/2 - m.getNumber(2))*ym-virus.y)/koeff;
						//virus.x += ddx;
						//virus.y += ddy;
						virus.x = _x;
						virus.y = _y;
						virus.csize = size;
						virus.recovery();
					}
					
					for each (var c in waitingCells)
						checkCollisions(virus,c);
					for each (c in renderedCells)					
						checkCollisions(virus,c);
					checkCollisions(virus, renderedVirAndPlasm);
					renderedVirAndPlasm[id] = virus;
					world.addChild(virus);
					i+=4;
				} else if(id < 2000000 && id != 1000000){
					var pid:uint = uint((id - 1000000)/1000);
					var cellDict:BodiesDictionary = waitingCells[pid];
					var cell:Cell;
					size = m.getNumber(i + 3)*xm;
					if (cellDict.empty){
						cell = new Cell(_x,_y,size,pid,false,showNick,showMass, nnArr[pid]);
					} else {
						cell = waitingCells[pid][id];
						delete waitingCells[pid][id];
						if (cell == undefined)
							cell = new Cell(_x,_y,size,pid,false,showNick,showMass, nnArr[pid]);
						var ddx = ((_gx + xArea/2 - m.getNumber(1))*xm-cell.x)/koeff;
						var ddy = ((_gy + yArea/2 - m.getNumber(2))*ym-cell.y)/koeff;
						cell.x += ddx;
						cell.y += ddy;
						cell.recovery();
						cell.csize = size;
					}

					for each (var c in renderedCells)
						checkCollisions(cell, c);
					if (renderedCells[pid].empty)
						renderedCells[pid].empty = false;
					renderedCells[pid][id] = cell;
					playersCellsInstances.addChild(cell);
					i+=4;
				} else if (id < 3000000 && id != 1000000){
					var plasm: Protoplasm = waitingVirAndPlasm[id];
					size = m.getNumber(i + 3)*xm;
					if (plasm == undefined){
						plasm = new Protoplasm(_x, _y, size, 0x00FF00);
					} else {
						delete waitingVirAndPlasm[id];
						var ddx = ((_gx + xArea/2 - m.getNumber(1))*xm-plasm.x)/koeff;
						var ddy = ((_gy + yArea/2 - m.getNumber(2))*ym-plasm.y)/koeff;
						plasm.x += ddx
						plasm.y += ddy;
						plasm.csize = size;
						plasm.recovery();
					}
					
					for each (var c in waitingCells)
						checkCollisions(plasm,c);
					for each (c in renderedCells)
						checkCollisions(plasm,c);
					checkCollisions(plasm, renderedVirAndPlasm);
					renderedVirAndPlasm[id] = plasm;
					world.addChild(plasm);
					i+=4;
				} else i+=4;
			}
			
			lastX = curX;
			lastY = curY;
			for (i = 0; i < maxPlayers;i++){
				for each (var cc in renderedCells[i]){
					cc.hbTest(this);
					cc.smooth();
					cc.draw();
				}
			}
			for each (var ca in renderedVirAndPlasm){
					ca.hbTest(this);
					ca.smooth();
					ca.draw();
			}
			var coll:Boolean;
			for each(var fa:Feed in _feed){
				coll = false;
				fa.x = (fa._gx+xa)*xm;
				fa.y = (fa._gy+ya)*ym;
				for (i = 0; i < maxPlayers;i++){
					for each (var ffc:Cell in renderedCells[i]){
						if (fa.hitCell(ffc)){
							coll = true;
							break;
						}
					}
				}
				if (coll)
					delete _feed[fa.fid];
				else {
					if(fa.hitWall(dx,dy)){
						delete _feed[fa.fid];
					}
					else
						feedSpr.addChildAt(fa, 0);
				}
			}
			var tVec:Vector.<BodiesDictionary> = waitingCells;
			waitingCells = renderedCells;
			renderedCells = tVec;
			for (var j:int = maxPlayers; j >= 0; j--)
				renderedCells[j] = new BodiesDictionary(); 
			waitingVirAndPlasm = renderedVirAndPlasm;
			renderedVirAndPlasm = new Dictionary();
		}
		
	public function checkCollisions(cell:Cell, cells:Object):void{
			for each (var s:Cell in cells){
				Cell.hitCells(s,cell);
				Cell.hitCells(cell,s);
				s.smooth();
				cell.smooth();
			}
		}
		
		private function addFood(m:Message){
			for (var i:uint = 0; i < m.length; i+=3){
				var id:uint = m.getInt(i);
				var _gx:Number = m.getNumber(i+1);
				var _gy:Number = m.getNumber(i+2);
				var xm:Number = ((stage.stageWidth as Number)+200)/xArea;
				var ym:Number = xm;
			
				var xa:Number = xArea/2 - lastX - 100/xm;
				var ya:Number = yArea/2 - lastY - 100/xm;
				var _x:Number = (_gx + xa)*xm;
				var _y:Number = (_gy + ya)*ym;
				if (id >=3000000){
					var feed: Feed = _feed[id];
						if (feed == undefined){
							feed = new Feed(_x, _y, _gx, _gy, id);
							_feed[id] = feed;
						}
					i+=3;
					}
				}
		}
		//В сообщении передается массив в котором последовательно идут: 1) айди объекта, 2) X, 3) Y, 4) радиус, далее айди следующего объекта и т.д. 
		//Айди следующие: 
		//0-9 - корм
		//11 - частица клетки
		//13 - вирус
		//Всё что от 1001 и более - клетка (1000 + номер игрока, это чтобы различать игроков)
		private function update(m: Message): void {
			if(fsu == 0){
				lastX = m.getNumber(1);
				lastY = m.getNumber(2);
				nextMsg = m;
				drawWorld(m);
			}
			if (fsu > 0)
				nextMsg = m;
			fsu++;
			if (fsu == 2){
				addEventListener(Event.ENTER_FRAME, onEnterFrame);
			} 
		}

		private function messageHandler(m: Message) {
		}



		/**
		 * @private
		 */
		private function handleError(error: PlayerIOError): void {
			trace(error);
		}

	}

}
