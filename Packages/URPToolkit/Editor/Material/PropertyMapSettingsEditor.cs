using UnityEditor;
using UnityEngine;

namespace GameApp.URPToolkit
{
    [CustomEditor(typeof(PropertyMapSettings))]
    public class PropertyMapSettingsEditor : Editor
    {
        public override void OnInspectorGUI()
        {
            base.OnInspectorGUI();
            
            GUILayout.BeginHorizontal();
            if (GUILayout.Button("Apply Property Map"))
            {
                ReplaceMaterials(target as PropertyMapSettings);
            }
            GUILayout.EndHorizontal();
        }

        public static void ReplaceMaterials(PropertyMapSettings settings)
        {
            settings.Init();
            var paths = settings.searchPaths.ToArray();
            var mats = AssetDatabase.FindAssets("t:Material", paths);
            var replaces = settings.mapDict;
            
            foreach (var matGuid in mats)
            {
                var matPath = AssetDatabase.GUIDToAssetPath(matGuid);
                var mat = AssetDatabase.LoadAssetAtPath<Material>(matPath);
                if (replaces.TryGetValue(mat.shader, out var rep))
                {
                    var serObj = new SerializedObject(mat);
                    var shaderProp = serObj.FindProperty("m_Shader");
                    shaderProp.objectReferenceValue = rep.target;
                    
                    var saveProps = serObj.FindProperty("m_SavedProperties");
                    var texProps = saveProps.FindPropertyRelative("m_TexEnvs");
                    var intProps = saveProps.FindPropertyRelative("m_Ints");
                    var floatProps = saveProps.FindPropertyRelative("m_Floats");
                    var colorProps = saveProps.FindPropertyRelative("m_Colors");
                    
                    ReplacePropName(texProps, rep);
                    ReplacePropName(intProps, rep);
                    ReplacePropName(floatProps, rep);
                    ReplacePropName(colorProps, rep);

                    serObj.ApplyModifiedProperties();
                }
            }
            
            AssetDatabase.SaveAssets();
        }

        public static void ReplacePropName(SerializedProperty property, PropertyMapSettings.MapItem map)
        {
            if (property == null) return;
            
            for (var i = 0; i < property.arraySize; i++)
            {
                var p = property.GetArrayElementAtIndex(i);
                var p1 = p.FindPropertyRelative("first");
                if (map.mapDict.TryGetValue(p1.stringValue, out var pm))
                {
                    p1.stringValue = pm.p2;
                }
                
            }
        }
    }
}