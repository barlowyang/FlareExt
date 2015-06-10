package flare.apps.controls
{
	import flash.display.BitmapData;
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	import flare.apps.core.Style;
	import flare.apps.events.ControlEvent;
	
	public class GradientColor extends Control implements IColorControl
	{
		
		private static var h:int;
		
		private static var v:int;
		
		private static var nullBitmapData:BitmapData;
		
		private static var shape:Shape = new Shape();
		
		private static var matrix:Matrix = new Matrix();
		
		private var _current:ColorKey;
		
		private var _keys:Vector.<ColorKey>;
		
		private var _colors:Array;
		
		private var _alphas:Array;
		
		private var _ratios:Array;
		
		private var _keyMoved:Boolean;
		
		private var _mode:int;
		
		public function GradientColor(tname:String = "", tx:Number = 0, ty:Number = 0, twidth:Number = 100, theight:Number = 100)
		{
			var _loc1_:* = 0;
			_keys = new Vector.<ColorKey>();
			super(tname, tx, tx, twidth, theight);
			
			if(!nullBitmapData)
			{
				nullBitmapData = new BitmapData(64,64,false,16711680);
				_loc1_ = 8;
				h = 0;
				while(h < 8)
				{
					v = 0;
					while(v < 8)
					{
						nullBitmapData.fillRect(new Rectangle(h * _loc1_,v * _loc1_,_loc1_,_loc1_),(h % 2 + v % 2) % 2 == 0?16777215:1.1579568E7);
						v = v + 1;
					}
					h = h + 1;
				}
			}
			this.addKey(0xffffff, 1, 0);
			this.minHeight = 18;
			this.maxHeight = 18;
			this.flexible = 1;
			this.view.cacheAsBitmap = true;
			this.view.addEventListener("mouseDown",mouseDownEvent,false,0,true);
		}
		
		private function mouseDownEvent(param1:MouseEvent) : void
		{
			dispatchEvent(new ControlEvent("undo",this));
			
			var t_bmp:BitmapData = new BitmapData(width,5,true,0);
			t_bmp.draw(view);
			var t_alpha:Number = (t_bmp.getPixel32(view.mouseX,2) >> 24 & 255) / 255;
			var t_color:int = t_bmp.getPixel(view.mouseX,2);
			current = addKey(t_color, t_alpha, view.mouseX / width * 255);
			t_bmp.dispose();
			
			_keyMoved = true;
			view.stage.addEventListener("mouseMove",keyMouseMoveEvent,false,0,true);
			view.stage.addEventListener("mouseUp",keyMouseUpEvent,false,0,true);
			dispatchEvent(new ControlEvent("change",this));
			//         ColorPanel.colorPanel.targetControl = this;
			//         ColorPanel.colorPanel.addEventListener("change",changeColorEvent,false,0,true);
			//         ColorPanel.colorPanel.addEventListener("undo",dispatchEvent,false,0,true);
		}
		
		public function addKey(t_color:int, t_opaticy:Number, t_radio:Number) : ColorKey
		{
			while(view.numChildren)
			{
				view.removeChildAt(0);
			}
			
//			current = new ColorKey(t_color, t_opaticy, t_radio);
			current = new ColorKey(Math.random() * 0xffffff, Math.random() * 0.5 + 0.5, t_radio);
			current.addEventListener("click", keyClickEvent,false,0,true);
			current.addEventListener("mouseDown",keyMouseDownEvent,false,0,true);
			current.addEventListener("rightClick",keyRightClickEvent,false,0,true);
			_keys.push(current);
			draw();
			return current;
		}
		
		public function removeKey(param1:int) : void
		{
			view.removeChildren();
			
			_keys.splice(param1,1);
			current = null;
			draw();
		}
		
		private function keyRightClickEvent(evt:MouseEvent) : void
		{
			var menu:NativeMenu = new NativeMenu();
			var target:ColorKey = evt.target as ColorKey;
			var control:GradientColor = this;
			
			var menuItem:NativeMenuItem = new NativeMenuItem("Remove Key");
			menuItem.addEventListener(Event.SELECT, function(param1:Event):void
			{
				if(_keys.length > 1)
				{
					dispatchEvent(new ControlEvent("undo",control));
					removeKey(_keys.indexOf(target));
					dispatchEvent(new ControlEvent("change",control));
				}
			});
			menuItem.enabled = _keys.length > 1;
			menu.addItem(menuItem);
			menu.display(view.stage, evt.stageX, evt.stageY);
		}
		
		private function keyClickEvent(param1:MouseEvent) : void
		{
			if(!_keyMoved)
			{
				//            ColorPanel.colorPanel.open();
			}
		}
		
		private function keyMouseDownEvent(evt:MouseEvent) : void
		{
			_keyMoved = false;
			evt.stopPropagation();
			current = evt.target as ColorKey;
			//         ColorPanel.colorPanel.targetControl = this;
			//         ColorPanel.colorPanel.addEventListener("change",changeColorEvent,false,0,true);
			//         ColorPanel.colorPanel.addEventListener("undo",dispatchEvent,false,0,true);
			view.stage.addEventListener("mouseMove",keyMouseMoveEvent);
			view.stage.addEventListener("mouseUp",keyMouseUpEvent);
		}
		
		private function keyMouseMoveEvent(evt:MouseEvent) : void
		{
			if(!_keyMoved)
			{
				dispatchEvent(new ControlEvent("undo",this));
			}
			_keyMoved = true;
			current.ratio = view.mouseX / width * 255;
			if((view.mouseY < -10 || view.mouseY > height + 10) && _keys.length > 1)
			{
				current.visible = false;
			}
			else
			{
				current.visible = true;
			}
			draw();
			dispatchEvent(new ControlEvent("change",this));
		}
		
		private function keyMouseUpEvent(evt:MouseEvent) : void
		{
			if(!current.visible)
			{
				if(!_keyMoved)
				{
					dispatchEvent(new ControlEvent("undo",this));
				}
				removeKey(_keys.indexOf(current));
				dispatchEvent(new ControlEvent("change",this));
			}
			view.stage.removeEventListener("mouseMove",keyMouseMoveEvent);
			view.stage.removeEventListener("mouseUp",keyMouseUpEvent);
		}
		
		override public function draw() : void
		{
			matrix.createGradientBox(width,height);
			_keys.sort(sortKeys);
			_colors = [];
			_alphas = [];
			_ratios = [];
			for each(var key:ColorKey in _keys)
			{
				if(key.visible)
				{
					view.addChild(key);
					key.x = key.ratio / 255 * width;
					key.y = height - 5;
					_colors.push(key.color);
					_alphas.push(key.opacity);
					_ratios.push(key.ratio);
				}
			}
			view.graphics.clear();
			
			view.graphics.beginFill(0,0);
			view.graphics.drawRect(0, 0, width, height);
			view.graphics.endFill();
			
			view.graphics.lineStyle(1, Style.borderBright, 1, true);
			
			view.graphics.beginBitmapFill(nullBitmapData);
			view.graphics.drawRect(0,0,width,height - 6);
			view.graphics.endFill();
			
			view.graphics.beginGradientFill("linear", _colors, _alphas, _ratios, matrix, "pad", "rgb");
			view.graphics.drawRect(0, 0, width, height - 6);
			view.graphics.endFill();
		}
		
		public function setColors(t_colors:Array, t_optacity:Array = null, t_alpha:Array = null) : void
		{
			var _loc4_:* = 0;
			_keys = new Vector.<ColorKey>();
			_current = null;
			while(view.numChildren)
			{
				view.removeChildAt(0);
			}
			_loc4_ = 0;
			while(_loc4_ < t_alpha.length)
			{
				current = addKey(t_colors?t_colors[_loc4_]:16777215,t_optacity?t_optacity[_loc4_]:1,t_alpha[_loc4_]);
				_loc4_++;
			}
			draw();
		}
		
		private function changeColorEvent(param1:ControlEvent) : void
		{
			dispatchEvent(new ControlEvent("change",this));
		}
		
		public function get color() : int
		{
			return current.color;
		}
		
		public function set color(param1:int) : void
		{
			if(current)
			{
				current.color = param1;
				current.draw();
			}
			draw();
		}
		
		public function get opacity() : Number
		{
			return current.opacity;
		}
		
		public function set opacity(param1:Number) : void
		{
			if(current)
			{
				current.opacity = param1;
				current.draw();
			}
			draw();
		}
		
		public function get colors() : Array
		{
			return _colors;
		}
		
		public function get alphas() : Array
		{
			return _alphas;
		}
		
		public function get ratios() : Array
		{
			return _ratios;
		}
		
		private function set current(tKey:ColorKey) : void
		{
			_current = tKey;
			for each(var _loc2_:ColorKey in _keys)
			{
				_loc2_.selected = false;
			}
			if(_current)
			{
				_current.selected = true;
			}
		}
		
		private function get current() : ColorKey
		{
			return _current;
		}
		
		public function get mode() : int
		{
			return _mode;
		}
		
		public function set mode(param1:int) : void
		{
			_mode = param1;
		}
		
		private function sortKeys(key1:ColorKey, key2:ColorKey) : int
		{
			if(key1.ratio > key2.ratio)
			{
				return 1;
			}
			if(key1.ratio < key2.ratio)
			{
				return -1;
			}
			return 0;
		}
	}
}

