package flare.apps.core
{
	import flash.display.BitmapData;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;
	import flash.text.TextFormat;
	
	import flare.apps.controls.BitmapFont;
	
	public class Style extends Object
	{
		
		public static var focusFilter:Array;
		
		public static var innerFocusFilter:Array;
		
		public static var backgroundColor:int = 4210752;
		
		public static var backgroundColor2:int = 2105376;
		
		public static var selectionColor:int = 2697513;
		
		public static var borderDark:int = 1381653;
		
		public static var borderBright:int = 6316128;
		
		public static var borderLight:int = 5263440;
		
		public static var labelsColor:int = 10461087;
		
		public static var labelsColor2:int = 7842533;
		
		public static var defaultFormat:TextFormat;
		
		public static var defaultFont:BitmapFont = new BitmapFont();
		
		public static var defaultFont2:BitmapFont;
		
		public static var defaultFont3:BitmapFont;
		
		public static var colorTransform:ColorTransform;
		
		public static function getBitmapData(w_t:uint, h_t:uint):BitmapData
		{
			var bmpData:BitmapData = new BitmapData(w_t, h_t);
			bmpData.fillRect(bmpData.rect, Math.random() * 0xffffff);
			return bmpData;
		}
		
		public function Style()
		{
			/*
			* Decompilation error
			* Code may be obfuscated
			* Tip: You can try enabling "Automatic deobfuscation" in Settings
			* Error type: ExecutionException (java.lang.StackOverflowError)
			*/
		}
	}
}
