package flare.naruto.particle.emitter.OneD
{
    import flare.naruto.particle.emitter.TValueBase;

    public class TOneDConst extends TValueBase
    {
        private var FValue:Number;
        
        public function TOneDConst(value:Number = 0)
        {
            FValue = value
        }
        
        override public function GenerateOneValue():*
        {
            return FValue;
        }
        
        public function get Value():Number
        {
            return FValue;
        }
        
        public function set Value(value:Number):void
        {
            FValue = value;
        }
    }
}