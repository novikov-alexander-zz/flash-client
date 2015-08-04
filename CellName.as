package {

	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.display.Sprite;
	import flash.text.TextFormat;
	import flash.filters.GlowFilter;
	import flash.display.BitmapData;
	import flash.display.Bitmap;

	public class CellName extends Sprite {
		var format1: TextFormat = new TextFormat();
		private var textField: TextField = new TextField();
		private var _size: Number;
		private var bmp:Bitmap;
		private var shadow: GlowFilter = new GlowFilter(0, 1.0, 4, 4, 60, 1);
		
		public function size() {
			return _size;
		}
		
		public function getTH(): Number{
			return textField.textHeight;
		}
		
		public function setX(_x: Number): void{
			bmp.x = _x;
		}
			
		
		public function setY(_y: Number): void{
			bmp.y = _y;
		}
		public function CellName(_size: Number = 10.0, _text: String = "") {
			super();
			this._size = _size;
			if (_text == null)
				_text = "Unknown cell";
			this.textField.text = _text;

			this.format1.font = "Verdana";
			this.format1.color = 0xFFFFFF;
			this.format1.underline = false;
			this.textField.selectable = false;

			this.textField.filters = [shadow];
			this.textField.gridFitType = flash.text.GridFitType.SUBPIXEL;
			
			setSize(_size);			
		}

		public function setSize(size: Number): void {
			removeChildren();
			_size = size;
			var nameLength: int = Math.max(Math.floor(1.6 * _size), 20 * this.textField.text.length);
			this.textField.width = nameLength;
			this.format1.size = Math.floor(nameLength / Number(textField.text.length));
			this.textField.setTextFormat(format1);

			var bmpd:BitmapData = new BitmapData(textField.textWidth+4, textField.textHeight+textField.textHeight, true, 0);			
			bmpd.draw(textField);
			bmp = new Bitmap(bmpd)
			addChild(bmp);
			
			bmp.x = -textField.textWidth / 2;
			bmp.y = -textField.textHeight / 2;
		}
	}
}