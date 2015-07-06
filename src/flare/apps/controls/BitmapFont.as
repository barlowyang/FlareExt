package flare.apps.controls
{
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.filters.BitmapFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	public class BitmapFont extends Object
	{
		public static const LEFT:uint = 1;
		public static const CENTER:uint = 2;
		public static const RIGHT:uint = 4;
		
		public static const TOP:uint = 8;
		public static const MIDDLE:uint = 16;
		public static const BOTTOM:uint = 32;
		
		private static var _textField:TextField = new TextField();
		
		private static var _vertex:Vector.<Number> = new Vector.<Number>();
		
		private static var _index:Vector.<int> = new Vector.<int>();
		
		private static var _uvs:Vector.<Number> = new Vector.<Number>();
		
		private var _bmp:BitmapData;
		
		private var _matrix:Matrix;
		
		private var _rect:Vector.<Rectangle>;
		
		private var _dots:Number;
		
		public function BitmapFont(txtFmt:TextFormat = null, filterArr:Array = null)
		{
			super();
			_matrix = new Matrix();
			createFont(txtFmt, filterArr);
			_dots = textWidth("...");
		}
		
		private function createFont(txtFmt:TextFormat, filterArr:Array) : void
		{
			var char_ascii:int = 0;
			_textField.text = "|";
			_textField.autoSize = "left";
			_textField.antiAliasType = "advanced";
			_rect = new Vector.<Rectangle>();
			if(txtFmt)
			{
				_textField.defaultTextFormat = txtFmt;
			}
			_bmp = new BitmapData(512, 512, true, 0);
			var tmp_matrix:Matrix = new Matrix();
			char_ascii = 32;
			while(char_ascii < 255)
			{
				_textField.text = String.fromCharCode(char_ascii);
				if(tmp_matrix.tx + _textField.width >= _bmp.width)
				{
					tmp_matrix.tx = 0;
					tmp_matrix.ty = tmp_matrix.ty + _textField.height;
				}
				_bmp.draw(_textField, tmp_matrix, null, null, null, true);
				_rect[_rect.length] = new Rectangle(tmp_matrix.tx,tmp_matrix.ty,_textField.width + 4,_textField.height);
				tmp_matrix.tx = tmp_matrix.tx + (_textField.width + 5);
				char_ascii++;
			}
			var bmp_t:BitmapData = new BitmapData(_bmp.width, tmp_matrix.ty + _textField.height + 4, true, 0);
			bmp_t.draw(_bmp, new Matrix(1, 0, 0, 1, -2));
			_bmp.dispose();
			_bmp = bmp_t;
			if(filterArr)
			{
				for each(var bitFilter:BitmapFilter in filterArr)
				{
					_bmp.applyFilter(_bmp, _bmp.rect, new Point(), bitFilter);
				}
			}
		}
		
		public function textWidth(msg:String, max_w:Number = Number.MAX_VALUE) : Number
		{
			var rect_t:Rectangle = null;
			var char_idx:int = 0;
			var char_ascii:* = 0;
			if(!msg || msg.length == 0)
			{
				return 0;
			}
			var msg_len:int = msg.length;
			var rect_len:int = _rect.length;
			var res_len:int = 0.0;
			char_idx = 0;
			while(char_idx < msg_len)
			{
				char_ascii = msg.charCodeAt(char_idx) - 32;
				if(char_ascii > rect_len)
				{
					char_ascii = 0;
				}
				if(char_ascii < 0)
				{
					char_ascii = 0;
				}
				rect_t = _rect[char_ascii];
				res_len = res_len + (rect_t.width - 8);
				if(res_len > max_w)
				{
					return max_w;
				}
				char_idx++;
			}
			return res_len;
		}
		
		public function textHeight() : Number
		{
			return _rect[0].height;
		}
		
		public function draw(graph:Graphics, x_t:Number, y_t:Number, w_t:Number, h_t:Number, msg:String, align_type:uint = 0, row_t:int = 0) : void
		{
			var rect_t:Rectangle = null;
			var char_idx:int = 0;
			var char_ascii:int = 0;
			var msg_w:Number = textWidth(msg);
			var txt_h:Number = _rect[0].height;
			if(_dots >= w_t)
			{
				return;
			}
			var is_over_w:* = false;
			if(msg_w > w_t)
			{
				is_over_w = true;
				msg_w = w_t;
			}
			if(align_type & CENTER)
			{
				x_t = x_t + Math.ceil(w_t * 0.5 - msg_w * 0.5);
			}
			else if(align_type & LEFT)
			{
				x_t = x_t + 0;
			}
			else if(align_type & RIGHT)
			{
				x_t = x_t + (w_t - msg_w);
			}
			
			if(align_type & MIDDLE)
			{
				y_t = y_t + Math.ceil(h_t * 0.5 - txt_h * 0.5);
			}
			else if(align_type & TOP)
			{
				y_t = y_t + 0;
			}
			else if(align_type & BOTTOM)
			{
				y_t = y_t + (h_t - txt_h);
			}
			
			graph.lineStyle();
			var msg_len:int = msg ? msg.length : 0;
			var start_x:int = x_t;
			var start_y:int = y_t;
			char_idx = 0;
			while(char_idx < msg_len)
			{
				char_ascii = msg.charCodeAt(char_idx) - 32;
				if(char_ascii > _rect.length)
				{
					char_ascii = 0;
				}
				rect_t = _rect[char_ascii];
				_matrix.tx = -rect_t.x + start_x;
				_matrix.ty = -rect_t.y + start_y;
				graph.beginBitmapFill(_bmp, _matrix);
				graph.drawRect(start_x, start_y, rect_t.width, rect_t.height);
				start_x = start_x + (rect_t.width - 8);
				if(row_t <= 0)
				{
					if(is_over_w && start_x - x_t + 4 + _dots > w_t)
					{
						is_over_w = false;
						char_idx = -1;
						msg_len = 3;
						msg = "...";
					}
				}
				else if(is_over_w && start_x - x_t + 4 >= w_t)
				{
					start_x = x_t;
					start_y = start_y + (txt_h - 4);
					row_t--;
				}
				
				char_idx++;
			}
		}
	}
}
