package  {
	import flash.display.Sprite;
	import flash.display.Shape;
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	
	public class Body extends Sprite {

		protected var _size: Number;
		protected var rounderObject:Shape = new Shape();

		public function get csize() {
			return _size;
		}
		
		public function set csize(_size:Number){
			this._size=_size;
			rounderObject.height = _size*2;
			rounderObject.width = _size*2;
		}
	}
	
}
