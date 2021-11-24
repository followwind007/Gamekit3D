using System.Collections.Generic;
using GameApp.URPToolkit.Parser;
using UnityEditor;

namespace GameApp.URPToolkit.Draw
{
    public interface ILitShaderGUI
    {
        
    }

    public static class LitShaderGUIImpl
    {
        public static void DoCustomPropertyAreaImpl(this ILitShaderGUI _, List<MaterialProperty> props, MaterialEditor materialEditor)
        {
            foreach (var p in props)
            {
                if ((p.flags & MaterialProperty.PropFlags.HideInInspector) != 0) continue;
                if (ShaderParser.IgnoreCBufferProperties.Contains(p.name)) continue;
                if (ShaderParser.ReservedProperties.Contains(p.name)) continue;
                if (ShaderParser.IgnoreTexture2D.Contains(p.name)) continue;
                
                materialEditor.DefaultShaderProperty(p, p.displayName);
            }
        }
    }
}