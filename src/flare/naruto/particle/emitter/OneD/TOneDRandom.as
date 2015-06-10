package flare.naruto.particle.emitter.OneD
{
    import flare.naruto.particle.emitter.TValueBase;

    public class TOneDRandom extends TValueBase
    {
        private var FMin:Number;
        private var FMax:Number;
        private var FDelta:Number;
        
        public function TOneDRandom(min:Number = 0, max:Number = 0)
        {
            FMin = min;
            FMax = max;
            GenerateDelta();
        }
        
        override public function GenerateOneValue():*
        {
            return Math.random() * FDelta + FMin
        }
        
        private function GenerateDelta():void
        {
            FDelta = FMax - FMin;
        }
        
        public function get Max():Number
        {
            return FMax;
        }
        public function set Max(value:Number):void
        {
            FMax = value;
            GenerateDelta();
        }

        public function get Min():Number
        {
            return FMin;
        }
        public function set Min(value:Number):void
        {
            FMin = value;
            GenerateDelta();
        }

    }
}