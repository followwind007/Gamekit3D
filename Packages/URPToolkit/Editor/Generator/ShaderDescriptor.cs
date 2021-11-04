using System.Collections.Generic;
using System.Linq;
using System.Text;
using GameApp.URPToolkit.Parser;

namespace GameApp.URPToolkit
{
    public abstract class ShaderBase
    {
        public string content;

        public virtual void Generate(StringBuilder sb, int indent)
        {
            
        }
    }

    public class ShaderProperty : ShaderBase
    {
        public List<string> attributes;
        public string name;
        public string displayName;
        public string type;
        public string value;
        public string valueExt;

        public override void Generate(StringBuilder sb, int indent)
        {
            sb.AppendIndent(indent);
            foreach (var attr in attributes)
            {
                sb.Append($"[{attr}]");
            }
            
            sb.Append($"{name}({displayName}, {type}) = {value}");
            if (!string.IsNullOrEmpty(valueExt))
            {
                sb.AppendLine($" {valueExt}");
            }
            else
            {
                sb.AppendLine();
            }
        }
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
        public override void Generate(StringBuilder sb, int indent)
        {
            if (tags.Count == 0) return;
            
            sb.AppendIndent(Keys.Tags, indent);
            sb.Append(Chars.BraceL3);
            for (var i = 0; i < tags.Count; i++)
            {
                var t = tags[i];
                sb.Append($"{t.key} = {t.value}");
                if (i != tags.Count - 1)
                {
                    sb.Append(Chars.Space);
                }
            }
            sb.AppendLine(Chars.BraceR3);
        }
    }

    public class ShaderLod : ShaderBase
    {
        public override void Generate(StringBuilder sb, int indent)
        {
            sb.AppendLineIndent($"{Keys.Lod} {content}", indent);
        }
    }

    public class ShaderPassName : ShaderBase
    {
        public override void Generate(StringBuilder sb, int indent)
        {
            sb.AppendLineIndent($"{Keys.Name} {content}", indent);
        }
    }

    public class ShaderMultiValBase : ShaderBase
    {
        public List<string> vals = new();

        protected void AppendVals(StringBuilder sb)
        {
            foreach (var v in vals)
            {
                sb.Append($" {v}");
            }

            sb.AppendLine();
        }

        protected void AppendVals(StringBuilder sb, string valBegin, string valEnd)
        {
            foreach (var v in vals)
            {
                sb.Append($"{valBegin}{v}{valEnd}");
            }

            sb.AppendLine();
        }
    }

    public class ShaderBlend : ShaderMultiValBase
    {
        public override void Generate(StringBuilder sb, int indent)
        {
            sb.AppendIndent(Keys.Blend, indent);
            AppendVals(sb, Chars.BraceL2, Chars.BraceR2);
        }
    }

    public class ShaderZWrite : ShaderMultiValBase
    {
        public override void Generate(StringBuilder sb, int indent)
        {
            sb.AppendIndent(Keys.ZWrite, indent);
            AppendVals(sb, Chars.BraceL2, Chars.BraceR2);
        }
    }

    public class ShaderZTest : ShaderMultiValBase
    {
        public override void Generate(StringBuilder sb, int indent)
        {
            sb.AppendIndent(Keys.ZTest, indent);
            AppendVals(sb);
        }
    }

    public class ShaderCull : ShaderMultiValBase
    {
        public override void Generate(StringBuilder sb, int indent)
        {
            sb.AppendIndent(Keys.Cull, indent);
            AppendVals(sb, Chars.BraceL2, Chars.BraceR2);
        }
    }

    public class ShaderColorMask : ShaderMultiValBase
    {
        public override void Generate(StringBuilder sb, int indent)
        {
            sb.AppendIndent(Keys.ColorMask, indent);
            AppendVals(sb);
        }
    }
    
    public class ShaderPragma : ShaderMultiValBase
    {
        public override void Generate(StringBuilder sb, int indent)
        {
            sb.AppendIndent($"{Chars.Hash}{Keys.Pragma}", indent);
            AppendVals(sb);
        }

        public string Type => vals.Count > 0 ? vals[0] : default;
        public bool IsType(string type) => type == Type;
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
    
    public class ShaderFunction : ShaderBase
    {
    }

    public class ShaderHlslPart : ShaderBase
    {
    }

    public class ShaderHlsl : ShaderBase
    {
        public int
            cbufferStart = -1,
            cbufferEnd = -1,
            dotBegin = -1,
            dotEnd = -1;

        public List<ShaderBase> vals = new();
    }

    public class ShaderPass : ShaderBase
    {
        public List<ShaderBase> vals = new();

        public string Name
        {
            get
            {
                if (vals.FirstOrDefault(shaderBase => shaderBase is ShaderPassName) is ShaderPassName v) return v.content;
                return default;
            }
        }
    }

    public class SubShader : ShaderBase
    {
        public List<ShaderBase> vals = new();
    }

    public class ShaderFallback : ShaderBase
    {
        public override void Generate(StringBuilder sb, int indent)
        {
            sb.AppendLineIndent($"{Keys.FallBack} {content}", indent);
        }
    }

    public class ShaderCustomEditor : ShaderBase
    {
        public override void Generate(StringBuilder sb, int indent)
        {
            sb.AppendLineIndent($"{Keys.CustomEditor} {content}", indent);
        }
    }
    
    public class ShaderDescriptor
    {
        public string path;

        public List<ShaderProperty> properties = new();
        public List<SubShader> subShaders = new();

        public ShaderFallback fallback;
        public ShaderCustomEditor customEditor;

        public void GenProperty(StringBuilder sb, int indent)
        {
            sb.AppendLineIndent(Keys.Properties, indent);
            sb.AppendLineIndent(Chars.BraceL3, indent);
            indent++;
            foreach (var p in properties)
            {
                p.Generate(sb, indent);
            }

            indent--;
            sb.AppendLineIndent(Chars.BraceR3, indent);
        }
    }
}