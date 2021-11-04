using System;
using System.Collections.Generic;
using System.IO;
using System.Reflection;

namespace GameApp.URPToolkit.Parser
{
    public readonly struct Keys
    {
        public const string
            Shader = "Shader",
            Properties = "Properties",
            SubShader = "SubShader",
            Pass = "Pass",
            Name = "Name",
            Blend = "Blend",
            ZWrite = "ZWrite",
            ZTest = "ZTest",
            Cull = "Cull",
            ColorMask = "ColorMask",
            HlslBegin = "HLSLPROGRAM",
            Tags = "Tags",
            Lod = "LOD",
            Pragma = "pragma",
            Include = "include",
            Struct = "struct",
            Function = "function",
            HlslEnd = "ENDHLSL",
            FallBack = "FallBack",
            CustomEditor = "CustomEditor",
            Ifndef = "ifndef",
            Ifdef = "ifdef",
            Define = "define",
            Defined = "defined",
            Else = "else",
            EndIf = "endif";
    }
        
    public readonly struct Chars
    {
        public const string
            BraceL1 = "(",
            BraceR1 = ")",
            BraceL2 = "[",
            BraceR2 = "]",
            BraceL3 = "{",
            BraceR3 = "}",
            Minus = "-",
            Equal = "=",
            Hash = "#",
            Space = " ",
            SemiColon = ";",
            Comma = ",";
    }

    public readonly struct PragmaKeys
    {
        public const string
           Vertex = "vertex", 
           Fragment = "fragment";
    }
    
    public partial class ShaderParser
    {
        public readonly struct PropType
        {
            public const string
                Range = "Range";
        }

        public readonly HashSet<string> ignoreSeps = new () { " ", "\f", "\t", "\v", "\n" };

        private string _sourcePath;

        private ShaderDescriptor _descriptor;

        private List<Token> _tokens;
        private int _idx;

        private int TokenLen => _tokens.Count;
        private Token Cur => _tokens[_idx];

        private SubShader _curSubShader;
        private ShaderPass _curShaderPass;

        private string _content;
        
        private HashSet<string> _keywords;
        private HashSet<string> Keywords
        {
            get
            {
                if (_keywords == null)
                {
                    _keywords = new HashSet<string>();
                    var t = typeof(Keys);
                    var ps = t.GetFields(BindingFlags.Static | BindingFlags.Public | BindingFlags.FlattenHierarchy);
                    
                    foreach (var info in ps)
                    {
                        if (info.GetRawConstantValue() is string val)
                        {
                            _keywords.Add(val);
                        }
                    }
                }
                return _keywords;
            }
        }

        private bool IsKeyword(string text) => Keywords.Contains(text);
        private Token NextToken => GetNextValid();

        public ShaderParser(string sourcePath)
        {
            _sourcePath = sourcePath;
        }

        public ShaderDescriptor ParseShader()
        {
            _descriptor = new ShaderDescriptor();
            InitToken();
            ToShaderState();
            return _descriptor;
        }

        private void InitToken()
        {
            _idx = 0;

            _content = File.ReadAllText(_sourcePath);
            var lexer = new Lexer(_content);
            _tokens = new List<Token> { lexer.Current };
            while (true)
            {
                var tk = lexer.GetNextToken();
                _tokens.Add(tk);
                if (tk.type == TokenType.End) break;
            }
        }

        private void ToShaderState()
        {
            ReadNextIdentifier(Keys.Shader);
            if (!ReadNextType(TokenType.QuotedString, false)) throw new ParseException(this,"Can not find shader path!");
            
            _descriptor.path = Cur.text;
            ReadNextChar(Chars.BraceL3);

            ReadNextIdentifier(Keys.Properties);
            ToPropertyState();
            
            while (NextToken.IsIdentifier(Keys.SubShader))
            {
                ReadNextIdentifier(Keys.SubShader);
                ToSubShaderState();
            }

            ToFinalState();
        }
        
        private void ToFinalState()
        {
            ReadUntilNextValid();
            while (!Cur.IsChar(Chars.BraceR3))
            {
                switch (Cur.text)
                {
                    case Keys.FallBack:
                        ReadNextQuotedString();
                        _descriptor.fallback = new ShaderFallback { content = Cur.text };
                        break;
                    case Keys.CustomEditor:
                        ReadNextQuotedString();
                        _descriptor.customEditor = new ShaderCustomEditor { content = Cur.text };
                        break;
                    default:
                        throw new ParseException(this, $"Unresolved symbol {Cur.type} '{Cur.text}'!");
                }
                ReadUntilNextValid();
            }
        }

        #region Readers
        
        private void ReadUntilIdentifier(string identifier, bool assert = true)
        {
            for (var i = _idx + 1; i < TokenLen; i++)
            {
                var tk = _tokens[i];
                if (tk.IsIdentifier(identifier))
                {
                    _idx = i;
                    return;
                }
            }

            if (assert) throw new ParseException(this,$"Can not find '{identifier}' keyword!");
        }

