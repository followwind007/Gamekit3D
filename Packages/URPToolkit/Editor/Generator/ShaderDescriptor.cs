using System.Collections.Generic;
using System.Linq;

namespace GameApp.URPToolkit
{
    public class ShaderBase
    {
        public string content;
    }

    public class ShaderProperty : ShaderBase
    {
        public List<string> attributes;
        public string name;
        public string displayName;
        public string type;
        public string value;
        public string valueExt;
    }

    public class VarProperty : ShaderBase
    {
    }

    public class StructProperty : ShaderBase
    {
    }

    public class ShaderInclude : ShaderBase
    {
    }

    public class ShaderTag : ShaderBase
    {
        public string key;
        public string value;
    }

    public class ShaderTags : ShaderBase
    {
        public List<ShaderTag> tags = new();
    }

    public class ShaderLod : ShaderBase
    {
    }

    public class PassName : ShaderBase
    {
    }

    public class ShaderMultiValBase : ShaderBase
    {
        public List<string> vals = new();
    }

    public class ShaderBlend : ShaderMultiValBase
    {
    }

    public class ShaderZWrite : ShaderMultiValBase
    {
    }

    public class ShaderZTest : ShaderMultiValBase
    {
    }

    public class ShaderCull : ShaderMultiValBase
    {
    }

    public class ShaderColorMask : ShaderMultiValBase
    {
    }

    public class ShaderKeyword : ShaderBase
    {
        public string name;
        public List<string> keywords;
    }

    public class ShaderStruct : ShaderBase
    {
        public List<StructProperty> properties = new();
    }

    public class ShaderPragma : ShaderMultiValBase
    {
    }

    public class ShaderFunction : ShaderBase
    {
    }

    public class ShaderHlsl : ShaderBase
    {
        public List<ShaderBase> vals = new();
    }

    public class ShaderPass : ShaderBase
    {
        public List<ShaderBase> vals = new();
    }

    public class SubShader
    {
        public List<ShaderBase> vals = new();
    }

    public class ShaderFallback : ShaderBase
    {
    }

    public class ShaderCustomEditor : ShaderBase
    {
    }
    
    public class ShaderDescriptor
    {
        public string path;

        public List<ShaderProperty> properties = new();
        public List<SubShader> subShaders = new();

        public ShaderFallback fallback;
        public ShaderCustomEditor customEditor;

        public List<ShaderPass> GetPass(string name)
        {
            var passes = new List<ShaderPass>();
            foreach (var subShader in subShaders)
            {
                var sb = subShader.vals.FirstOrDefault(sbVal =>
                    sbVal is ShaderPass sp && sp.vals.Any(spv => spv is PassName pn && pn.content == name));
                if (sb is ShaderPass pass) passes.Add(pass);
            }

            return passes;
        }
    }
}