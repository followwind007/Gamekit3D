using System.Collections.Generic;
using System.Text;

namespace GameApp.URPToolkit.Parser
{
    public partial class ShaderParser
    {
        private void ToPropertyState()
        {
            ReadNextChar(Chars.BraceL3);
            
            var ps = _descriptor.properties;
            
            while (!Cur.IsEnd)
            {
                ReadUntilNextValid();

                if (Cur.IsChar(Chars.BraceR3)) break;
                var p = new ShaderProperty
                {
                    attributes = ReadPropertyAttributes(),
                    name = Cur.text
                };

                ReadNextChar(Chars.BraceL1);
                ReadNextQuotedString();
                p.displayName = Cur.text;
                
                ReadNextChar(Chars.Comma);

                p.type = ReadPropertyType();
                
                ReadNextChar(Chars.BraceR1);

                ReadNextChar(Chars.Equal);

                p.value = ReadPropertyValue();
                p.valueExt = ReadPropertyValueExt();

                ps.Add(p);
            }
        }

        private List<string> ReadPropertyAttributes()
        {
            var attrs = new List<string>();
            while (Cur.IsChar(Chars.BraceL2))
            {
                ReadNextIdentifier();
                attrs.Add(Cur.text);

                ReadNextChar(Chars.BraceR2);

                ReadUntilNextValid();
            }
            return attrs;
        }

        private string ReadPropertyType()
        {
            ReadUntilNextValid();
            if (Cur.IsIdentifier(PropType.Range))
            {
                var sb = new StringBuilder();
                sb.Append(Cur.text);
                ReadNextChar(Chars.BraceL1);
                sb.Append(Cur.text);
                ReadNextNumber(out var r1);
                sb.Append(r1);
                ReadNextChar(Chars.Comma);
                sb.Append(Cur.text);
                ReadNextNumber(out var r2);
                sb.Append(r2);
                ReadNextChar(Chars.BraceR1);
                sb.Append(Cur.text);
                return sb.ToString();
            }
            return Cur.text;
        }

        private string ReadPropertyValue()
        {
            var tk = NextToken;
            if (tk.IsChar(Chars.BraceL1))
            {
                ReadNextChar(Chars.BraceL1);
                var startIdx = Cur.startPosition;
                ReadUntilChar(Chars.BraceR1);
                var endIdx = Cur.endPosition;
                return _content.Substring(startIdx, endIdx - startIdx);
            }
            else if (tk.IsNumber || tk.IsChar(Chars.Minus))
            {
                ReadNextNumber(out var num, false); 
                return num;
            }
            else if (tk.IsQuotedString)
            {
                ReadNextQuotedString();
                return Cur.text;
            }
            throw new ParseException(this,$"Expected value description but found {Cur.type} '{Cur.text}'!");
        }

        private string ReadPropertyValueExt()
        {
            if (NextToken.IsChar(Chars.BraceL3))
            {
                var val = "";
                ReadNextChar(Chars.BraceL3);
                val += Cur.text;
                ReadNextChar(Chars.BraceR3);
                val += Cur.text;
                return val;
            }

            return default;
        }
    }
}