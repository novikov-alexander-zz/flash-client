package {
	import flash.geom.Point;
	import flash.display.Sprite;
	import flash.display.Shape;
	import fl.motion.Color;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.display.BitmapData;
	import flash.geom.Matrix;

	public class Protoplasm extends Cell{
		public function Protoplasm(_x: Number, _y: Number, _gx: Number, _gy: Number, size: Number, color: Number = 0x0000FF) {
			super(_x, _y, _gx, _gy, size, color, false, false)
		}
	}
}