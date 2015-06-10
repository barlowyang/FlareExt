package flare.apps.containers
{
   import flash.display.Shape;
   import flash.display.Sprite;
   
   import flare.apps.controls.Control;
   import flare.apps.core.Style;
   
   public class Container extends Control
   {
      
      public var background:Boolean = false;
      
      public var backgroundColor:int;
      
      private var _controls:Vector.<Control>;
      
      private var _borders:Shape;
      
      private var _content:Sprite;
      
      public function Container()
      {
         backgroundColor = Style.backgroundColor;
         _controls = new Vector.<Control>();
         _borders = new Shape();
         _content = new Sprite();
         super("",0,0,100,100);
         this.showBorders = false;
         this.view.addChild(_content);
         this.view.addChild(_borders);
         this.flexible = 1;
      }
      
      public function addControl(param1:Control) : void
      {
         this.addControlAt(param1,controls.length);
      }
      
      public function addControlAt(param1:Control, param2:int = 0) : void
      {
         if(param1.parent == this)
         {
            return;
         }
         if(param1.parent)
         {
            param1.parent.removeControl(param1);
         }
         controls.splice(param2,0,param1);
         param1.parent = this;
         param1.addEventListener("click",dispatchEvent);
         param1.addEventListener("undo",dispatchEvent);
         param1.addEventListener("stop",dispatchEvent);
         param1.addEventListener("change",dispatchEvent);
         _content.addChild(param1.view);
      }
      
      public function removeAllControls() : void
      {
         while(controls.length)
         {
            removeControl(controls[0]);
         }
      }
      
      public function removeControl(param1:Control) : void
      {
         var _loc2_:int = controls.indexOf(param1);
         if(_loc2_ != -1)
         {
            controls.splice(_loc2_,1);
            _content.removeChild(param1.view);
            param1.parent = null;
            param1.removeEventListener("click",dispatchEvent);
            param1.removeEventListener("undo",dispatchEvent);
            param1.removeEventListener("stop",dispatchEvent);
            param1.removeEventListener("change",dispatchEvent);
         }
      }
      
      public function getControlByName(param1:String, param2:int = 0) : Control
      {
         var _loc3_:* = null;
         var _loc6_:* = 0;
         var _loc5_:* = controls;
         for each(var _loc4_:Control in controls)
         {
            if(_loc4_.name == param1 && param2 < 0)
            {
               return _loc4_;
            }
            if(_loc4_ is Container)
            {
               _loc3_ = Container(_loc4_).getControlByName(param1,param2);
               if(_loc3_)
               {
                  return _loc3_;
               }
            }
         }
         return null;
      }
      
      public function get content() : Sprite
      {
         return _content;
      }
      
      public function get showBorders() : Boolean
      {
         return _borders.visible;
      }
      
      public function set showBorders(param1:Boolean) : void
      {
         _borders.visible = param1;
      }
      
      public function get controls() : Vector.<Control>
      {
         return _controls;
      }
      
      public function update() : void
      {
		  
      }
      
      override public function draw() : void
      {
         _borders.graphics.clear();
         if(_borders.visible)
         {
            _borders.graphics.lineStyle(1,Style.borderBright,1,true);
            _borders.graphics.drawRect(0,0,width,height);
         }
         view.graphics.clear();
         if(background)
         {
            view.graphics.beginFill(backgroundColor);
            view.graphics.drawRect(0,0,width,height);
         }
      }
   }
}
