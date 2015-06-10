package flare.naruto.particle.emitter.ThreeD
{
    import flash.geom.Vector3D;
    
    import flare.naruto.particle.emitter.TParticleAreaBase;
    
	/**
	 * 圆环
	 *  
	 * @author GameTrees
	 * 
	 */
    public class TThreeDSphere extends TParticleAreaBase
    {
        private var FInnerRadius3:Number;
        private var FOuterRadius3:Number;
        private var FCenterX:Number;
        private var FCenterY:Number;
        private var FCenterZ:Number;
        
        public function TThreeDSphere(innerRadius:Number = 0, outerRadius:Number = 100, centerX:Number = 0, centerY:Number = 0, centerZ:Number = 0)
        {
            super();
            FInnerRadius3 = Math.pow(innerRadius, 3);
            FOuterRadius3 = Math.pow(outerRadius, 3);
            FCenterX = centerX;
            FCenterY = centerY;
            FCenterZ = centerZ;
        }
        
        public function get CenterZ():Number
        {
            return FCenterZ;
        }
        public function set CenterZ(value:Number):void
        {
            FCenterZ = value;
        }

        public function get CenterY():Number
        {
            return FCenterY;
        }
        public function set CenterY(value:Number):void
        {
            FCenterY = value;
        }

        public function get CenterX():Number
        {
            return FCenterX;
        }
        public function set CenterX(value:Number):void
        {
            FCenterX = value;
        }

        public function get OuterRadius():Number
        {
            return Math.pow(FOuterRadius3, 1/3);
        }
        public function set OuterRadius(value:Number):void
        {
            FOuterRadius3 = Math.pow(value, 3);
        }
        
        public function get InnerRadius():Number
        {
            return Math.pow(FInnerRadius3, 1/3);
        }
        public function set InnerRadius(value:Number):void
        {
            FInnerRadius3 = Math.pow(value, 3);
        }

        override public function GeneratePos():Vector3D
        {
            var degree1:Number = Math.random() * Math.PI * 2;
            var radius:Number = Math.pow(Math.random() * (FOuterRadius3 - FInnerRadius3) + FInnerRadius3, 1 / 3);
            var direction:Vector3D = new Vector3D(Math.random() - 0.5, Math.random() - 0.5, Math.random() - 0.5);
            if (direction.length == 0)
                direction.x = 1;
            direction.normalize();
            direction.scaleBy(radius);
            direction.x += FCenterX;
            direction.y += FCenterY;
            direction.z += FCenterZ;
            return direction;
        }
    }
}