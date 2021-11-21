using System;
using System.Collections.Generic;
using UnityEngine;

namespace GameApp.URPToolkit
{
    [CreateAssetMenu(fileName = "PropertyMapSettings", menuName = "URPToolkit/PropertyMapSettings", order = 0)]
    public class PropertyMapSettings : ScriptableObject
    {
        [Serializable]
        public class PropertyMap
        {
            public string p1;
            public string p2;
        }
        
        [Serializable]
        public class MapItem
        {
            public Shader source;
            public Shader target;

            public List<PropertyMap> maps = new();

            public readonly Dictionary<string, PropertyMap> mapDict = new();
        }

        public List<MapItem> maps = new();
        
        public readonly Dictionary<Shader, MapItem> mapDict = new();

        public List<string> searchPaths = new();

        public void Init()
        {
            mapDict.Clear();
            
            foreach (var map in maps)
            {
                mapDict[map.source] = map;
                map.mapDict.Clear();
                foreach (var propMap in map.maps)
                {
                    map.mapDict[propMap.p1] = propMap;
                }
            }
        }
    }
}