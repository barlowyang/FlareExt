package flare.apps.controls
{
   import flash.events.EventDispatcher;
   import flash.utils.getQualifiedClassName;
   
   import flare.apps.containers.Container;
   
   public class Control extends EventDispatcher
   {
      
      private static var tIndex:int = 1;
      
      private var _view:View;
      
      private var _enabled:Boolean = true;
      
      private var _flexible:Number = 0;
      
      private var _x:Number = 0;
      
      private var _y:Number = 0;
      
      private var _width:Number = 100;
      
      private var _height:Number = 20;
      
      private var _minWidth:Number = -1;
      
      private var _minHeight:Number = -1;
      
      private var _maxWidth:Number = -1;
      
      private var _maxHeight:Number = -1;
      
      public var parentControl:Control;
      
      public var parent:Container;
      
      public var name:String;
      
      public var description:String;
      
      public function Control(tname:String = "", tx:Number = 0, ty:Number = 0, twidth:Number = 100, theight:Number = 100)
      {
         super();
         _view = new View(this);
         this.name = tname;
         this.x = tx;
         this.y = ty;
         _width = twidth;
         _height = theight;
      }
      
      private function setTabIndex() : void
      {
         tIndex = tIndex + 1;
         tabIndex = tIndex;
      }
      
      public function get x() : Number
      {
         return _x;
      }
      
      public function set x(val:Number) : void
      {
         _x = val;
         view.x = val;
      }
      
      public function get y() : Number
      {
         return _y;
      }
      
      public function set y(val:Number) : void
      {
         _y = val;
         view.y = val;
      }
      
      public function get width() : Number
      {
         return _width;
      }
      
      public function set width(val:Number) : void
      {
         if(flexible != 0)
         {
            if(_minWidth != -1 && val < _minWidth)
            {
               val = _minWidth;
            }
            if(!(_maxWidth == -1) && val > _maxWidth)
            {
               val = _maxWidth;
            }
         }
		 
         if(val < 0)
         {
            val = 0.0;
         }
         if(val != _width)
         {
            _width = val;
         }
      }
      
      public function get height() : Number
      {
         return _height;
      }
      
      public function set height(val:Number) : void
      {
         if(flexible != 0)
         {
            if(!(_minHeight == -1) && val < _minHeight)
            {
               val = _minHeight;
            }
            if(!(_maxHeight == -1) && val > _maxHeight)
            {
               val = _maxHeight;
            }
         }
         if(val < 0)
         {
            val = 0.0;
         }
         if(val != _height)
         {
            _height = val;
         }
      }
      
      public function get minWidth() : Number
      {
         return _minWidth;
      }
      
      public function set minWidth(param1:Number) : void
      {
         _minWidth = param1;
      }
      
      public function get minHeight() : Number
      {
         return _minHeight;
      }
      
      public function set minHeight(param1:Number) : void
      {
         _minHeight = param1;
      }
      
      public function get maxWidth() : Number
      {
         return _maxWidth;
      }
      
      public function set maxWidth(param1:Number) : void
      {
         _maxWidth = param1;
      }
      
      public function get maxHeight() : Number
      {
         return _maxHeight;
      }
      
      public function set maxHeight(val:Number) : void
      {
         _maxHeight = val;
      }
      
      public function get flexible() : Number
      {
         return _flexible;
      }
      
      public function set flexible(val:Number) : void
      {
         if(val < 0)
         {
            val = 0.0;
         }
         _flexible = val;
      }
      
      public function get enabled() : Boolean
      {
         return _enabled;
      }
      
      public function set enabled(val:Boolean) : void
      {
         _enabled = val;
         view.mouseEnabled = val;
         view.mouseChildren = val;
         view.tabChildren = val;
         view.tabEnabled = val;
         view.alpha = val ? 1 : 0.5;
      }
      
      public function get view() : View
      {
         _view.name = name;
         return _view;
      }
      
      public function get visible() : Boolean
      {
         return _view.visible;
      }
      
      public function set visible(param1:Boolean) : void
      {
         _view.visible = param1;
      }
	  
      public function draw() : void
      {
		  
      }
      
      public function set tabIndex(param1:int) : void
      {
		  
      }
      
      public function get tabIndex() : int
      {
         return view.tabIndex;
      }
      
      public function setFocus() : void
      {
         if(view.stage)
         {
            view.stage.focus = view;
         }
      }
      
      override public function toString() : String
      {
         var _loc1_:String = getQualifiedClassName(this);
         _loc1_ = _loc1_.substr(_loc1_.indexOf("::") + 2);
         return "[" + _loc1_ + " name=" + name + "]";
      }
   }
}
