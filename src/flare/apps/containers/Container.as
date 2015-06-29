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
      
      public function addControl(child:Control) : void
      {
         this.addControlAt(child, controls.length);
      }
      
      public function addControlAt(child:Control, idx:int = 0) : void
      {
         if(child.parent == this)
         {
            return;
         }
         if(child.parent)
         {
            child.parent.removeControl(child);
         }
         controls.splice(idx,0,child);
         child.parent = this;
         child.addEventListener("click",dispatchEvent);
         child.addEventListener("undo",dispatchEvent);
         child.addEventListener("stop",dispatchEvent);
         child.addEventListener("change",dispatchEvent);
         _content.addChild(child.view);
      }
      
      public function removeAllControls() : void
      {
         while(controls.length)
         {
            removeControl(controls[0]);
         }
      }
      
      public function removeControl(child:Control) : void
      {
         var idx:int = controls.indexOf(child);
         if(idx != -1)
         {
            controls.splice(idx,1);
            _content.removeChild(child.view);
            child.parent = null;
            child.removeEventListener("click",dispatchEvent);
            child.removeEventListener("undo",dispatchEvent);
            child.removeEventListener("stop",dispatchEvent);
            child.removeEventListener("change",dispatchEvent);
         }
      }
	  
      /*
      public function getControlByName(param1:String, param2:int = 0) : Control
      {
         var child_1:Control;
         for each(var child_2:Control in controls)
         {
            if(child_2.name == param1 && param2 < 0)
            {
               return child_2;
            }
            if(child_2 is Container)
            {
               child_1 = Container(child_2).getControlByName(param1,param2);
               if(child_1)
               {
                  return child_1;
               }
            }
         }
         return null;
      }*/
      
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
