using System.Collections.Generic;

namespace GameApp.URPToolkit.Parser
{
    public partial class ShaderParser
    {
        private List<ShaderBase> CurPassVals => _curShaderPass.vals;
        private void ToSubShaderState()
        {
            var subShader = new SubShader();
            _curSubShader = subShader;
            _descriptor.subShaders.Add(subShader);
            
            ReadNextChar(Chars.BraceL3);

            ReadUntilNextValid();

            while (!Cur.IsEnd && !Cur.IsChar(Chars.BraceR3))
            {
                switch (Cur.text)
                {
                    case Keys.Pass:
                        ToPassState();
                        break;
                    default:
                        TryMatchShaderKeyword(_curSubShader.vals);
                        break;
                }

                ReadUntilNextValid();
            }
        }

        private void ToPassState()
        {
            var shaderPass = new ShaderPass();
            _curShaderPass = shaderPass;
            _curSubShader.vals.Add(shaderPass);
            
            ReadNextChar(Chars.BraceL3);
            
            ReadUntilNextValid();

            if (Cur.IsChar(Chars.BraceR3)) return;
            
            
            while (!Cur.IsEnd && !Cur.IsChar(Chars.BraceR3))
            {
                if (Cur.IsChar(Chars.Hash)) ReadNextIdentifier();

                switch (Cur.text)
                {
                    case Keys.Name:
                        ReadNextQuotedString();
                        CurPassVals.Add(new ShaderPassName { content = Cur.text });
                        break;
                    case Keys.HlslBegin:
                        var hlsl = new ShaderHlsl();
                        ToHlslState(hlsl, true);
                        CurPassVals.Add(hlsl);
                        break;
                    default:
                        TryMatchShaderKeyword(CurPassVals);
                        break;
                }
                
                ReadUntilNextValid();
            }
        }

        private void TryMatchShaderKeyword(List<ShaderBase> list)
        {
            switch (Cur.text)
            {
                case Keys.Tags:
                    list.Add(new ShaderTags { tags = ReadTags() });
                    break;
                case Keys.Lod:
                    ReadNextNumber(out var num);
                    list.Add(new ShaderLod { content = num });
                    break;
                case Keys.Blend:
                    list.Add(new ShaderBlend { vals = ReadBrace2_s() });
                    break;
                case Keys.ZWrite:
                    list.Add(new ShaderZWrite { vals = ReadBrace2_s() });
                    break;
                case Keys.ZTest:
                    list.Add(new ShaderZTest { vals = ReadBrace2_s() });
                    break;
                case Keys.Cull:
                    list.Add(new ShaderCull { vals = ReadBrace2_s() });
                    break;
                case Keys.ColorMask:
                    list.Add(new ShaderColorMask {vals = ReadBrace2_s() });
                    break;
                default:
                    throw new ParseException(this, $"Unexpected pass symbol {Cur.type} '{Cur.text}'!");
            }
        }

        private List<ShaderTag> ReadTags()
        {
            var tags = new List<ShaderTag>();
            ReadNextChar(Chars.BraceL3);
            ReadUntilNextValid();
            while (Cur.IsQuotedString)
            {
                var tag = new ShaderTag { key = Cur.text };
                ReadNextChar(Chars.Equal);
                ReadNextQuotedString();
                tag.value = Cur.text;
                ReadUntilNextValid();
            }
            return tags;
        }

        private List<string> ReadBrace2_s()
        {
            var vals = new List<string>();
            
            while (!IsKeyword(NextToken.text) && !NextToken.IsChar(Chars.Hash))
            {
                var existBrace = NextToken.IsChar(Chars.BraceL2);
                if (existBrace) ReadNextChar(Chars.BraceL2);
                ReadNextNumberOrIndentifier(out var val);
                vals.Add(val);
                if (existBrace) ReadNextChar(Chars.BraceR2);
            }
            
            return vals;
        }

    }
}