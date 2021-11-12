using System.IO;
using GameApp.URPToolkit.Draw;
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
            ShaderCreatorWindow.OpenWindow(ShaderCreatorWindow.CreaterType.Lit);
        }

        [MenuItem("Assets/Create/Shader/URP UnLit Shader", false, 1002)]
        public static void CreateUnLitShader()
        {
            ShaderCreatorWindow.OpenWindow(ShaderCreatorWindow.CreaterType.Unlit);
        }

        [MenuItem("Assets/URPToolkit/Update Selected Shaders", false, 2001)]
        public static void UpdateSelectedShaders()
        {
            foreach (var obj in Selection.objects)
            {
                if (obj is Shader)
                {
                    var path = AssetDatabase.GetAssetPath(obj);
                    
                }
            }
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
        
        [MenuItem("Assets/TestParserHlsl", false, 3002)]
        public static void TestParserHlsl()
        {
            var sel = Selection.activeObject;
            if (sel == null) return;
            var path = AssetDatabase.GetAssetPath(sel);
            var parser = new ShaderParser(path);
            
        }

        [MenuItem("Assets/TestCreatorUnlit", false, 3003)]
        public static void TestCreatorUnLit()
        {
            var creator = new UnlitShaderCreator("Assets/Shaders/NewUnlit.shader", ShaderCreator.Mode.Create);
            creator.Create();
        }
        
        [MenuItem("Assets/TestCreatorLit", false, 3004)]
        public static void TestCreatorLit()
        {
            var creator = new LitShaderCreator("Assets/Shaders/NewLit.shader", ShaderCreator.Mode.Create);
            creator.Create();
        }

        public static string CurSelPath
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