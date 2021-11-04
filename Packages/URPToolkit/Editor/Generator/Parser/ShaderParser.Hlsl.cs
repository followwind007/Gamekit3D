using System;
using System.Collections.Generic;
using System.Text;

namespace GameApp.URPToolkit.Parser
{
    public partial class ShaderParser
    {
        private void ToHlslState(ShaderHlsl hlsl, bool checkEndIdentity)
        {
            var startIdx = _idx;
            
            var hlslStart = Cur.startPosition;
            if (checkEndIdentity)
            {
                ReadUntilIdentifier(Keys.HlslEnd);
            }
            else
            {
                ReadUnitilEnd();
            }
            
            var endIdx = _idx;
            for (var i = startIdx + 1; i < endIdx; i++)
            {
                var tk = _tokens[i];
                _idx = i;
                if (tk.IsIdentifier(Keys.Pragma))
                {
                    var pragma = new ShaderPragma { vals = ReadBrace2_s() };
                    hlsl.vals.Add(pragma);
                }
            }

            _idx = endIdx;
            var hlslEnd = Cur.endPosition;
            hlsl.content = _content.Substring(hlslStart, hlslEnd - hlslStart);
        }

        private static readonly HashSet<string> IgnoreCBufferProperties = new()
        {
            "_WorkflowMode",
            "_SmoothnessTextureChannel",
            "_SpecularHighlights",
            "_EnvironmentReflections",
            "_Blend",
            "_Cull",
            "_AlphaClip"
        };

        private static readonly HashSet<string> IgnoreTexture2D = new()
        {
            "_BaseMap",
            "_BumpMap",            
            "_EmissionMap"        
        };

        public string CreateInput(string descriptorPath)
        {
            InitToken();
            var descParser = new ShaderParser(descriptorPath);
            var descriptor = descParser.ParseShader();
            
            var indent = 0;
            var sb = new StringBuilder();
            
            while (_idx < TokenLen)
            {
                if (Cur.IsIdentifier("CBUFFER_START"))
                {
                    ReadUntilIdentifier("CBUFFER_END");
                    AppendProperties(descriptor, sb, indent);
                    sb.AppendLine();
                    AppendSampler(descriptor, sb, indent);
                    _idx++;
                    continue;
                }
                
                if (Cur.IsChar(Chars.Hash) && GetNextValids(2, out var tokens))
                {
                    if (tokens[0].IsIdentifier(Keys.Ifdef) && tokens[1].IsIdentifier("UNITY_DOTS_INSTANCING_ENABLED"))
                    {
                        ReadUntilIdentifier(Keys.EndIf);
                        _idx++;
                        continue;
                    }
                }

                if (Cur.IsIdentifier("TEXTURE2D"))
                {
                    ReadUntilChar(Chars.SemiColon);
                    _idx++;
                    continue;
                }

                if (Cur.IsIdentifier("SAMPLER"))
                {
                    ReadUntilChar(Chars.SemiColon);
                    _idx++;
                    continue;
                }

                sb.Append(Cur.text);
                _idx++;
            }

            return sb.ToString();
        }

        private void AppendProperties(ShaderDescriptor descriptor, StringBuilder sb, int indent)
        {
            sb.AppendLineIndent("CBUFFER_START(UnityPerMaterial)", indent);

            sb.AppendLineIndent("float4 _BaseMap_ST;", indent);
            sb.AppendLineIndent("float4 _DetailAlbedoMap_ST;", indent);
            foreach (var p in descriptor.properties)
            {
                if (p.attributes.Contains("HideInInspector")) continue;
                if (IgnoreCBufferProperties.Contains(p.name)) continue;
                if (p.type == "2D") continue;
                    
                if (p.type == "Float" || p.type.StartsWith("Range"))
                {
                    sb.AppendLineIndent($"float {p.name};", indent);
                }
                else if (p.type == "Color")
                {
                    sb.AppendLineIndent($"half4 {p.name};", indent);
                }
                else
                {
                    throw new Exception($"Unresolved property {p.name} with type: '{p.type}'!");
                }
            }
            
            sb.AppendLineIndent("CBUFFER_END", indent);
        }

        private void AppendSampler(ShaderDescriptor descriptor, StringBuilder sb, int indent)
        {
            foreach (var p in descriptor.properties)
            {
                if (p.type != "2D") continue;
                if (IgnoreTexture2D.Contains(p.name)) continue;
                sb.AppendLineIndent($"TEXTURE2D({p.name}); SAMPLER(sampler{p.name});", indent);
            }
        }
    }
}