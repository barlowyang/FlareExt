package flare.ide.controls
{
	import com.greensock.TweenLite;
	
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import flare.apps.controls.Control;
	import flare.apps.core.Style;
	import flare.apps.events.ControlEvent;
	import flare.ide.controls.infos.RuleFrameInfo;
	
	public class Rule extends Control
	{
		private var _gui:Shape;
		private var _flag:Shape;
		
		private var _cursor:Shape;
		
		private var _bmpHeader:BitmapData;
		
		private var _matrix:Matrix;
		
		private var _currentFrame:int = 0;
		
		private var _mouse:Point;
		
		private var _position:Number = 0;
		
		public var step:Number = 5;
		
		public var size:Number = 8;
		
		public function Rule()
		{
			_gui = new Shape();
			_flag = new Shape();
			_cursor = new Shape();
			_matrix = new Matrix();
			_mouse = new Point();
			super();
			
			flexible = 1;
			view.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownEvent,false,0,true);
			view.addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelEvent,false,0,true);
			view.addEventListener(MouseEvent.MIDDLE_MOUSE_DOWN, mouseDragEvent,false,0,true);
			view.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, mouseDragEvent,false,0,true);
			view.addChild(_cursor);
			view.addChild(_gui);
			view.addChild(_flag);
		}
		
		private const RULE_HEIGHT:uint = 25;
		public function update() : void
		{
			_cursor.graphics.clear();
			_cursor.graphics.beginFill(Style.backgroundColor2, 0.5);
			_cursor.graphics.lineStyle(1, 10564660);
			_cursor.graphics.drawRect(0, 0, size, RULE_HEIGHT - 1);
			
			_bmpHeader = new BitmapData(size,28,true,0);
			_gui.graphics.clear();
			_gui.graphics.lineStyle(1,Style.borderBright,1,true);
			_gui.graphics.moveTo(0, 0);
			_gui.graphics.lineTo(0, 6);
			
			_gui.graphics.moveTo(0, RULE_HEIGHT - 6);
			_gui.graphics.lineTo(0, RULE_HEIGHT);
			_bmpHeader.draw(_gui);
		}
		
		private function mouseDragEvent(evt:MouseEvent) : void
		{
			_mouse.setTo(view.mouseX, view.mouseY);
			view.stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveDragEvent,false,0,true);
			view.stage.addEventListener(MouseEvent.MIDDLE_MOUSE_UP, mouseUpDragEvent,false,0,true);
			view.stage.addEventListener(MouseEvent.RIGHT_MOUSE_UP, mouseUpDragEvent,false,0,true);
		}
		
		private function mouseUpDragEvent(evt:MouseEvent) : void
		{
			view.stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveDragEvent);
			view.stage.removeEventListener(MouseEvent.MIDDLE_MOUSE_UP, mouseUpDragEvent);
			view.stage.removeEventListener(MouseEvent.RIGHT_MOUSE_UP, mouseUpDragEvent);
		}
		
		private function mouseMoveDragEvent(evt:MouseEvent) : void
		{
			position = position + (_mouse.x - view.mouseX);
			_mouse.setTo(view.mouseX,view.mouseY);
		}
		
		private function mouseDownEvent(evt:MouseEvent) : void
		{
			view.stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseFrameMoveEvent,false,0,true);
			view.stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpEvent,false,0,true);
			view.stage.addEventListener(Event.ENTER_FRAME, enterFrameEvent,false,0,true);
			currentFrame = view.mouseX / size + _position / size;
			dispatchEvent(new ControlEvent(ControlEvent.CHANGE, this));
		}
		
		private function mouseUpEvent(evt:MouseEvent) : void
		{
			view.stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseFrameMoveEvent);
			view.stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpEvent);
			view.stage.removeEventListener(Event.ENTER_FRAME, enterFrameEvent);
			dispatchEvent(new ControlEvent(ControlEvent.CLICK, this));
		}
		
		private function enterFrameEvent(evt:Event) : void
		{
			if(view.mouseX < step)
			{
				position = position - step * 2;
			}
			if(view.mouseX > width)
			{
				position = position + step * 2;
			}
			var oldFrame:int = _currentFrame;
			currentFrame = view.mouseX / size + _position / size;
			if(oldFrame != _currentFrame)
			{
				dispatchEvent(new ControlEvent(ControlEvent.CHANGE, this));
			}
		}
		
		private function mouseFrameMoveEvent(evt:MouseEvent) : void
		{
			currentFrame = view.mouseX / size + _position / size;
			dispatchEvent(new ControlEvent(ControlEvent.CHANGE, this));
		}
		
		private function mouseWheelEvent(evt:MouseEvent) : void
		{
			TweenLite.to(this, 0.25, {"position":position - evt.delta * 25});
		}
		
		override public function draw() : void
		{
			var x_t:int = 0;
			var x_t_1:Number;
			if(!_bmpHeader)
			{
				update();
			}
			view.scrollRect = new Rectangle(0,0,width,height);
			_cursor.x = _currentFrame * size + 1 - _position;
			var startFrame:int = (_position / size / step) * step;
			var font_start_x:int = _position % (size * step);
			_matrix.setTo(1,0,0,1,-_position,0);
			_gui.graphics.clear();
			_gui.graphics.beginBitmapFill(_bmpHeader,_matrix);
			_gui.graphics.drawRect(0,0,width,height);
			x_t = 0;
			while(x_t < width)
			{
				x_t_1 = x_t - font_start_x + 2;
				
//				drawFlag(Math.random() * 100, 0xffff00, Math.random() * 3);
					
				Style.defaultFont.draw(_gui.graphics, x_t_1, height - 20, 30, height, startFrame.toString(), 1);
				if(x_t_1 <= width)
				{
					startFrame = startFrame + step;
					x_t = x_t + size * step;
					continue;
				}
				break;
			}
			
			drawFlag(_flagInfos || new Array());
			dispatchEvent(new Event(ControlEvent.DRAW_EXIT));
		}
		
		private var _flagInfos:Array;
		/**
		 * 
		 * @param curFrame
		 * @param flagColor
		 * @param type 0:全	 1：上半		2：下半
		 * 
		 */
		public function drawFlag(infos:Array):void
		{
			_flagInfos = infos;
			var startFrame:int = (_position / size / step) * step;
			var endFrame:int = startFrame + width / step;
			_flag.graphics.clear();
			for each (var frameInfo:RuleFrameInfo in _flagInfos)
			{
				if (frameInfo.frame >= startFrame && frameInfo.frame <= endFrame)
				{
					var tmpPos:int = frameInfo.frame * size;
					_flag.graphics.beginFill(frameInfo.color, 0.5);
					var tmpX:int = tmpPos - _position;
					var tmpY:int = 1;
					var tmpW:int = size;
					var tmpH:int = RULE_HEIGHT - 2;
					if (frameInfo.type == 1)
					{
						tmpH = RULE_HEIGHT >> 1;
					} 
					else if (frameInfo.type == 2)
					{
						tmpY = tmpH = RULE_HEIGHT >> 1;
					}
					_flag.graphics.drawRect(tmpX, tmpY, tmpW, tmpH);
					_flag.graphics.endFill();
				}
			}
		}
		
		public function get position() : Number
		{
			return _position;
		}
		
		public function set position(val:Number) : void
		{
			_position = val;
			if(_position < 0)
			{
				_position = 0;
			}
			draw();
		}
		
		public function get currentFrame() : int
		{
			return _currentFrame;
		}
		
		public function set currentFrame(val:int) : void
		{
			_currentFrame = val;
			if(_currentFrame < 0)
			{
				_currentFrame = 0;
			}
			_cursor.x = _currentFrame * size + 1 - _position;
		}
	}
}
