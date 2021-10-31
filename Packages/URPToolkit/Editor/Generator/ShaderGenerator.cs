using GameApp.URPToolkit.Parser;

namespace GameApp.URPToolkit
{
    public class ShaderGenerator
    {
        private string _sourcePath;
        private string _destPath;
        private ShaderDescriptor _descriptor;
        
        public ShaderGenerator(string sourcePath, string destPath)
        {
            _sourcePath = sourcePath;
            _destPath = destPath;
        }

        public void Generate()
        {
            var parser = new ShaderParser(_sourcePath);
            _descriptor = parser.Parse();
            
            
        }
    }
}