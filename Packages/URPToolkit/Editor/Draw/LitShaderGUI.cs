using System.Collections.Generic;
using GameApp.URPToolkit.Parser;
using UnityEditor;
using UnityEditor.Rendering;
using UnityEngine;

namespace GameApp.URPToolkit.Draw
{
    public class LitShaderGUI : LitShaderInternal
    {
        private List<MaterialProperty> _customProps = new();
        public class CustomStyles
        {
            public static readonly GUIContent CustomProperty = EditorGUIUtility.TrTextContent("Custom Property",
                "Custom properties.");
        }
        public override void FillAdditionalFoldouts(MaterialHeaderScopeList materialScopesList)
        {
            base.FillAdditionalFoldouts(materialScopesList);
            materialScopesList.RegisterHeaderScope(CustomStyles.CustomProperty, 16, _ =>
            {
                DoCustomPropertyArea();
            });
        }

        public override void FindProperties(MaterialProperty[] properties)
        {
            base.FindProperties(properties);
            
            _customProps.Clear();
            foreach (var prop in properties)
            {
                var p = FindProperty(prop.name, properties);
                _customProps.Add(p);
            }
        }

        private void DoCustomPropertyArea()
        {
            foreach (var p in _customProps)
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