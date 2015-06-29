package flare.apps.controls
{
   import flash.display.Shape;
   import flash.events.MouseEvent;
   
   import flare.apps.core.Style;
   import flare.apps.events.ControlEvent;
   
   public class ImageButton extends Image
   {
      
      private var _state:String;
      
      private var _border:Shape;
      
      private var _single:Boolean = false;
      
      public var toggle:Boolean;
      
      public function ImageButton(request:* = null, toggle_t:Boolean = false)
      {
         _border = new Shape();
         if(toggle_t && request is Array == false)
         {
            _single = true;
            request = [request, request];
         }
         super(request);
         this.toggle = toggle_t;
         view.buttonMode = true;
         view.addEventListener("click",mouseClickEvent);
         view.addEventListener("mouseOver",handleEvents);
         view.addEventListener("mouseOut",handleEvents);
         view.addEventListener("mouseDown",handleEvents);
         view.addEventListener("mouseUp",handleEvents);
         view.addChild(_border);
      }
      
      private function handleEvents(evt:MouseEvent) : void
      {
         _state = evt.type;
         draw();
      }
      
      private function mouseClickEvent(evt:MouseEvent) : void
      {
         dispatchEvent(new ControlEvent(ControlEvent.UNDO, this,evt.ctrlKey,evt.altKey,evt.shiftKey,evt.controlKey));
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
         dispatchEvent(new ControlEvent(ControlEvent.CLICK,this,evt.ctrlKey,evt.altKey,evt.shiftKey,evt.controlKey));
      }
      
      override public function draw() : void
      {
         view.graphics.clear();
         _border.graphics.clear();
         if("mouseOver" !== _state)
         {
            if("mouseUp" !== _state)
            {
               if("mouseDown" === _state)
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
