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
    }

    public class ShaderTags : ShaderBase
    {
        public List<ShaderTag> tags = new();
    }

    public class ShaderLod : ShaderBase
    {
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

    public class CgProgram
    {
        public List<ShaderPragma> pragms = new();
        public List<VarProperty> properties = new();
        
        public ShaderStruct attributes;
        public ShaderFunction vertexFunc;
        
        public ShaderStruct varings;
        public ShaderFunction fragFunc;
    }

    public class SubShader
    {
        public List<ShaderTag> tags = new();
        public ShaderLod shaderLod;
        public CgProgram cgProgram = new();
    }

    public class ShaderFallback
    {
        public string content;
    }
    
    public class ShaderDescriptor
    {
        public string path;

        public List<ShaderProperty> properties = new();
        public List<SubShader> subShaders = new();

        public ShaderFallback fallback;
    }
}