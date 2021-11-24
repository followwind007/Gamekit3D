using System.Collections.Generic;
using UnityEditor;
using UnityEditor.Rendering;
using UnityEngine;

namespace GameApp.URPToolkit.Draw
{
    public class UnlitShaderGUI : UnlitShaderInternal, ILitShaderGUI
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
                this.DoCustomPropertyAreaImpl(_customProps, materialEditor);
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
    }
}