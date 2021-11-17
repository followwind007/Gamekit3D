using System;
using System.IO;
using System.Text;
using GameApp.URPToolkit.Parser;
using UnityEditor;

namespace GameApp.URPToolkit
{
    public abstract class ShaderCreator
    {
        public enum Mode
        {
            Create,
            Update
        }
        
        public const string PackagePath = "Packages/com.unity.render-pipelines.universal";
        
        protected string litInput;
        protected string litForwardPass;

        protected string path;

        protected ShaderDescriptor descriptor;
        protected ShaderDescriptor selDescriptor;
        protected ShaderParser litInputParser;
        protected ShaderParser forwardPassParser;
        protected string forwardPath;
        protected string inputPath;

        protected int indent;
        protected StringBuilder sb;

        protected Mode mode;

        private ShaderDescriptor PropDescriptor => selDescriptor ?? descriptor;
        private ShaderDescriptor CustomEditorDescriptor => selDescriptor ?? descriptor;

        protected ShaderCreator(string path, Mode mode)
        {
            this.path = path;
            this.mode = mode;
            inputPath = path.Replace(".shader", "_Input.hlsl");
            forwardPath = path.Replace(".shader", "_ForwardPass.hlsl");
            
            if (mode == Mode.Update)
            {
                selDescriptor = new ShaderParser(path).ParseShader();
            }
        }
        
        public abstract void CreateDescriptor();

        public void Create()
        {
            CreateDescriptor();
            sb = new StringBuilder();
            indent = 0;
            AppendLineIndentAnno($"type:{GetType().Name}");
            sb.AppendLine();
            AppendIndent(Keys.Shader);
            AppendSpace();
            AppendLine(descriptor.path);
            AppendLine(Chars.BraceL3);
            
            indent++;
            
            PropDescriptor.GenProperty(sb, indent);
            GenSubShader();
            descriptor.fallback?.Generate(sb, indent);
            CustomEditorDescriptor.customEditor?.Generate(sb, indent);

            indent--;
            
            AppendIndent(Chars.BraceR3);
            
            File.WriteAllText(path, sb.ToString());
            
            CreateInput();
            CreateForwardPass();
            AssetDatabase.Refresh();
        }

        public void CreateInput()
        {
            var inputText = litInputParser.CreateInput(path);
            File.WriteAllText(inputPath, inputText);
        }

        public void CreateForwardPass()
        {
            if (mode == Mode.Create)
            {
                var forwardPassText = File.ReadAllText(forwardPassParser.SourcePath);
                File.WriteAllText(forwardPath, forwardPassText);
            }
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
                if (subBase is ShaderPass sp)
                {
                    AppendLineIndent(Keys.Pass);
                    AppendLineIndent(Chars.BraceL3);
                    indent++;
                    
                    foreach (var passBase in sp.vals)
                    {
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
                if (hb is ShaderInclude sp)
                {
                    if (sp.content.Contains(litInput))
                    {
                        AppendLineIndent($"{Chars.Hash}{Keys.Include} \"{inputPath}\"");
                        continue;
                    }
                    else if (sp.content.Contains(litForwardPass))
                    {
                        AppendLineIndent($"{Chars.Hash}{Keys.Include} \"{forwardPath}\"");
                        continue;
                    }
                }
                
                hb.Generate(sb, indent);
            }
            
            AppendLineIndent(Keys.HlslEnd);
        }

        protected void AppendIndent(string value) => sb.AppendIndent(value, indent);
        protected void AppendLineIndent(string value) => sb.AppendLineIndent(value, indent);
        protected void AppendLineIndentAnno(string value) => AppendLineIndent($"/*{value}*/");
        protected void Append(string value) => sb.Append(value);
        protected void AppendLine(string value) => sb.AppendLine(value);
        protected void AppendSpace() => sb.Append(' ');
        protected void AppendTab() => sb.Append('\t');
    }

    public class UnlitShaderCreator : ShaderCreator
    {
        public UnlitShaderCreator(string path, Mode mode) : base(path, mode) { }
        
        public override void CreateDescriptor()
        {
            var litParser = new ShaderParser($"{PackagePath}/Shaders/UnLit.shader");
            descriptor = litParser.ParseShader();
            if (mode == Mode.Create)
            {
                descriptor.path = "\"CustomUnlit\"";
            }

            litInput = "UnlitInput.hlsl";
            litForwardPass = "UnlitForwardPass.hlsl";
        
            litInputParser = new ShaderParser($"{PackagePath}/Shaders/UnLitInput.hlsl");
            forwardPassParser = new ShaderParser($"{PackagePath}/Shaders/UnlitForwardPass.hlsl");
        }
    }

    public class LitShaderCreator : ShaderCreator
    {
        public LitShaderCreator(string path, Mode mode) : base(path, mode) { }
        
        public override void CreateDescriptor()
        {
            var litParser = new ShaderParser($"{PackagePath}/Shaders/Lit.shader");
            descriptor = litParser.ParseShader();
            if (mode == Mode.Create)
            {
                descriptor.path = "\"CustomLit\"";
            }
            
            litInput = "LitInput.hlsl";
            litForwardPass = "LitForwardPass.hlsl";

            litInputParser = new ShaderParser($"{PackagePath}/Shaders/LitInput.hlsl");
            forwardPassParser = new ShaderParser($"{PackagePath}/Shaders/LitForwardPass.hlsl");
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