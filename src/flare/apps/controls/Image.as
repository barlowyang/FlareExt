package flare.apps.controls
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Loader;
   import flash.display.LoaderInfo;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.net.URLRequest;
   
   import flare.apps.core.Style;
   
   public class Image extends Control
   {
      
      public var stretch:String = "none";
      
      public var keepRatio:Boolean = true;
      
      public var borders:Boolean = true;
      
      private var _source:*;
      
      private var _autoAdjust:Boolean;
      
      private var _index:int;
      
      private var _array:Array;
      
      private var _content:Sprite;
      
      public function Image(param1:* = null, param2:String = "none", param3:Number = NaN, param4:Number = NaN)
      {
         _array = [];
         _content = new Sprite();
         super("",0,0,1,1);
         this.stretch = param2;
         this.source = param1;
         view.addChild(_content);
         if(!isNaN(param3) && !isNaN(param4))
         {
            setSize(param3,param4);
         }
         else
         {
            _autoAdjust = true;
         }
      }
      
      private function setSize(param1:Number, param2:Number) : void
      {
         var _loc3_:* = null;
         flexible = 1;
         this.width = param1;
         this.height = param2;
         minWidth = param1;
         maxWidth = param1;
         minHeight = param2;
         maxHeight = param2;
         if(parent)
         {
            _loc3_ = parent;
            while(_loc3_.parent)
            {
               _loc3_ = _loc3_.parent;
            }
            _loc3_.update();
            _loc3_.draw();
         }
      }
      
      public function get source() : *
      {
         return _source;
      }
      
      public function set source(param1:*) : void
      {
         if(!param1)
         {
            return;
         }
         if(param1 is String)
         {
            param1 = (param1).split(",");
         }
         if(param1 is Array)
         {
            _array = [];
            var _loc4_:* = 0;
            var _loc3_:* = param1;
            for each(var _loc2_:* in param1)
            {
               _array.push(addSource(_loc2_));
            }
         }
         else
         {
            _array = [addSource(param1)];
         }
         _content.removeChildren();
         _content.addChild(_array[0]);
         if(stretch == "none")
         {
            width = _content.width;
            height = _content.height;
         }
         draw();
      }
      
      private function addSource(param1:*) : *
      {
         var _loc2_:* = null;
         var _loc3_:* = null;
         if(param1 is Bitmap)
         {
            _loc2_ = param1;
            return _loc2_;
         }
         if(param1 is BitmapData)
         {
            _loc2_ = new Bitmap(param1);
            return _loc2_;
         }
         if(param1 is String)
         {
            _loc3_ = new Loader();
            _loc3_.contentLoaderInfo.addEventListener("complete",completeLoaderEvent);
            _loc3_.load(new URLRequest(param1));
            return _loc3_;
         }
      }
      
      private function completeLoaderEvent(param1:Event) : void
      {
         var _loc3_:LoaderInfo = param1.target as LoaderInfo;
         var _loc2_:Bitmap = _loc3_.content as Bitmap;
         if(_autoAdjust)
         {
            setSize(_loc2_.width,_loc2_.height);
         }
         draw();
      }
      
      public function get count() : int
      {
         return _array.length;
      }
      
      public function get index() : int
      {
         return _index;
      }
      
      public function set index(param1:int) : void
      {
         _index = param1 % _array.length;
         _content.removeChildren();
         if(_index < _array.length)
         {
            _content.addChild(_array[_index]);
         }
         else
         {
            _content.addChild(_array[0]);
         }
         width = _content.width;
         height = _content.height;
         draw();
      }
      
      override public function draw() : void
      {
         var _loc2_:* = null;
         var _loc1_:* = NaN;
         var _loc3_:* = NaN;
         view.graphics.clear();
         if(stretch == "none")
         {
            _content.x = width * 0.5 - _content.width * 0.5;
            _content.y = height * 0.5 - _content.height * 0.5;
            _content.scaleX = 1;
            _content.scaleY = 1;
         }
         else
         {
            if(height == 0 || width == 0)
            {
               return;
            }
            if(_content.numChildren == 0)
            {
               return;
            }
            _loc2_ = _content.getChildAt(0) as Bitmap;
            if(_loc2_)
            {
               _loc1_ = _loc2_.bitmapData.width;
               _loc3_ = _loc2_.bitmapData.height;
               _loc3_ = height;
               _loc1_ = _loc3_ * _loc2_.bitmapData.width / _loc2_.bitmapData.height;
               _content.width = _loc1_;
               _content.height = _loc3_;
               if(stretch == "left")
               {
                  maxWidth = _loc1_;
                  minWidth = _loc1_;
               }
               else
               {
                  maxHeight = _loc3_;
                  minHeight = _loc3_;
               }
            }
            _content.x = width * 0.5 - _content.width * 0.5;
            _content.y = height * 0.5 - _content.height * 0.5;
         }
         if(borders)
         {
            view.graphics.lineStyle(1,Style.borderLight);
            view.graphics.drawRect(0,0,width,height);
         }
      }
   }
}
