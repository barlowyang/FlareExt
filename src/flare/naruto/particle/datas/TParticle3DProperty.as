package flare.naruto.particle.datas
{
	import flash.geom.Point;
	import flash.geom.Vector3D;
	
	import flare.core.Particles3DExt;
	import flare.core.Texture3D;
	import flare.naruto.particle.emitter.TParticleAreaBase;

	/**
	 * 粒子属性
	 *  
	 * @author GameTrees
	 * 
	 */
	public class TParticle3DProperty
	{
		private var FPos:Vector3D;
		private var FRot:Vector3D;
		private var FScale:Vector3D;
		
		private var FStatic:Boolean;
		private var FVisible:Boolean;
		private var FLayer:uint;
		
		private var FBlendMode:uint;
		private var FSortMode:uint;
		private var FArea:TParticleAreaBase;
		private var FEnergy:Vector3D;
		
		private var FHemisphere:Boolean;
		private var FReverse:Boolean;
		private var FWorldPos:Boolean;
		private var FWorldVel:Boolean;
		
		private var FNum:uint;
		private var FDuration:Number;
		private var FLoops:uint;
		private var FDelay:Number;
		private var FShots:uint;
		
		private var FVelocity:Vector3D;
		private var FGravity:Vector3D;
		private var FRandomVel:Number;
		private var FGravityPower:Number;
		
		private var FStartSize:Point;
		private var FEndSize:Point;
		private var FRandomScale:Number;
		
		private var FSpin:Number;
		private var FRandomSpin:Number;
		
		private var FUseRadomGradientColor:Boolean;
		private var FColors:Array;
		private var FColorRatios:Array;
		private var FAlpha:Array;
		private var FAlphaRatio:Array;
		private var FTint:uint;
		private var FRndFrame:Boolean;
		private var FTextureFrames:Point;
		private var FMainTexture:Texture3D;
		private var FBlendTexture:Texture3D;
		
		private var FParticle:Particles3DExt;
		
		public function TParticle3DProperty(Particle:Particles3DExt)
		{
			FParticle = Particle;
			/*
			FColors = [16777215];
			FAlpha = [1,0];
			FColorRatios = [0];
			FAlphaRatio = [0,255];
			FEnergy = new Vector3D(100,100,100);
			FArea = new TThreeDConst();
			FStartSize = new Point(1,1);
			FEndSize = new Point(1,1);
			FVelocity = new Vector3D(0,0,0);
			FGravity = new Vector3D();
			FTextureFrames = new Point(1,1);
			*/
		}
	}
}