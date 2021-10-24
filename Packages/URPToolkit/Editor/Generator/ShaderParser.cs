using System;
using System.Collections.Generic;
using System.IO;

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
        
        private struct LexState
        {
            public string key;
            public string str;
        }

        private static readonly HashSet<char> SepChars = new() { ' ', '\f', '\t', '\v', '{', '}', ',', ';' };
        
        private string _sourcePath;
        private string _content;
        
        private int _idx;
        private int _line;

        private LexState _lex;

        private int Length => _content.Length;
        private char Cur => _content[_idx];

        private HashSet<string> _keywords;

        private ShaderDescriptor _descriptor;

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

        public ShaderParser(string sourcePath)
        {
            _sourcePath = sourcePath;
        }

        public string Parse()
        {
            _descriptor = new ShaderDescriptor();
            var content = File.ReadAllText(_sourcePath);
            _content = content;
            _line = 0;
            _idx = 0;
            while (_idx < Length)
            {
                NextLex();
                switch (_lex.key)
                {
                    case Keys.Shader:
                        ShaderState();
                        break;
                    case Keys.Properties:
                        PropertyState();
                        break;
                    case Keys.SubShader:
                        SubShaderState();
                        break;
                    case Keys.Fallback:
                        FallbackState();
                        break;
                }
            }
            
            return default;
        }

        private void ShaderState()
        {
            
        }

        private void PropertyState()
        {
            
        }

        private void SubShaderState()
        {
            
        }

        private void FallbackState()
        {
            
        }

        private void NextLex()
        {
            _lex.key = null;
            _lex.str = null;
            
            var cur = Cur;

            switch (cur)
            {
                case '\r': case '\n':
                    _line++;
                    Next();
                    break;
                case ' ': case '\f': case '\t': case '\v': case '#':
                    Next();
                    break;
                case '/':
                    if (_idx + 1 < Length)
                    {
                        if (_content[_idx + 1] == '/')
                        {
                            ReadToLineEnd();
                        }
                        else if (_content[_idx + 1] == '*')
                        {
                            ReadToTemplate("*/");
                        }
                    }
                    else
                    {
                        _lex.str += cur;
                    }
                    Next();
                    break;
                default:
                    if (char.IsLetter(cur))
                    {
                        var str = ReadUntilSep();
                        if (Keywords.Contains(str))
                        {
                            _lex.key = str;
                        }
                    }
                    else
                    {
                        Next();
                        _lex.str += cur;
                    }
                    
                    break;
            }
        }

        private void ReadToLineEnd()
        {
            for (var i = _idx; i < Length; i++)
            {
                if (_content[i] == '\n') break;
                _idx++;
            }
        }

        private void ReadToTemplate(string template)
        {
            var idx = _content.IndexOf(template, _idx, StringComparison.Ordinal);
            if (idx > 0)
            {
                _idx = idx + template.Length;
            }
            else
            {
                throw GetException($"Miss matching template '{template}'");
            }
        }
        
        private string ReadUntilSep()
        {
            var start = _idx;
            
            while (_idx < Length)
            {
                bool sep;
                var cur = Cur;
                switch (cur)
                {
                    case '\n': case '\r':
                        sep = true;
                        break;
                    default:
                        sep = SepChars.Contains(cur);
                        break;
                }

                if (sep) break;
                
                Next();
            }

            return _content.Substring(start, _idx - start);
        }
        
        private string ReadName()
        {
            while (_idx < Length)
            {
                var cur = Cur;
                if (cur == ' ')
                    Next();
                else if(char.IsLetter(cur))
                    break;
                else
                    throw GetException($"Read name error at {cur}");
            }
            
            var start = _idx;
            while (_idx < Length)
            {
                var cur = Cur;
                if (char.IsLetter(cur) || char.IsNumber(cur) || cur == '_')
                    Next();
                else
                    break;
            }
            return _content.Substring(start, _idx - start);
        }

        private int ReadInteger()
        {
            while (_idx < Length)
            {
                var cur = Cur;
                if (cur == ' ')
                    Next();
                else if (char.IsNumber(cur))
                    break;
                else
                    throw GetException($"Read number error at {cur}.");
                
            }

            var start = _idx;
            while (_idx < Length)
            {
                if (char.IsNumber(Cur))
                    Next();
                else
                    break;
            }

            var str = _content.Substring(start, _idx - start);
            
            if (!int.TryParse(str, out var res))
                throw GetException($"Try parse '{str}' to integer error.");
            
            return res;
        }

        private void Next()
        {
            _idx++;
        }
        
        private Exception GetException(string msg)
        {
            return new Exception($"{msg} line{_line}");
        }
    }
}