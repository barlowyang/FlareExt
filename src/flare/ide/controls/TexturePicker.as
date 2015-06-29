package flare.ide.controls
{
	import flash.desktop.NativeDragManager;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.NativeDragEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Rectangle;
	import flash.net.FileFilter;
	import flash.utils.ByteArray;
	
	import flare.apps.controls.Control;
	import flare.apps.controls.ImageButton;
	import flare.apps.core.Style;
	import flare.apps.events.ControlEvent;
	import flare.core.Texture3D;
	import flare.system.Device3D;
	
	public class TexturePicker extends Control
	{
		[Embed(source="../../../../embed/hot.png")]
		private static var MenuIcon:Class ;
		
		private static var menuIcon:Bitmap;
		
		private static var h:int;
		
		private static var v:int;
		
		private static var nullBitmapData:BitmapData;
		
		private static var _lastFile:File;
		
		private var _texture:Texture3D;
		
		private var _menu:ImageButton;
		
		private var _bitmap:Bitmap;
		private var _curBd:BitmapData;
		
		private var _file:File;
		
		public var type:int = 0;
		
		public var enableDrag:Boolean = true;
		
		public var canBeChanged:Boolean = true;
		
		public function TexturePicker(tex_1:Texture3D = null, menu_visible:Boolean = true, type_t:int = 0)
		{
			super();
			if(!nullBitmapData)
			{
				drawCheckered();
			}
			_bitmap = new Bitmap(nullBitmapData);
			_menu = new ImageButton(new MenuIcon());
			_menu.view.addEventListener(MouseEvent.CLICK, clickMenuEvent,false,0,true);
			_menu.visible = menu_visible;
			_menu.x = 55;
			view.focusRect = false;
			view.buttonMode = true;
			view.cacheAsBitmap = true;
			view.addChild(_bitmap);
			view.addChild(_menu.view);
			if(canBeChanged)
			{
				view.addEventListener("click",clickEvent);
			}
			view.addEventListener(NativeDragEvent.NATIVE_DRAG_ENTER,dragEnterEvent,false,0,true);
			view.addEventListener(NativeDragEvent.NATIVE_DRAG_DROP, dragDropEvent,false,0,true);
			flexible = 0;
			width = 50;
			height = 50;
			maxHeight = height;
			minHeight = height;
			maxWidth = width;
			minWidth = width;
			this.type = type_t;
			this.texture = tex_1;
		}
		
		private static function drawCheckered() : void
		{
			nullBitmapData = new BitmapData(64,64,false,16711680);
			var node_s:* = 8;
			h = 0;
			while(h < 8)
			{
				v = 0;
				while(v < 8)
				{
					nullBitmapData.fillRect(new Rectangle(h * node_s,v * node_s,node_s,node_s),(h % 2 + v % 2) % 2 == 0?Style.backgroundColor:Style.backgroundColor2);
					v = v + 1;
				}
				h = h + 1;
			}
		}
		
		private function clickMenuEvent(param1:MouseEvent) : void
		{
			/*
			param1.stopImmediatePropagation();
			param1.preventDefault();
			var _loc2_:Context = Context.getInstance();
			if(texture)
			{
			_loc2_.selection.resources = [_loc2_.project.getResource(texture)];
			_loc2_.selection.textures = [texture];
			_loc2_.openPanel("TEXTURES");
			_loc2_.callCallback("onShowSelectedResources");
			}
			*/
		}
		
		private function clickEvent(param1:MouseEvent) : void
		{
			var _loc3_:FileFilter = new FileFilter("Images (*.jpg, *.png, *.atf, *.bmp, *.tga, *.dds, *.psd)","*.jpg;*.png;*.atf;*.bmp;*.tga;*.dds;*.psd;");
			var _loc2_:File = _lastFile || (_file ? _file.parent : new File());
			_loc2_.browseForOpen("Import Texture",[_loc3_]);
			_loc2_.addEventListener(Event.SELECT, fileSelectEvent);
			_loc2_.addEventListener(Event.CANCEL, cancelSelectEvent);
		}
		
		private function cancelSelectEvent(evt:Event) : void
		{
			evt.target.removeEventListener(Event.SELECT,fileSelectEvent);
			evt.target.removeEventListener(Event.CANCEL,cancelSelectEvent);
		}
		
		private function fileSelectEvent(evt:Event) : void
		{
			evt.target.removeEventListener(Event.SELECT,fileSelectEvent);
			evt.target.removeEventListener(Event.CANCEL,cancelSelectEvent);
			var img_file:File = evt.target as File;
			_lastFile = img_file.parent;
			loadTexture(img_file);
		}
		
		private function dragEnterEvent(evt:NativeDragEvent) : void
		{
			if(!canBeChanged)
			{
				return;
			}
			if(evt.clipboard.getData("Texture3D") is Texture3D)
			{
				NativeDragManager.acceptDragDrop(view);
				return;
			}
			if(evt.clipboard.getData("resource.selection") is Array)
			{
				NativeDragManager.acceptDragDrop(view);
				return;
			}
			var file_list:Array = evt.clipboard.getData("air:file list") as Array;
			if(!file_list)
			{
				return;
			}
			trace(file_list);
			var img_file:File = file_list[0] as File;
			if(img_file && img_file.extension && (img_file.extension.toLowerCase() == "jpg" || img_file.extension.toLowerCase() == "png" || img_file.extension.toLowerCase() == "atf" || img_file.extension.toLowerCase() == "psd" || img_file.extension.toLowerCase() == "bmp" || img_file.extension.toLowerCase() == "tga" || img_file.extension.toLowerCase() == "dds"))
			{
				NativeDragManager.acceptDragDrop(view);
			}
		}
		
		private function dragDropEvent(evt:NativeDragEvent) : void
		{
			dispatchEvent(new ControlEvent(ControlEvent.UNDO, this));
			var tex_t:Texture3D = evt.clipboard.getData("Texture3D") as Texture3D;
			if(tex_t)
			{
				this.texture = tex_t;
				this.loadCompleteEvent(null);
				_file = null;
				return;
			}
			var file_arr:Array = evt.clipboard.getData("resource.selection") as Array;
			if(file_arr)
			{
				this.texture = file_arr[0].resource.object as Texture3D;
				this.loadCompleteEvent(null);
				_file = null;
				return;
			}
			file_arr = evt.clipboard.getData("air:file list") as Array;
			var img_file:File = file_arr[0] as File;
			if(img_file && (img_file.extension.toLowerCase() == "jpg" || img_file.extension.toLowerCase() == "png" || img_file.extension.toLowerCase() == "atf" || img_file.extension.toLowerCase() == "psd" || img_file.extension.toLowerCase() == "bmp" || img_file.extension.toLowerCase() == "tga" || img_file.extension.toLowerCase() == "dds"))
			{
				loadTexture(img_file);
			}
		}
		
		private function loadTexture(res_file:File) : void
		{
			dispatchEvent(new ControlEvent(ControlEvent.UNDO, this));
			
			/*
			var _loc3_:Context = Context.getInstance();
			var _loc2_:Resource = _loc3_.project.importFile(param1);
			if(_loc2_.object is Texture3D)
			{
			_loc3_.selection.resources = [_loc2_];
			_loc3_.selection.textures = [_loc2_.object];
			_loc3_.callCallback("onShowSelectedResources");
			_file = param1;
			this.texture = _loc2_.object as Texture3D;
			if(texture.loaded)
			{
			loadCompleteEvent(null);
			}
			return;
			}
			*/
			var stream_file:FileStream = new FileStream();
			stream_file.open(res_file, FileMode.READ);
			var file_bytes:ByteArray = new ByteArray();
			stream_file.readBytes(file_bytes);
			
			var bmp_loader:Loader = new Loader();
			bmp_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onBmpComplete);
			bmp_loader.loadBytes(file_bytes);
		}
		
		private function onBmpComplete(evt:Event):void
		{
			var contentInfo:LoaderInfo = evt.currentTarget as LoaderInfo;
			contentInfo.removeEventListener(Event.COMPLETE, onBmpComplete);
			
			_curBd = Bitmap(contentInfo.content).bitmapData;
			loadCompleteEvent(null);
		}
		
		public function get texture() : Texture3D
		{
			if (_texture == null)
			{
				_texture = new Texture3D(_curBd);
			}
			else
			{
				_texture.bitmapData = _curBd;
			}
			return _texture;
		}
		
		public function set texture(tex_t:Texture3D) : void
		{
			_texture = tex_t;
			if(tex_t)
			{
				_texture.typeMode = type;
				_texture.upload(Device3D.scene);
				if(!_texture.loaded)
				{
					_texture.addEventListener(Event.COMPLETE, loadCompleteEvent,false,0,true);
					_texture.addEventListener(IOErrorEvent.IO_ERROR, ioErrorEvent,false,0,true);
					_texture.load();
				}
			}
			else
			{
				draw();
			}
		}
		
		private function loadCompleteEvent(evt:Event) : void
		{
			draw();
			dispatchEvent(new ControlEvent(Event.CHANGE, this));
		}
		
		private function ioErrorEvent(evt:IOErrorEvent) : void
		{
			trace(evt);
		}
		
		override public function draw() : void
		{
			view.graphics.clear();
			view.graphics.lineStyle(1,Style.borderBright,1,true);
			view.graphics.beginFill(0);
			view.graphics.drawRect(0,0,width,height);
			view.graphics.endFill();
			_bitmap.x = 1;
			_bitmap.y = 1;
			_bitmap.width = width - 2;
			_bitmap.height = height - 2;
			
			_bitmap.bitmapData = _curBd || nullBitmapData;
			
			_bitmap.width = width - 2;
			_bitmap.height = height - 2;
			
			//		 trace(_bitmap.width, _bitmap.height);
			/*
			var _loc2_:Context = Context.getInstance();
			var _loc1_:Resource = _loc2_.project.getResource(_texture);
			if(_texture && _loc1_)
			{
			_bitmap.bitmapData = _loc1_.thumb || nullBitmapData;
			}
			else
			{
			_bitmap.bitmapData = nullBitmapData;
			}
			*/
		}
	}
}
