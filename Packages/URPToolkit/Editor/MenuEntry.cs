using System;
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
            var creator = new LitShaderCreator($"{CurSelPath}/New Lit Shader.shader");
            creator.Create();
        }

        [MenuItem("Assets/Create/Shader/URP UnLit Shader", false, 1002)]
        public static void CreateUnLitShader()
        {
            var creator = new UnlitShaderCreator($"{CurSelPath}/New Unlit Shader.shader");
            creator.Create();
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
        
        [MenuItem("Assets/TestParser", false, 3002)]
        public static void TestParser()
        {
            var sel = Selection.activeObject;
            if (sel == null) return;
            var path = AssetDatabase.GetAssetPath(sel);
            var destPath = path.Replace(".shader", ".gen.shader");
            var generator = new ShaderGenerator(path, destPath);
            generator.Generate();
        }

        private static string CurSelPath
        {
            get
            {
                var path = AssetDatabase.GetAssetPath(Selection.activeObject);
                if (!string.IsNullOrEmpty(Path.GetExtension(path)))
                {
                    var lastIdx = path.LastIndexOf('/');
                    if (lastIdx >= 0)
                    {
                        path = path.Substring(0, lastIdx + 1);
                    }
                }

                return path;
            }
        }
    }
}