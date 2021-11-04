using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using GameApp.URPToolkit.Parser;
using UnityEditor;

namespace GameApp.URPToolkit
{
    public abstract class ShaderCreator
    {
        public const string PackagePath = "Packages/com.unity.render-pipelines.universal";
        protected string path;

        protected ShaderDescriptor descriptor;
        protected ShaderParser litInputParser;

        protected int indent;
        protected StringBuilder sb;
        protected List<string> validPasses = new();

        private static readonly HashSet<string> ValidPragmas = new() { PragmaKeys.Vertex, PragmaKeys.Fragment };

        protected ShaderCreator(string path)
        {
            this.path = path;
        }
        
        public abstract void CreateDescriptor();

        public void Create()
        {
            CreateDescriptor();
            sb = new StringBuilder();
            indent = 0;
            AppendIndent(Keys.Shader);
            AppendSpace();
            AppendLine(descriptor.path);
            AppendLine(Chars.BraceL3);
            
            indent++;
            
            descriptor.GenProperty(sb, indent);
            GenSubShader();
            descriptor.fallback?.Generate(sb, indent);
            descriptor.customEditor?.Generate(sb, indent);

            indent--;
            
            AppendIndent(Chars.BraceR3);
            
            File.WriteAllText(path, sb.ToString());
            
            CreateInput();
            AssetDatabase.Refresh();
        }

        public void CreateInput()
        {
            var inputText = litInputParser.CreateInput(path);
            var inputPath = path.Replace(".shader", "_Input.hlsl");
            File.WriteAllText(inputPath, inputText);
        }

        protected void GenSubShader()
        {
            if (descriptor.subShaders.Count == 0) throw new Exception("Need at least one SubShader");
            var ss = descriptor.subShaders[0];
            
            AppendLineIndent(Keys.SubShader);
            AppendLineIndent(Chars.BraceL3);
            indent++;
            foreach (var subBase in ss.vals)
            {
                if (subBase is ShaderPass sp && validPasses.Contains(sp.Name))
                {
                    AppendLineIndent(Keys.Pass);
                    AppendLineIndent(Chars.BraceL3);
                    indent++;
                    
                    foreach (var passBase in sp.vals)
                    {
                        if (passBase is ShaderPragma) continue;
                        if (passBase is ShaderHlsl hlsl)
                        {
                            GenHlsl(hlsl);
                            continue;
                        }

                        passBase.Generate(sb, indent);
                    }

                    indent--;
                    AppendLineIndent(Chars.BraceR3);
                    continue;
                }
                
                subBase.Generate(sb, indent);
            }
            indent--;
            AppendLineIndent(Chars.BraceR3);
        }

        protected void GenHlsl(ShaderHlsl hlsl)
        {
            AppendLineIndent(Keys.HlslBegin);
            foreach (var hb in hlsl.vals)
            {
                if (hb is ShaderPragma sp && ValidPragmas.Contains(sp.Type))
                {
                    //sp.Generate(sb, indent);
                }
            }
            
            AppendLineIndent(Keys.HlslEnd);
        }

        protected void AppendIndent(string value) => sb.AppendIndent(value, indent);
        protected void AppendLineIndent(string value) => sb.AppendLineIndent(value, indent);
        protected void Append(string value) => sb.Append(value);
        protected void AppendLine(string value) => sb.AppendLine(value);
        protected void AppendSpace() => sb.Append(' ');
        protected void AppendTab() => sb.Append('\t');
    }

    public class UnlitShaderCreator : ShaderCreator
    {
        public UnlitShaderCreator(string path) : base(path) { }
        
        public override void CreateDescriptor()
        {
            var litParser = new ShaderParser($"{PackagePath}/Shaders/UnLit.shader");
            descriptor = litParser.ParseShader();
            descriptor.path = "\"Hidden/CustomUnlit\"";
            validPasses = new List<string> { "\"Unlit\"" };

            litInputParser = new ShaderParser($"{PackagePath}/Shaders/UnLitInput.hlsl");
        }
    }

    public class LitShaderCreator : ShaderCreator
    {
        public LitShaderCreator(string path) : base(path) { }
        
        public override void CreateDescriptor()
        {
            var litParser = new ShaderParser($"{PackagePath}/Shaders/Lit.shader");
            descriptor = litParser.ParseShader();
            descriptor.path = "\"Hidden/CustomLit\"";
            validPasses = new List<string> { "\"ForwardLit\"" };
            
            litInputParser = new ShaderParser($"{PackagePath}/Shaders/LitInput.hlsl");
        }
    }

    internal static class StringBuilderExtension
    {
        public static void AppendIndent(this StringBuilder target, string value, int indent)
        {
            target.AppendIndent(indent);
            target.Append(value);
        }
        
        public static void AppendIndent(this StringBuilder target, int indent)
        {
            for (var i = 0; i < indent; i++) target.Append('\t');
        }

        public static void AppendLineIndent(this StringBuilder target, string value, int indent)
        {
            target.AppendIndent(indent);
            target.AppendLine(value);
        }
    }
}