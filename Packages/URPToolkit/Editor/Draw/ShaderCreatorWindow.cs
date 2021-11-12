using UnityEditor;
using UnityEngine;

namespace GameApp.URPToolkit.Draw
{
    public class ShaderCreatorWindow : EditorWindow
    {
        public enum CreaterType
        {
            Lit,
            Unlit
        }

        private CreaterType _type;

        private string _name;
        
        public static void OpenWindow(CreaterType type)
        {
            var window = CreateWindow<ShaderCreatorWindow>("Shader Creator");
            window._type = type;
            window._name = $"New{type}";
        }

        private void OnGUI()
        {
            _name = EditorGUILayout.TextField("Shader Name", _name);
            GUILayout.FlexibleSpace();
            if (GUILayout.Button("Create New Shader"))
            {
                ShaderCreator creator = null;
                switch (_type)
                {
                    case CreaterType.Lit:
                        creator = new LitShaderCreator($"{MenuEntry.CurSelPath}/{_name}.shader", ShaderCreator.Mode.Create);
                        break;
                    case CreaterType.Unlit:
                        creator = new UnlitShaderCreator($"{MenuEntry.CurSelPath}/{_name}.shader", ShaderCreator.Mode.Create);
                        break;
                }
                creator?.Create();
            }
        }
    }
}