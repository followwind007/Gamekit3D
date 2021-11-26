#ifndef UNIVERSAL_FORWARD_LIT_PASS_INCLUDED
#define UNIVERSAL_FORWARD_LIT_PASS_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

// GLES2 has limited amount of interpolators
#if defined(_PARALLAXMAP) && !defined(SHADER_API_GLES)
#define REQUIRES_TANGENT_SPACE_VIEW_DIR_INTERPOLATOR
#endif

#if (defined(_NORMALMAP) || (defined(_PARALLAXMAP) && !defined(REQUIRES_TANGENT_SPACE_VIEW_DIR_INTERPOLATOR))) || defined(_DETAIL)
#define REQUIRES_WORLD_SPACE_TANGENT_INTERPOLATOR
#endif

// keep this file in sync with LitGBufferPass.hlsl

struct Attributes
{
    float4 positionOS   : POSITION;
    float3 normalOS     : NORMAL;
    float4 tangentOS    : TANGENT;
    float2 texcoord     : TEXCOORD0;
    float2 staticLightmapUV   : TEXCOORD1;
    float2 dynamicLightmapUV  : TEXCOORD2;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    float2 uv                       : TEXCOORD0;

#if defined(REQUIRES_WORLD_SPACE_POS_INTERPOLATOR)
    float3 positionWS               : TEXCOORD1;
#endif

    half3 normalWS                 : TEXCOORD2;
#if defined(REQUIRES_WORLD_SPACE_TANGENT_INTERPOLATOR)
    half4 tangentWS                : TEXCOORD3;    // xyz: tangent, w: sign
#endif
    float3 viewDirWS                : TEXCOORD4;

#ifdef _ADDITIONAL_LIGHTS_VERTEX
    half4 fogFactorAndVertexLight   : TEXCOORD5; // x: fogFactor, yzw: vertex light
#else
    half  fogFactor                 : TEXCOORD5;
#endif

#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
    float4 shadowCoord              : TEXCOORD6;
#endif

#if defined(REQUIRES_TANGENT_SPACE_VIEW_DIR_INTERPOLATOR)
    half3 viewDirTS                : TEXCOORD7;
#endif

    DECLARE_LIGHTMAP_OR_SH(staticLightmapUV, vertexSH, 8);
#ifdef DYNAMICLIGHTMAP_ON
    float2  dynamicLightmapUV : TEXCOORD9; // Dynamic lightmap UVs
#endif

    float2 localDir : TEXCOORD10;
    float3 worldRefl : TEXCOORD11;
    float4 screenPos : TEXCOORD12;
    float3 viewDir : TEXCOORD13;
    float depth : TEXCOORD14;
    float4 projPos : TEXCOORD15;
    float4 grabPos : TEXCOORD16;
    float4 color : COLOR;
    
    float4 positionCS               : SV_POSITION;
    UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
};

void InitializeInputData(Varyings input, half3 normalTS, out InputData inputData)
{
    inputData = (InputData)0;

#if defined(REQUIRES_WORLD_SPACE_POS_INTERPOLATOR)
    inputData.positionWS = input.positionWS;
#endif

    half3 viewDirWS = GetWorldSpaceNormalizeViewDir(input.positionWS);
#if defined(_NORMALMAP) || defined(_DETAIL)
    float sgn = input.tangentWS.w;      // should be either +1 or -1
    float3 bitangent = sgn * cross(input.normalWS.xyz, input.tangentWS.xyz);
    half3x3 tangentToWorld = half3x3(input.tangentWS.xyz, bitangent.xyz, input.normalWS.xyz);

    #if defined(_NORMALMAP)
    inputData.tangentToWorld = tangentToWorld;
    #endif
    inputData.normalWS = TransformTangentToWorld(normalTS, tangentToWorld);
#else
    inputData.normalWS = input.normalWS;
#endif

    inputData.normalWS = NormalizeNormalPerPixel(inputData.normalWS);
    inputData.viewDirectionWS = viewDirWS;

#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
    inputData.shadowCoord = input.shadowCoord;
#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
    inputData.shadowCoord = TransformWorldToShadowCoord(inputData.positionWS);
#else
    inputData.shadowCoord = float4(0, 0, 0, 0);
#endif
#ifdef _ADDITIONAL_LIGHTS_VERTEX
    inputData.fogCoord = InitializeInputDataFog(float4(input.positionWS, 1.0), input.fogFactorAndVertexLight.x);
    inputData.vertexLighting = input.fogFactorAndVertexLight.yzw;
#else
    inputData.fogCoord = InitializeInputDataFog(float4(input.positionWS, 1.0), input.fogFactor);
#endif

#if defined(DYNAMICLIGHTMAP_ON)
    inputData.bakedGI = SAMPLE_GI(input.staticLightmapUV, input.dynamicLightmapUV, input.vertexSH, inputData.normalWS);
#else
    inputData.bakedGI = SAMPLE_GI(input.staticLightmapUV, input.vertexSH, inputData.normalWS);
#endif

    inputData.normalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(input.positionCS);
    inputData.shadowMask = SAMPLE_SHADOWMASK(input.staticLightmapUV);

    #if defined(DEBUG_DISPLAY)
    #if defined(DYNAMICLIGHTMAP_ON)
    inputData.dynamicLightmapUV = input.dynamicLightmapUV;
    #endif
    #if defined(LIGHTMAP_ON)
    inputData.staticLightmapUV = input.staticLightmapUV;
    #else
    inputData.vertexSH = input.vertexSH;
    #endif
    #endif
}

