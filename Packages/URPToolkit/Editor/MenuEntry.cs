using System.IO;
using GameApp.URPToolkit.Parser;
using UnityEditor;
using UnityEngine;

namespace GameApp.URPToolkit
{
    public static class MenuEntry
    {
        [MenuItem("Assets/Create/Shader/URP Lit Shader", false, 1001)]
        public static void CreateLitShader()
        {
            
        }

        [MenuItem("Assets/Create/Shader/URP UnLit Shader", false, 1002)]
        public static void CreateUnLitShader()
        {
            
        }

        [MenuItem("Assets/URPToolkit/Upgrade Selected Shaders", false, 2001)]
        public static void UpdateSelectedShaders()
        {
            
        }

        [MenuItem("Assets/TestLexer", false, 3001)]
        public static void TestLexer()
        {
            var sel = Selection.activeObject;
            if (sel == null) return;
            var path = AssetDatabase.GetAssetPath(sel);
            var content = File.ReadAllText(path);
            var lexer = new Lexer(content);
            for (var i = 0; i < 1000; i++)
            {
                var tk = lexer.GetNextToken();
                if (tk.type == TokenType.End) break;
                Debug.Log($"{tk.lineNumber + 1}:\t{tk.type}: {tk.text}");
            }
        }
    }
}