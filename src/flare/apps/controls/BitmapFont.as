package flare.apps.controls
{
   import flash.display.BitmapData;
   import flash.display.Graphics;
   import flash.filters.BitmapFilter;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   import flash.text.TextFormat;
   
   public class BitmapFont extends Object
   {
      
      private static var _textField:TextField = new TextField();
      
      private static var _vertex:Vector.<Number> = new Vector.<Number>();
      
      private static var _index:Vector.<int> = new Vector.<int>();
      
      private static var _uvs:Vector.<Number> = new Vector.<Number>();
      
      private var _bmp:BitmapData;
      
      private var _matrix:Matrix;
      
      private var _rect:Vector.<Rectangle>;
      
      private var _dots:Number;
      
      public function BitmapFont(param1:TextFormat = null, param2:Array = null)
      {
         super();
         _matrix = new Matrix();
         createFont(param1,param2);
         _dots = textWidth("...");
      }
      
      private function createFont(txtFmt:TextFormat, param2:Array) : void
      {
         var _loc6_:* = 0;
         _textField.text = "|";
         _textField.autoSize = "left";
         _textField.antiAliasType = "advanced";
         _rect = new Vector.<Rectangle>();
         if(txtFmt)
         {
            _textField.defaultTextFormat = txtFmt;
         }
         _bmp = new BitmapData(512,512,true,0);
         var _loc5_:Matrix = new Matrix();
         _loc6_ = 32;
         while(_loc6_ < 255)
         {
            _textField.text = String.fromCharCode(_loc6_);
            if(_loc5_.tx + _textField.width >= _bmp.width)
            {
               _loc5_.tx = 0;
               _loc5_.ty = _loc5_.ty + _textField.height;
            }
            _bmp.draw(_textField,_loc5_,null,null,null,true);
            _rect[_rect.length] = new Rectangle(_loc5_.tx,_loc5_.ty,_textField.width + 4,_textField.height);
            _loc5_.tx = _loc5_.tx + (_textField.width + 5);
            _loc6_++;
         }
         var _loc4_:BitmapData = new BitmapData(_bmp.width,_loc5_.ty + _textField.height + 4,true,0);
         _loc4_.draw(_bmp,new Matrix(1,0,0,1,-2));
         _bmp.dispose();
         _bmp = _loc4_;
         if(param2)
         {
            for each(var bitFilter:BitmapFilter in param2)
            {
               _bmp.applyFilter(_bmp, _bmp.rect, new Point(), bitFilter);
            }
         }
      }
      
      public function textWidth(param1:String, param2:Number = 1.7976931348623157E308) : Number
      {
         var _loc5_:* = null;
         var _loc8_:* = 0;
         var _loc4_:* = 0;
         if(!param1 || param1.length == 0)
         {
            return 0;
         }
         var _loc7_:int = param1.length;
         var _loc3_:int = _rect.length;
         var _loc6_:* = 0.0;
         _loc8_ = 0;
         while(_loc8_ < _loc7_)
         {
            _loc4_ = param1.charCodeAt(_loc8_) - 32;
            if(_loc4_ > _loc3_)
            {
               _loc4_ = 0;
            }
            if(_loc4_ < 0)
            {
               _loc4_ = 0;
            }
            _loc5_ = _rect[_loc4_];
            _loc6_ = _loc6_ + (_loc5_.width - 8);
            if(_loc6_ > param2)
            {
               return param2;
            }
            _loc8_++;
         }
         return _loc6_;
      }
      
      public function textHeight() : Number
      {
         return _rect[0].height;
      }
      
      public function draw(param1:Graphics, param2:Number, param3:Number, param4:Number, param5:Number, param6:String, param7:uint = 0, param8:int = 0) : void
      {
         var _loc17_:* = null;
         var _loc13_:* = 0;
         var _loc9_:* = 0;
         var _loc15_:Number = textWidth(param6);
         var _loc12_:Number = _rect[0].height;
         if(_dots >= param4)
         {
            return;
         }
         var _loc11_:* = false;
         if(_loc15_ > param4)
         {
            _loc11_ = true;
            _loc15_ = param4;
         }
         if(param7 & 2)
         {
            param2 = param2 + Math.ceil(param4 * 0.5 - _loc15_ * 0.5);
         }
         else if(param7 & 1)
         {
            param2 = param2 + 0;
         }
         else if(param7 & 4)
         {
            param2 = param2 + (param4 - _loc15_);
         }
         
         
         if(param7 & 16)
         {
            param3 = param3 + Math.ceil(param5 * 0.5 - _loc12_ * 0.5);
         }
         else if(param7 & 8)
         {
            param3 = param3 + 0;
         }
         else if(param7 & 32)
         {
            param3 = param3 + (param5 - _loc12_);
         }
         
         
         param1.lineStyle();
         var _loc10_:int = param6?param6.length:0;
         var _loc16_:* = param2;
         var _loc14_:* = param3;
         _loc13_ = 0;
         while(_loc13_ < _loc10_)
         {
            _loc9_ = param6.charCodeAt(_loc13_) - 32;
            if(_loc9_ > _rect.length)
            {
               _loc9_ = 0;
            }
            _loc17_ = _rect[_loc9_];
            _matrix.tx = -_loc17_.x + _loc16_;
            _matrix.ty = -_loc17_.y + _loc14_;
            param1.beginBitmapFill(_bmp,_matrix);
            param1.drawRect(_loc16_,_loc14_,_loc17_.width,_loc17_.height);
            _loc16_ = _loc16_ + (_loc17_.width - 8);
            if(param8 <= 0)
            {
               if(_loc11_ && _loc16_ - param2 + 4 + _dots > param4)
               {
                  _loc11_ = false;
                  _loc13_ = -1;
                  _loc10_ = 3;
                  param6 = "...";
               }
            }
            else if(_loc11_ && _loc16_ - param2 + 4 >= param4)
            {
               _loc16_ = param2;
               _loc14_ = _loc14_ + (_loc12_ - 4);
               param8--;
            }
            
            _loc13_++;
         }
      }
   }
}
