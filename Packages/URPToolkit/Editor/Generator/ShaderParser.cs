using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using GameApp.URPToolkit.Parser;

namespace GameApp.URPToolkit
{
    public class ShaderParser
    {
        public readonly struct Keys
        {
            public const string
                Shader = "Shader",
                Properties = "Properties",
                SubShader = "SubShader",
                HlslBegin = "HLSLPROGRAM",
                Tags = "Tags",
                Pragma = "pragma",
                Struct = "struct",
                Function = "function",
                HlslEnd = "ENDHLSL",
                Fallback = "Fallback";
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
                Comma = ",";
        }
        
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

        /*
        private HashSet<string> _keywords;
        private HashSet<string> Keywords
        {
            get
            {
                if (_keywords == null)
                {
                    _keywords = new HashSet<string>();
                    var t = typeof(Keys);
                    var ps = t.GetProperties();
                    foreach (var info in ps)
                    {
                        if (info.GetConstantValue() is string val)
                        {
                            _keywords.Add(val);
                        }
                    }
                }
                return _keywords;
            }
        }
        */

        public ShaderParser(string sourcePath)
        {
            _sourcePath = sourcePath;
        }

        public string Parse()
        {
            _idx = 0;
            _descriptor = new ShaderDescriptor();
            
            var content = File.ReadAllText(_sourcePath);
            var lexer = new Lexer(content);
            _tokens = new List<Token>();
            
            while (true)
            {
                var tk = lexer.GetNextToken();
                _tokens.Add(tk);
                if (tk.type == TokenType.End) break;
            }

            ToShaderState();

            return default;
        }

        private void ToShaderState()
        {
            ReadNextIdentifier(Keys.Shader, true);
            if (!ReadNextType(TokenType.QuotedString)) ThrowException("Can not find shader path!");
            
            _descriptor.path = Cur.text;
            ReadNextChar(Chars.BraceL3);
            
            ReadNextIdentifier(Keys.Properties);
            ReadNextChar(Chars.BraceL3);

            ReadUntilChar(Chars.BraceR3, true);
            
            ToPropertyState();
            
            ToSubShaderState();
        }

        private void ToPropertyState()
        {
            var ps = _descriptor.properties;
            while (Cur.type != TokenType.End)
            {
                ReadUntilNextValid();

                if (Cur.IsChar(Chars.BraceR3)) break;
                var p = new ShaderProperty
                {
                    attributes = ReadPropertyAttributes()
                };
                ReadNextIdentifier();
                p.name = Cur.text;
                
                ReadNextChar(Chars.BraceL1);
                ReadNextQuotedString();
                p.displayName = Cur.text;
                
                ReadNextChar(Chars.Comma);

                p.type = ReadPropertyType();
                
                ReadNextChar(Chars.BraceR1);

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
            ReadNextIdentifier();
            if (Cur.IsIdentifier(PropType.Range))
            {
                var sb = new StringBuilder();
                ReadNextChar(Chars.BraceL1);
                sb.Append(Cur.text);
                ReadNextNumber();
                sb.Append(Cur.text);
                ReadNextChar(Chars.Comma);
                sb.Append(Cur.text);
                ReadNextNumber();
                sb.Append(Cur.text);
                ReadNextChar(Chars.BraceR1);
            }
            return Cur.text;
        }

        private void ToSubShaderState()
        {
            
        }

        private void ToFallbackState()
        {
            
        }

        #region Readers
        
        private bool ReadUntilIdentifier(string identifier, bool assert = false)
        {
            for (var i = _idx + 1; i < TokenLen; i++)
            {
                var tk = _tokens[i];
                if (tk.type == TokenType.Identifier && tk.text == identifier)
                {
                    _idx = i;
                    return true;
                }
            }

            if (assert) ThrowException($"Can not find '{identifier}' keyword!");

            return false;
        }

        private bool ReadNextIdentifier(bool assert = true)
        {
            ReadUntilNextValid();
            
            var tk = Cur;
            if (tk.type == TokenType.Identifier)
            {
                return true;
            }

            if (assert) ThrowException($"Expect identifier but find {tk.type} '{tk.value}'!");

            return false;
        }
        
        private bool ReadNextIdentifier(string identifier, bool assert = false)
        {
            ReadUntilNextValid();
            
            var tk = Cur;
            if (tk.type == TokenType.Identifier && tk.text == identifier)
            {
                return true;
            }

            if (assert) ThrowException($"Can not find next keyword '{identifier}'!");

            return false;
        }

        private bool ReadUntilType(TokenType type, bool assert = false)
        {
            for (var i = _idx + 1; i < TokenLen; i++)
            {
                var tk = _tokens[i];
                if (tk.type == type)
                {
                    _idx = i;
                    return true;
                }
            }

            if (assert) ThrowException($"Can not find token type '{type}'!");
            
            return false;
        }
        
        private bool ReadNextType(TokenType type, bool assert = false)
        {
            ReadUntilNextValid();
            
            if (Cur.type == type)
            {
                return true;
            }

            if (assert) ThrowException($"Can not find next token type '{type}'!");
            
            return false;
        }

        private bool ReadUntilChar(string c, bool assert = false)
        {
            for (var i = _idx + 1; i < TokenLen; i++)
            {
                var tk = _tokens[i];
                if (tk.type == TokenType.Char && tk.text == c)
                {
                    _idx = i;
                    return true;
                }
            }

            if (assert)
            {
                ThrowException($"Can not find Char '{c}'!");
            }

            return false;
        }
        
        private bool ReadNextChar(string c, bool assert = true)
        {
            ReadUntilNextValid();
            var tk = Cur;
            if (tk.type == TokenType.Char && tk.text == c)
            {
                return true;
            }

            if (assert) ThrowException($"Can not find next Char '{c}'!");

            return false;
        }

        private bool ReadNextQuotedString(bool assert = true)
        {
            ReadUntilNextValid();
            if (Cur.type == TokenType.QuotedString)
            {
                return true;
            }
            
            if (assert) ThrowException($"Expect QuotedString but found {Cur.type} '{Cur.text}'!");

            return false;
        }

        private bool ReadNextNumber(bool assert = true)
        {
            ReadUntilNextValid();
            if (Cur.IsNumber)
            {
                return true;
            }
            
            if (assert) ThrowException($"Expect Number but found {Cur.type} '{Cur.text}'!");

            return false;
        }
        
        public bool ReadUntilNextValid(bool assert = true)
        {
            int i;
            for (i = _idx + 1; i < TokenLen; i++)
            {
                var tk = _tokens[i];
                if (tk.type == TokenType.WhiteSpace) continue;
                if (tk.type == TokenType.Char)
                {
                    if (ignoreSeps.Contains(tk.text)) continue;
                }
                break;
            }

            if (i < TokenLen)
            {
                _idx = i;
                return true;
            }
            
            if (assert) ThrowException("Can not find next valid token!");
            
            return false;
        }
        
        #endregion
        
        private void ThrowException(string msg)
        {
            var tk = Cur;
            throw new Exception($"{msg} in file: {_sourcePath} at: {tk.lineNumber}:({tk.startPosition},{tk.endPosition})");
        }
    }
}