TEXTURE2D(_CameraDepthTexture); SAMPLER(sampler_CameraDepthTexture);
TEXTURE2D(_CameraOpaqueTexture); SAMPLER(sampler_CameraOpaqueTexture);
TEXTURE2D(_DirectionalShadowMask); SAMPLER(sampler_DirectionalShadowMask);

inline float InverseLerp(float a, float b, float value)
{
    return saturate((value - a) / (b - a));
}

inline half3 Blend(half3 bg, half3 fore, half alpha) {
    return (bg * (1-alpha)) + (alpha*fore);
}

static const float3 forward = float3(0,0,1);
        
float4 Blur(Texture2D tex, SamplerState s, float depth, float2 uv, float2 grapUV) {
    float4 color = 0;
    float2 blurSize = _DepthBlur * grapUV * depth;
    float2 ouv = uv;
    
    float k = 1.0 / 9;
    for(int y=0; y<3; y++) {
        for(int x=0; x<3; x++) {
            float2 offset = float2(x-1, y-1);
            uv.xy = ouv + blurSize * offset;
            float4 c = SAMPLE_TEXTURE2D(tex, s, uv); 
            color += c * k;
        }
    }
    return color;
}

float4 Blur(Texture2D tex, SamplerState s, float4 uv) {
    float4 color = 0;
    float2 blurSize = 0.1;
    float2 ouv = uv.xy;
    float k = 1.0 / 9;
    for(int y=0; y<3; y++) {
        for(int x=0; x<3; x++) {
            float2 offset = float2(x-1, y-1);
            uv.xy = ouv + blurSize * offset;
            float4 c = SAMPLE_TEXTURE2D(tex, s, uv.xy); 
            color += c * k;
        }
    }
    return color;
}

inline float4 ComputeGrabScreenPos (float4 pos) {
    #if UNITY_UV_STARTS_AT_TOP
    float scale = -1.0;
    #else
    float scale = 1.0;
    #endif
    float4 o = pos * 0.5f;
    o.xy = float2(o.x, o.y*scale) + o.w;
    #ifdef UNITY_SINGLE_PASS_STEREO
    o.xy = TransformStereoScreenSpaceTex(o.xy, pos.w);
    #endif
    o.zw = pos.zw;
    return o;
}

///////////////////////////////////////////////////////////////////////////////
//                  Vertex and Fragment functions                            //
///////////////////////////////////////////////////////////////////////////////

// Used in Standard (Physically Based) shader
Varyings LitPassVertex(Attributes input)
{
    Varyings output = (Varyings)0;

    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_TRANSFER_INSTANCE_ID(input, output);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

    output.localDir = input.positionOS.xz;
    input.positionOS.y += sin(_WaveFrequency*_Time[1] + length(output.localDir)*_WaveLength) *_WaveHeight;
    float4 vertex = TransformObjectToHClip(input.positionOS.xyz);
    output.projPos = ComputeScreenPos (vertex);
    output.projPos.z = -TransformWorldToView(TransformObjectToWorld(input.positionOS.xyz)).z;
    output.grabPos = ComputeGrabScreenPos(vertex);
    
    VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);

    float3 relPos = vertexInput.positionWS.xyz - _WorldSpaceCameraPos.xyz;
    output.depth = length(relPos);

    // normalWS and tangentWS already normalize.
    // this is required to avoid skewing the direction during interpolation
    // also required for per-vertex lighting and SH evaluation
    VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);

    half3 vertexLight = VertexLighting(vertexInput.positionWS, normalInput.normalWS);

    half fogFactor = 0;
    #if !defined(_FOG_FRAGMENT)
        fogFactor = ComputeFogFactor(vertexInput.positionCS.z);
    #endif

    output.uv = TRANSFORM_TEX(input.texcoord, _BaseMap);

    // already normalized from normal transform to WS.
    output.normalWS = normalInput.normalWS;
