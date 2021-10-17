Shader "Hidden/Custom/Lit" {
    Properties {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
    }
    SubShader {
        Tags { "RenderType"="Opaque" }
        LOD 200
        
        CGPROGRAM
        #pragma vertex LitPassVertex
        #pragma fragment LitPassFragment

        struct Input {
            float2 uv_MainTex;
        };
        
        ENDCG
    }
    
    FallBack "Hidden/Universal Render Pipeline/FallbackError"
}