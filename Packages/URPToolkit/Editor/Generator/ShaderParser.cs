using System;
using System.Collections.Generic;
using System.IO;
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

        private string _sourcePath;

        private HashSet<string> _keywords;

        private ShaderDescriptor _descriptor;

        private List<Token> _tokens;
        private int _idx;

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

            while (_idx < _tokens.Count)
            {
                var tk = _tokens[_idx];
                switch (tk.text)
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

                _idx++;
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
        
        private Exception GetException(string msg)
        {
            var tk = _tokens[_idx];
            return new Exception($"{msg} in file: {_sourcePath} at: {tk.lineNumber}:({tk.startPosition},{tk.endPosition})");
        }
    }
}