#if defined(REQUIRES_WORLD_SPACE_TANGENT_INTERPOLATOR) || defined(REQUIRES_TANGENT_SPACE_VIEW_DIR_INTERPOLATOR)
    real sign = input.tangentOS.w * GetOddNegativeScale();
    half4 tangentWS = half4(normalInput.tangentWS.xyz, sign);
#endif
#if defined(REQUIRES_WORLD_SPACE_TANGENT_INTERPOLATOR)
    output.tangentWS = tangentWS;
#endif

#if defined(REQUIRES_TANGENT_SPACE_VIEW_DIR_INTERPOLATOR)
    half3 viewDirWS = GetWorldSpaceNormalizeViewDir(vertexInput.positionWS);
    half3 viewDirTS = GetViewDirectionTangentSpace(tangentWS, output.normalWS, viewDirWS);
    output.viewDirTS = viewDirTS;
#endif

    OUTPUT_LIGHTMAP_UV(input.staticLightmapUV, unity_LightmapST, output.staticLightmapUV);
#ifdef DYNAMICLIGHTMAP_ON
    output.dynamicLightmapUV = input.dynamicLightmapUV.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
#endif
    OUTPUT_SH(output.normalWS.xyz, output.vertexSH);
#ifdef _ADDITIONAL_LIGHTS_VERTEX
    output.fogFactorAndVertexLight = half4(fogFactor, vertexLight);
#else
    output.fogFactor = fogFactor;
#endif

#if defined(REQUIRES_WORLD_SPACE_POS_INTERPOLATOR)
    output.positionWS = vertexInput.positionWS;
#endif

#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
    output.shadowCoord = GetShadowCoord(vertexInput);
#endif

    output.positionCS = vertexInput.positionCS;

    return output;
}

