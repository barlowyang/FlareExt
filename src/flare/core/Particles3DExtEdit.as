package flare.core
{
	import flare.naruto.particle.datas.TParticle3DProperty;
	import flare.naruto.particle.emitter.TParticleAreaBase;
	
	public class Particles3DExtEdit extends Particles3DExt
	{
		public function Particles3DExtEdit(name:String="particles", area_param:TParticleAreaBase=null, texture:Texture3D=null)
		{
			super(name, area_param, texture);
		}
		
		public function get property():TParticle3DProperty
		{
			return new TParticle3DProperty(this);
		}
	}
}