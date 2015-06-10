package flare.apps.controls
{
   import flash.display.Sprite;
   
   public class View extends Sprite
   {
      
      private var _control:Control;
      
      public function View(t_control:Control)
      {
         super();
         _control = t_control;
         tabEnabled = false;
         tabIndex = -1;
         focusRect = false;
      }
      
      public function get control() : Control
      {
         return _control;
      }
   }
}