inline void InitializeStandardLitSurfaceDataCustom(Varyings input, out SurfaceData outSurfaceData)
{
    float2 uv = input.uv;

    float depthSample = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, sampler_CameraDepthTexture, input.projPos.xy);
    float sceneZ = LinearEyeDepth(depthSample, _ZBufferParams);
    float partZ = input.projPos.z;

    float2 screenUV = input.screenPos.xy;
    screenUV /= input.screenPos.w;

    float shadowmask = SAMPLE_TEXTURE2D(_DirectionalShadowMask, sampler_DirectionalShadowMask, screenUV).b;
    half shadow = lerp(_ShadowFade, 0, shadowmask);
    _BaseColor = lerp(_BaseColor, _ShadowColor, shadow);

    float zDiff = abs(sceneZ-partZ);
    float edge = InverseLerp(_FoamDepth, 0, zDiff);
    float fog = 1-InverseLerp(_FogDepth, 0, zDiff);
    float fade = InverseLerp(_EdgeBlend, 0, zDiff);

    fog *= (1-(shadow*0.15));
			
    float2 foamUV = (input.positionWS.xz*_FoamScale) + (_Speed * input.localDir * _Time[0]);
    half noise = SAMPLE_TEXTURE2D(_Noise, sampler_Noise, (_Time[0]+foamUV)/32).r;
    half scaleNoise = lerp(0.999,1.001, noise);
    float2 foamUV1 = scaleNoise*foamUV + (_Speed * _SinTime[2]*input.localDir);
    float2 foamUV2 = scaleNoise*0.7 * foamUV + (_Speed * _SinTime[2]*input.localDir*0.6);
    half4 foam = (SAMPLE_TEXTURE2D(_FoamTex, sampler_FoamTex, foamUV1) +
        SAMPLE_TEXTURE2D(_FoamTex, sampler_FoamTex, foamUV2)) * lerp(_FoamColor, _ShadowColor, shadow);
    float3 rippleNormals = normalize(lerp(SampleNormal(foamUV1, _Ripples, sampler_Ripples), SampleNormal(foamUV2, _Ripples, sampler_Ripples), noise));
    float3 normal = normalize(lerp(rippleNormals, forward, 1-(_Turbulence*1.0/fog)));
    normal = lerp(normal, forward, fade);

    half3 color = Blend(_BaseColor.rgb, foam.rgb, edge);

    half3 scum = SAMPLE_TEXTURE2D(_ScumTex, sampler_ScumTex, input.positionWS.xz*_ScumScale).rgb;
    half scumNoise = SAMPLE_TEXTURE2D(_Noise, sampler_Noise, input.positionWS.xz*_ScumNoiseScale).r;
    half scumAmount = 1.0f - pow(abs(input.color.r), scumNoise*_ScumFalloff);
			
    float4 bgUV = input.grabPos;
    float2 offset = normal.xy * _ScreenParams.xy * _Focus;
    bgUV.xy = offset * bgUV.z + bgUV.xy;
    bgUV.xy /= bgUV.w;
    half3 bg = Blur(_CameraOpaqueTexture, sampler_CameraOpaqueTexture, fog, bgUV.xy, input.grabPos.xy).rgb;
    float4 reflPos = input.projPos;
    reflPos.xy += rippleNormals.xy;
    float3 refl = Blur(_ReflectionTex, sampler_ReflectionTex, reflPos).rgb * (1-shadow);
    half rim = (1.0 - pow(abs(saturate(pow(abs(dot(normalize(input.viewDir), normal)),0.125))),4)) * (1-shadow);

    float distanceAlpha = 1-InverseLerp(_WaterCullDistance*0.7, _WaterCullDistance, input.depth);
    color = Blend(color, scum, scumAmount);
    half3 albedo = Blend(bg, color, fog);
    
    half albedoAlpha = min(1-fade,distanceAlpha);
    outSurfaceData.alpha = albedoAlpha;

    half4 specGloss = SampleMetallicSpecGloss(uv, albedoAlpha);
    outSurfaceData.albedo = albedo;

    #if _SPECULAR_SETUP
    outSurfaceData.metallic = half(1.0);
    outSurfaceData.specular = specGloss.rgb;
    #else
    outSurfaceData.metallic = specGloss.r;
    outSurfaceData.specular = half3(0.0, 0.0, 0.0);
    #endif

    outSurfaceData.smoothness = specGloss.a;
    outSurfaceData.normalTS = normal;
    outSurfaceData.occlusion = SampleOcclusion(uv);
    outSurfaceData.emission = (foam.rgb*edge*_EmissionColor.rgb) + (rim*refl) * (1-scumAmount);

    #if defined(_CLEARCOAT) || defined(_CLEARCOATMAP)
    half2 clearCoat = SampleClearCoat(uv);
    outSurfaceData.clearCoatMask       = clearCoat.r;
    outSurfaceData.clearCoatSmoothness = clearCoat.g;
    #else
    outSurfaceData.clearCoatMask       = half(0.0);
    outSurfaceData.clearCoatSmoothness = half(0.0);
    #endif

    #if defined(_DETAIL)
    half detailMask = SAMPLE_TEXTURE2D(_DetailMask, sampler_DetailMask, uv).a;
    float2 detailUv = uv * _DetailAlbedoMap_ST.xy + _DetailAlbedoMap_ST.zw;
    outSurfaceData.albedo = ApplyDetailAlbedo(detailUv, outSurfaceData.albedo, detailMask);
    outSurfaceData.normalTS = ApplyDetailNormal(detailUv, outSurfaceData.normalTS, detailMask);
    #endif
}


// Used in Standard (Physically Based) shader
half4 LitPassFragment(Varyings input) : SV_Target
{
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

#if defined(_PARALLAXMAP)
#if defined(REQUIRES_TANGENT_SPACE_VIEW_DIR_INTERPOLATOR)
    half3 viewDirTS = input.viewDirTS;
#else
    half3 viewDirWS = GetWorldSpaceNormalizeViewDir(input.positionWS);
    half3 viewDirTS = GetViewDirectionTangentSpace(input.tangentWS, input.normalWS, viewDirWS);
#endif
    ApplyPerPixelDisplacement(viewDirTS, input.uv);
#endif

    SurfaceData surfaceData;
    InitializeStandardLitSurfaceDataCustom(input, surfaceData);

    InputData inputData;
    InitializeInputData(input, surfaceData.normalTS, inputData);
    SETUP_DEBUG_TEXTURE_DATA(inputData, input.uv, _BaseMap);

#ifdef _DBUFFER
    ApplyDecalToSurfaceData(input.positionCS, surfaceData, inputData);
#endif

    half4 color = UniversalFragmentPBR(inputData, surfaceData);

    color.rgb = MixFog(color.rgb, inputData.fogCoord);
    color.a = OutputAlpha(color.a, _Surface);

    return color;
}

#endif
