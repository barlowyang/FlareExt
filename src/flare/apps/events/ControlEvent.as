package flare.apps.events
{
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   import flare.apps.controls.Control;
   
   public class ControlEvent extends MouseEvent
   {
      
      public static const CLICK:String = "click";
      
      public static const RIGHT_CLICK:String = "rightClick";
      
      public static const DOUBLE_CLICK:String = "doubleClick";
      
      public static const CHANGE:String = "change";
      
      public static const STOP:String = "stop";
      
      public static const UNDO:String = "undo";
      
      private var _target:Control;
      
      public function ControlEvent(param1:String, param2:Control, param3:Boolean = false, param4:Boolean = false, param5:Boolean = false, param6:Boolean = false)
      {
         super(param1,false,false,NaN,NaN,param2?param2.view:null,param3,param4,param5,param6);
         _target = param2;
      }
      
      override public function get target() : Object
      {
         return _target;
      }
      
      override public function get currentTarget() : Object
      {
         return _target;
      }
      
      override public function clone() : Event
      {
         return new ControlEvent(type,_target,ctrlKey,altKey,shiftKey);
      }
      
      override public function toString() : String
      {
         return formatToString("ControlEvent","type","target");
      }
   }
}
