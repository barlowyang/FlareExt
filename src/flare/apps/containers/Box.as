package flare.apps.containers
{
   import flash.display.BitmapData;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.ui.Mouse;
   import flash.ui.MouseCursor;
   import flash.ui.MouseCursorData;
   import flash.utils.Dictionary;
   
   import flare.apps.controls.Control;
   import flare.apps.core.Style;
   
   public class Box extends Container
   {
      
      public static const VERTICAL:String = "vertical";
      
      public static const HORIZONTAL:String = "horizontal";
      
      public static const GRID:String = "grid";
      
      private static var _curosrs:Boolean = false;
      
      private var _borders:Shape;
      
      private var _contentBars:Sprite;
      
      private var _bar:Sprite;
      
      private var _last:Number;
      
      public var space:Number = 5;
      
      public var margins:Number = 0;
      
      public var rowCount:int = 1;
      
      public var gridSize:Point;
      
      private var _orientation:String = "vertical";
      
      public function Box()
      {
         var mouseCursorData:MouseCursorData;
         _borders = new Shape();
         _contentBars = new Sprite();
         gridSize = new Point(32,32);
         super();
         if(!_curosrs)
         {
            mouseCursorData = new MouseCursorData();
            mouseCursorData.data = Vector.<BitmapData>([Style.getBitmapData(32, 32)]);
            mouseCursorData.hotSpot = new Point(16,16);
            Mouse.registerCursor("resize_h", mouseCursorData);
            mouseCursorData = new MouseCursorData();
            mouseCursorData.data = Vector.<BitmapData>([Style.getBitmapData(32, 32)]);
            mouseCursorData.hotSpot = new Point(16,16);
            Mouse.registerCursor("resize_v", mouseCursorData);
         }
		 
         _curosrs = true;
         _contentBars.visible = false;
         if(!name)
         {
            name = "Box" + new Date().getMilliseconds();
         }
      }
      
      override public function addControl(param1:Control) : void
      {
         this.addControlAt(param1,controls.length);
      }
      
      override public function addControlAt(param1:Control, param2:int = 0) : void
      {
         super.addControlAt(param1,param2);
         var _loc3_:Sprite = new Sprite();
         _loc3_.addEventListener("mouseOver",mouseOverEvent);
         _loc3_.addEventListener("mouseOut",mouseOutEvent);
         _loc3_.addEventListener("mouseDown",mouseDownEvent);
         _loc3_.addEventListener("middleMouseDown",mouseDownEvent);
         _loc3_.addEventListener("rightMouseDown",mouseDownEvent);
         _contentBars.addChild(_loc3_);
         view.addChild(_borders);
         view.addChild(_contentBars);
      }
      
      override public function removeControl(child:Control) : void
      {
         super.removeControl(child);
         _contentBars.removeChildAt(0);
      }
      
      private function mouseOverEvent(evt:MouseEvent) : void
      {
         if(!evt.buttonDown)
         {
            Mouse.cursor = orientation == "horizontal"?"resize_h":"resize_v";
         }
      }
      
      private function mouseOutEvent(evt:MouseEvent) : void
      {
         if(!evt.buttonDown)
         {
            Mouse.cursor = "auto";
         }
      }
      
      private function mouseDownEvent(evt:MouseEvent) : void
      {
         if(orientation == "horizontal")
         {
            _last = evt.stageX;
         }
         else
         {
            _last = evt.stageY;
         }
         _bar = evt.target as Sprite;
         view.mouseChildren = false;
         view.mouseEnabled = false;
         view.stage.addEventListener(MouseEvent.MOUSE_UP,mouseUpEvent);
         view.stage.addEventListener(MouseEvent.MIDDLE_MOUSE_UP,mouseUpEvent);
         view.stage.addEventListener(MouseEvent.RIGHT_MOUSE_UP,mouseUpEvent);
         view.stage.addEventListener(MouseEvent.MOUSE_MOVE,mouseMoveEvent);
      }
      
      private function mouseUpEvent(evt:MouseEvent) : void
      {
         view.mouseChildren = true;
         view.mouseEnabled = true;
		 view.stage.removeEventListener(MouseEvent.MOUSE_UP,mouseUpEvent);
		 view.stage.removeEventListener(MouseEvent.MIDDLE_MOUSE_UP,mouseUpEvent);
		 view.stage.removeEventListener(MouseEvent.RIGHT_MOUSE_UP,mouseUpEvent);
		 view.stage.removeEventListener(MouseEvent.MOUSE_MOVE,mouseMoveEvent);
         if(evt.target != _bar)
         {
            Mouse.cursor = MouseCursor.AUTO;
         }
      }
      
      private function get totalFlexible() : Number
      {
         var total_flexible:* = 0.0;
         for each(var child:Control in controls)
         {
            if(child.visible)
            {
               total_flexible = total_flexible + child.flexible;
            }
         }
         return total_flexible;
      }
      
      private function mouseMoveEvent(evt:MouseEvent) : void
      {
         var mouseSpeed:Number;
         var total_flexible_t:Number = totalFlexible;
         var child:int = _contentBars.getChildIndex(_bar);
         if(orientation == "horizontal")
         {
            mouseSpeed = evt.stageX - _last;
            _last = evt.stageX;
            controls[child].flexible = controls[child].flexible + mouseSpeed * total_flexible_t / width;
            controls[child + 1].flexible = controls[child + 1].flexible - mouseSpeed * total_flexible_t / width;
         }
         else
         {
            mouseSpeed = evt.stageY - _last;
            _last = evt.stageY;
            controls[child].flexible = controls[child].flexible + mouseSpeed * total_flexible_t / height;
            controls[child + 1].flexible = controls[child + 1].flexible - mouseSpeed * total_flexible_t / height;
         }
         update();
         draw();
         for each(var child_t:* in controls)
         {
            if(child_t.flexible != 0)
            {
               if(orientation == "horizontal")
               {
				   child_t.flexible = child_t.width / width;
               }
               else
               {
				   child_t.flexible = child_t.height / height;
               }
            }
         }
         draw();
      }
      
      public function normalize() : void
      {
         var _loc1_:* = null;
         var _loc3_:* = 0.0;
         var _loc2_:* = 0.0;
         for each(_loc1_ in controls)
         {
            if(_loc1_.flexible != 0)
            {
               _loc3_ = _loc3_ + _loc1_.flexible;
               _loc2_ = _loc2_ + _loc1_.width;
            }
         }
         var _loc7_:* = 0;
         var _loc6_:* = controls;
         for each(_loc1_ in controls)
         {
            if(_loc1_.flexible != 0)
            {
               _loc1_.flexible = _loc1_.width / _loc2_;
            }
         }
      }
      
      public function get allowResize() : Boolean
      {
         return _contentBars.visible;
      }
      
      public function set allowResize(val:Boolean) : void
      {
         _contentBars.visible = val;
         draw();
      }
      
      override public function update() : void
      {
         if(!visible)
         {
            return;
         }
         if(orientation == "vertical")
         {
            spreadVertical();
         }
         else if(orientation == "horizontal")
         {
            spreadHorizontal();
         }
         
         var _loc3_:* = 0;
         var _loc2_:* = controls;
         for each(var child:Control in controls)
         {
            if(child is Container)
            {
               Container(child).update();
            }
         }
      }
      
      private function spreadHorizontal() : void
      {
         var _loc1_:* = null;
         var _loc4_:* = 0;
         var _loc3_:* = NaN;
         var _loc8_:* = NaN;
         var _loc10_:* = NaN;
         var _loc6_:* = NaN;
         var _loc7_:* = NaN;
         var _loc5_:Number = width - margins * 2 - space * (controls.length - 1);
         var _loc2_:Number = height - margins * 2;
         var _loc9_:Dictionary = new Dictionary();
         do
         {
            _loc3_ = 0.0;
            _loc8_ = 0.0;
            var _loc12_:* = 0;
            var _loc11_:* = controls;
            for each(_loc1_ in controls)
            {
               if(_loc1_.visible)
               {
                  if(_loc1_.flexible == 0 || _loc9_[_loc1_] == true)
                  {
                     _loc3_ = _loc3_ + _loc1_.width;
                     _loc9_[_loc1_] = true;
                  }
                  else
                  {
                     _loc8_ = _loc8_ + _loc1_.flexible;
                  }
               }
            }
            _loc6_ = 0.0;
            _loc7_ = _loc5_ - _loc3_;
            var _loc14_:* = 0;
            var _loc13_:* = controls;
            for each(_loc1_ in controls)
            {
               if(_loc1_.visible)
               {
                  if(_loc9_[_loc1_] == undefined)
                  {
                     _loc10_ = _loc1_.flexible * _loc7_ / _loc8_;
                     _loc1_.width = _loc10_;
                     _loc1_.height = _loc2_;
                     if(_loc1_.width != _loc10_)
                     {
                        _loc9_[_loc1_] = true;
                     }
                  }
                  _loc6_ = _loc6_ + _loc1_.width;
               }
            }
            if(_loc6_ > _loc5_)
            {
               var _loc16_:* = 0;
               var _loc15_:* = controls;
               for each(_loc1_ in controls)
               {
                  if(_loc1_.visible)
                  {
                     if(_loc1_.flexible && (_loc1_.minWidth == -1 || _loc1_.minWidth < _loc1_.width))
                     {
                        delete _loc9_[_loc1_];
                        true;
                     }
                  }
               }
            }
            else if(_loc6_ < _loc5_)
            {
               var _loc18_:* = 0;
               var _loc17_:* = controls;
               for each(_loc1_ in controls)
               {
                  if(_loc1_.visible)
                  {
                     if(_loc1_.flexible && (_loc1_.maxWidth == -1 || _loc1_.maxWidth > _loc1_.width))
                     {
                        delete _loc9_[_loc1_];
                        true;
                     }
                  }
               }
            }
            
         }
         while(Math.abs(_loc6_ - _loc5_) > 0.01 && _loc4_ < 2);
         
      }
      
      private function spreadVertical() : void
      {
         var _loc12_:* = 0;
         var _loc1_:* = null;
         var _loc4_:* = 0;
         var _loc3_:* = NaN;
         var _loc8_:* = NaN;
         var _loc11_:* = NaN;
         var _loc6_:* = NaN;
         var _loc7_:* = NaN;
         var _loc9_:int = controls.length;
         var _loc5_:Number = width - margins * 2;
         var _loc2_:Number = height - margins * 2 - space * (controls.length - 1);
         var _loc10_:Dictionary = new Dictionary();
         do
         {
            _loc3_ = 0.0;
            _loc8_ = 0.0;
            var _loc14_:* = 0;
            var _loc13_:* = controls;
            for each(_loc1_ in controls)
            {
               if(_loc1_.visible)
               {
                  if(_loc1_.flexible == 0 || _loc10_[_loc1_] == true)
                  {
                     _loc3_ = _loc3_ + _loc1_.height;
                     _loc10_[_loc1_] = true;
                  }
                  else
                  {
                     _loc8_ = _loc8_ + _loc1_.flexible;
                  }
               }
            }
            _loc6_ = 0.0;
            _loc7_ = _loc2_ - _loc3_;
            var _loc16_:* = 0;
            var _loc15_:* = controls;
            for each(_loc1_ in controls)
            {
               if(_loc1_.visible)
               {
                  if(_loc10_[_loc1_] == undefined)
                  {
                     _loc11_ = _loc1_.flexible * _loc7_ / _loc8_;
                     _loc1_.width = _loc5_;
                     _loc1_.height = _loc11_;
                     if(_loc1_.height != _loc11_)
                     {
                        _loc10_[_loc1_] = true;
                     }
                  }
                  _loc6_ = _loc6_ + _loc1_.height;
               }
            }
            if(_loc6_ > _loc2_)
            {
               var _loc18_:* = 0;
               var _loc17_:* = controls;
               for each(_loc1_ in controls)
               {
                  if(_loc1_.visible)
                  {
                     if(_loc1_.flexible && (_loc1_.minHeight == -1 || _loc1_.minHeight < _loc1_.height))
                     {
                        delete _loc10_[_loc1_];
                        true;
                     }
                  }
               }
            }
            else if(_loc6_ < _loc2_)
            {
               var _loc20_:* = 0;
               var _loc19_:* = controls;
               for each(_loc1_ in controls)
               {
                  if(_loc1_.visible)
                  {
                     if(_loc1_.flexible && (_loc1_.maxHeight == -1 || _loc1_.maxHeight > _loc1_.height))
                     {
                        delete _loc10_[_loc1_];
                        true;
                     }
                  }
               }
            }
            
         }
         while(Math.abs(_loc6_ - _loc2_) > 0.01 && _loc4_ < 2);
         
      }
      
      override public function draw() : void
      {
         var _loc1_:* = null;
         var _loc7_:* = NaN;
         var _loc2_:* = 0;
         var _loc6_:* = NaN;
         var _loc4_:* = null;
         var _loc9_:* = 0;
         var _loc5_:* = null;
         if(!visible)
         {
            return;
         }
         super.draw();
         var _loc3_:Number = margins;
         var _loc8_:Number = margins;
         if(orientation == "grid")
         {
            if(!parent)
            {
               return;
            }
            _loc7_ = parent.width - 15 - margins;
            _loc2_ = _loc7_ / (gridSize.x + space);
            _loc6_ = _loc7_ / _loc2_;
            rowCount = _loc2_;
         }
         var _loc11_:* = 0;
         var _loc10_:* = controls;
         for each(_loc1_ in controls)
         {
            if(_loc1_.visible)
            {
               if(orientation == "vertical")
               {
                  _loc1_.y = _loc3_;
                  _loc1_.x = margins;
                  _loc3_ = _loc1_.y + _loc1_.height + space;
               }
               else if(orientation == "horizontal")
               {
                  _loc1_.x = _loc3_;
                  _loc1_.y = margins;
                  _loc3_ = _loc1_.x + _loc1_.width + space;
               }
               else if(orientation == "grid")
               {
                  _loc1_.x = _loc3_;
                  _loc1_.y = _loc8_;
                  _loc1_.width = _loc6_ - space;
                  _loc1_.height = gridSize.y;
                  _loc3_ = _loc3_ + _loc6_;
                  if(_loc3_ >= _loc7_)
                  {
                     _loc3_ = margins;
                     _loc8_ = _loc8_ + (gridSize.y + space);
                  }
               }
               
               
               _loc1_.draw();
            }
         }
         if(orientation != "grid")
         {
            rowCount = 1;
         }
         if(_contentBars.visible)
         {
            _contentBars.x = 0;
            _contentBars.y = 0;
            view.addChild(_contentBars);
            _loc9_ = 0;
            while(_loc9_ < controls.length)
            {
               _loc5_ = _contentBars.getChildAt(controls.indexOf(controls[_loc9_])) as Sprite;
               _loc5_.graphics.clear();
               _loc5_.visible = controls[_loc9_].visible;
               if(_loc5_.visible)
               {
                  _loc4_ = _loc5_;
               }
               if(orientation == "vertical")
               {
                  _loc5_.x = 0;
                  _loc5_.y = controls[_loc9_].y + controls[_loc9_].height + space * 0.5;
                  _loc5_.graphics.beginFill(16776960,0);
                  _loc5_.graphics.drawRect(0,-3,width,6);
                  _loc5_.graphics.lineStyle(1,Style.borderDark,1,true);
                  _loc5_.graphics.moveTo(0,0);
                  _loc5_.graphics.lineTo(width,0);
               }
               else
               {
                  _loc5_.y = 0;
                  _loc5_.x = controls[_loc9_].x + controls[_loc9_].width + space * 0.5;
                  _loc5_.graphics.beginFill(16776960,0);
                  _loc5_.graphics.drawRect(-3,0,6,height);
                  _loc5_.graphics.lineStyle(1,Style.borderDark,1,true);
                  _loc5_.graphics.moveTo(0,0);
                  _loc5_.graphics.lineTo(0,height);
               }
               _loc9_++;
            }
            if(_loc4_)
            {
               _loc4_.visible = false;
            }
         }
      }
      
      override public function set width(param1:Number) : void
      {
         var _loc2_:Number = minWidth;
         var _loc3_:Number = maxWidth;
         if(flexible != 0)
         {
            if(!(_loc2_ == -1) && param1 < _loc2_)
            {
               var param1:* = _loc2_;
            }
            if(!(_loc3_ == -1) && param1 > _loc3_)
            {
               param1 = _loc3_;
            }
         }
         if(param1 < 0)
         {
            param1 = 0.0;
         }
         if(param1 != super.width)
         {
            super.width = param1;
         }
      }
      
      override public function set height(val:Number) : void
      {
         var _loc2_:Number = minHeight;
         var _loc3_:Number = maxHeight;
         if(flexible != 0)
         {
            if(!(_loc2_ == -1) && val < _loc2_)
            {
               val = _loc2_;
            }
            if(!(_loc3_ == -1) && val > _loc3_)
            {
               val = _loc3_;
            }
         }
         if(val < 0)
         {
            val = 0.0;
         }
         if(val != super.height)
         {
            super.height = val;
         }
      }
      
      override public function get minWidth() : Number
      {
         var _loc4_:* = 0;
         var _loc2_:* = null;
         if(flexible == 0)
         {
            return super.width;
         }
         if(!visible)
         {
            return super.minWidth == -1?-1:0.0;
         }
         var _loc1_:* = 0.0;
         var _loc3_:int = controls.length;
         _loc4_ = 0;
         while(_loc4_ < _loc3_)
         {
            _loc2_ = controls[_loc4_];
            if(_loc2_.visible)
            {
               if(orientation == "vertical")
               {
                  if(_loc2_.flexible == 0)
                  {
                     _loc1_ = Math.max(_loc1_,_loc2_.width);
                  }
                  else
                  {
                     _loc1_ = Math.max(_loc1_,_loc2_.minWidth);
                  }
               }
               else if(orientation == "horizontal")
               {
                  if(_loc2_.flexible == 0)
                  {
                     _loc1_ = _loc1_ + _loc2_.width;
                  }
                  else
                  {
                     _loc1_ = _loc1_ + Math.max(0,_loc2_.minWidth);
                  }
               }
               else
               {
                  return -1;
               }
               
            }
            _loc4_++;
         }
         _loc1_ = _loc1_ + (margins * 2 + (orientation == "vertical"?0:space * (controls.length - 1)));
         return Math.max(super.minWidth,_loc1_);
      }
      
      override public function get maxWidth() : Number
      {
         var _loc4_:* = 0;
         var _loc1_:* = null;
         if(flexible == 0)
         {
            return super.width;
         }
         if(!visible)
         {
            return super.maxWidth == -1?-1:0.0;
         }
         var _loc2_:* = 0.0;
         var _loc3_:int = controls.length;
         _loc4_ = 0;
         while(_loc4_ < _loc3_)
         {
            _loc1_ = controls[_loc4_];
            if(_loc1_.visible)
            {
               if(orientation == "vertical")
               {
                  if(_loc1_.flexible == 0)
                  {
                     _loc2_ = _loc1_.x + _loc1_.width;
                  }
                  else if(_loc1_.maxWidth != -1)
                  {
                     _loc2_ = Math.max(_loc2_,_loc1_.maxWidth);
                  }
                  else
                  {
                     return super.maxWidth;
                  }
                  
               }
               else if(orientation == "horizontal")
               {
                  if(_loc1_.flexible == 0)
                  {
                     _loc2_ = _loc2_ + (_loc1_.width + space);
                  }
                  else if(_loc1_.maxWidth != -1)
                  {
                     _loc2_ = _loc2_ + Math.max(0,_loc1_.maxWidth);
                  }
                  else
                  {
                     return super.maxWidth;
                  }
                  
               }
               else
               {
                  return -1;
               }
               
            }
            _loc4_++;
         }
         _loc2_ = _loc2_ + (margins * 2 + (orientation == "vertical"?space * (controls.length - 1):0.0));
         return Math.min(super.maxWidth != -1?super.maxWidth:_loc2_,_loc2_);
      }
      
      override public function get minHeight() : Number
      {
         var _loc4_:* = 0;
         var _loc2_:* = null;
         if(flexible == 0)
         {
            return super.height;
         }
         if(!visible)
         {
            return super.minHeight == -1?-1:0.0;
         }
         var _loc1_:* = 0.0;
         var _loc3_:int = controls.length;
         _loc4_ = 0;
         while(_loc4_ < _loc3_)
         {
            _loc2_ = controls[_loc4_];
            if(_loc2_.visible)
            {
               if(orientation == "vertical")
               {
                  if(_loc2_.flexible == 0)
                  {
                     _loc1_ = _loc1_ + _loc2_.height;
                  }
                  else
                  {
                     _loc1_ = _loc1_ + Math.max(0,_loc2_.minHeight);
                  }
               }
               else if(_loc2_.flexible == 0)
               {
                  _loc1_ = Math.max(_loc1_,_loc2_.y + _loc2_.height);
               }
               else
               {
                  _loc1_ = Math.max(_loc1_,_loc2_.y + _loc2_.minHeight);
               }
               
            }
            _loc4_++;
         }
         _loc1_ = _loc1_ + (margins * 2 + (orientation == "vertical"?space * (controls.length - 1):0.0));
         return Math.max(super.minHeight,_loc1_);
      }
      
      override public function get maxHeight() : Number
      {
         var _loc4_:* = 0;
         var _loc1_:* = null;
         if(flexible == 0)
         {
            return super.height;
         }
         if(!visible)
         {
            return super.maxHeight == -1?-1:0.0;
         }
         var _loc2_:* = 0.0;
         var _loc3_:int = controls.length;
         _loc4_ = 0;
         while(_loc4_ < _loc3_)
         {
            _loc1_ = controls[_loc4_];
            if(_loc1_.visible)
            {
               if(orientation == "vertical")
               {
                  if(_loc1_.flexible == 0)
                  {
                     _loc2_ = _loc2_ + (_loc1_.height + space);
                  }
                  else if(_loc1_.maxHeight != -1)
                  {
                     _loc2_ = _loc2_ + Math.max(0,_loc1_.maxHeight);
                  }
                  else
                  {
                     return super.maxHeight;
                  }
                  
               }
               else if(_loc1_.flexible == 0)
               {
                  _loc2_ = Math.max(_loc2_,_loc1_.y + _loc1_.height);
               }
               else if(_loc1_.maxHeight != -1)
               {
                  _loc2_ = Math.max(_loc2_,_loc1_.y + _loc1_.maxHeight);
               }
               else
               {
                  return super.maxHeight;
               }
               
               
            }
            _loc4_++;
         }
         _loc2_ = _loc2_ + (margins * 2 + (orientation == "vertical"?space * (controls.length - 1):0.0));
         return Math.min(super.maxHeight != -1?super.maxHeight:_loc2_,_loc2_);
      }
      
      public function get orientation() : String
      {
         return _orientation;
      }
      
      public function set orientation(param1:String) : void
      {
         _orientation = param1;
      }
   }
}
