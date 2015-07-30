package {
	import flash.geom.Point;
	import flash.display.Shape;
	import fl.motion.Color;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.display.BitmapData;
	import flash.geom.Matrix;

	public class Feed extends Body {

		private var color: Number;
		public var _gx:Number, _gy:Number;
		public var fid:uint;

		public function Feed(_x: Number, _y: Number, _gx:Number, _gy:Number, id: uint) {
			this.x = _x;
			this.y = _y;
			this._gx = _gx;
			this._gy = _gy;
			this.fid = id;
			this._size = 3;
			var size: Number = 4;
			switch(id%10) {
				case 0:
					this.color = 0xFF3333;
					break;
				case 1:
					this.color = 0x0033FF;
					break;
				case 2:
					this.color = 0xCC00CC;
					break;
				case 3:
					this.color = 0x660066;
					break;
				case 4:
					this.color = 0x0099FF;
					break;
				case 5:
					this.color = 0xCC3333;
					break;
				case 6:
					this.color = 0x996600;
					break;
				case 7:
					this.color = 0x9933CC;
					break;
				case 8:
					this.color = 0x66FF00;
					break;
				case 9:
					this.color = 0xFFFF33;
					break;
			}

			/*var k = 2 * Math.PI / 5;
			for (var i: Number = 0; i < 5; i++) {
				_points.push(new CellPoint(_size * Math.sin(i * k), _size * Math.cos(i * k)));
			}
		*/


			rounderObject = new Shape();
			addChild(rounderObject);

			this.cacheAsBitmap = false;
			draw();

		}

		public function hitCell(c: Cell): Boolean {
			var dx:Number = c.x-x;
			var dy:Number = c.y-y;
			if (((dx-c.csize)*(dx+c.csize)+dy*dy) < 0)
					return true;
			return false;
		}
		
		
		public function hitWall(dx:Number, dy:Number): Boolean {
			var _x:Number = x - dx;
			var _y:Number = y - dy;

			if((_x < -10) || (_x > 860) || (_y < -10) || (_y > 660)){
				return true;
			}
			return false;
		}
		
		public function draw() {
			//drawToBuf();
			rounderObject.graphics.clear();

			rounderObject.graphics.beginFill(color);
			rounderObject.graphics.lineStyle(1, color + 0x001100);
			/*rounderObject.graphics.moveTo(_points[0].sx(), _points[0].sy());

			for (var i: Number = 0; i < 5; i++) {
				rounderObject.graphics.lineTo(_points[i].sx(), _points[i].sy());
			}*/
			rounderObject.graphics.drawCircle(0, 0, _size);
		}
	}
}