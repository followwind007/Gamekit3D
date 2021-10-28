using System.Collections.Generic;

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

    public class ShaderBlend : ShaderBase
    {
        public List<string> blends = new();
    }

    public class ShaderZWrite : ShaderBase
    {
        public List<string> writes = new();
    }

    public class ShaderCull : ShaderBase
    {
        public List<string> culls = new();
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

    public class ShaderPragma : ShaderBase
    {
    }

    public class ShaderFunction : ShaderBase
    {
    }

    public class ShaderHlsl : ShaderBase
    {
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
    }
}