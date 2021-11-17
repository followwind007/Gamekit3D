/*type:LitShaderCreator*/

Shader "Universal Render Pipeline/Lit"
{
	Properties
	{
		_WorkflowMode("WorkflowMode", Float) = 1.0
		[MainTexture]_BaseMap("Albedo", 2D) = "white" {}
		[MainColor]_BaseColor("Color", Color) = (1,1,1,1)
		_Cutoff("Alpha Cutoff", Range(0.0,1.0)) = 0.5
		_Smoothness("Smoothness", Range(0.0,1.0)) = 0.5
		_SmoothnessTextureChannel("Smoothness texture channel", Float) = 0
		_Metallic("Metallic", Range(0.0,1.0)) = 0.0
		_MetallicGlossMap("Metallic", 2D) = "white" {}
		_SpecColor("Specular", Color) = (0.2, 0.2, 0.2)
		_SpecGlossMap("Specular", 2D) = "white" {}
		[ToggleOff]_SpecularHighlights("Specular Highlights", Float) = 1.0
		[ToggleOff]_EnvironmentReflections("Environment Reflections", Float) = 1.0
		_BumpScale("Scale", Float) = 1.0
		_BumpMap("Normal Map", 2D) = "bump" {}
		_Parallax("Scale", Range(0.005,0.08)) = 0.005
		_ParallaxMap("Height Map", 2D) = "black" {}
		_OcclusionStrength("Strength", Range(0.0,1.0)) = 1.0
		_OcclusionMap("Occlusion", 2D) = "white" {}
		[HDR]_EmissionColor("Color", Color) = (0,0,0)
		_EmissionMap("Emission", 2D) = "white" {}
		_DetailMask("Detail Mask", 2D) = "white" {}
		_DetailAlbedoMapScale("Scale", Range(0.0,2.0)) = 1.0
		_DetailAlbedoMap("Detail Albedo x2", 2D) = "linearGrey" {}
		_DetailNormalMapScale("Scale", Range(0.0,2.0)) = 1.0
		[Normal]_DetailNormalMap("Normal Map", 2D) = "bump" {}
		_TopMap("Top Albedo", 2D) = "white" {}
		_TopNormalMap("Top Normal", 2D) = "white" {}
		_TopMetallicMap("Top Metallic Map", 2D) = "white" {}
		_TopMetallic("Top Metallic", Range(0.0,1.0)) = 1
		_TopGlossiness("Top Glossiness", Range(0.0,1.0)) = 1
		_TopNoiseMap("Top Noise", 2D) = "white" {}
		[HideInInspector]_ClearCoatMask("_ClearCoatMask", Float) = 0.0
		[HideInInspector]_ClearCoatSmoothness("_ClearCoatSmoothness", Float) = 0.0
		_Surface("__surface", Float) = 0.0
		_Blend("__blend", Float) = 0.0
		_Cull("__cull", Float) = 2.0
		[ToggleUI]_AlphaClip("__clip", Float) = 0.0
		[HideInInspector]_SrcBlend("__src", Float) = 1.0
		[HideInInspector]_DstBlend("__dst", Float) = 0.0
		[HideInInspector]_ZWrite("__zw", Float) = 1.0
		[ToggleUI]_ReceiveShadows("Receive Shadows", Float) = 1.0
		_QueueOffset("Queue offset", Float) = 0.0
		[HideInInspector]_MainTex("BaseMap", 2D) = "white" {}
		[HideInInspector]_Color("Base Color", Color) = (1, 1, 1, 1)
		[HideInInspector]_GlossMapScale("Smoothness", Float) = 0.0
		[HideInInspector]_Glossiness("Smoothness", Float) = 0.0
		[HideInInspector]_GlossyReflections("EnvironmentReflections", Float) = 0.0
		[HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
		[HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
		[HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
	}
	SubShader
	{
		LOD 300
		Pass
		{
			Name "ForwardLit"
			Blend[_SrcBlend][_DstBlend]
			ZWrite[_ZWrite]
			Cull[_Cull]
			HLSLPROGRAM
			#pragma exclude_renderers gles gles3 glcore
			#pragma target 4.5
			#pragma shader_feature_local _NORMALMAP
			#pragma shader_feature_local _PARALLAXMAP
			#pragma shader_feature_local _RECEIVE_SHADOWS_OFF
			#pragma shader_feature_local _ _DETAIL_MULX2 _DETAIL_SCALED
			#pragma shader_feature_local_fragment _SURFACE_TYPE_TRANSPARENT
			#pragma shader_feature_local_fragment _ALPHATEST_ON
			#pragma shader_feature_local_fragment _ALPHAPREMULTIPLY_ON
			#pragma shader_feature_local_fragment _EMISSION
			#pragma shader_feature_local_fragment _METALLICSPECGLOSSMAP
			#pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
			#pragma shader_feature_local_fragment _OCCLUSIONMAP
			#pragma shader_feature_local_fragment _SPECULARHIGHLIGHTS_OFF
			#pragma shader_feature_local_fragment _ENVIRONMENTREFLECTIONS_OFF
			#pragma shader_feature_local_fragment _SPECULAR_SETUP
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
			#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
			#pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
			#pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
			#pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
			#pragma multi_compile_fragment _ _SHADOWS_SOFT
			#pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
			#pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
			#pragma multi_compile_fragment _ _LIGHT_LAYERS
			#pragma multi_compile_fragment _ _LIGHT_COOKIES
			#pragma multi_compile _ _CLUSTERED_RENDERING
			#pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
			#pragma multi_compile _ SHADOWS_SHADOWMASK
			#pragma multi_compile _ DIRLIGHTMAP_COMBINED
			#pragma multi_compile _ LIGHTMAP_ON
			#pragma multi_compile _ DYNAMICLIGHTMAP_ON
			#pragma multi_compile_fog
			#pragma multi_compile_fragment _ DEBUG_DISPLAY
			#pragma multi_compile_instancing
			#pragma instancing_options renderinglayer
			#pragma multi_compile _ DOTS_INSTANCING_ON
			#pragma vertex LitPassVertex
			#pragma fragment LitPassFragment
			#include "Assets/Shaders/URP_Rock_Input.hlsl"
			#include "Assets/Shaders/URP_Rock_ForwardPass.hlsl"
			ENDHLSL
		}
		Pass
		{
			Name "ShadowCaster"
			ZWrite On
			ZTest LEqual
			ColorMask 0
			Cull[_Cull]
			HLSLPROGRAM
			#pragma exclude_renderers gles gles3 glcore
			#pragma target 4.5
			#pragma shader_feature_local_fragment _ALPHATEST_ON
			#pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
			#pragma multi_compile_instancing
			#pragma multi_compile _ DOTS_INSTANCING_ON
			#pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
			#pragma vertex ShadowPassVertex
			#pragma fragment ShadowPassFragment
			#include "Assets/Shaders/URP_Rock_Input.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Shaders/ShadowCasterPass.hlsl"
			ENDHLSL
		}
		Pass
		{
			Name "GBuffer"
			ZWrite[_ZWrite]
			ZTest LEqual
			Cull[_Cull]
			HLSLPROGRAM
			#pragma exclude_renderers gles gles3 glcore
			#pragma target 4.5
			#pragma shader_feature_local _NORMALMAP
			#pragma shader_feature_local_fragment _ALPHATEST_ON
			#pragma shader_feature_local_fragment _EMISSION
			#pragma shader_feature_local_fragment _METALLICSPECGLOSSMAP
			#pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
			#pragma shader_feature_local_fragment _OCCLUSIONMAP
			#pragma shader_feature_local _PARALLAXMAP
			#pragma shader_feature_local _ _DETAIL_MULX2 _DETAIL_SCALED
			#pragma shader_feature_local_fragment _SPECULARHIGHLIGHTS_OFF
			#pragma shader_feature_local_fragment _ENVIRONMENTREFLECTIONS_OFF
			#pragma shader_feature_local_fragment _SPECULAR_SETUP
			#pragma shader_feature_local _RECEIVE_SHADOWS_OFF
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
			#pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
			#pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
			#pragma multi_compile_fragment _ _SHADOWS_SOFT
			#pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
			#pragma multi_compile_fragment _ _LIGHT_LAYERS
			#pragma multi_compile_fragment _ _RENDER_PASS_ENABLED
			#pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
			#pragma multi_compile _ SHADOWS_SHADOWMASK
			#pragma multi_compile _ DIRLIGHTMAP_COMBINED
			#pragma multi_compile _ LIGHTMAP_ON
			#pragma multi_compile _ DYNAMICLIGHTMAP_ON
			#pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT
			#pragma multi_compile_instancing
			#pragma instancing_options renderinglayer
			#pragma multi_compile _ DOTS_INSTANCING_ON
			#pragma vertex LitGBufferPassVertex
			#pragma fragment LitGBufferPassFragment
			#include "Assets/Shaders/URP_Rock_Input.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Shaders/LitGBufferPass.hlsl"
			ENDHLSL
		}
		Pass
		{
			Name "DepthOnly"
			ZWrite On
			ColorMask 0
			Cull[_Cull]
			HLSLPROGRAM
			#pragma exclude_renderers gles gles3 glcore
			#pragma target 4.5
			#pragma vertex DepthOnlyVertex
			#pragma fragment DepthOnlyFragment
			#pragma shader_feature_local_fragment _ALPHATEST_ON
			#pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
			#pragma multi_compile_instancing
			#pragma multi_compile _ DOTS_INSTANCING_ON
			#include "Assets/Shaders/URP_Rock_Input.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Shaders/DepthOnlyPass.hlsl"
			ENDHLSL
		}
		Pass
		{
			Name "DepthNormals"
			ZWrite On
			Cull[_Cull]
			HLSLPROGRAM
			#pragma exclude_renderers gles gles3 glcore
			#pragma target 4.5
			#pragma vertex DepthNormalsVertex
			#pragma fragment DepthNormalsFragment
			#pragma shader_feature_local _NORMALMAP
			#pragma shader_feature_local _PARALLAXMAP
			#pragma shader_feature_local _ _DETAIL_MULX2 _DETAIL_SCALED
			#pragma shader_feature_local_fragment _ALPHATEST_ON
			#pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
			#pragma multi_compile_instancing
			#pragma multi_compile _ DOTS_INSTANCING_ON
			#include "Assets/Shaders/URP_Rock_Input.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Shaders/LitDepthNormalsPass.hlsl"
			ENDHLSL
		}
		Pass
		{
			Name "Meta"
			Cull Off
			HLSLPROGRAM
			#pragma exclude_renderers gles gles3 glcore
			#pragma target 4.5
			#pragma vertex UniversalVertexMeta
			#pragma fragment UniversalFragmentMetaLit
			#pragma shader_feature EDITOR_VISUALIZATION
			#pragma shader_feature_local_fragment _SPECULAR_SETUP
			#pragma shader_feature_local_fragment _EMISSION
			#pragma shader_feature_local_fragment _METALLICSPECGLOSSMAP
			#pragma shader_feature_local_fragment _ALPHATEST_ON
			#pragma shader_feature_local_fragment _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
			#pragma shader_feature_local _ _DETAIL_MULX2 _DETAIL_SCALED
			#pragma shader_feature_local_fragment _SPECGLOSSMAP
			#include "Assets/Shaders/URP_Rock_Input.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Shaders/LitMetaPass.hlsl"
			ENDHLSL
		}
		Pass
		{
			Name "Universal2D"
			Blend[_SrcBlend][_DstBlend]
			ZWrite[_ZWrite]
			Cull[_Cull]
			HLSLPROGRAM
			#pragma exclude_renderers gles gles3 glcore
			#pragma target 4.5
			#pragma vertex vert
			#pragma fragment frag
			#pragma shader_feature_local_fragment _ALPHATEST_ON
			#pragma shader_feature_local_fragment _ALPHAPREMULTIPLY_ON
			#include "Assets/Shaders/URP_Rock_Input.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Shaders/Utils/Universal2D.hlsl"
			ENDHLSL
		}
	}
	FallBack "Hidden/Universal Render Pipeline/FallbackError"
	CustomEditor "GameApp.URPToolkit.Draw.LitShaderGUI"
}