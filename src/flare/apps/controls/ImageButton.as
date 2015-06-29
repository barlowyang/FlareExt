package flare.apps.controls
{
   import flash.display.Shape;
   import flash.events.MouseEvent;
   import flare.apps.events.ControlEvent;
   import flare.apps.core.Style;
   
   public class ImageButton extends Image
   {
      
      private var _state:String;
      
      private var _border:Shape;
      
      private var _single:Boolean = false;
      
      public var toggle:Boolean;
      
      public function ImageButton(param1:* = null, param2:Boolean = false)
      {
         _border = new Shape();
         if(param2 && param1 is Array == false)
         {
            _single = true;
            param1 = [param1,param1];
         }
         super(param1);
         this.toggle = param2;
         view.buttonMode = true;
         view.addEventListener("click",mouseClickEvent);
         view.addEventListener("mouseOver",handleEvents);
         view.addEventListener("mouseOut",handleEvents);
         view.addEventListener("mouseDown",handleEvents);
         view.addEventListener("mouseUp",handleEvents);
         view.addChild(_border);
      }
      
      private function handleEvents(param1:MouseEvent) : void
      {
         _state = param1.type;
         draw();
      }
      
      private function mouseClickEvent(param1:MouseEvent) : void
      {
         dispatchEvent(new ControlEvent("undo",this,param1.ctrlKey,param1.altKey,param1.shiftKey,param1.controlKey));
         if(toggle)
         {
            if(count > 1)
            {
               index = index + 1;
            }
            else
            {
               index = 1 - index;
            }
            draw();
         }
         else
         {
            index = index + 1;
         }
         dispatchEvent(new ControlEvent("click",this,param1.ctrlKey,param1.altKey,param1.shiftKey,param1.controlKey));
      }
      
      override public function draw() : void
      {
         view.graphics.clear();
         _border.graphics.clear();
         var _loc1_:* = _state;
         if("mouseOver" !== _loc1_)
         {
            if("mouseUp" !== _loc1_)
            {
               if("mouseDown" === _loc1_)
               {
                  view.graphics.beginFill(Style.backgroundColor2);
                  view.graphics.drawRect(0,0,width,height);
                  _border.graphics.lineStyle(1,Style.borderDark,1,true);
                  _border.graphics.drawRect(0,0,width,height);
               }
            }
            if(toggle)
            {
               if(index == 1 && (_single))
               {
                  view.graphics.beginFill(Style.backgroundColor2);
                  view.graphics.drawRect(-1,-1,width + 2,height + 2);
               }
            }
            return;
         }
         view.graphics.beginFill(Style.backgroundColor);
         view.graphics.drawRect(0,0,width,height);
         _border.graphics.lineStyle(1,12632256,1,true);
         _border.graphics.drawRect(0,0,width,height);
         if(toggle)
         {
            if(index == 1 && (_single))
            {
               view.graphics.beginFill(Style.backgroundColor2);
               view.graphics.drawRect(-1,-1,width + 2,height + 2);
            }
         }
      }
   }
}
