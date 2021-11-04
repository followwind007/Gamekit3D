Shader "Hidden/CustomUnlit"
{
	Properties
	{
		[MainTexture]_BaseMap("Texture", 2D) = "white" {}
		[MainColor]_BaseColor("Color", Color) = (1, 1, 1, 1)
		_Cutoff("AlphaCutout", Range(0.0,1.0)) = 0.5
		_Surface("__surface", Float) = 0.0
		_Blend("__mode", Float) = 0.0
		_Cull("__cull", Float) = 2.0
		[ToggleUI]_AlphaClip("__clip", Float) = 0.0
		[HideInInspector]_BlendOp("__blendop", Float) = 0.0
		[HideInInspector]_SrcBlend("__src", Float) = 1.0
		[HideInInspector]_DstBlend("__dst", Float) = 0.0
		[HideInInspector]_ZWrite("__zw", Float) = 1.0
		_QueueOffset("Queue offset", Float) = 0.0
		[HideInInspector]_MainTex("BaseMap", 2D) = "white" {}
		[HideInInspector]_Color("Base Color", Color) = (0.5, 0.5, 0.5, 1)
		[HideInInspector]_SampleGI("SampleGI", float) = 0.0
	}
	SubShader
	{
		LOD 100
		Blend[_SrcBlend][_DstBlend]
		ZWrite[_ZWrite]
		Cull[_Cull]
		Pass
		{
			Name "Unlit"
			HLSLPROGRAM
			ENDHLSL
		}
	}
	FallBack "Hidden/Universal Render Pipeline/FallbackError"
	CustomEditor "UnityEditor.Rendering.Universal.ShaderGUI.UnlitShader"
}