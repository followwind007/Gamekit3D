using UnityEditor;
using UnityEngine;

namespace GameApp.URPToolkit.Draw
{
    //[CustomEditor(typeof(Shader))]
    public class ShaderEditor : Editor
    {
        public override void OnInspectorGUI()
        {
            EditorGUI.EndDisabledGroup();
            GUILayout.BeginHorizontal();
            if (GUILayout.Button("Regenerate"))
            {
                
            }
            GUILayout.EndHorizontal();
            GUILayout.Space(10);

            base.OnInspectorGUI();
        }
    }
}