import flash.display.Sprite;
import flash.filters.DropShadowFilter;

class ColorKey extends Sprite
{
	
	public var color:int = 16777215;
	
	public var opacity:Number = 1;
	
	private var _selected:Boolean;
	
	private var _ratio:Number = 0;
	
	function ColorKey(tcolor:int, topacity:Number = 1, tratio:Number = 0)
	{
		super();
		this.color = tcolor;
		this.opacity = topacity;
		this.ratio = tratio;
		this.buttonMode = true;
		this.tabEnabled = false;
		this.draw();
		this.filters = [new DropShadowFilter(4,45,0,0.4)];
	}
	
	public function get ratio() : Number
	{
		return _ratio;
	}
	
	public function set ratio(val:Number) : void
	{
		if(val < 0)
		{
			val = 0.0;
		}
		if(val > 255)
		{
			val = 255;
		}
		_ratio = val;
	}
	
	public function get selected() : Boolean
	{
		return _selected;
	}
	
	public function set selected(bool:Boolean) : void
	{
		_selected = bool;
		draw();
	}
	
	public function draw() : void
	{
		this.graphics.clear();
		this.graphics.lineStyle(1, _selected ? 16763648 : 1.4079702E7, 1, true);
		this.graphics.beginFill(color);
		this.graphics.moveTo(0,0);
		this.graphics.lineTo(5,6);
		this.graphics.lineTo(-5,6);
	}
}
