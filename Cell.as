package {
	import flash.geom.Point;
	import flash.display.Sprite;
	import flash.display.Shape;
	import fl.motion.Color;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.display.BitmapData;
	import flash.display.LineScaleMode;
	import flash.geom.Matrix;
	import flash.display.Graphics;

	public class Cell extends Body {

		private var maxX: Number = 50000;
		private var maxY: Number = 50000;
		protected var _points: Array = new Array();
		protected var pointsCount: uint;
		protected var color: Number;
		protected var _name: CellName;
		private var _mass: CellName;

		private var p1: Point = new Point();
		private var p2: Point = new Point();

		private var pointsAcc: Array = new Array();
		private var tPointsAcc: Array = new Array();

		public function Cell(_x: Number, _y: Number, size: Number, color: Number = 0x0000FF, _isVir: Boolean = false, nd: Boolean = true, md: Boolean = false, nickname: String = "Cell") {
			this.x = _x;
			this.y = _y;
			this._size = size;

			this.color = _isVir ? 0x00FF00 : color;

			var _thornCoeff: Number = 1;
			pointsCount = 2 * Math.floor(Math.sqrt(20 * _size));
			var k: Number = 2 * Math.PI / pointsCount;
			for(var i: int = 0; i < pointsCount; i++) {
				_thornCoeff = (i % 2) && _isVir ? 0.9 : 1;
				//ВНИМАНИЕ! Стоит обратить внимание, что тут под сайзом точки, передаваемым третьим параметром, понимается ее коэффициент деформации.
				//При желании можно изменить это: передавать единичный вектор и настоящую удаленность от центра, но тогда нужно менять hitCells.
				_points.push(new CellPoint(_size * Math.sin(i * k) * _thornCoeff, _size * Math.cos(i * k) * _thornCoeff));
			}
			rounderObject = new Shape();
			addChild(rounderObject);

			if(nickname == null)
				trace(_isVir);
			if(!_isVir && nd) {
				trace(nickname);
				_name = new CellName(size, nickname);
				if(md) {
					var textH: Number = _name.getTH();
					_name.setY(-textH / 2 - 2.5)
				}
				addChild(_name);
			}

			if(!_isVir && md) {
				_mass = new CellName(size, String(Math.round(size)));
				var textHm: Number = _mass.getTH();
				_mass.setY(textHm / 4 + 2.5)
				addChild(_mass);
			}

			this.cacheAsBitmap = false;
			draw();

		}
		
		public static function hitCells(a: Cell, b: Cell):void{
			//trace("1")
			var aX:Number = a.x;
			var aY:Number = a.y;
			var aSize:Number = a._size;
			
			var bX:Number = b.x;
			var bY:Number = b.y;
			var bSize:Number = b._size;
			
			var dist2:Number = (aX - bX)*(aX - bX) + (aY - bY)*(aY - bY);
			var sSize:Number = bSize+aSize;
			if (dist2 >= sSize*sSize){
				//return a;
				return;
			}
			bSize *= bSize;
			bSize = 1/bSize;
			aSize *= aSize;
			//trace("2")
			var radius:Number;
			var apX:Number;
			var apY:Number;
			//trace("3")
			for (var i:int = 0; i < a.pointsCount; i += 1){
				//trace("4")
				var point:CellPoint = a._points[i];
				apX = point.sx() + aX;
				//trace("4.1")
				apY = point.sy() + aY;
				//trace("4.2")
				dist2 = ((apX - bX)*(apX - bX) + (apY - bY)*(apY - bY))*bSize;
				//trace("4.3")
				if (dist2 > 1){
					continue;
				}
				//trace("5")
				radius = point.size();
				var r2:Number = radius*radius;
				while((dist2 < r2*r2) && (dist2 < 1) && (radius > 0.7)){
					//trace("5")
					point.decreaseSize(0.05);
					r2 -= 0.0025;
					radius -= 0.05;
					apX = point.sx() + aX;
					apY = point.sy() + aY;
					dist2 = ((apX - bX)*(apX - bX) + (apY - bY)*(apY - bY))*bSize;
					
				}
				//trace("6")
			}
			//return a;
		}


		private function checkBound(cp: CellPoint, game: Game, _pointsAcc: Array): Boolean {
			if((cp.sx()*1.421 + this.x < game.clb) ||
				(cp.sx()*1.421 + this.x > game.crb) ||
				(cp.sy()*1.421 + this.y < game.ctb) ||
				(cp.sy()*1.421 + this.y > game.cbb)) {
				cp.decreaseSize(0.01);
				_pointsAcc.push(cp);
				return false;
			}
			return true;
		}

		public function hbTest(game: Game) {
			var cX:Number = this.x;
			var cY:Number = this.y;
			var cSize:Number = this._size;
			var pX;
			var pY;
			for (var i:int = 0; i < pointsCount; i += 1){
				pX = _points[i].sx() + cX;
				pY = _points[i].sy() + cY;
				while((pX > game.crb || pX < game.clb || pY < game.ctb || pY > game.cbb) && (this._points[i].size() > 0.55)){
					this._points[i].decreaseSize(0.05);
					pX = this._points[i].sx() + cX;
					pY = this._points[i].sy() + cY;
				}
			}

		}

		public override function set csize(_size: Number) {
			this._size = _size;
			this.rounderObject.width = _size +_size;
			this.rounderObject.height = _size + _size;
			if (_name!= null)
				_name.setSize(_size);
		}

		public function recovery() {
			for(var i: int = 0; i < pointsCount; i++) {
				_points[i].setSize(1);
			}
		}

		public function smooth() {
			for(var i: int = 0; i < pointsCount; i++) {
				_points[i].setSize((_points[(i + pointsCount - 1) % pointsCount].size() + _points[(i + pointsCount - 2) % pointsCount].size() + _points[(i + 1) % pointsCount].size() + _points[(i + 2) % pointsCount].size() + 4 * _points[i].size()) / 8);
			}
		}

		public function draw() {
			var gr:Graphics = rounderObject.graphics;
			gr.clear();
			gr.beginFill(color);
			gr.lineStyle(3, color + 0x006600, 1.0, false, LineScaleMode.NONE);
			gr.moveTo(_points[0].sx(), _points[0].sy());

			for(var i: int = 0; i < pointsCount; ++i) {
				gr.lineTo(_points[i].sx(), _points[i].sy());
			}
		}
	}
}
