package flare.apps.controls
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Loader;
   import flash.display.LoaderInfo;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.net.URLRequest;
   
   import flare.apps.containers.Container;
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
      
      public function Image(request:* = null, stretch_t:String = "none", w_t:Number = NaN, h_t:Number = NaN)
      {
         _array = [];
         _content = new Sprite();
         super("",0,0,1,1);
         this.stretch = stretch_t;
         this.source = request;
         view.addChild(_content);
		 
         if(!isNaN(w_t) && !isNaN(h_t))
         {
            setSize(w_t,h_t);
         }
         else
         {
            _autoAdjust = true;
         }
      }
      
      private function setSize(w_t:Number, h_t:Number) : void
      {
         var parent_t:Container;
         flexible = 1;
         this.width = w_t;
         this.height = h_t;
         minWidth = w_t;
         maxWidth = w_t;
         minHeight = h_t;
         maxHeight = h_t;
         if(parent)
         {
            parent_t = parent;
            while(parent_t.parent)
            {
               parent_t = parent_t.parent;
            }
            parent_t.update();
            parent_t.draw();
         }
      }
      
      public function get source() : *
      {
         return _source;
      }
      
      public function set source(val:*) : void
      {
         if(!val)
         {
            return;
         }
         if(val is String)
         {
            val = (val).split(",");
         }
         if(val is Array)
         {
            _array = [];
            for each(var child_t:* in val)
            {
               _array.push(addSource(child_t));
            }
         }
         else
         {
            _array = [addSource(val)];
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
      
      private function addSource(val:*) : *
      {
         var img_loader:Loader;
		 
         if(val is Bitmap)
         {
            return val;
         }
         if(val is BitmapData)
         {
            return new Bitmap(val);
         }
         if(val is String)
         {
            img_loader = new Loader();
            img_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, completeLoaderEvent);
            img_loader.load(new URLRequest(val));
            return img_loader;
         }
      }
      
      private function completeLoaderEvent(evt:Event) : void
      {
         var img_loader_info:LoaderInfo = evt.target as LoaderInfo;
		 img_loader_info.removeEventListener(Event.COMPLETE, completeLoaderEvent);
         var img_bmp:Bitmap = img_loader_info.content as Bitmap;
         if(_autoAdjust)
         {
            setSize(img_bmp.width, img_bmp.height);
         }
         draw();
      }
      
      public function get count():int
      {
         return _array.length;
      }
      
      public function get index():int
      {
         return _index;
      }
      
      public function set index(val:int) : void
      {
         _index = val % _array.length;
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
         var bmp:Bitmap;
         var w_t:Number;
         var h_t:Number;
		 
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
            bmp = _content.getChildAt(0) as Bitmap;
            if(bmp)
            {
               w_t = bmp.bitmapData.width;
               h_t = bmp.bitmapData.height;
               h_t = height;
               w_t = h_t * bmp.bitmapData.width / bmp.bitmapData.height;
               _content.width = w_t;
               _content.height = h_t;
               if(stretch == "left")
               {
                  maxWidth = w_t;
                  minWidth = w_t;
               }
               else
               {
                  maxHeight = h_t;
                  minHeight = h_t;
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
