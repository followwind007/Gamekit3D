using System.IO;

namespace GameApp.URPToolkit
{
    public class ShaderParser
    {
        private enum Token
        {
            None,
            ShaderBegin,
            PropertyBegin,
            Property,
            SubShaderBegin,
            Pragma,
            
            HlslBegin,
            VarProperty,

            AttributesBegin,
            AttrProperty,
            
            VaringsBegin,
            VaringsProperty,
            
            VertexBegin,
            FragBegin
        }
        
        private struct LexState
        {
            public Token tk;
            public string str;
        }
        
        private enum Stage
        {
            StructName,
            StructId,
            StructContent,
            FieldType,
            FieldName,
            FieldId
        }
        
        private enum State
        {
            StructDec,
            TypeDec
        }
        
        private struct GState
        {
            public State state;
            public Stage stage;

            public void Next()
            {
                stage++;
            }
        }
        
        private string _sourcePath;
        
        public ShaderParser(string sourcePath)
        {
            _sourcePath = sourcePath;
        }

        public string Parse()
        {
            var rawText = File.ReadAllText(_sourcePath);
            
            return default;
        }
        
    }
}