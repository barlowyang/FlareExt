package flare.naruto.particle.emitter.ThreeD
{
    import flash.geom.Matrix3D;
    import flash.geom.Vector3D;
    
    import flare.naruto.particle.emitter.TParticleAreaBase;
    
	/**
	 * 圆柱
	 *  
	 * @author GameTrees
	 * 
	 */
    public class TThreeDCylinder extends TParticleAreaBase
    {
        private var FInnerRadius:Number;
        private var FOuterRadius:Number;
        private var FHeight:Number;
        private var FCenterX:Number;
        private var FCenterY:Number;
        private var FCenterZ:Number;
        private var FDirectionX:Number;
        private var FDirectionY:Number;
        private var FDirectionZ:Number;
        private var FMatrix:Matrix3D;
        
        public function TThreeDCylinder(innerRadius:Number = 0, outerRadius:Number = 50, height:Number = 200, centerX:Number=0, centerY:Number=0, centerZ:Number=0, dX:Number=0, dY:Number=0, dZ:Number=0)
        {
            super();
            
            FInnerRadius = innerRadius;
            FOuterRadius = outerRadius;
            
            FHeight = height;
            FCenterX = centerX;
            FCenterY = centerY;
            FCenterZ = centerZ;
            
            FDirectionX = dX;
            FDirectionY = dY;
            FDirectionZ = dZ;
            UpdateMatrix();
        }
            
        public function get DirectionX():Number
        {
            return FDirectionX;
        }
        public function get DirectionY():Number
        {
            return FDirectionY;
        }
        public function get DirectionZ():Number
        {
            return FDirectionZ;
        }
        public function set DirectionX(v:Number):void
        {
            FDirectionX = v;
            UpdateMatrix();
        }
        public function set DirectionY(v:Number):void
        {
            FDirectionY = v;
            UpdateMatrix();
        }
        public function set DirectionZ(v:Number):void
        {
            FDirectionZ = v;
            UpdateMatrix();
        }
        
        private function UpdateMatrix():void
        {
            var direction:Vector3D = new Vector3D(FDirectionX, FDirectionY, FDirectionZ);
            if (direction.length > 0)
            {
                direction.normalize();
                var flag:int = direction.dotProduct(Vector3D.Y_AXIS) > 0 ? 1 : -1;
                var degree:Number = flag * Vector3D.angleBetween(Vector3D.Y_AXIS, direction) / Math.PI * 180;
                if (degree != 0)
                {
                    var rotationAxis:Vector3D = Vector3D.Y_AXIS.crossProduct(direction);
                    FMatrix = new Matrix3D();
                    FMatrix.appendRotation(degree, rotationAxis);
                }
            }
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

        public function get Height():Number
        {
            return FHeight;
        }
        public function set Height(value:Number):void
        {
            FHeight = value;
        }

        public function get OuterRadius():Number
        {
            return FOuterRadius;
        }
        public function set OuterRadius(value:Number):void
        {
            FOuterRadius = value;
        }

        public function get InnerRadius():Number
        {
            return FInnerRadius;
        }
        public function set InnerRadius(value:Number):void
        {
            FInnerRadius = value;
        }

        override public function GeneratePos():Vector3D
        {
            var h:Number = Math.random() * FHeight; // - FHeight / 2;
            var r:Number = FOuterRadius * Math.pow(Math.random() * (1 - FInnerRadius / FOuterRadius) + FInnerRadius / FOuterRadius, 1 / 2);
            var degree1:Number = Math.random() * Math.PI * 2;
            var point:Vector3D = new Vector3D(r * Math.cos(degree1), h, r * Math.sin(degree1));
            if (FMatrix)
            {
                point = FMatrix.deltaTransformVector(point);
            }
            point.x += FCenterX;
            point.y += FCenterY;
            point.z += FCenterZ;
            return point;
        }
        
    }
}