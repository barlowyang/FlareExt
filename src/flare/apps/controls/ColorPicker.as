package flare.apps.controls
{
   import flash.display.BitmapData;
   import flash.events.FocusEvent;
   import flash.events.MouseEvent;
   import flash.geom.Rectangle;
   
   import flare.apps.core.Style;
   
   public class ColorPicker extends Control
   {
      
      private static var h:int;
      
      private static var v:int;
      
      private static var nullBitmapData:BitmapData = new BitmapData(32,32,false,16711680);
      
      private var _color:int = 16777215;
      
      private var _alpha:Number = 1;
      
      private var _mode:int;
      
      public function ColorPicker(color_t:int = 16777215, alpha_t:Number = 1, mode_t:int = 0)
      {
         super();
         view.focusRect = false;
         view.buttonMode = true;
         view.addEventListener("click",clickEvent);
         view.addEventListener("focusIn",focusInEvent);
         view.addEventListener("focusOut",focusOutEvent);
         flexible = 1;
         minWidth = 50;
         maxWidth = 50;
         minHeight = 18;
         maxHeight = 18;
		 
         this.color = color_t;
         this.a = alpha_t;
         _mode = mode_t;
		 
         drawCheckered();
         draw();
      }
      
      private function focusInEvent(param1:FocusEvent) : void
      {
         view.filters = Style.focusFilter;
      }
      
      private function focusOutEvent(param1:FocusEvent) : void
      {
         view.filters = [];
      }
      
      private function drawCheckered() : void
      {
         h = 0;
         while(h < 16)
         {
            v = 0;
            while(v < 16)
            {
               nullBitmapData.fillRect(new Rectangle(h * 8,v * 8,8,8),(h % 2 + v % 2) % 2 == 0?16777215:1.1579568E7);
               v = v + 1;
            }
            h = h + 1;
         }
      }
      
      private function clickEvent(param1:MouseEvent) : void
      {
         view.stage.focus = view;
		 /*
         ColorPanel.colorPanel.targetControl = this;
         ColorPanel.colorPanel.open();
         ColorPanel.colorPanel.addEventListener("change",changeControlEvent,false,0,true);
         ColorPanel.colorPanel.addEventListener("undo",undoControlEvent,false,0,true);
         ColorPanel.colorPanel.addEventListener("stop",stopControlEvent,false,0,true);
		 */
      }
      /*
      private function stopControlEvent(param1:ControlEvent) : void
      {
         dispatchEvent(new ControlEvent("stop",this));
      }
      
      private function undoControlEvent(param1:ControlEvent) : void
      {
         dispatchEvent(new ControlEvent("undo",this));
      }
      
      private function changeControlEvent(param1:ControlEvent) : void
      {
         dispatchEvent(new ControlEvent("change",this));
      }
      */
	  
      override public function draw() : void
      {
         view.graphics.clear();
		 
         view.graphics.lineStyle(1,Style.borderBright,1,true);
         view.graphics.beginBitmapFill(nullBitmapData);
         view.graphics.drawRect(0,0,width,height);
         view.graphics.endFill();
		 
         view.graphics.beginFill(_color,_alpha);
         view.graphics.drawRect(0,0,width,height);
         view.graphics.endFill();
      }
      
      public function set color(val:int) : void
      {
         _color = val;
         draw();
      }
      
      public function get color() : int
      {
         return _color;
      }
      
      public function set a(val:Number) : void
      {
         _alpha = val;
         draw();
      }
      
      public function get a() : Number
      {
         return _alpha;
      }
      
      public function get r() : Number
      {
         return red / 255;
      }
      
      public function get g() : Number
      {
         return green / 255;
      }
      
      public function get b() : Number
      {
         return blue / 255;
      }
      
      public function get red() : int
      {
         return _color >> 16 & 255;
      }
      
      public function get green() : int
      {
         return _color >> 8 & 255;
      }
      
      public function get blue() : int
      {
         return _color & 255;
      }
      
      public function fromRGB(red_c:int, green_c:int, blue_c:int) : void
      {
         _color = red_c << 16 ^ green_c << 8 ^ blue_c;
         draw();
      }
      
      public function fromVector(valVec:Vector.<Number>) : void
      {
         _color = 0;
         if(valVec.length >= 1)
         {
            _color = _color | (valVec[0] * 255) << 16;
         }
         if(valVec.length >= 2)
         {
            _color = _color | (valVec[1] * 255) << 8;
         }
         if(valVec.length >= 3)
         {
            _color = _color | (valVec[2] * 255);
         }
         if(valVec.length >= 4)
         {
            _alpha = _alpha | valVec[3];
         }
         draw();
      }
      
      public function get mode() : int
      {
         return _mode;
      }
   }
}