        private void ReadNextIdentifier(bool assert = true)
        {
            ReadUntilNextValid();
            
            var tk = Cur;
            if (tk.IsIdentifier())
            {
                return;
            }

            if (assert) throw new ParseException(this,$"Expect identifier but find {tk.type} '{tk.value}'!");
        }
        
        private void ReadNextIdentifier(string identifier, bool assert = true)
        {
            ReadUntilNextValid();
            
            var tk = Cur;
            if (tk.IsIdentifier(identifier))
            {
                return;
            }

            if (assert) throw new ParseException(this,$"Can not find next keyword '{identifier}'!");
        }

        private bool ReadNextType(TokenType type, bool assert = true)
        {
            ReadUntilNextValid();
            
            if (Cur.type == type)
            {
                return true;
            }

            if (assert) throw new ParseException(this,$"Can not find next token type '{type}'!");
            
            return false;
        }
        
        private void ReadUntilChar(string c, bool assert = true)
        {
            for (var i = _idx + 1; i < TokenLen; i++)
            {
                var tk = _tokens[i];
                if (tk.IsChar(c))
                {
                    _idx = i;
                    return;
                }
            }

            if (assert) throw new ParseException(this,$"Can not find '{c}' Char!");
        }

        private void ReadNextChar(string c, bool assert = true)
        {
            ReadUntilNextValid();
            var tk = Cur;
            if (tk.type == TokenType.Char && tk.text == c)
            {
                return;
            }

            if (assert) throw new ParseException(this,$"Expect Char '{c}', but found {tk.type} '{tk.text}'!");
        }

        private void ReadNextQuotedString(bool assert = true)
        {
            ReadUntilNextValid();
            if (Cur.type == TokenType.QuotedString)
            {
                return;
            }
            
            if (assert) throw new ParseException(this,$"Expect QuotedString but found {Cur.type} '{Cur.text}'!");
        }

        private void ReadNextNumber(out string val, bool assert = true)
        {
            ReadUntilNextValid();
            val = "";
            if (Cur.IsChar(Chars.Minus))
            {
                val += Cur.text;
                ReadUntilNextValid();
            }
            
            if (Cur.IsNumber)
            {
                val += Cur.text;
                return;
            }
            
            if (assert) throw new ParseException(this,$"Expect Number but found {Cur.type} '{Cur.text}'!");
        }

        private void ReadNextNumberOrIndentifier(out string val, bool assert = true)
        {
            val = "";
            var tk = NextToken;
            if (tk.IsChar(Chars.Minus))
            {
                ReadNextNumber(out val, assert);
                return;
            }
            else if(tk.IsNumber || tk.IsIdentifier())
            {
                ReadUntilNextValid();
                val = Cur.text;
                return;
            }

            if (assert) throw new ParseException(this, $"Except Number or Identifier but found {tk.type} '{tk.text}'!");
        }
        
        private void ReadUntilNextValid(bool assert = true)
        {
            var i = _GetNextValidIdx();

            if (i < TokenLen - 1)
            {
                _idx = i;
                return;
            }
            
            if (assert) throw new ParseException(this,"Can not find next valid token!");
        }

        private void ReadUnitilEnd()
        {
            _idx = TokenLen - 1;
        }

        private Token GetNextValid(bool assert = true)
        {
            var i = _GetNextValidIdx();

            if (i < TokenLen - 1)
            {
                return _tokens[i];
            }
            
            if (assert) throw new ParseException(this,"Can not find next valid token!");
            return default;
        }

        private bool GetNextValids(int count, out List<Token> tokens, bool assert = true)
        {
            tokens = new List<Token>();
            for (var i = _idx + 1; i < TokenLen; i++)
            {
                if (!_IsValidToken(i)) continue;
                tokens.Add(_tokens[i]);
                if (tokens.Count == count) return true;
            }

            if (assert) throw new ParseException(this, $"Can not find next {count} valid token!");
            
            return false;
        }

        private int _GetNextValidIdx()
        {
            int i;
            for (i = _idx + 1; i < TokenLen; i++)
            {
                if (!_IsValidToken(i))
                {
                    continue;
                }
                break;
            }

            return i;
        }

        private bool _IsValidToken(int idx)
        {
            var tk = _tokens[idx];
            if (tk.type == TokenType.WhiteSpace) return false;
            if (tk.type == TokenType.Comment) return false;
            if (tk.type == TokenType.Char)
            {
                if (ignoreSeps.Contains(tk.text)) return false;
            }

            return true;
        }
        
        #endregion
        
        private class ParseException : Exception
        {
            public ParseException(ShaderParser p, string msg) : 
                base($"{msg} in file: {p._sourcePath} at line: {p.Cur.lineNumber + 1} ({p.Cur.LinePosition},{p.Cur.EndLinePosition})")
            {
            }
        }
    }
}