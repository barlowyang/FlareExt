package flare.core
{
	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	import flash.display.GradientType;
	import flash.display.InterpolationMethod;
	import flash.display.Shape;
	import flash.display3D.Context3DBlendFactor;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import flash.utils.getTimer;
	
	import flare.basic.Scene3D;
	import flare.flsl.FLSLMaterial;
	import flare.materials.Material3D;
	import flare.naruto.particle.emitter.TParticleAreaBase;
	import flare.naruto.particle.emitter.ThreeD.TThreeDConst;
	import flare.system.Device3D;
	import flare.utils.Matrix3DUtils;
	
	public class Particles3DExt extends Pivot3D implements IDrawable
	{
		
		private static var data:Class = Particles3D_data;
		
		private static const flsl:ByteArray = new data();
		
		private static const COLOR_SAMPLES:int = 256;
		
		public static const SORT_NONE:int = 0;
		
		public static const SORT_YOUNGEST_FIRST:int = 1;
		
		public static const SORT_OLDEST_FIRST:int = 2;
		
		public static const BLEND_NONE:int = 0;
		
		public static const BLEND_ADDITIVE:int = 1;
		
		public static const BLEND_ALPHA_BLENDED:int = 2;
		
		public static const BLEND_MULTIPLY:int = 3;
		
		public static const BLEND_SCREEN:int = 4;
		
		public static const BLEND_ALPHA_BLENDED2:int = 5;
		
		private static var _shape:Shape = new Shape();
		
		private static var _matrix:Matrix = new Matrix();
		
		{
			data = Particles3D_data;
			_shape = new Shape();
			_matrix = new Matrix();
		}
		
		public var duration:Number = 1;
		
		public var initParticleFunction:Function;
		
		public var randomSeed:uint = 200;
		
		private var _temp:Vector3D;
		
		private var _currIndex:int;
		
		private var _time:Number = 0;
		
		private var _lastTime:Number = 0;
		
		private var _lastCountOffset:Number = 0;
		
		private var _prevTime:Number = 0;
		
		private var _paused:Boolean;
		
		private var _reverse:Boolean;
		
		private var _started:Boolean;
		
		private var _buildQueued:Boolean = true;
		
		private var _init:ParticleInit3D;
		
		private var _surface:Surface3D;
		
		private var _positionSurface:Surface3D;
		
		private var _velocitySurface:Surface3D;
		
		private var _material:FLSLMaterial;
		
		private var _posBytes:ByteArray;
		
		private var _velBytes:ByteArray;
		
		private var _blendMode:int = 1;
		
		private var _colorTexture:Texture3D;
		
		private var _colors:Array;
		
		private var _alphas:Array;
		
		private var _colorRatios:Array;
		
		private var _alphaRatios:Array;
		
		private var _worldPositions:Boolean = false;
		
		private var _worldVelocities:Boolean = false;
		
		private var _sortParticleMode:int = 0;
		
		private var _numParticles:int;
		
		private var _delay:Number = 0;
		
		private var _loops:Number = 0;
		
		private var _shots:int = 0;
		
		private var _useRandomColors:Boolean = false;
		
		private var _energy:Vector3D;
		
//		private var _area:Vector3D;
		private var _area:TParticleAreaBase;
		
		private var _hemisphere:Boolean = false;
		
		private var _startSize:Point;
		
		private var _endSize:Point;
		
		private var _randomScale:Number = 0;
		
		private var _velocity:Vector3D;
		
		private var _randomVelocity:Number = 0;
		
		private var _spin:Number = 0;
		
		private var _randomSpin:Number = 0;
		
		private var _gravity:Vector3D;
		
		private var _srcFactor:String = "one";
		
		private var _destFactor:String = "one";
		
		private var _textureFrames:Point;
		
		private var _randomFrame:Boolean = false;
		
		private var _clonedColors:Boolean = false;
		
		private var _rndSeed:uint;
		
		public function Particles3DExt(name:String = "particles", area_param:TParticleAreaBase = null, texture:Texture3D = null)
		{
			this._temp = new Vector3D();
			this._colors = [16777215];
			this._alphas = [1,0];
			this._colorRatios = [0];
			this._alphaRatios = [0,255];
			this._energy = new Vector3D(100,100,100);
			this._area = area_param || new TThreeDConst();
			
			this._startSize = new Point(1,1);
			this._endSize = new Point(1,1);
			this._velocity = new Vector3D(0,0,0);
			this._gravity = new Vector3D();
			this._textureFrames = new Point(1,1);
			this._rndSeed = this.randomSeed;
			super(name);
			this._init = new ParticleInit3D();
			this._posBytes = new ByteArray();
			this._velBytes = new ByteArray();
			this._posBytes.endian = Endian.LITTLE_ENDIAN;
			this._velBytes.endian = Endian.LITTLE_ENDIAN;
			this._material = new FLSLMaterial("particles");
			this._material.byteCode = flsl;
			this._material.params.delay.value = Vector.<Number>([0]);
			this._material.params.time.value = Vector.<Number>([0]);
			this._material.params.loops.value = Vector.<Number>([0]);
			this._material.params.randomColors.value = Vector.<Number>([0]);
			this._material.params.gravity.value = Vector.<Number>([0,0,0,2]);
			this._material.params.size.value = Vector.<Number>([1,1,1,1]);
			this._material.params.worldPosition.value = Vector.<Number>([0]);
			this._material.params.reverse.value = Vector.<Number>([0]);
			this._material.params.spin.value = Vector.<Number>([0]);
			this._material.params.frames.value = Vector.<Number>([1,1]);
			this._material.params.randomFrame.value = Vector.<Number>([0]);
			this._material.params.tint.value = Vector.<Number>([1,1,1,1]);
			
			this._positionSurface = new Surface3D("position_particles");
			this._positionSurface.addVertexData(Surface3D.POSITION);
			this._velocitySurface = new Surface3D("velocity_particles");
			this._velocitySurface.addVertexData(Surface3D.COLOR0);
			this._surface = new Surface3D("particles");
			this._surface.addExternalSource(Surface3D.POSITION,this._positionSurface);
			this._surface.addExternalSource(Surface3D.COLOR0,this._velocitySurface);
			this._surface.addVertexData(Surface3D.UV0);
			this._surface.addVertexData(Surface3D.PARTICLE);
			this._surface.addVertexData(Surface3D.COLOR1,1);
			this._surface.bounds = new Boundings3D();
			this._surface.material = this._material;
			this.numParticles = 200;
			this.duration = 1;
			this.shots = 0;
			this.energy.setTo(100,100,100);
			this.texture = texture || new Texture3D(Device3D.nullBitmapData);
			this.blendMode = BLEND_ALPHA_BLENDED;
			this.setLayer(10);
		}
		
		override function addedToScene(scene:Scene3D) : void
		{
			super.addedToScene(scene);
			this.start();
		}
		
		override function removedFromScene() : void
		{
			this.pause();
			super.removedFromScene();
		}
		
		override public function clone() : Pivot3D
		{
			var c:Pivot3D = null;
			var n:Particles3DExt = new Particles3DExt(name, _area, this.texture);
			n.copyFrom(this);
			n.dirty = true;
			n.duration = this.duration;
			n.texture = this.texture;
			n.blendTexture = this.blendTexture;
			n.initParticleFunction = this.initParticleFunction;
			n._clonedColors = true;
			n._colors = this._colors;
			n._alphas = this._alphas;
			n._colorRatios = this._colorRatios;
			n._alphaRatios = this._alphaRatios;
			n._useRandomColors = this._useRandomColors;
			n._colorTexture = this._colorTexture;
			n._material.params.randomColors.value[0] = this._useRandomColors?1:0;
			n._material.params.colorTexture.value = this._colorTexture;
			n._material.params.tint.value = this._material.params.tint.value.concat();
			n.sortMode = this._sortParticleMode;
			n.numParticles = this._numParticles;
			n.delay = this._delay;
			n.loops = this._loops;
			n.shots = this._shots;
			n.energy.copyFrom(this.energy);
			n.area = this.area;
			n.velocity = this._velocity;
			n.randomVelocity = this._randomVelocity;
			n.gravity.copyFrom(this._gravity);
			n.gravityPower = this.gravityPower;
			n.blendMode = this._blendMode;
			n.hemisphere = this._hemisphere;
			n.startSize.copyFrom(this.startSize);
			n.endSize.copyFrom(this.endSize);
			n.randomScale = this._randomScale;
			n.spin = this._spin;
			n.randomSpin = this._randomSpin;
			n.worldVelocities = this._worldVelocities;
			n.worldPositions = this._worldPositions;
			n.textureFrames = this._textureFrames;
			n.reverse = this._reverse;
			if(!this._paused)
			{
				n.pause();
			}
			for each(c in children)
			{
				if(!c.lock)
				{
					n.addChild(c.clone());
				}
			}
			return n;
		}
		
		override public function dispose() : void
		{
			if(this._posBytes)
			{
				this._posBytes.clear();
			}
			if(this._velBytes)
			{
				this._velBytes.clear();
			}
			if(this._colorTexture)
			{
				this._colorTexture.download();
			}
			if(this._surface)
			{
				this._surface.dispose();
				this._surface = null;
			}
			if(this._material)
			{
				this._material.dispose();
				this._material = null;
			}
			super.dispose();
		}
		
		public function setColors(colors:Array, ratios:Array) : void
		{
			var i:* = 0;
			if(this._clonedColors)
			{
				this._clonedColors = false;
				this._colorTexture = null;
			}
			this._colorTexture = this._colorTexture || new Texture3D(new BitmapData(256,16,true,4.294967295E9));
			this._colorTexture.allowRuntimeCompression = 0;
			this._colorTexture.wrapMode = Texture3D.WRAP_CLAMP;
			this._colorTexture.download();
			this._colors = colors;
			this._colorRatios = ratios;
			_matrix.createGradientBox(COLOR_SAMPLES,16);
			_shape.graphics.clear();
			_shape.graphics.beginGradientFill(GradientType.LINEAR,this._colors,null,this._colorRatios,_matrix,"pad",InterpolationMethod.RGB);
			_shape.graphics.drawRect(0,0,COLOR_SAMPLES,8);
			this._colorTexture.bitmapData.draw(_shape);
			if(!this._useRandomColors)
			{
				var colors_1:Array = [];
				for(i = 0; i < this._alphas.length; i++)
				{
					colors_1.push(16777215);
				}
				_shape.graphics.clear();
				_shape.graphics.beginGradientFill(GradientType.LINEAR,colors_1,this._alphas,this._alphaRatios,_matrix,"pad",InterpolationMethod.RGB);
				_shape.graphics.drawRect(0,8,COLOR_SAMPLES,8);
				this._colorTexture.bitmapData.copyChannel(this._colorTexture.bitmapData,new Rectangle(0,8,COLOR_SAMPLES,8),new Point(),BitmapDataChannel.ALPHA,BitmapDataChannel.ALPHA);
			}
			this._material.params.colorTexture.value = this._colorTexture;
		}
		
		public function setAlphas(alphas:Array, ratios:Array) : void
		{
			if(this._clonedColors)
			{
				this._clonedColors = false;
				this._colorTexture = null;
			}
			this._colorTexture = this._colorTexture || new Texture3D(new BitmapData(256,16,true,4.294967295E9));
			this._colorTexture.allowRuntimeCompression = 0;
			this._colorTexture.wrapMode = Texture3D.WRAP_CLAMP;
			this._colorTexture.download();
			this._alphas = alphas;
			this._alphaRatios = ratios;
			_matrix.createGradientBox(COLOR_SAMPLES,16);
			var rect:Rectangle = new Rectangle(0,8,COLOR_SAMPLES,8);
			var colors:Array = [];
			for(var i:int = 0; i < alphas.length; i++)
			{
				colors.push(16777215);
			}
			_shape.graphics.clear();
			_shape.graphics.beginGradientFill(GradientType.LINEAR,colors,this._alphas,this._alphaRatios,_matrix,"pad",InterpolationMethod.RGB);
			_shape.graphics.drawRect(0,8,COLOR_SAMPLES,16);
			this._colorTexture.bitmapData.fillRect(rect,0);
			this._colorTexture.bitmapData.draw(_shape);
			if(!this._useRandomColors)
			{
				this.setColors(this._colors,this._colorRatios);
				this._colorTexture.bitmapData.copyChannel(this._colorTexture.bitmapData,rect,new Point(),BitmapDataChannel.ALPHA,BitmapDataChannel.ALPHA);
			}
			this._material.params.colorTexture.value = this._colorTexture;
		}
		
		public function setTint(r:Number, g:Number, b:Number, a:Number = 1) : void
		{
			this._material.params.tint.value[0] = r;
			this._material.params.tint.value[1] = g;
			this._material.params.tint.value[2] = b;
			this._material.params.tint.value[3] = a;
		}
		
		public function get tint() : Vector.<Number>
		{
			return this._material.params.tint.value;
		}
		
		override public function get inView() : Boolean
		{
			return true;
		}
		
		public function get numParticles() : int
		{
			return this._numParticles;
		}
		
		public function set numParticles(value:int) : void
		{
			this._numParticles = value;
			this._buildQueued = true;
		}
		
		private function initFunction(emitter:Particles3DExt, index:int, init:ParticleInit3D) : void
		{
			/*
			init.position.x = this._area.x * this.random() - this._area.x * 0.5;
			init.position.y = this._area.y * this.random() - this._area.y * 0.5;
			init.position.z = this._area.z * this.random() - this._area.z * 0.5;
			*/
			var tmp_pos:Vector3D = _area.GeneratePos();
			init.position.x = tmp_pos.x;
			init.position.y = tmp_pos.y;
			init.position.z = tmp_pos.z;
			
			
			init.velocity.x = this.random() - 0.5;
			init.velocity.y = this.random() - 0.5;
			init.velocity.z = this.random() - 0.5;
			init.velocity.x = init.velocity.x * this._energy.x;
			init.velocity.y = init.velocity.y * this._energy.y;
			init.velocity.z = init.velocity.z * this._energy.z;
			if(emitter._hemisphere)
			{
				if(init.velocity.y < 0)
				{
					init.velocity.y = init.velocity.y * -1;
				}
				if(init.position.y < 0)
				{
					init.position.y = init.position.y * -1;
				}
			}
			init.velocity.normalize();
			init.velocity.x = init.velocity.x * this._energy.x * 0.5;
			init.velocity.y = init.velocity.y * this._energy.y * 0.5;
			init.velocity.z = init.velocity.z * this._energy.z * 0.5;
			this._temp.x = this.random() - 0.5;
			this._temp.y = this.random() - 0.5;
			this._temp.z = this.random() - 0.5;
			this._temp.normalize();
			this._temp.scaleBy(emitter._randomVelocity * 0.5);
			init.velocity.incrementBy(emitter._velocity);
			init.velocity.incrementBy(this._temp);
			if((emitter._worldPositions) || (emitter._worldVelocities))
			{
				emitter.localToGlobal(init.position,init.position);
				emitter.localToGlobalVector(init.velocity,init.velocity);
			}
			init.spin = -emitter._spin - (this.random() - 0.5) * emitter._randomSpin * 2;
			init.scale = 1 + this.random() * emitter._randomScale;
		}
		
		public function reset() : void
		{
			this._buildQueued = true;
		}
		
		public function build() : void
		{
			var time:* = NaN;
			var time2:* = NaN;
			if(!this._buildQueued)
			{
				return;
			}
			if(this.numParticles == 0)
			{
				return;
			}
			this._buildQueued = false;
			this._rndSeed = this.randomSeed;
			var position:Vector.<Number> = new Vector.<Number>();
			var velocity:Vector.<Number> = new Vector.<Number>();
			var vertex:Vector.<Number> = new Vector.<Number>();
			var indices:Vector.<uint> = new Vector.<uint>();
			this._positionSurface.vertexVector = position;
			this._velocitySurface.vertexVector = velocity;
			this._surface.vertexVector = vertex;
			this._surface.indexVector = indices;
			this._surface.download();
			this._positionSurface.download();
			this._velocitySurface.download();
			var index:int = 0;
			for(var i:int = 0; i < this._numParticles; i++)
			{
				if(this.initParticleFunction != null)
				{
					this.initParticleFunction(this,i,this._init);
				}
				else
				{
					this.initFunction(this,i,this._init);
				}
				velocity.push(this._init.velocity.x,this._init.velocity.y,this._init.velocity.z,
					this._init.velocity.x,this._init.velocity.y,this._init.velocity.z,
					this._init.velocity.x,this._init.velocity.y,this._init.velocity.z,
					this._init.velocity.x,this._init.velocity.y,this._init.velocity.z);
				
				position.push(this._init.position.x,this._init.position.y,this._init.position.z,
					this._init.position.x,this._init.position.y,this._init.position.z,
					this._init.position.x,this._init.position.y,this._init.position.z,
					this._init.position.x,this._init.position.y,this._init.position.z);
				time = i / this._numParticles;
				if(this._shots > 0)
				{
					time = time - time % (1 / this._shots);
				}
				
				time2 = this.random();
				vertex.push(1,1,this._init.scale,-this._init.scale,time,this._init.spin,time2,
					0,1,-this._init.scale,-this._init.scale,time,this._init.spin,time2,
					1,0,this._init.scale,this._init.scale,time,this._init.spin,time2,
					0,0,-this._init.scale,this._init.scale,time,this._init.spin,time2);
				if(this._sortParticleMode == SORT_YOUNGEST_FIRST)
				{
					indices.unshift(index,index + 1,index + 2,index + 3,index + 2,index + 1);
				}
				else
				{
					indices.push(index,index + 1,index + 2,index + 3,index + 2,index + 1);
				}
				index = index + 4;
			}
			this._material.rebuild();
			if(!this._colorTexture)
			{
				this.setColors(this._colors,this._colorRatios);
				this.setAlphas(this._alphas,this._alphaRatios);
			}
			this._lastTime = -this.duration;
			this._prevTime = getTimer();
			this._lastCountOffset = 0;
			this._currIndex = this._numParticles;
			if((this.worldPositions) || (this.worldVelocities))
			{
				if(this._surface.vertexBuffer)
				{
					this.updateBuffers(this._numParticles);
				}
			}
			if(!this._paused)
			{
				this._paused = false;
				this._started = true;
			}
		}
		
		public function get material() : FLSLMaterial
		{
			return this._material;
		}
		
		public function set delay(value:Number) : void
		{
			this._delay = value;
			this._material.params.delay.value[0] = value;
		}
		
		public function get delay() : Number
		{
			return this._delay;
		}
		
		public function set loops(value:Number) : void
		{
			this._loops = value;
		}
		
		public function get loops() : Number
		{
			return this._loops;
		}
		
		public function get colors() : Array
		{
			return this._colors;
		}
		
		public function get alphas() : Array
		{
			return this._alphas;
		}
		
		public function get colorRatios() : Array
		{
			return this._colorRatios;
		}
		
		public function get alphaRatios() : Array
		{
			return this._alphaRatios;
		}
		
		public function get shots() : int
		{
			return this._shots;
		}
		
		public function set shots(value:int) : void
		{
			if(this._shots != value)
			{
				this._shots = value;
				this._buildQueued = true;
			}
		}
		
		public function get worldPositions() : Boolean
		{
			return this._worldPositions;
		}
		
		public function set worldPositions(value:Boolean) : void
		{
			this._worldPositions = value;
			this._material.params.worldPosition.value[0] = value?1:0;
			this._buildQueued = true;
		}
		
		public function get worldVelocities() : Boolean
		{
			return this._worldVelocities;
		}
		
		public function set worldVelocities(value:Boolean) : void
		{
			this._worldVelocities = value;
			this._buildQueued = true;
		}
		
		public function get texture() : Texture3D
		{
			return this._material.params.texture.value;
		}
		
		public function set texture(value:Texture3D) : void
		{
			this._material.params.texture.value = value;
		}
		
		public function get blendTexture() : Texture3D
		{
			return this._material.params.blendTexture.value;
		}
		
		public function set blendTexture(value:Texture3D) : void
		{
			this._material.params.blendTexture.value = value;
			this._buildQueued = true;
		}
		
		override public function get sortMode() : int
		{
			return this._sortParticleMode;
		}
		
		override public function set sortMode(value:int) : void
		{
			this._sortParticleMode = value;
			this._buildQueued = true;
		}
		
		public function get useRandomColors() : Boolean
		{
			return this._useRandomColors;
		}
		
		public function set useRandomColors(value:Boolean) : void
		{
			this._useRandomColors = value;
			this.setColors(this._colors,this._colorRatios);
			this.setAlphas(this._alphas,this._alphaRatios);
			this._material.params.randomColors.value[0] = value?1:0;
			this._buildQueued = true;
		}
		
		public function set gravity(value:Vector3D) : void
		{
			this._gravity = value;
		}
		
		public function get gravity() : Vector3D
		{
			return this._gravity;
		}
		
		public function set gravityPower(value:Number) : void
		{
			this._material.params.gravity.value[3] = value;
		}
		
		public function get gravityPower() : Number
		{
			return this._material.params.gravity.value[3];
		}
		
		public function get startSize() : Point
		{
			return this._startSize;
		}
		
		public function set startSize(value:Point) : void
		{
			this._startSize = value;
			this._material.params.size.value[0] = value.x;
			this._material.params.size.value[1] = value.y;
		}
		
		public function get randomScale() : Number
		{
			return this._randomScale;
		}
		
		public function set randomScale(value:Number) : void
		{
			this._randomScale = value;
			this._buildQueued = true;
		}
		
		public function get endSize() : Point
		{
			return this._endSize;
		}
		
		public function set endSize(value:Point) : void
		{
			this._endSize = value;
			this._material.params.size.value[2] = value.x;
			this._material.params.size.value[3] = value.y;
		}
		
		public function get textureFrames() : Point
		{
			return this._textureFrames;
		}
		
		public function set textureFrames(value:Point) : void
		{
			if(!this._textureFrames.equals(value))
			{
				this._textureFrames = value;
				this._material.params.frames.value[0] = value.x;
				this._material.params.frames.value[1] = value.y;
				this._buildQueued = true;
			}
		}
		
		public function get randomFrame() : Boolean
		{
			return this._randomFrame;
		}
		
		public function set randomFrame(value:Boolean) : void
		{
			this._randomFrame = value;
			this._material.params.randomFrame.value[0] = value?1:0;
			this._buildQueued = true;
		}
		
		public function get velocity() : Vector3D
		{
			return this._velocity;
		}
		
		public function set velocity(value:Vector3D) : void
		{
			this._velocity = value;
			this._buildQueued = true;
		}
		
		public function get randomVelocity() : Number
		{
			return this._randomVelocity;
		}
		
		public function set randomVelocity(value:Number) : void
		{
			this._randomVelocity = value;
			this._buildQueued = true;
		}
		
		public function get spin() : Number
		{
			return this._spin;
		}
		
		public function set spin(value:Number) : void
		{
			this._spin = value;
			this._material.params.spin.value[0] = !(this._spin + this._randomSpin == 0)?1:0;
			this._buildQueued = true;
		}
		
		public function get randomSpin() : Number
		{
			return this._randomSpin;
		}
		
		public function set randomSpin(value:Number) : void
		{
			this._randomSpin = value;
			this._material.params.spin.value[0] = !(this._spin + this._randomSpin == 0)?1:0;
			this._buildQueued = true;
		}
		
		public function get energy() : Vector3D
		{
			return this._energy;
		}
		
		public function set energy(value:Vector3D) : void
		{
			this._energy = value;
			this._buildQueued = true;
		}
		
		public function get hemisphere() : Boolean
		{
			return this._hemisphere;
		}
		
		public function set hemisphere(value:Boolean) : void
		{
			this._hemisphere = value;
			this._buildQueued = true;
		}
		
		public function get area() : TParticleAreaBase
		{
			return this._area;
		}
		
		public function set area(value:TParticleAreaBase) : void
		{
			this._area = value;
			this._buildQueued = true;
		}
		
		private function get colorTexture() : Texture3D
		{
			return this._colorTexture;
		}
		
		private function updateBuffers(count:int) : void
		{
			var x:* = NaN;
			var y:* = NaN;
			var z:* = NaN;
			var startIndex:int = this._currIndex;
			while(count)
			{
				this._currIndex--;
				count--;
				if(this.initParticleFunction != null)
				{
					this.initParticleFunction(this,this._currIndex,this._init);
				}
				else
				{
					this.initFunction(this,this._currIndex,this._init);
				}
				if(this._worldPositions)
				{
					x = this._init.position.x;
					y = this._init.position.y;
					z = this._init.position.z;
					this._posBytes.writeFloat(x);
					this._posBytes.writeFloat(y);
					this._posBytes.writeFloat(z);
					this._posBytes.writeFloat(x);
					this._posBytes.writeFloat(y);
					this._posBytes.writeFloat(z);
					this._posBytes.writeFloat(x);
					this._posBytes.writeFloat(y);
					this._posBytes.writeFloat(z);
					this._posBytes.writeFloat(x);
					this._posBytes.writeFloat(y);
					this._posBytes.writeFloat(z);
				}
				if(this._worldVelocities)
				{
					x = this._init.velocity.x;
					y = this._init.velocity.y;
					z = this._init.velocity.z;
					this._velBytes.writeFloat(x);
					this._velBytes.writeFloat(y);
					this._velBytes.writeFloat(z);
					this._velBytes.writeFloat(x);
					this._velBytes.writeFloat(y);
					this._velBytes.writeFloat(z);
					this._velBytes.writeFloat(x);
					this._velBytes.writeFloat(y);
					this._velBytes.writeFloat(z);
					this._velBytes.writeFloat(x);
					this._velBytes.writeFloat(y);
					this._velBytes.writeFloat(z);
				}
				if(this._currIndex <= 0)
				{
					if((this._worldPositions) && (this._positionSurface.vertexBuffer))
					{
						this._positionSurface.vertexBuffer.uploadFromByteArray(this._posBytes,0,this._currIndex * 4,(startIndex - this._currIndex) * 4);
					}
					if((this._worldVelocities) && (this._velocitySurface.vertexBuffer))
					{
						this._velocitySurface.vertexBuffer.uploadFromByteArray(this._velBytes,0,this._currIndex * 4,(startIndex - this._currIndex) * 4);
					}
					this._currIndex = this._numParticles;
					startIndex = this._numParticles;
				}
			}
			if(startIndex - this._currIndex > 0)
			{
				if((this._worldPositions) && (this._positionSurface.vertexBuffer))
				{
					this._positionSurface.vertexBuffer.uploadFromByteArray(this._posBytes,0,this._currIndex * 4,(startIndex - this._currIndex) * 4);
				}
				if((this._worldVelocities) && (this._velocitySurface.vertexBuffer))
				{
					this._velocitySurface.vertexBuffer.uploadFromByteArray(this._velBytes,0,this._currIndex * 4,(startIndex - this._currIndex) * 4);
				}
			}
		}
		
		private function updateParticles(currTime:Number) : void
		{
			var deltaTime:* = NaN;
			var timePerShot:* = NaN;
			var timePerParticle:* = NaN;
			if(!this._surface.vertexBuffer)
			{
				return;
			}
			this._posBytes.position = 0;
			this._velBytes.position = 0;
			var count:Number = 0;
			if(this._shots > 0)
			{
				timePerShot = this.duration / this._shots;
				deltaTime = currTime - this._lastTime;
				if(deltaTime >= timePerShot)
				{
					count = this._numParticles / this._shots + this._lastCountOffset;
					count = count % this._numParticles;
					this.updateBuffers(count);
					this._lastCountOffset = count - int(count);
					this._lastTime = this._lastTime + timePerShot;
				}
			}
			else
			{
				timePerParticle = this.duration / this._numParticles;
				deltaTime = currTime - this._lastTime + timePerParticle;
				if(deltaTime >= timePerParticle)
				{
					count = int(deltaTime / timePerParticle);
					count = count % this._numParticles;
					this.updateBuffers(count);
					this._lastTime = this._lastTime + count * timePerParticle;
				}
			}
		}
		
		public function start() : void
		{
			this._time = 0;
			this._lastTime = -this.duration;
			this._prevTime = getTimer();
			this._lastCountOffset = 0;
			this._currIndex = this._numParticles;
			this._paused = false;
			this._started = true;
			if((this.worldPositions) || (this.worldVelocities))
			{
				if(this._surface.vertexBuffer)
				{
					this.updateBuffers(this._numParticles);
				}
			}
		}
		
		public function pause() : void
		{
			this._paused = true;
		}
		
		public function resume() : void
		{
			this._paused = false;
		}
		
		public function set time(value:Number) : void
		{
			this._time = value;
		}
		
		public function get time() : Number
		{
			return this._time;
		}
		
		public function get blendMode() : int
		{
			return this._blendMode;
		}
		
		public function set blendMode(value:int) : void
		{
			this._blendMode = value;
			switch(this._blendMode)
			{
				case BLEND_NONE:
					this._srcFactor = Context3DBlendFactor.ONE;
					this._destFactor = Context3DBlendFactor.ZERO;
					break;
				case BLEND_ADDITIVE:
					this._srcFactor = Context3DBlendFactor.ONE;
					this._destFactor = Context3DBlendFactor.ONE;
					break;
				case BLEND_ALPHA_BLENDED:
					this._srcFactor = Context3DBlendFactor.ONE;
					this._destFactor = Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;
					break;
				case BLEND_ALPHA_BLENDED2:
					this._srcFactor = Context3DBlendFactor.SOURCE_ALPHA;
					this._destFactor = Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;
					break;
				case BLEND_MULTIPLY:
					this._srcFactor = Context3DBlendFactor.DESTINATION_COLOR;
					this._destFactor = Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;
					break;
				case BLEND_SCREEN:
					this._srcFactor = Context3DBlendFactor.ONE;
					this._destFactor = Context3DBlendFactor.ONE_MINUS_SOURCE_COLOR;
					break;
			}
		}
		
		public function get reverse() : Boolean
		{
			return this._reverse;
		}
		
		public function set reverse(value:Boolean) : void
		{
			this._reverse = value;
			this._material.params.reverse.value[0] = value?1:0;
			this._buildQueued = true;
		}
		
		public function get paused() : Boolean
		{
			return this._paused;
		}
		
		override public function get isPlaying() : Boolean
		{
			return !this._paused;
		}
		
		override public function getTextures(includeChildren:Boolean = true, out:Vector.<Texture3D> = null) : Vector.<Texture3D>
		{
			var out_1:Vector.<Texture3D> = super.getTextures(includeChildren, out);
			if((this.texture) && (out_1.indexOf(this.texture) == -1))
			{
				out_1.push(this.texture);
			}
			if((this.blendTexture) && (out_1.indexOf(this.blendTexture) == -1))
			{
				out_1.push(this.blendTexture);
			}
			return out_1;
		}
		
		override public function draw(includeChildren:Boolean = true, material:Material3D = null) : void
		{
			var currParticle:* = 0;
			var i:* = 0;
			if(this._buildQueued)
			{
				this.build();
			}
			if(!_scene)
			{
				upload(Device3D.scene);
			}
			if(_eventFlags & ENTER_DRAW_FLAG)
			{
				dispatchEvent(_enterDrawEvent);
			}
			var time:Number = this._time - this._delay;
			var t:int = getTimer();
			if(!this._paused)
			{
				this._time = this._time + (t - this._prevTime) / 1000;
			}
			this._prevTime = t;
			if((this._loops > 0) && (time / this.duration > this._loops))
			{
				if((this._started) && (hasEventListener(ANIMATION_COMPLETE_EVENT)))
				{
					dispatchEvent(new Event(ANIMATION_COMPLETE_EVENT));
				}
				this._started = false;
				return;
			}
			if(time < -this.duration)
			{
				return;
			}
			if((!visible) || (this.numParticles == 0))
			{
				return;
			}
			world.copyColumnTo(3,this._temp);
			Matrix3DUtils.transformVector(Device3D.view,this._temp,this._temp);
			priority = this._temp.z / Device3D.camera.far * 100000;
			if((this._worldPositions) || (this._worldVelocities))
			{
				this.updateParticles(time);
			}
			Device3D.global.copyFrom(world);
			Device3D.worldViewProj.copyFrom(Device3D.global);
			Device3D.worldViewProj.append(Device3D.viewProj);
			Device3D.objectsDrawn++;
			getScale(false,this._temp);
			var scale:Number = this._temp.length;
			this._material.params.loops.value[0] = this._loops == 0?time / this.duration + 1:this._loops;
			this._material.params.time.value[0] = time / this.duration;
			this._material.params.size.value[0] = this._startSize.x * scale;
			this._material.params.size.value[1] = this._startSize.y * scale;
			this._material.params.size.value[2] = this._endSize.x * scale;
			this._material.params.size.value[3] = this._endSize.y * scale;
			this._material.params.gravity.value[0] = this._gravity.x * scale;
			this._material.params.gravity.value[1] = this._gravity.y * scale;
			this._material.params.gravity.value[2] = this._gravity.z * scale;
			this._material.params.colorTexture.value = this._colorTexture;
			this._material.programs[0].sourceFactor = this._srcFactor;
			this._material.programs[0].destFactor = this._destFactor;
			if(this._sortParticleMode == SORT_NONE)
			{
				this._material.draw(this,this._surface);
			}
			else
			{
				if(this._sortParticleMode == SORT_YOUNGEST_FIRST)
				{
					currParticle = time % this.duration / this.duration * this._numParticles;
					if(currParticle < 0)
					{
						currParticle = 0;
					}
				}
				else
				{
					currParticle = this._numParticles - time % this.duration / this.duration * this._numParticles;
					currParticle = currParticle % this._numParticles;
				}
				this._material.draw(this,this._surface,currParticle * 6,(this._numParticles - currParticle) * 2);
				this._material.draw(this,this._surface,0,currParticle * 2);
			}
			if(includeChildren)
			{
				for(i = children.length - 1; i >= 0; children[i].draw(true,material),i--)
				{
				}
			}
			if(_eventFlags & EXIT_DRAW_FLAG)
			{
				dispatchEvent(_exitDrawEvent);
			}
		}
		
		private function random() : Number
		{
			return (this._rndSeed = this._rndSeed * 16807 % 2147483647) / 2147483647 + 2.33E-10;
		}

	}
}


