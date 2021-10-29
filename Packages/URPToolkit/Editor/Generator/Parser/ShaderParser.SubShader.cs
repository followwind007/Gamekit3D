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
                    case Keys.Tags:
                        _curSubShader.vals.Add(new ShaderTags { tags = ReadTags() });
                        break;
                    case Keys.Lod:
                        ReadNextNumber(out var num);
                        _curSubShader.vals.Add(new ShaderLod { content = num });
                        break;
                    case Keys.Pass:
                        ToPassState();
                        break;
                    default:
                        throw new ParseException(this, $"Unresolved symbol {Cur.type} '{Cur.text}'!");
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
                    case Keys.Tags:
                        CurPassVals.Add(new ShaderTags { tags = ReadTags() });
                        break;
                    case Keys.Name:
                        ReadNextQuotedString();
                        CurPassVals.Add(new PassName { content = Cur.text});
                        break;
                    case Keys.Blend:
                        CurPassVals.Add(new ShaderBlend { vals = ReadBrace2_s() });
                        break;
                    case Keys.ZWrite:
                        CurPassVals.Add(new ShaderZWrite { vals = ReadBrace2_s() });
                        break;
                    case Keys.ZTest:
                        CurPassVals.Add(new ShaderZTest { vals = ReadBrace2_s() });
                        break;
                    case Keys.Cull:
                        CurPassVals.Add(new ShaderCull { vals = ReadBrace2_s() });
                        break;
                    case Keys.ColorMask:
                        CurPassVals.Add(new ShaderColorMask {vals = ReadBrace2_s() } );
                        break;
                    case Keys.HlslBegin:
                        ToHlslState();
                        break;
                    default:
                        throw new ParseException(this, $"Unexpected pass symbol {Cur.type} '{Cur.text}'!");
                }
                
                ReadUntilNextValid();
            }
        }

        private void ToHlslState()
        {
            var hlslStart = Cur.startPosition;
            ReadUntilIdentifier(Keys.HlslEnd);
            var hlslEnd = Cur.endPosition;
            var hlslContent = _content.Substring(hlslStart, hlslEnd - hlslStart);
            CurPassVals.Add(new ShaderHlsl { content = hlslContent });
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
            
            while (!IsKeyword(NextToken.text))
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