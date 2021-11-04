#ifndef UNIVERSAL_UNLIT_INPUT_INCLUDED
#define UNIVERSAL_UNLIT_INPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"

CBUFFER_START(UnityPerMaterial)
float4 _BaseMap_ST;
float4 _DetailAlbedoMap_ST;
half4 _BaseColor;
float _Cutoff;
float _Surface;
float _QueueOffset;
CBUFFER_END

TEXTURE2D(_MainTex); SAMPLER(sampler_MainTex);




#endif
