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

        protected int indent;
        protected StringBuilder sb;
        
        protected ShaderCreator(string path)
        {
            this.path = path;
        }
        
        public abstract ShaderDescriptor CreateDescriptor();

        public void Create()
        {
            descriptor = CreateDescriptor();
            sb = new StringBuilder();
            indent = 0;
            AppendIndent("Shader");
            AppendSpace();
            Append(descriptor.path);
            AppendLine("{");
            descriptor.GenProperty(sb, indent);
            GenSubShader();
            AppendIndent("}");
            
            File.WriteAllText(path, sb.ToString());
            AssetDatabase.Refresh();
        }

        protected void GenSubShader()
        {
            GenPass();
        }

        protected void GenPass()
        {
            
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
        
        public override ShaderDescriptor CreateDescriptor()
        {
            var litParser = new ShaderParser($"{PackagePath}/Shaders/UnLit.shader");
            var desc = litParser.Parse();
            desc.path = "\"Hidden/CustomUnlit\"";
            return desc;
        }
    }

    public class LitShaderCreator : ShaderCreator
    {
        public LitShaderCreator(string path) : base(path) { }
        
        public override ShaderDescriptor CreateDescriptor()
        {
            var litParser = new ShaderParser($"{PackagePath}/Shaders/Lit.shader");
            var desc = litParser.Parse();
            desc.path = "\"Hidden/CustomLit\"";
            return desc;
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