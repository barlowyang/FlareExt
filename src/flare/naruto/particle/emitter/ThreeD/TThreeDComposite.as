package flare.naruto.particle.emitter.ThreeD
{
    import flash.geom.Vector3D;
    
    import flare.naruto.particle.emitter.TParticleAreaBase;
    import flare.naruto.particle.emitter.TValueBase;
    import flare.naruto.particle.emitter.OneD.TOneDConst;
    
    public class TThreeDComposite extends TParticleAreaBase
    {
        private var FXValue:TValueBase;
        private var FYValue:TValueBase;
        private var FZValue:TValueBase;
        private var FIsometric:Boolean;
        
        public function TThreeDComposite()
        {
            super();
            FXValue = new TOneDConst();
            FYValue = new TOneDConst();
            FZValue = new TOneDConst();
        }
        
        public function get Isometric():Boolean
        {
            return FIsometric;
        }
        public function set Isometric(value:Boolean):void
        {
            FIsometric = value;
        }

        public function get X():TValueBase
        {
            return FXValue;
        }
        public function set X(value:TValueBase):void
        {
            FXValue = value;
        }
        
        public function get Y():TValueBase
        {
            return FYValue;
        }
        public function set Y(value:TValueBase):void
        {
            FYValue = value;
        }

        public function get Z():TValueBase
        {
            return FZValue;
        }
        public function set Z(value:TValueBase):void
        {
            FZValue = value;
        }
        
        override public function GenerateOneValue():*
        {
            var x:Number = FXValue.GenerateOneValue();
            var y:Number = FIsometric ? x : FYValue.GenerateOneValue();
            var z:Number = FIsometric ? x : FZValue.GenerateOneValue();
            return new Vector3D(x, y, z);
        }
    }
}