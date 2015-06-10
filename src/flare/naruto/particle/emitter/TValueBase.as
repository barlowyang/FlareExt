package flare.naruto.particle.emitter
{
	

    public class TValueBase
    {
        
        public function TValueBase()
        {
        }
        
        public function GenerateOneValue():*
        {
            throw new Error("Must override by sub class!");
        }
    }
}