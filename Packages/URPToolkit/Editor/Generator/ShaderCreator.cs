using GameApp.URPToolkit.Parser;

namespace GameApp.URPToolkit
{
    public abstract class ShaderCreator
    {
        public const string PackagePath = "Packages/com.unity.render-pipelines.universal";
        protected string path;

        protected ShaderDescriptor descriptor;
        
        protected ShaderCreator(string path)
        {
            this.path = path;
        }
        
        public abstract ShaderDescriptor CreateDescriptor();

        public void Create()
        {
            descriptor = CreateDescriptor();
        }
    }

    public class UnlitShaderCreator : ShaderCreator
    {
        public UnlitShaderCreator(string path) : base(path) { }
        
        public override ShaderDescriptor CreateDescriptor()
        {
            var litParser = new ShaderParser($"{PackagePath}/Shaders/UnLit.shader");
            var desc = litParser.Parse();
            desc.path = "Hidden/CustomUnlit";
            return desc;
        }
    }

    public class LitShaderCreator : ShaderCreator
    {
        public LitShaderCreator(string path) : base(path) { }
        
        public override ShaderDescriptor CreateDescriptor()
        {
            var litParser = new ShaderParser($"{PackagePath}/Shaders/Lit.shader");
            var desc = litParser.Parse();
            desc.path = "Hidden/CustomLit";
            return desc;
        }
    }
}