Shader "Gen/Rock"
{
    Properties
    {
        [NoScaleOffset]_MainTex("MainTex", 2D) = "white" {}
        [NoScaleOffset]_BumpMap("BumpMap", 2D) = "white" {}
        [NoScaleOffset]_DetailBump("DetailBump", 2D) = "white" {}
        _DetailScale("DetailScale", Float) = 1
        [NoScaleOffset]_OcclusionMap("OcclusionMap", 2D) = "white" {}
        _OcclusionStrength("OcclusionStrength", Range(0, 1)) = 1
        [NoScaleOffset]_MetallicRough("MetallicRough", 2D) = "white" {}
        _Metallic("Metallic", Range(0, 1)) = 0
        _Glossiness("Glossiness", Range(0, 1)) = 0.5
        [NoScaleOffset]_TopAlbedo("TopAlbedo", 2D) = "white" {}
        [NoScaleOffset]_TopNormal("TopNormal", 2D) = "white" {}
        [NoScaleOffset]_TopMetallicRough("TopMetallicRough", 2D) = "white" {}
        _TopMetallic("TopMetallic", Range(0, 1)) = 0
        _TopGlossiness("TopGlossiness", Range(0, 1)) = 0.5
        [NoScaleOffset]_Noise("Noise", 2D) = "white" {}
        [HideInInspector]_QueueOffset("_QueueOffset", Float) = 0
        [HideInInspector]_QueueControl("_QueueControl", Float) = -1
        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Opaque"
            "UniversalMaterialType" = "Lit"
            "Queue"="Geometry"
            "ShaderGraphShader"="true"
            "ShaderGraphTargetId"="UniversalLitSubTarget"
        }
        Pass
        {
            Name "Universal Forward"
            Tags
            {
                "LightMode" = "UniversalForward"
            }
        
        // Render State
        Cull Back
        Blend One Zero
        ZTest LEqual
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma instancing_options renderinglayer
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        #pragma multi_compile _ _SCREEN_SPACE_OCCLUSION
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DYNAMICLIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
        #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
        #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
        #pragma multi_compile _ _REFLECTION_PROBE_BLENDING
        #pragma multi_compile _ _REFLECTION_PROBE_BOX_PROJECTION
        #pragma multi_compile _ _SHADOWS_SOFT
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
        #pragma multi_compile _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        #pragma multi_compile _ _LIGHT_LAYERS
        #pragma multi_compile _ DEBUG_DISPLAY
        #pragma multi_compile _ _LIGHT_COOKIES
        #pragma multi_compile _ _CLUSTERED_RENDERING
        // GraphKeywords: <None>
        
        // Defines
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_VIEWDIRECTION_WS
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #define VARYINGS_NEED_SHADOW_COORD
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_FORWARD
        #define _FOG_FRAGMENT 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 tangentWS;
             float4 texCoord0;
             float3 viewDirectionWS;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh;
            #endif
             float4 fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpaceNormal;
             float3 TangentSpaceNormal;
             float3 WorldSpaceTangent;
             float3 WorldSpaceBiTangent;
             float3 WorldSpacePosition;
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float3 interp1 : INTERP1;
             float4 interp2 : INTERP2;
             float4 interp3 : INTERP3;
             float3 interp4 : INTERP4;
             float2 interp5 : INTERP5;
             float2 interp6 : INTERP6;
             float3 interp7 : INTERP7;
             float4 interp8 : INTERP8;
             float4 interp9 : INTERP9;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            output.interp3.xyzw =  input.texCoord0;
            output.interp4.xyz =  input.viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            output.interp5.xy =  input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.interp6.xy =  input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.interp7.xyz =  input.sh;
            #endif
            output.interp8.xyzw =  input.fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.interp9.xyzw =  input.shadowCoord;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            output.texCoord0 = input.interp3.xyzw;
            output.viewDirectionWS = input.interp4.xyz;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.interp5.xy;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.interp6.xy;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.interp7.xyz;
            #endif
            output.fogFactorAndVertexLight = input.interp8.xyzw;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.interp9.xyzw;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _TopAlbedo_TexelSize;
        float4 _TopNormal_TexelSize;
        float4 _TopMetallicRough_TexelSize;
        float _TopMetallic;
        float _TopGlossiness;
        float4 _Noise_TexelSize;
        float4 _MainTex_TexelSize;
        float4 _BumpMap_TexelSize;
        float4 _DetailBump_TexelSize;
        float _DetailScale;
        float4 _OcclusionMap_TexelSize;
        float4 _MetallicRough_TexelSize;
        float _Metallic;
        float _Glossiness;
        float _OcclusionStrength;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_TopAlbedo);
        SAMPLER(sampler_TopAlbedo);
        TEXTURE2D(_TopNormal);
        SAMPLER(sampler_TopNormal);
        TEXTURE2D(_TopMetallicRough);
        SAMPLER(sampler_TopMetallicRough);
        TEXTURE2D(_Noise);
        SAMPLER(sampler_Noise);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        TEXTURE2D(_BumpMap);
        SAMPLER(sampler_BumpMap);
        TEXTURE2D(_DetailBump);
        SAMPLER(sampler_DetailBump);
        TEXTURE2D(_OcclusionMap);
        SAMPLER(sampler_OcclusionMap);
        TEXTURE2D(_MetallicRough);
        SAMPLER(sampler_MetallicRough);
        float _TopScale;
        float _noiseScale;
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_NormalUnpack_float(float4 In, out float3 Out)
        {
                        Out = UnpackNormal(In);
                    }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void blend_rnm_float(float3 n1, float3 n2, out float3 Out){
            n1.z += 1;
            
            n2.xy = -n2.xy;
            
            Out = n1 * dot(n1, n2) / n1.z - n2;
        }
        
        void Unity_Absolute_float3(float3 In, out float3 Out)
        {
            Out = abs(In);
        }
        
        void Unity_Lerp_float3(float3 A, float3 B, float3 T, out float3 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Lerp_float(float A, float B, float T, out float Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Blend_Overlay_float(float Base, float Blend, out float Out, float Opacity)
        {
            float result1 = 1.0 - 2.0 * (1.0 - Base) * (1.0 - Blend);
            float result2 = 2.0 * Base * Blend;
            float zeroOrOne = step(Base, 0.5);
            Out = result2 * zeroOrOne + (1 - zeroOrOne) * result1;
            Out = lerp(Base, Out, Opacity);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 NormalTS;
            float3 Emission;
            float Metallic;
            float Smoothness;
            float Occlusion;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_43c517f37e4644129a3c62f9b44c4cc3_Out_0 = UnityBuildTexture2DStructNoScale(_MainTex);
            float4 _SampleTexture2D_39cbc473170e41df85ee0f0a83ef6576_RGBA_0 = SAMPLE_TEXTURE2D(_Property_43c517f37e4644129a3c62f9b44c4cc3_Out_0.tex, _Property_43c517f37e4644129a3c62f9b44c4cc3_Out_0.samplerstate, _Property_43c517f37e4644129a3c62f9b44c4cc3_Out_0.GetTransformedUV(IN.uv0.xy));
            float _SampleTexture2D_39cbc473170e41df85ee0f0a83ef6576_R_4 = _SampleTexture2D_39cbc473170e41df85ee0f0a83ef6576_RGBA_0.r;
            float _SampleTexture2D_39cbc473170e41df85ee0f0a83ef6576_G_5 = _SampleTexture2D_39cbc473170e41df85ee0f0a83ef6576_RGBA_0.g;
            float _SampleTexture2D_39cbc473170e41df85ee0f0a83ef6576_B_6 = _SampleTexture2D_39cbc473170e41df85ee0f0a83ef6576_RGBA_0.b;
            float _SampleTexture2D_39cbc473170e41df85ee0f0a83ef6576_A_7 = _SampleTexture2D_39cbc473170e41df85ee0f0a83ef6576_RGBA_0.a;
            UnityTexture2D _Property_e25deacfb3324ff694a822d7d2782220_Out_0 = UnityBuildTexture2DStructNoScale(_TopAlbedo);
            float _Split_73415ceb64e243dd9b6cdbed882c419e_R_1 = IN.WorldSpacePosition[0];
            float _Split_73415ceb64e243dd9b6cdbed882c419e_G_2 = IN.WorldSpacePosition[1];
            float _Split_73415ceb64e243dd9b6cdbed882c419e_B_3 = IN.WorldSpacePosition[2];
            float _Split_73415ceb64e243dd9b6cdbed882c419e_A_4 = 0;
            float2 _Vector2_5f4c26f1391b4632bf69806499d07368_Out_0 = float2(_Split_73415ceb64e243dd9b6cdbed882c419e_R_1, _Split_73415ceb64e243dd9b6cdbed882c419e_B_3);
            float _Property_4cc655dc7833446f8e8423a5be711b34_Out_0 = _TopScale;
            float2 _Multiply_15222a5e1788439f9cea4567369a72d5_Out_2;
            Unity_Multiply_float2_float2(_Vector2_5f4c26f1391b4632bf69806499d07368_Out_0, (_Property_4cc655dc7833446f8e8423a5be711b34_Out_0.xx), _Multiply_15222a5e1788439f9cea4567369a72d5_Out_2);
            float4 _SampleTexture2D_a48fb84304c3411f9709cd397fa3863a_RGBA_0 = SAMPLE_TEXTURE2D(_Property_e25deacfb3324ff694a822d7d2782220_Out_0.tex, _Property_e25deacfb3324ff694a822d7d2782220_Out_0.samplerstate, _Property_e25deacfb3324ff694a822d7d2782220_Out_0.GetTransformedUV(_Multiply_15222a5e1788439f9cea4567369a72d5_Out_2));
            float _SampleTexture2D_a48fb84304c3411f9709cd397fa3863a_R_4 = _SampleTexture2D_a48fb84304c3411f9709cd397fa3863a_RGBA_0.r;
            float _SampleTexture2D_a48fb84304c3411f9709cd397fa3863a_G_5 = _SampleTexture2D_a48fb84304c3411f9709cd397fa3863a_RGBA_0.g;
            float _SampleTexture2D_a48fb84304c3411f9709cd397fa3863a_B_6 = _SampleTexture2D_a48fb84304c3411f9709cd397fa3863a_RGBA_0.b;
            float _SampleTexture2D_a48fb84304c3411f9709cd397fa3863a_A_7 = _SampleTexture2D_a48fb84304c3411f9709cd397fa3863a_RGBA_0.a;
            UnityTexture2D _Property_4bdc709e69274a8abd70923126c48288_Out_0 = UnityBuildTexture2DStructNoScale(_Noise);
            float _Property_6b0c37a327bd4d6cb692e37ecd028405_Out_0 = _noiseScale;
            float2 _Multiply_fe25618f7cdf431e8c9baf94f854e2fe_Out_2;
            Unity_Multiply_float2_float2(_Multiply_15222a5e1788439f9cea4567369a72d5_Out_2, (_Property_6b0c37a327bd4d6cb692e37ecd028405_Out_0.xx), _Multiply_fe25618f7cdf431e8c9baf94f854e2fe_Out_2);
            float4 _SampleTexture2D_635f4dc215c440f8b6eec0882db2d3aa_RGBA_0 = SAMPLE_TEXTURE2D(_Property_4bdc709e69274a8abd70923126c48288_Out_0.tex, _Property_4bdc709e69274a8abd70923126c48288_Out_0.samplerstate, _Property_4bdc709e69274a8abd70923126c48288_Out_0.GetTransformedUV(_Multiply_fe25618f7cdf431e8c9baf94f854e2fe_Out_2));
            float _SampleTexture2D_635f4dc215c440f8b6eec0882db2d3aa_R_4 = _SampleTexture2D_635f4dc215c440f8b6eec0882db2d3aa_RGBA_0.r;
            float _SampleTexture2D_635f4dc215c440f8b6eec0882db2d3aa_G_5 = _SampleTexture2D_635f4dc215c440f8b6eec0882db2d3aa_RGBA_0.g;
            float _SampleTexture2D_635f4dc215c440f8b6eec0882db2d3aa_B_6 = _SampleTexture2D_635f4dc215c440f8b6eec0882db2d3aa_RGBA_0.b;
            float _SampleTexture2D_635f4dc215c440f8b6eec0882db2d3aa_A_7 = _SampleTexture2D_635f4dc215c440f8b6eec0882db2d3aa_RGBA_0.a;
            float _Split_2fa854d8373b43319e3815f773f182a3_R_1 = IN.WorldSpaceNormal[0];
            float _Split_2fa854d8373b43319e3815f773f182a3_G_2 = IN.WorldSpaceNormal[1];
            float _Split_2fa854d8373b43319e3815f773f182a3_B_3 = IN.WorldSpaceNormal[2];
            float _Split_2fa854d8373b43319e3815f773f182a3_A_4 = 0;
            float _Clamp_8d87bc8399b744c8b4ded4378bcce6e2_Out_3;
            Unity_Clamp_float(_Split_2fa854d8373b43319e3815f773f182a3_G_2, 0, 1, _Clamp_8d87bc8399b744c8b4ded4378bcce6e2_Out_3);
            float _Smoothstep_8d527e2955cd4ea99e6c0611c3827735_Out_3;
            Unity_Smoothstep_float(_SampleTexture2D_635f4dc215c440f8b6eec0882db2d3aa_R_4, 1, _Clamp_8d87bc8399b744c8b4ded4378bcce6e2_Out_3, _Smoothstep_8d527e2955cd4ea99e6c0611c3827735_Out_3);
            float _Smoothstep_87f8055d79104aeab092ae8a9aa36fea_Out_3;
            Unity_Smoothstep_float(0.1, 0.2, _Smoothstep_8d527e2955cd4ea99e6c0611c3827735_Out_3, _Smoothstep_87f8055d79104aeab092ae8a9aa36fea_Out_3);
            float4 _Lerp_45fd290440944ec2a7bed0c07e3c9b69_Out_3;
            Unity_Lerp_float4(_SampleTexture2D_39cbc473170e41df85ee0f0a83ef6576_RGBA_0, _SampleTexture2D_a48fb84304c3411f9709cd397fa3863a_RGBA_0, (_Smoothstep_87f8055d79104aeab092ae8a9aa36fea_Out_3.xxxx), _Lerp_45fd290440944ec2a7bed0c07e3c9b69_Out_3);
            UnityTexture2D _Property_a27ac9c53e69461a82c212b5187b0104_Out_0 = UnityBuildTexture2DStructNoScale(_BumpMap);
            float4 _SampleTexture2D_943cec569c7b4a03895335215ba3311f_RGBA_0 = SAMPLE_TEXTURE2D(_Property_a27ac9c53e69461a82c212b5187b0104_Out_0.tex, _Property_a27ac9c53e69461a82c212b5187b0104_Out_0.samplerstate, _Property_a27ac9c53e69461a82c212b5187b0104_Out_0.GetTransformedUV(IN.uv0.xy));
            float _SampleTexture2D_943cec569c7b4a03895335215ba3311f_R_4 = _SampleTexture2D_943cec569c7b4a03895335215ba3311f_RGBA_0.r;
            float _SampleTexture2D_943cec569c7b4a03895335215ba3311f_G_5 = _SampleTexture2D_943cec569c7b4a03895335215ba3311f_RGBA_0.g;
            float _SampleTexture2D_943cec569c7b4a03895335215ba3311f_B_6 = _SampleTexture2D_943cec569c7b4a03895335215ba3311f_RGBA_0.b;
            float _SampleTexture2D_943cec569c7b4a03895335215ba3311f_A_7 = _SampleTexture2D_943cec569c7b4a03895335215ba3311f_RGBA_0.a;
            float3 _NormalUnpack_901dd2e193ba41e59ca415ff2571b164_Out_1;
            Unity_NormalUnpack_float(_SampleTexture2D_943cec569c7b4a03895335215ba3311f_RGBA_0, _NormalUnpack_901dd2e193ba41e59ca415ff2571b164_Out_1);
            UnityTexture2D _Property_dc790173492f4c8dae6b8e9b6a9b4a46_Out_0 = UnityBuildTexture2DStructNoScale(_DetailBump);
            float4 _UV_133bb460e44d444c993cc22603aa6b6c_Out_0 = IN.uv0;
            float _Property_795999a212424e2d898087c63cf42c6a_Out_0 = _DetailScale;
            float4 _Multiply_cc4f87f5571d405ab75fe99748a2a6b5_Out_2;
            Unity_Multiply_float4_float4(_UV_133bb460e44d444c993cc22603aa6b6c_Out_0, (_Property_795999a212424e2d898087c63cf42c6a_Out_0.xxxx), _Multiply_cc4f87f5571d405ab75fe99748a2a6b5_Out_2);
            float4 _SampleTexture2D_4149636f70a648d194cfb2f4bc674e1b_RGBA_0 = SAMPLE_TEXTURE2D(_Property_dc790173492f4c8dae6b8e9b6a9b4a46_Out_0.tex, _Property_dc790173492f4c8dae6b8e9b6a9b4a46_Out_0.samplerstate, _Property_dc790173492f4c8dae6b8e9b6a9b4a46_Out_0.GetTransformedUV((_Multiply_cc4f87f5571d405ab75fe99748a2a6b5_Out_2.xy)));
            float _SampleTexture2D_4149636f70a648d194cfb2f4bc674e1b_R_4 = _SampleTexture2D_4149636f70a648d194cfb2f4bc674e1b_RGBA_0.r;
            float _SampleTexture2D_4149636f70a648d194cfb2f4bc674e1b_G_5 = _SampleTexture2D_4149636f70a648d194cfb2f4bc674e1b_RGBA_0.g;
            float _SampleTexture2D_4149636f70a648d194cfb2f4bc674e1b_B_6 = _SampleTexture2D_4149636f70a648d194cfb2f4bc674e1b_RGBA_0.b;
            float _SampleTexture2D_4149636f70a648d194cfb2f4bc674e1b_A_7 = _SampleTexture2D_4149636f70a648d194cfb2f4bc674e1b_RGBA_0.a;
            float3 _NormalUnpack_9f89177866b84dda99b829ef9bb74c7d_Out_1;
            Unity_NormalUnpack_float(_SampleTexture2D_4149636f70a648d194cfb2f4bc674e1b_RGBA_0, _NormalUnpack_9f89177866b84dda99b829ef9bb74c7d_Out_1);
            float3 _blendrnmCustomFunction_80ece8cf7f4f4658b304ac674b395bf3_Out_2;
            blend_rnm_float(_NormalUnpack_901dd2e193ba41e59ca415ff2571b164_Out_1, _NormalUnpack_9f89177866b84dda99b829ef9bb74c7d_Out_1, _blendrnmCustomFunction_80ece8cf7f4f4658b304ac674b395bf3_Out_2);
            float _Split_1c9b34a4135b4b309f09c88a8130b0fb_R_1 = IN.WorldSpaceNormal[0];
            float _Split_1c9b34a4135b4b309f09c88a8130b0fb_G_2 = IN.WorldSpaceNormal[1];
            float _Split_1c9b34a4135b4b309f09c88a8130b0fb_B_3 = IN.WorldSpaceNormal[2];
            float _Split_1c9b34a4135b4b309f09c88a8130b0fb_A_4 = 0;
            float3 _Absolute_faa09bddaa9b4a9a9695fc00c1fdd222_Out_1;
            Unity_Absolute_float3(IN.WorldSpaceNormal, _Absolute_faa09bddaa9b4a9a9695fc00c1fdd222_Out_1);
            float3 _Vector3_45a95e02f7e44117b8b512938753a000_Out_0 = float3(_Split_1c9b34a4135b4b309f09c88a8130b0fb_R_1, _Split_1c9b34a4135b4b309f09c88a8130b0fb_B_3, (_Absolute_faa09bddaa9b4a9a9695fc00c1fdd222_Out_1).x);
            UnityTexture2D _Property_7d1394ed1b0245d39df9cf3d018c7b08_Out_0 = UnityBuildTexture2DStructNoScale(_TopNormal);
            float4 _SampleTexture2D_dac00903c04645979af2a2f7b1ccdd74_RGBA_0 = SAMPLE_TEXTURE2D(_Property_7d1394ed1b0245d39df9cf3d018c7b08_Out_0.tex, _Property_7d1394ed1b0245d39df9cf3d018c7b08_Out_0.samplerstate, _Property_7d1394ed1b0245d39df9cf3d018c7b08_Out_0.GetTransformedUV(_Multiply_15222a5e1788439f9cea4567369a72d5_Out_2));
            float _SampleTexture2D_dac00903c04645979af2a2f7b1ccdd74_R_4 = _SampleTexture2D_dac00903c04645979af2a2f7b1ccdd74_RGBA_0.r;
            float _SampleTexture2D_dac00903c04645979af2a2f7b1ccdd74_G_5 = _SampleTexture2D_dac00903c04645979af2a2f7b1ccdd74_RGBA_0.g;
            float _SampleTexture2D_dac00903c04645979af2a2f7b1ccdd74_B_6 = _SampleTexture2D_dac00903c04645979af2a2f7b1ccdd74_RGBA_0.b;
            float _SampleTexture2D_dac00903c04645979af2a2f7b1ccdd74_A_7 = _SampleTexture2D_dac00903c04645979af2a2f7b1ccdd74_RGBA_0.a;
            float3 _NormalUnpack_b99686ccbda846ccb4d56a24d0c50799_Out_1;
            Unity_NormalUnpack_float(_SampleTexture2D_dac00903c04645979af2a2f7b1ccdd74_RGBA_0, _NormalUnpack_b99686ccbda846ccb4d56a24d0c50799_Out_1);
            float3 _blendrnmCustomFunction_34849db80d0e42ba94ed4cbabdc3add6_Out_2;
            blend_rnm_float(_Vector3_45a95e02f7e44117b8b512938753a000_Out_0, _NormalUnpack_b99686ccbda846ccb4d56a24d0c50799_Out_1, _blendrnmCustomFunction_34849db80d0e42ba94ed4cbabdc3add6_Out_2);
            float3x3 Transform_85dc59b8e1f4427abd83c0afa7f15262_tangentTransform_World = float3x3(IN.WorldSpaceTangent, IN.WorldSpaceBiTangent, IN.WorldSpaceNormal);
            float3 _Transform_85dc59b8e1f4427abd83c0afa7f15262_Out_1 = TransformWorldToTangent(_blendrnmCustomFunction_34849db80d0e42ba94ed4cbabdc3add6_Out_2.xyz, Transform_85dc59b8e1f4427abd83c0afa7f15262_tangentTransform_World);
            float3 _Lerp_c9a656bec6d446fc9281cf65211c19e5_Out_3;
            Unity_Lerp_float3(_blendrnmCustomFunction_80ece8cf7f4f4658b304ac674b395bf3_Out_2, _Transform_85dc59b8e1f4427abd83c0afa7f15262_Out_1, (_Smoothstep_87f8055d79104aeab092ae8a9aa36fea_Out_3.xxx), _Lerp_c9a656bec6d446fc9281cf65211c19e5_Out_3);
            UnityTexture2D _Property_adeae3eb29db4484aacd0df533beeb84_Out_0 = UnityBuildTexture2DStructNoScale(_MetallicRough);
            float4 _SampleTexture2D_90d08b6dea154ba086a89e9c4fa90889_RGBA_0 = SAMPLE_TEXTURE2D(_Property_adeae3eb29db4484aacd0df533beeb84_Out_0.tex, _Property_adeae3eb29db4484aacd0df533beeb84_Out_0.samplerstate, _Property_adeae3eb29db4484aacd0df533beeb84_Out_0.GetTransformedUV(IN.uv0.xy));
            float _SampleTexture2D_90d08b6dea154ba086a89e9c4fa90889_R_4 = _SampleTexture2D_90d08b6dea154ba086a89e9c4fa90889_RGBA_0.r;
            float _SampleTexture2D_90d08b6dea154ba086a89e9c4fa90889_G_5 = _SampleTexture2D_90d08b6dea154ba086a89e9c4fa90889_RGBA_0.g;
            float _SampleTexture2D_90d08b6dea154ba086a89e9c4fa90889_B_6 = _SampleTexture2D_90d08b6dea154ba086a89e9c4fa90889_RGBA_0.b;
            float _SampleTexture2D_90d08b6dea154ba086a89e9c4fa90889_A_7 = _SampleTexture2D_90d08b6dea154ba086a89e9c4fa90889_RGBA_0.a;
            float _Property_a455d08c3216492788a35af588e7d59c_Out_0 = _Metallic;
            float _Multiply_be21cf394ee14c70883f2664ceadfa1e_Out_2;
            Unity_Multiply_float_float(_SampleTexture2D_90d08b6dea154ba086a89e9c4fa90889_R_4, _Property_a455d08c3216492788a35af588e7d59c_Out_0, _Multiply_be21cf394ee14c70883f2664ceadfa1e_Out_2);
            float _Property_75c543340504427c915199ab104372ff_Out_0 = _TopMetallic;
            float _Multiply_c5c4fb340ac44cb2a01710361efeba15_Out_2;
            Unity_Multiply_float_float(_SampleTexture2D_635f4dc215c440f8b6eec0882db2d3aa_R_4, _Property_75c543340504427c915199ab104372ff_Out_0, _Multiply_c5c4fb340ac44cb2a01710361efeba15_Out_2);
            float _Lerp_b4930116db9040b5bb31c1df912919d1_Out_3;
            Unity_Lerp_float(_Multiply_be21cf394ee14c70883f2664ceadfa1e_Out_2, _Multiply_c5c4fb340ac44cb2a01710361efeba15_Out_2, _Smoothstep_87f8055d79104aeab092ae8a9aa36fea_Out_3, _Lerp_b4930116db9040b5bb31c1df912919d1_Out_3);
            float _Property_e33fdaf769234c808d8b15a4d4c37cfa_Out_0 = _Glossiness;
            float _Multiply_ff4016ca0c924f7ba52435684ab9062e_Out_2;
            Unity_Multiply_float_float(_SampleTexture2D_90d08b6dea154ba086a89e9c4fa90889_A_7, _Property_e33fdaf769234c808d8b15a4d4c37cfa_Out_0, _Multiply_ff4016ca0c924f7ba52435684ab9062e_Out_2);
            UnityTexture2D _Property_81de6ddbfe474f97a08cf1e76917e9c5_Out_0 = UnityBuildTexture2DStructNoScale(_TopMetallicRough);
            float4 _SampleTexture2D_4256ce8787af4f87b77f164fea21fe56_RGBA_0 = SAMPLE_TEXTURE2D(_Property_81de6ddbfe474f97a08cf1e76917e9c5_Out_0.tex, _Property_81de6ddbfe474f97a08cf1e76917e9c5_Out_0.samplerstate, _Property_81de6ddbfe474f97a08cf1e76917e9c5_Out_0.GetTransformedUV(IN.uv0.xy));
            float _SampleTexture2D_4256ce8787af4f87b77f164fea21fe56_R_4 = _SampleTexture2D_4256ce8787af4f87b77f164fea21fe56_RGBA_0.r;
            float _SampleTexture2D_4256ce8787af4f87b77f164fea21fe56_G_5 = _SampleTexture2D_4256ce8787af4f87b77f164fea21fe56_RGBA_0.g;
            float _SampleTexture2D_4256ce8787af4f87b77f164fea21fe56_B_6 = _SampleTexture2D_4256ce8787af4f87b77f164fea21fe56_RGBA_0.b;
            float _SampleTexture2D_4256ce8787af4f87b77f164fea21fe56_A_7 = _SampleTexture2D_4256ce8787af4f87b77f164fea21fe56_RGBA_0.a;
            float _Property_2fb63e5a04854cc287bd40e62e8a065d_Out_0 = _TopGlossiness;
            float _Multiply_06baa96b04654f0698dac0b4c0e005d8_Out_2;
            Unity_Multiply_float_float(_SampleTexture2D_4256ce8787af4f87b77f164fea21fe56_A_7, _Property_2fb63e5a04854cc287bd40e62e8a065d_Out_0, _Multiply_06baa96b04654f0698dac0b4c0e005d8_Out_2);
            float _Blend_8594f3141c25440b8a89512b16231a9f_Out_2;
            Unity_Blend_Overlay_float(_Multiply_ff4016ca0c924f7ba52435684ab9062e_Out_2, _Multiply_06baa96b04654f0698dac0b4c0e005d8_Out_2, _Blend_8594f3141c25440b8a89512b16231a9f_Out_2, _Smoothstep_87f8055d79104aeab092ae8a9aa36fea_Out_3);
            UnityTexture2D _Property_b0ef4fae6d054745adbbddb7b2a40bf1_Out_0 = UnityBuildTexture2DStructNoScale(_OcclusionMap);
            float4 _SampleTexture2D_9e10038709b147ef8dfc91ee1f818f38_RGBA_0 = SAMPLE_TEXTURE2D(_Property_b0ef4fae6d054745adbbddb7b2a40bf1_Out_0.tex, _Property_b0ef4fae6d054745adbbddb7b2a40bf1_Out_0.samplerstate, _Property_b0ef4fae6d054745adbbddb7b2a40bf1_Out_0.GetTransformedUV(IN.uv0.xy));
            float _SampleTexture2D_9e10038709b147ef8dfc91ee1f818f38_R_4 = _SampleTexture2D_9e10038709b147ef8dfc91ee1f818f38_RGBA_0.r;
            float _SampleTexture2D_9e10038709b147ef8dfc91ee1f818f38_G_5 = _SampleTexture2D_9e10038709b147ef8dfc91ee1f818f38_RGBA_0.g;
            float _SampleTexture2D_9e10038709b147ef8dfc91ee1f818f38_B_6 = _SampleTexture2D_9e10038709b147ef8dfc91ee1f818f38_RGBA_0.b;
            float _SampleTexture2D_9e10038709b147ef8dfc91ee1f818f38_A_7 = _SampleTexture2D_9e10038709b147ef8dfc91ee1f818f38_RGBA_0.a;
            float _Property_73daf17ddc69480f84893ab863305ada_Out_0 = _OcclusionStrength;
            float _Lerp_89a62424edfb44fda4ab08c8cb63acb6_Out_3;
            Unity_Lerp_float(1, _SampleTexture2D_9e10038709b147ef8dfc91ee1f818f38_R_4, _Property_73daf17ddc69480f84893ab863305ada_Out_0, _Lerp_89a62424edfb44fda4ab08c8cb63acb6_Out_3);
            surface.BaseColor = (_Lerp_45fd290440944ec2a7bed0c07e3c9b69_Out_3.xyz);
            surface.NormalTS = _Lerp_c9a656bec6d446fc9281cf65211c19e5_Out_3;
            surface.Emission = float3(0, 0, 0);
            surface.Metallic = _Lerp_b4930116db9040b5bb31c1df912919d1_Out_3;
            surface.Smoothness = _Blend_8594f3141c25440b8a89512b16231a9f_Out_2;
            surface.Occlusion = _Lerp_89a62424edfb44fda4ab08c8cb63acb6_Out_3;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
            
        
            // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
            float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);
        
            // use bitangent on the fly like in hdrp
            // IMPORTANT! If we ever support Flip on double sided materials ensure bitangent and tangent are NOT flipped.
            float crossSign = (input.tangentWS.w > 0.0 ? 1.0 : -1.0)* GetOddNegativeScale();
            float3 bitang = crossSign * cross(input.normalWS.xyz, input.tangentWS.xyz);
        
            output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
            // to pr               eserve mikktspace compliance we use same scale renormFactor as was used on the normal.
            // This                is explained in section 2.2 in "surface gradient based bump mapping framework"
            output.WorldSpaceTangent = renormFactor * input.tangentWS.xyz;
            output.WorldSpaceBiTangent = renormFactor * bitang;
        
            output.WorldSpacePosition = input.positionWS;
            output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"
        
        ENDHLSL
        }
        Pass
        {
            Name "GBuffer"
            Tags
            {
                "LightMode" = "UniversalGBuffer"
            }
        
        // Render State
        Cull Back
        Blend One Zero
        ZTest LEqual
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma instancing_options renderinglayer
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DYNAMICLIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
        #pragma multi_compile _ _REFLECTION_PROBE_BLENDING
        #pragma multi_compile _ _REFLECTION_PROBE_BOX_PROJECTION
        #pragma multi_compile _ _SHADOWS_SOFT
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
        #pragma multi_compile _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        #pragma multi_compile _ _GBUFFER_NORMALS_OCT
        #pragma multi_compile _ _LIGHT_LAYERS
        #pragma multi_compile _ _RENDER_PASS_ENABLED
        #pragma multi_compile _ DEBUG_DISPLAY
        // GraphKeywords: <None>
        
        // Defines
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_VIEWDIRECTION_WS
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #define VARYINGS_NEED_SHADOW_COORD
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_GBUFFER
        #define _FOG_FRAGMENT 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 tangentWS;
             float4 texCoord0;
             float3 viewDirectionWS;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh;
            #endif
             float4 fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpaceNormal;
             float3 TangentSpaceNormal;
             float3 WorldSpaceTangent;
             float3 WorldSpaceBiTangent;
             float3 WorldSpacePosition;
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float3 interp1 : INTERP1;
             float4 interp2 : INTERP2;
             float4 interp3 : INTERP3;
             float3 interp4 : INTERP4;
             float2 interp5 : INTERP5;
             float2 interp6 : INTERP6;
             float3 interp7 : INTERP7;
             float4 interp8 : INTERP8;
             float4 interp9 : INTERP9;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            output.interp3.xyzw =  input.texCoord0;
            output.interp4.xyz =  input.viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            output.interp5.xy =  input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.interp6.xy =  input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.interp7.xyz =  input.sh;
            #endif
            output.interp8.xyzw =  input.fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.interp9.xyzw =  input.shadowCoord;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            output.texCoord0 = input.interp3.xyzw;
            output.viewDirectionWS = input.interp4.xyz;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.interp5.xy;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.interp6.xy;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.interp7.xyz;
            #endif
            output.fogFactorAndVertexLight = input.interp8.xyzw;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.interp9.xyzw;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _TopAlbedo_TexelSize;
        float4 _TopNormal_TexelSize;
        float4 _TopMetallicRough_TexelSize;
        float _TopMetallic;
        float _TopGlossiness;
        float4 _Noise_TexelSize;
        float4 _MainTex_TexelSize;
        float4 _BumpMap_TexelSize;
        float4 _DetailBump_TexelSize;
        float _DetailScale;
        float4 _OcclusionMap_TexelSize;
        float4 _MetallicRough_TexelSize;
        float _Metallic;
        float _Glossiness;
        float _OcclusionStrength;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_TopAlbedo);
        SAMPLER(sampler_TopAlbedo);
        TEXTURE2D(_TopNormal);
        SAMPLER(sampler_TopNormal);
        TEXTURE2D(_TopMetallicRough);
        SAMPLER(sampler_TopMetallicRough);
        TEXTURE2D(_Noise);
        SAMPLER(sampler_Noise);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        TEXTURE2D(_BumpMap);
        SAMPLER(sampler_BumpMap);
        TEXTURE2D(_DetailBump);
        SAMPLER(sampler_DetailBump);
        TEXTURE2D(_OcclusionMap);
        SAMPLER(sampler_OcclusionMap);
        TEXTURE2D(_MetallicRough);
        SAMPLER(sampler_MetallicRough);
        float _TopScale;
        float _noiseScale;
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_NormalUnpack_float(float4 In, out float3 Out)
        {
                        Out = UnpackNormal(In);
                    }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void blend_rnm_float(float3 n1, float3 n2, out float3 Out){
            n1.z += 1;
            
            n2.xy = -n2.xy;
            
            Out = n1 * dot(n1, n2) / n1.z - n2;
        }
        
        void Unity_Absolute_float3(float3 In, out float3 Out)
        {
            Out = abs(In);
        }
        
        void Unity_Lerp_float3(float3 A, float3 B, float3 T, out float3 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Lerp_float(float A, float B, float T, out float Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Blend_Overlay_float(float Base, float Blend, out float Out, float Opacity)
        {
            float result1 = 1.0 - 2.0 * (1.0 - Base) * (1.0 - Blend);
            float result2 = 2.0 * Base * Blend;
            float zeroOrOne = step(Base, 0.5);
            Out = result2 * zeroOrOne + (1 - zeroOrOne) * result1;
            Out = lerp(Base, Out, Opacity);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 NormalTS;
            float3 Emission;
            float Metallic;
            float Smoothness;
            float Occlusion;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_43c517f37e4644129a3c62f9b44c4cc3_Out_0 = UnityBuildTexture2DStructNoScale(_MainTex);
            float4 _SampleTexture2D_39cbc473170e41df85ee0f0a83ef6576_RGBA_0 = SAMPLE_TEXTURE2D(_Property_43c517f37e4644129a3c62f9b44c4cc3_Out_0.tex, _Property_43c517f37e4644129a3c62f9b44c4cc3_Out_0.samplerstate, _Property_43c517f37e4644129a3c62f9b44c4cc3_Out_0.GetTransformedUV(IN.uv0.xy));
            float _SampleTexture2D_39cbc473170e41df85ee0f0a83ef6576_R_4 = _SampleTexture2D_39cbc473170e41df85ee0f0a83ef6576_RGBA_0.r;
            float _SampleTexture2D_39cbc473170e41df85ee0f0a83ef6576_G_5 = _SampleTexture2D_39cbc473170e41df85ee0f0a83ef6576_RGBA_0.g;
            float _SampleTexture2D_39cbc473170e41df85ee0f0a83ef6576_B_6 = _SampleTexture2D_39cbc473170e41df85ee0f0a83ef6576_RGBA_0.b;
            float _SampleTexture2D_39cbc473170e41df85ee0f0a83ef6576_A_7 = _SampleTexture2D_39cbc473170e41df85ee0f0a83ef6576_RGBA_0.a;
            UnityTexture2D _Property_e25deacfb3324ff694a822d7d2782220_Out_0 = UnityBuildTexture2DStructNoScale(_TopAlbedo);
            float _Split_73415ceb64e243dd9b6cdbed882c419e_R_1 = IN.WorldSpacePosition[0];
            float _Split_73415ceb64e243dd9b6cdbed882c419e_G_2 = IN.WorldSpacePosition[1];
            float _Split_73415ceb64e243dd9b6cdbed882c419e_B_3 = IN.WorldSpacePosition[2];
            float _Split_73415ceb64e243dd9b6cdbed882c419e_A_4 = 0;
            float2 _Vector2_5f4c26f1391b4632bf69806499d07368_Out_0 = float2(_Split_73415ceb64e243dd9b6cdbed882c419e_R_1, _Split_73415ceb64e243dd9b6cdbed882c419e_B_3);
            float _Property_4cc655dc7833446f8e8423a5be711b34_Out_0 = _TopScale;
            float2 _Multiply_15222a5e1788439f9cea4567369a72d5_Out_2;
            Unity_Multiply_float2_float2(_Vector2_5f4c26f1391b4632bf69806499d07368_Out_0, (_Property_4cc655dc7833446f8e8423a5be711b34_Out_0.xx), _Multiply_15222a5e1788439f9cea4567369a72d5_Out_2);
            float4 _SampleTexture2D_a48fb84304c3411f9709cd397fa3863a_RGBA_0 = SAMPLE_TEXTURE2D(_Property_e25deacfb3324ff694a822d7d2782220_Out_0.tex, _Property_e25deacfb3324ff694a822d7d2782220_Out_0.samplerstate, _Property_e25deacfb3324ff694a822d7d2782220_Out_0.GetTransformedUV(_Multiply_15222a5e1788439f9cea4567369a72d5_Out_2));
            float _SampleTexture2D_a48fb84304c3411f9709cd397fa3863a_R_4 = _SampleTexture2D_a48fb84304c3411f9709cd397fa3863a_RGBA_0.r;
            float _SampleTexture2D_a48fb84304c3411f9709cd397fa3863a_G_5 = _SampleTexture2D_a48fb84304c3411f9709cd397fa3863a_RGBA_0.g;
            float _SampleTexture2D_a48fb84304c3411f9709cd397fa3863a_B_6 = _SampleTexture2D_a48fb84304c3411f9709cd397fa3863a_RGBA_0.b;
            float _SampleTexture2D_a48fb84304c3411f9709cd397fa3863a_A_7 = _SampleTexture2D_a48fb84304c3411f9709cd397fa3863a_RGBA_0.a;
            UnityTexture2D _Property_4bdc709e69274a8abd70923126c48288_Out_0 = UnityBuildTexture2DStructNoScale(_Noise);
            float _Property_6b0c37a327bd4d6cb692e37ecd028405_Out_0 = _noiseScale;
            float2 _Multiply_fe25618f7cdf431e8c9baf94f854e2fe_Out_2;
            Unity_Multiply_float2_float2(_Multiply_15222a5e1788439f9cea4567369a72d5_Out_2, (_Property_6b0c37a327bd4d6cb692e37ecd028405_Out_0.xx), _Multiply_fe25618f7cdf431e8c9baf94f854e2fe_Out_2);
            float4 _SampleTexture2D_635f4dc215c440f8b6eec0882db2d3aa_RGBA_0 = SAMPLE_TEXTURE2D(_Property_4bdc709e69274a8abd70923126c48288_Out_0.tex, _Property_4bdc709e69274a8abd70923126c48288_Out_0.samplerstate, _Property_4bdc709e69274a8abd70923126c48288_Out_0.GetTransformedUV(_Multiply_fe25618f7cdf431e8c9baf94f854e2fe_Out_2));
            float _SampleTexture2D_635f4dc215c440f8b6eec0882db2d3aa_R_4 = _SampleTexture2D_635f4dc215c440f8b6eec0882db2d3aa_RGBA_0.r;
            float _SampleTexture2D_635f4dc215c440f8b6eec0882db2d3aa_G_5 = _SampleTexture2D_635f4dc215c440f8b6eec0882db2d3aa_RGBA_0.g;
            float _SampleTexture2D_635f4dc215c440f8b6eec0882db2d3aa_B_6 = _SampleTexture2D_635f4dc215c440f8b6eec0882db2d3aa_RGBA_0.b;
            float _SampleTexture2D_635f4dc215c440f8b6eec0882db2d3aa_A_7 = _SampleTexture2D_635f4dc215c440f8b6eec0882db2d3aa_RGBA_0.a;
            float _Split_2fa854d8373b43319e3815f773f182a3_R_1 = IN.WorldSpaceNormal[0];
            float _Split_2fa854d8373b43319e3815f773f182a3_G_2 = IN.WorldSpaceNormal[1];
            float _Split_2fa854d8373b43319e3815f773f182a3_B_3 = IN.WorldSpaceNormal[2];
            float _Split_2fa854d8373b43319e3815f773f182a3_A_4 = 0;
            float _Clamp_8d87bc8399b744c8b4ded4378bcce6e2_Out_3;
            Unity_Clamp_float(_Split_2fa854d8373b43319e3815f773f182a3_G_2, 0, 1, _Clamp_8d87bc8399b744c8b4ded4378bcce6e2_Out_3);
            float _Smoothstep_8d527e2955cd4ea99e6c0611c3827735_Out_3;
            Unity_Smoothstep_float(_SampleTexture2D_635f4dc215c440f8b6eec0882db2d3aa_R_4, 1, _Clamp_8d87bc8399b744c8b4ded4378bcce6e2_Out_3, _Smoothstep_8d527e2955cd4ea99e6c0611c3827735_Out_3);
            float _Smoothstep_87f8055d79104aeab092ae8a9aa36fea_Out_3;
            Unity_Smoothstep_float(0.1, 0.2, _Smoothstep_8d527e2955cd4ea99e6c0611c3827735_Out_3, _Smoothstep_87f8055d79104aeab092ae8a9aa36fea_Out_3);
            float4 _Lerp_45fd290440944ec2a7bed0c07e3c9b69_Out_3;
            Unity_Lerp_float4(_SampleTexture2D_39cbc473170e41df85ee0f0a83ef6576_RGBA_0, _SampleTexture2D_a48fb84304c3411f9709cd397fa3863a_RGBA_0, (_Smoothstep_87f8055d79104aeab092ae8a9aa36fea_Out_3.xxxx), _Lerp_45fd290440944ec2a7bed0c07e3c9b69_Out_3);
            UnityTexture2D _Property_a27ac9c53e69461a82c212b5187b0104_Out_0 = UnityBuildTexture2DStructNoScale(_BumpMap);
            float4 _SampleTexture2D_943cec569c7b4a03895335215ba3311f_RGBA_0 = SAMPLE_TEXTURE2D(_Property_a27ac9c53e69461a82c212b5187b0104_Out_0.tex, _Property_a27ac9c53e69461a82c212b5187b0104_Out_0.samplerstate, _Property_a27ac9c53e69461a82c212b5187b0104_Out_0.GetTransformedUV(IN.uv0.xy));
            float _SampleTexture2D_943cec569c7b4a03895335215ba3311f_R_4 = _SampleTexture2D_943cec569c7b4a03895335215ba3311f_RGBA_0.r;
            float _SampleTexture2D_943cec569c7b4a03895335215ba3311f_G_5 = _SampleTexture2D_943cec569c7b4a03895335215ba3311f_RGBA_0.g;
            float _SampleTexture2D_943cec569c7b4a03895335215ba3311f_B_6 = _SampleTexture2D_943cec569c7b4a03895335215ba3311f_RGBA_0.b;
            float _SampleTexture2D_943cec569c7b4a03895335215ba3311f_A_7 = _SampleTexture2D_943cec569c7b4a03895335215ba3311f_RGBA_0.a;
            float3 _NormalUnpack_901dd2e193ba41e59ca415ff2571b164_Out_1;
            Unity_NormalUnpack_float(_SampleTexture2D_943cec569c7b4a03895335215ba3311f_RGBA_0, _NormalUnpack_901dd2e193ba41e59ca415ff2571b164_Out_1);
            UnityTexture2D _Property_dc790173492f4c8dae6b8e9b6a9b4a46_Out_0 = UnityBuildTexture2DStructNoScale(_DetailBump);
            float4 _UV_133bb460e44d444c993cc22603aa6b6c_Out_0 = IN.uv0;
            float _Property_795999a212424e2d898087c63cf42c6a_Out_0 = _DetailScale;
            float4 _Multiply_cc4f87f5571d405ab75fe99748a2a6b5_Out_2;
            Unity_Multiply_float4_float4(_UV_133bb460e44d444c993cc22603aa6b6c_Out_0, (_Property_795999a212424e2d898087c63cf42c6a_Out_0.xxxx), _Multiply_cc4f87f5571d405ab75fe99748a2a6b5_Out_2);
            float4 _SampleTexture2D_4149636f70a648d194cfb2f4bc674e1b_RGBA_0 = SAMPLE_TEXTURE2D(_Property_dc790173492f4c8dae6b8e9b6a9b4a46_Out_0.tex, _Property_dc790173492f4c8dae6b8e9b6a9b4a46_Out_0.samplerstate, _Property_dc790173492f4c8dae6b8e9b6a9b4a46_Out_0.GetTransformedUV((_Multiply_cc4f87f5571d405ab75fe99748a2a6b5_Out_2.xy)));
            float _SampleTexture2D_4149636f70a648d194cfb2f4bc674e1b_R_4 = _SampleTexture2D_4149636f70a648d194cfb2f4bc674e1b_RGBA_0.r;
            float _SampleTexture2D_4149636f70a648d194cfb2f4bc674e1b_G_5 = _SampleTexture2D_4149636f70a648d194cfb2f4bc674e1b_RGBA_0.g;
            float _SampleTexture2D_4149636f70a648d194cfb2f4bc674e1b_B_6 = _SampleTexture2D_4149636f70a648d194cfb2f4bc674e1b_RGBA_0.b;
            float _SampleTexture2D_4149636f70a648d194cfb2f4bc674e1b_A_7 = _SampleTexture2D_4149636f70a648d194cfb2f4bc674e1b_RGBA_0.a;
            float3 _NormalUnpack_9f89177866b84dda99b829ef9bb74c7d_Out_1;
            Unity_NormalUnpack_float(_SampleTexture2D_4149636f70a648d194cfb2f4bc674e1b_RGBA_0, _NormalUnpack_9f89177866b84dda99b829ef9bb74c7d_Out_1);
            float3 _blendrnmCustomFunction_80ece8cf7f4f4658b304ac674b395bf3_Out_2;
            blend_rnm_float(_NormalUnpack_901dd2e193ba41e59ca415ff2571b164_Out_1, _NormalUnpack_9f89177866b84dda99b829ef9bb74c7d_Out_1, _blendrnmCustomFunction_80ece8cf7f4f4658b304ac674b395bf3_Out_2);
            float _Split_1c9b34a4135b4b309f09c88a8130b0fb_R_1 = IN.WorldSpaceNormal[0];
            float _Split_1c9b34a4135b4b309f09c88a8130b0fb_G_2 = IN.WorldSpaceNormal[1];
            float _Split_1c9b34a4135b4b309f09c88a8130b0fb_B_3 = IN.WorldSpaceNormal[2];
            float _Split_1c9b34a4135b4b309f09c88a8130b0fb_A_4 = 0;
            float3 _Absolute_faa09bddaa9b4a9a9695fc00c1fdd222_Out_1;
            Unity_Absolute_float3(IN.WorldSpaceNormal, _Absolute_faa09bddaa9b4a9a9695fc00c1fdd222_Out_1);
            float3 _Vector3_45a95e02f7e44117b8b512938753a000_Out_0 = float3(_Split_1c9b34a4135b4b309f09c88a8130b0fb_R_1, _Split_1c9b34a4135b4b309f09c88a8130b0fb_B_3, (_Absolute_faa09bddaa9b4a9a9695fc00c1fdd222_Out_1).x);
            UnityTexture2D _Property_7d1394ed1b0245d39df9cf3d018c7b08_Out_0 = UnityBuildTexture2DStructNoScale(_TopNormal);
            float4 _SampleTexture2D_dac00903c04645979af2a2f7b1ccdd74_RGBA_0 = SAMPLE_TEXTURE2D(_Property_7d1394ed1b0245d39df9cf3d018c7b08_Out_0.tex, _Property_7d1394ed1b0245d39df9cf3d018c7b08_Out_0.samplerstate, _Property_7d1394ed1b0245d39df9cf3d018c7b08_Out_0.GetTransformedUV(_Multiply_15222a5e1788439f9cea4567369a72d5_Out_2));
            float _SampleTexture2D_dac00903c04645979af2a2f7b1ccdd74_R_4 = _SampleTexture2D_dac00903c04645979af2a2f7b1ccdd74_RGBA_0.r;
            float _SampleTexture2D_dac00903c04645979af2a2f7b1ccdd74_G_5 = _SampleTexture2D_dac00903c04645979af2a2f7b1ccdd74_RGBA_0.g;
            float _SampleTexture2D_dac00903c04645979af2a2f7b1ccdd74_B_6 = _SampleTexture2D_dac00903c04645979af2a2f7b1ccdd74_RGBA_0.b;
            float _SampleTexture2D_dac00903c04645979af2a2f7b1ccdd74_A_7 = _SampleTexture2D_dac00903c04645979af2a2f7b1ccdd74_RGBA_0.a;
            float3 _NormalUnpack_b99686ccbda846ccb4d56a24d0c50799_Out_1;
            Unity_NormalUnpack_float(_SampleTexture2D_dac00903c04645979af2a2f7b1ccdd74_RGBA_0, _NormalUnpack_b99686ccbda846ccb4d56a24d0c50799_Out_1);
            float3 _blendrnmCustomFunction_34849db80d0e42ba94ed4cbabdc3add6_Out_2;
            blend_rnm_float(_Vector3_45a95e02f7e44117b8b512938753a000_Out_0, _NormalUnpack_b99686ccbda846ccb4d56a24d0c50799_Out_1, _blendrnmCustomFunction_34849db80d0e42ba94ed4cbabdc3add6_Out_2);
            float3x3 Transform_85dc59b8e1f4427abd83c0afa7f15262_tangentTransform_World = float3x3(IN.WorldSpaceTangent, IN.WorldSpaceBiTangent, IN.WorldSpaceNormal);
            float3 _Transform_85dc59b8e1f4427abd83c0afa7f15262_Out_1 = TransformWorldToTangent(_blendrnmCustomFunction_34849db80d0e42ba94ed4cbabdc3add6_Out_2.xyz, Transform_85dc59b8e1f4427abd83c0afa7f15262_tangentTransform_World);
            float3 _Lerp_c9a656bec6d446fc9281cf65211c19e5_Out_3;
            Unity_Lerp_float3(_blendrnmCustomFunction_80ece8cf7f4f4658b304ac674b395bf3_Out_2, _Transform_85dc59b8e1f4427abd83c0afa7f15262_Out_1, (_Smoothstep_87f8055d79104aeab092ae8a9aa36fea_Out_3.xxx), _Lerp_c9a656bec6d446fc9281cf65211c19e5_Out_3);
            UnityTexture2D _Property_adeae3eb29db4484aacd0df533beeb84_Out_0 = UnityBuildTexture2DStructNoScale(_MetallicRough);
            float4 _SampleTexture2D_90d08b6dea154ba086a89e9c4fa90889_RGBA_0 = SAMPLE_TEXTURE2D(_Property_adeae3eb29db4484aacd0df533beeb84_Out_0.tex, _Property_adeae3eb29db4484aacd0df533beeb84_Out_0.samplerstate, _Property_adeae3eb29db4484aacd0df533beeb84_Out_0.GetTransformedUV(IN.uv0.xy));
            float _SampleTexture2D_90d08b6dea154ba086a89e9c4fa90889_R_4 = _SampleTexture2D_90d08b6dea154ba086a89e9c4fa90889_RGBA_0.r;
            float _SampleTexture2D_90d08b6dea154ba086a89e9c4fa90889_G_5 = _SampleTexture2D_90d08b6dea154ba086a89e9c4fa90889_RGBA_0.g;
            float _SampleTexture2D_90d08b6dea154ba086a89e9c4fa90889_B_6 = _SampleTexture2D_90d08b6dea154ba086a89e9c4fa90889_RGBA_0.b;
            float _SampleTexture2D_90d08b6dea154ba086a89e9c4fa90889_A_7 = _SampleTexture2D_90d08b6dea154ba086a89e9c4fa90889_RGBA_0.a;
            float _Property_a455d08c3216492788a35af588e7d59c_Out_0 = _Metallic;
            float _Multiply_be21cf394ee14c70883f2664ceadfa1e_Out_2;
            Unity_Multiply_float_float(_SampleTexture2D_90d08b6dea154ba086a89e9c4fa90889_R_4, _Property_a455d08c3216492788a35af588e7d59c_Out_0, _Multiply_be21cf394ee14c70883f2664ceadfa1e_Out_2);
            float _Property_75c543340504427c915199ab104372ff_Out_0 = _TopMetallic;
            float _Multiply_c5c4fb340ac44cb2a01710361efeba15_Out_2;
            Unity_Multiply_float_float(_SampleTexture2D_635f4dc215c440f8b6eec0882db2d3aa_R_4, _Property_75c543340504427c915199ab104372ff_Out_0, _Multiply_c5c4fb340ac44cb2a01710361efeba15_Out_2);
            float _Lerp_b4930116db9040b5bb31c1df912919d1_Out_3;
            Unity_Lerp_float(_Multiply_be21cf394ee14c70883f2664ceadfa1e_Out_2, _Multiply_c5c4fb340ac44cb2a01710361efeba15_Out_2, _Smoothstep_87f8055d79104aeab092ae8a9aa36fea_Out_3, _Lerp_b4930116db9040b5bb31c1df912919d1_Out_3);
            float _Property_e33fdaf769234c808d8b15a4d4c37cfa_Out_0 = _Glossiness;
            float _Multiply_ff4016ca0c924f7ba52435684ab9062e_Out_2;
            Unity_Multiply_float_float(_SampleTexture2D_90d08b6dea154ba086a89e9c4fa90889_A_7, _Property_e33fdaf769234c808d8b15a4d4c37cfa_Out_0, _Multiply_ff4016ca0c924f7ba52435684ab9062e_Out_2);
            UnityTexture2D _Property_81de6ddbfe474f97a08cf1e76917e9c5_Out_0 = UnityBuildTexture2DStructNoScale(_TopMetallicRough);
            float4 _SampleTexture2D_4256ce8787af4f87b77f164fea21fe56_RGBA_0 = SAMPLE_TEXTURE2D(_Property_81de6ddbfe474f97a08cf1e76917e9c5_Out_0.tex, _Property_81de6ddbfe474f97a08cf1e76917e9c5_Out_0.samplerstate, _Property_81de6ddbfe474f97a08cf1e76917e9c5_Out_0.GetTransformedUV(IN.uv0.xy));
            float _SampleTexture2D_4256ce8787af4f87b77f164fea21fe56_R_4 = _SampleTexture2D_4256ce8787af4f87b77f164fea21fe56_RGBA_0.r;
            float _SampleTexture2D_4256ce8787af4f87b77f164fea21fe56_G_5 = _SampleTexture2D_4256ce8787af4f87b77f164fea21fe56_RGBA_0.g;
            float _SampleTexture2D_4256ce8787af4f87b77f164fea21fe56_B_6 = _SampleTexture2D_4256ce8787af4f87b77f164fea21fe56_RGBA_0.b;
            float _SampleTexture2D_4256ce8787af4f87b77f164fea21fe56_A_7 = _SampleTexture2D_4256ce8787af4f87b77f164fea21fe56_RGBA_0.a;
            float _Property_2fb63e5a04854cc287bd40e62e8a065d_Out_0 = _TopGlossiness;
            float _Multiply_06baa96b04654f0698dac0b4c0e005d8_Out_2;
            Unity_Multiply_float_float(_SampleTexture2D_4256ce8787af4f87b77f164fea21fe56_A_7, _Property_2fb63e5a04854cc287bd40e62e8a065d_Out_0, _Multiply_06baa96b04654f0698dac0b4c0e005d8_Out_2);
            float _Blend_8594f3141c25440b8a89512b16231a9f_Out_2;
            Unity_Blend_Overlay_float(_Multiply_ff4016ca0c924f7ba52435684ab9062e_Out_2, _Multiply_06baa96b04654f0698dac0b4c0e005d8_Out_2, _Blend_8594f3141c25440b8a89512b16231a9f_Out_2, _Smoothstep_87f8055d79104aeab092ae8a9aa36fea_Out_3);
            UnityTexture2D _Property_b0ef4fae6d054745adbbddb7b2a40bf1_Out_0 = UnityBuildTexture2DStructNoScale(_OcclusionMap);
            float4 _SampleTexture2D_9e10038709b147ef8dfc91ee1f818f38_RGBA_0 = SAMPLE_TEXTURE2D(_Property_b0ef4fae6d054745adbbddb7b2a40bf1_Out_0.tex, _Property_b0ef4fae6d054745adbbddb7b2a40bf1_Out_0.samplerstate, _Property_b0ef4fae6d054745adbbddb7b2a40bf1_Out_0.GetTransformedUV(IN.uv0.xy));
            float _SampleTexture2D_9e10038709b147ef8dfc91ee1f818f38_R_4 = _SampleTexture2D_9e10038709b147ef8dfc91ee1f818f38_RGBA_0.r;
            float _SampleTexture2D_9e10038709b147ef8dfc91ee1f818f38_G_5 = _SampleTexture2D_9e10038709b147ef8dfc91ee1f818f38_RGBA_0.g;
            float _SampleTexture2D_9e10038709b147ef8dfc91ee1f818f38_B_6 = _SampleTexture2D_9e10038709b147ef8dfc91ee1f818f38_RGBA_0.b;
            float _SampleTexture2D_9e10038709b147ef8dfc91ee1f818f38_A_7 = _SampleTexture2D_9e10038709b147ef8dfc91ee1f818f38_RGBA_0.a;
            float _Property_73daf17ddc69480f84893ab863305ada_Out_0 = _OcclusionStrength;
            float _Lerp_89a62424edfb44fda4ab08c8cb63acb6_Out_3;
            Unity_Lerp_float(1, _SampleTexture2D_9e10038709b147ef8dfc91ee1f818f38_R_4, _Property_73daf17ddc69480f84893ab863305ada_Out_0, _Lerp_89a62424edfb44fda4ab08c8cb63acb6_Out_3);
            surface.BaseColor = (_Lerp_45fd290440944ec2a7bed0c07e3c9b69_Out_3.xyz);
            surface.NormalTS = _Lerp_c9a656bec6d446fc9281cf65211c19e5_Out_3;
            surface.Emission = float3(0, 0, 0);
            surface.Metallic = _Lerp_b4930116db9040b5bb31c1df912919d1_Out_3;
            surface.Smoothness = _Blend_8594f3141c25440b8a89512b16231a9f_Out_2;
            surface.Occlusion = _Lerp_89a62424edfb44fda4ab08c8cb63acb6_Out_3;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
            
        
            // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
            float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);
        
            // use bitangent on the fly like in hdrp
            // IMPORTANT! If we ever support Flip on double sided materials ensure bitangent and tangent are NOT flipped.
            float crossSign = (input.tangentWS.w > 0.0 ? 1.0 : -1.0)* GetOddNegativeScale();
            float3 bitang = crossSign * cross(input.normalWS.xyz, input.tangentWS.xyz);
        
            output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
            // to pr               eserve mikktspace compliance we use same scale renormFactor as was used on the normal.
            // This                is explained in section 2.2 in "surface gradient based bump mapping framework"
            output.WorldSpaceTangent = renormFactor * input.tangentWS.xyz;
            output.WorldSpaceBiTangent = renormFactor * bitang;
        
            output.WorldSpacePosition = input.positionWS;
            output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityGBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRGBufferPass.hlsl"
        
        ENDHLSL
        }
        Pass
        {
            Name "ShadowCaster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }
        
        // Render State
        Cull Back
        ZTest LEqual
        ZWrite On
        ColorMask 0
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        #pragma multi_compile _ _CASTING_PUNCTUAL_LIGHT_SHADOW
        // GraphKeywords: <None>
        
        // Defines
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_SHADOWCASTER
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _TopAlbedo_TexelSize;
        float4 _TopNormal_TexelSize;
        float4 _TopMetallicRough_TexelSize;
        float _TopMetallic;
        float _TopGlossiness;
        float4 _Noise_TexelSize;
        float4 _MainTex_TexelSize;
        float4 _BumpMap_TexelSize;
        float4 _DetailBump_TexelSize;
        float _DetailScale;
        float4 _OcclusionMap_TexelSize;
        float4 _MetallicRough_TexelSize;
        float _Metallic;
        float _Glossiness;
        float _OcclusionStrength;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_TopAlbedo);
        SAMPLER(sampler_TopAlbedo);
        TEXTURE2D(_TopNormal);
        SAMPLER(sampler_TopNormal);
        TEXTURE2D(_TopMetallicRough);
        SAMPLER(sampler_TopMetallicRough);
        TEXTURE2D(_Noise);
        SAMPLER(sampler_Noise);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        TEXTURE2D(_BumpMap);
        SAMPLER(sampler_BumpMap);
        TEXTURE2D(_DetailBump);
        SAMPLER(sampler_DetailBump);
        TEXTURE2D(_OcclusionMap);
        SAMPLER(sampler_OcclusionMap);
        TEXTURE2D(_MetallicRough);
        SAMPLER(sampler_MetallicRough);
        float _TopScale;
        float _noiseScale;
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        // GraphFunctions: <None>
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
            
        
        
        
        
        
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"
        
        ENDHLSL
        }
        Pass
        {
            Name "DepthOnly"
            Tags
            {
                "LightMode" = "DepthOnly"
            }
        
        // Render State
        Cull Back
        ZTest LEqual
        ZWrite On
        ColorMask 0
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _TopAlbedo_TexelSize;
        float4 _TopNormal_TexelSize;
        float4 _TopMetallicRough_TexelSize;
        float _TopMetallic;
        float _TopGlossiness;
        float4 _Noise_TexelSize;
        float4 _MainTex_TexelSize;
        float4 _BumpMap_TexelSize;
        float4 _DetailBump_TexelSize;
        float _DetailScale;
        float4 _OcclusionMap_TexelSize;
        float4 _MetallicRough_TexelSize;
        float _Metallic;
        float _Glossiness;
        float _OcclusionStrength;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_TopAlbedo);
        SAMPLER(sampler_TopAlbedo);
        TEXTURE2D(_TopNormal);
        SAMPLER(sampler_TopNormal);
        TEXTURE2D(_TopMetallicRough);
        SAMPLER(sampler_TopMetallicRough);
        TEXTURE2D(_Noise);
        SAMPLER(sampler_Noise);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        TEXTURE2D(_BumpMap);
        SAMPLER(sampler_BumpMap);
        TEXTURE2D(_DetailBump);
        SAMPLER(sampler_DetailBump);
        TEXTURE2D(_OcclusionMap);
        SAMPLER(sampler_OcclusionMap);
        TEXTURE2D(_MetallicRough);
        SAMPLER(sampler_MetallicRough);
        float _TopScale;
        float _noiseScale;
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        // GraphFunctions: <None>
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
            
        
        
        
        
        
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"
        
        ENDHLSL
        }
        Pass
        {
            Name "DepthNormals"
            Tags
            {
                "LightMode" = "DepthNormals"
            }
        
        // Render State
        Cull Back
        ZTest LEqual
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHNORMALS
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 tangentWS;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpaceNormal;
             float3 TangentSpaceNormal;
             float3 WorldSpaceTangent;
             float3 WorldSpaceBiTangent;
             float3 WorldSpacePosition;
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float3 interp1 : INTERP1;
             float4 interp2 : INTERP2;
             float4 interp3 : INTERP3;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            output.interp3.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            output.texCoord0 = input.interp3.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _TopAlbedo_TexelSize;
        float4 _TopNormal_TexelSize;
        float4 _TopMetallicRough_TexelSize;
        float _TopMetallic;
        float _TopGlossiness;
        float4 _Noise_TexelSize;
        float4 _MainTex_TexelSize;
        float4 _BumpMap_TexelSize;
        float4 _DetailBump_TexelSize;
        float _DetailScale;
        float4 _OcclusionMap_TexelSize;
        float4 _MetallicRough_TexelSize;
        float _Metallic;
        float _Glossiness;
        float _OcclusionStrength;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_TopAlbedo);
        SAMPLER(sampler_TopAlbedo);
        TEXTURE2D(_TopNormal);
        SAMPLER(sampler_TopNormal);
        TEXTURE2D(_TopMetallicRough);
        SAMPLER(sampler_TopMetallicRough);
        TEXTURE2D(_Noise);
        SAMPLER(sampler_Noise);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        TEXTURE2D(_BumpMap);
        SAMPLER(sampler_BumpMap);
        TEXTURE2D(_DetailBump);
        SAMPLER(sampler_DetailBump);
        TEXTURE2D(_OcclusionMap);
        SAMPLER(sampler_OcclusionMap);
        TEXTURE2D(_MetallicRough);
        SAMPLER(sampler_MetallicRough);
        float _TopScale;
        float _noiseScale;
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_NormalUnpack_float(float4 In, out float3 Out)
        {
                        Out = UnpackNormal(In);
                    }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void blend_rnm_float(float3 n1, float3 n2, out float3 Out){
            n1.z += 1;
            
            n2.xy = -n2.xy;
            
            Out = n1 * dot(n1, n2) / n1.z - n2;
        }
        
        void Unity_Absolute_float3(float3 In, out float3 Out)
        {
            Out = abs(In);
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Lerp_float3(float3 A, float3 B, float3 T, out float3 Out)
        {
            Out = lerp(A, B, T);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 NormalTS;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_a27ac9c53e69461a82c212b5187b0104_Out_0 = UnityBuildTexture2DStructNoScale(_BumpMap);
            float4 _SampleTexture2D_943cec569c7b4a03895335215ba3311f_RGBA_0 = SAMPLE_TEXTURE2D(_Property_a27ac9c53e69461a82c212b5187b0104_Out_0.tex, _Property_a27ac9c53e69461a82c212b5187b0104_Out_0.samplerstate, _Property_a27ac9c53e69461a82c212b5187b0104_Out_0.GetTransformedUV(IN.uv0.xy));
            float _SampleTexture2D_943cec569c7b4a03895335215ba3311f_R_4 = _SampleTexture2D_943cec569c7b4a03895335215ba3311f_RGBA_0.r;
            float _SampleTexture2D_943cec569c7b4a03895335215ba3311f_G_5 = _SampleTexture2D_943cec569c7b4a03895335215ba3311f_RGBA_0.g;
            float _SampleTexture2D_943cec569c7b4a03895335215ba3311f_B_6 = _SampleTexture2D_943cec569c7b4a03895335215ba3311f_RGBA_0.b;
            float _SampleTexture2D_943cec569c7b4a03895335215ba3311f_A_7 = _SampleTexture2D_943cec569c7b4a03895335215ba3311f_RGBA_0.a;
            float3 _NormalUnpack_901dd2e193ba41e59ca415ff2571b164_Out_1;
            Unity_NormalUnpack_float(_SampleTexture2D_943cec569c7b4a03895335215ba3311f_RGBA_0, _NormalUnpack_901dd2e193ba41e59ca415ff2571b164_Out_1);
            UnityTexture2D _Property_dc790173492f4c8dae6b8e9b6a9b4a46_Out_0 = UnityBuildTexture2DStructNoScale(_DetailBump);
            float4 _UV_133bb460e44d444c993cc22603aa6b6c_Out_0 = IN.uv0;
            float _Property_795999a212424e2d898087c63cf42c6a_Out_0 = _DetailScale;
            float4 _Multiply_cc4f87f5571d405ab75fe99748a2a6b5_Out_2;
            Unity_Multiply_float4_float4(_UV_133bb460e44d444c993cc22603aa6b6c_Out_0, (_Property_795999a212424e2d898087c63cf42c6a_Out_0.xxxx), _Multiply_cc4f87f5571d405ab75fe99748a2a6b5_Out_2);
            float4 _SampleTexture2D_4149636f70a648d194cfb2f4bc674e1b_RGBA_0 = SAMPLE_TEXTURE2D(_Property_dc790173492f4c8dae6b8e9b6a9b4a46_Out_0.tex, _Property_dc790173492f4c8dae6b8e9b6a9b4a46_Out_0.samplerstate, _Property_dc790173492f4c8dae6b8e9b6a9b4a46_Out_0.GetTransformedUV((_Multiply_cc4f87f5571d405ab75fe99748a2a6b5_Out_2.xy)));
            float _SampleTexture2D_4149636f70a648d194cfb2f4bc674e1b_R_4 = _SampleTexture2D_4149636f70a648d194cfb2f4bc674e1b_RGBA_0.r;
            float _SampleTexture2D_4149636f70a648d194cfb2f4bc674e1b_G_5 = _SampleTexture2D_4149636f70a648d194cfb2f4bc674e1b_RGBA_0.g;
            float _SampleTexture2D_4149636f70a648d194cfb2f4bc674e1b_B_6 = _SampleTexture2D_4149636f70a648d194cfb2f4bc674e1b_RGBA_0.b;
            float _SampleTexture2D_4149636f70a648d194cfb2f4bc674e1b_A_7 = _SampleTexture2D_4149636f70a648d194cfb2f4bc674e1b_RGBA_0.a;
            float3 _NormalUnpack_9f89177866b84dda99b829ef9bb74c7d_Out_1;
            Unity_NormalUnpack_float(_SampleTexture2D_4149636f70a648d194cfb2f4bc674e1b_RGBA_0, _NormalUnpack_9f89177866b84dda99b829ef9bb74c7d_Out_1);
            float3 _blendrnmCustomFunction_80ece8cf7f4f4658b304ac674b395bf3_Out_2;
            blend_rnm_float(_NormalUnpack_901dd2e193ba41e59ca415ff2571b164_Out_1, _NormalUnpack_9f89177866b84dda99b829ef9bb74c7d_Out_1, _blendrnmCustomFunction_80ece8cf7f4f4658b304ac674b395bf3_Out_2);
            float _Split_1c9b34a4135b4b309f09c88a8130b0fb_R_1 = IN.WorldSpaceNormal[0];
            float _Split_1c9b34a4135b4b309f09c88a8130b0fb_G_2 = IN.WorldSpaceNormal[1];
            float _Split_1c9b34a4135b4b309f09c88a8130b0fb_B_3 = IN.WorldSpaceNormal[2];
            float _Split_1c9b34a4135b4b309f09c88a8130b0fb_A_4 = 0;
            float3 _Absolute_faa09bddaa9b4a9a9695fc00c1fdd222_Out_1;
            Unity_Absolute_float3(IN.WorldSpaceNormal, _Absolute_faa09bddaa9b4a9a9695fc00c1fdd222_Out_1);
            float3 _Vector3_45a95e02f7e44117b8b512938753a000_Out_0 = float3(_Split_1c9b34a4135b4b309f09c88a8130b0fb_R_1, _Split_1c9b34a4135b4b309f09c88a8130b0fb_B_3, (_Absolute_faa09bddaa9b4a9a9695fc00c1fdd222_Out_1).x);
            UnityTexture2D _Property_7d1394ed1b0245d39df9cf3d018c7b08_Out_0 = UnityBuildTexture2DStructNoScale(_TopNormal);
            float _Split_73415ceb64e243dd9b6cdbed882c419e_R_1 = IN.WorldSpacePosition[0];
            float _Split_73415ceb64e243dd9b6cdbed882c419e_G_2 = IN.WorldSpacePosition[1];
            float _Split_73415ceb64e243dd9b6cdbed882c419e_B_3 = IN.WorldSpacePosition[2];
            float _Split_73415ceb64e243dd9b6cdbed882c419e_A_4 = 0;
            float2 _Vector2_5f4c26f1391b4632bf69806499d07368_Out_0 = float2(_Split_73415ceb64e243dd9b6cdbed882c419e_R_1, _Split_73415ceb64e243dd9b6cdbed882c419e_B_3);
            float _Property_4cc655dc7833446f8e8423a5be711b34_Out_0 = _TopScale;
            float2 _Multiply_15222a5e1788439f9cea4567369a72d5_Out_2;
            Unity_Multiply_float2_float2(_Vector2_5f4c26f1391b4632bf69806499d07368_Out_0, (_Property_4cc655dc7833446f8e8423a5be711b34_Out_0.xx), _Multiply_15222a5e1788439f9cea4567369a72d5_Out_2);
            float4 _SampleTexture2D_dac00903c04645979af2a2f7b1ccdd74_RGBA_0 = SAMPLE_TEXTURE2D(_Property_7d1394ed1b0245d39df9cf3d018c7b08_Out_0.tex, _Property_7d1394ed1b0245d39df9cf3d018c7b08_Out_0.samplerstate, _Property_7d1394ed1b0245d39df9cf3d018c7b08_Out_0.GetTransformedUV(_Multiply_15222a5e1788439f9cea4567369a72d5_Out_2));
            float _SampleTexture2D_dac00903c04645979af2a2f7b1ccdd74_R_4 = _SampleTexture2D_dac00903c04645979af2a2f7b1ccdd74_RGBA_0.r;
            float _SampleTexture2D_dac00903c04645979af2a2f7b1ccdd74_G_5 = _SampleTexture2D_dac00903c04645979af2a2f7b1ccdd74_RGBA_0.g;
            float _SampleTexture2D_dac00903c04645979af2a2f7b1ccdd74_B_6 = _SampleTexture2D_dac00903c04645979af2a2f7b1ccdd74_RGBA_0.b;
            float _SampleTexture2D_dac00903c04645979af2a2f7b1ccdd74_A_7 = _SampleTexture2D_dac00903c04645979af2a2f7b1ccdd74_RGBA_0.a;
            float3 _NormalUnpack_b99686ccbda846ccb4d56a24d0c50799_Out_1;
            Unity_NormalUnpack_float(_SampleTexture2D_dac00903c04645979af2a2f7b1ccdd74_RGBA_0, _NormalUnpack_b99686ccbda846ccb4d56a24d0c50799_Out_1);
            float3 _blendrnmCustomFunction_34849db80d0e42ba94ed4cbabdc3add6_Out_2;
            blend_rnm_float(_Vector3_45a95e02f7e44117b8b512938753a000_Out_0, _NormalUnpack_b99686ccbda846ccb4d56a24d0c50799_Out_1, _blendrnmCustomFunction_34849db80d0e42ba94ed4cbabdc3add6_Out_2);
            float3x3 Transform_85dc59b8e1f4427abd83c0afa7f15262_tangentTransform_World = float3x3(IN.WorldSpaceTangent, IN.WorldSpaceBiTangent, IN.WorldSpaceNormal);
            float3 _Transform_85dc59b8e1f4427abd83c0afa7f15262_Out_1 = TransformWorldToTangent(_blendrnmCustomFunction_34849db80d0e42ba94ed4cbabdc3add6_Out_2.xyz, Transform_85dc59b8e1f4427abd83c0afa7f15262_tangentTransform_World);
            UnityTexture2D _Property_4bdc709e69274a8abd70923126c48288_Out_0 = UnityBuildTexture2DStructNoScale(_Noise);
            float _Property_6b0c37a327bd4d6cb692e37ecd028405_Out_0 = _noiseScale;
            float2 _Multiply_fe25618f7cdf431e8c9baf94f854e2fe_Out_2;
            Unity_Multiply_float2_float2(_Multiply_15222a5e1788439f9cea4567369a72d5_Out_2, (_Property_6b0c37a327bd4d6cb692e37ecd028405_Out_0.xx), _Multiply_fe25618f7cdf431e8c9baf94f854e2fe_Out_2);
            float4 _SampleTexture2D_635f4dc215c440f8b6eec0882db2d3aa_RGBA_0 = SAMPLE_TEXTURE2D(_Property_4bdc709e69274a8abd70923126c48288_Out_0.tex, _Property_4bdc709e69274a8abd70923126c48288_Out_0.samplerstate, _Property_4bdc709e69274a8abd70923126c48288_Out_0.GetTransformedUV(_Multiply_fe25618f7cdf431e8c9baf94f854e2fe_Out_2));
            float _SampleTexture2D_635f4dc215c440f8b6eec0882db2d3aa_R_4 = _SampleTexture2D_635f4dc215c440f8b6eec0882db2d3aa_RGBA_0.r;
            float _SampleTexture2D_635f4dc215c440f8b6eec0882db2d3aa_G_5 = _SampleTexture2D_635f4dc215c440f8b6eec0882db2d3aa_RGBA_0.g;
            float _SampleTexture2D_635f4dc215c440f8b6eec0882db2d3aa_B_6 = _SampleTexture2D_635f4dc215c440f8b6eec0882db2d3aa_RGBA_0.b;
            float _SampleTexture2D_635f4dc215c440f8b6eec0882db2d3aa_A_7 = _SampleTexture2D_635f4dc215c440f8b6eec0882db2d3aa_RGBA_0.a;
            float _Split_2fa854d8373b43319e3815f773f182a3_R_1 = IN.WorldSpaceNormal[0];
            float _Split_2fa854d8373b43319e3815f773f182a3_G_2 = IN.WorldSpaceNormal[1];
            float _Split_2fa854d8373b43319e3815f773f182a3_B_3 = IN.WorldSpaceNormal[2];
            float _Split_2fa854d8373b43319e3815f773f182a3_A_4 = 0;
            float _Clamp_8d87bc8399b744c8b4ded4378bcce6e2_Out_3;
            Unity_Clamp_float(_Split_2fa854d8373b43319e3815f773f182a3_G_2, 0, 1, _Clamp_8d87bc8399b744c8b4ded4378bcce6e2_Out_3);
            float _Smoothstep_8d527e2955cd4ea99e6c0611c3827735_Out_3;
            Unity_Smoothstep_float(_SampleTexture2D_635f4dc215c440f8b6eec0882db2d3aa_R_4, 1, _Clamp_8d87bc8399b744c8b4ded4378bcce6e2_Out_3, _Smoothstep_8d527e2955cd4ea99e6c0611c3827735_Out_3);
            float _Smoothstep_87f8055d79104aeab092ae8a9aa36fea_Out_3;
            Unity_Smoothstep_float(0.1, 0.2, _Smoothstep_8d527e2955cd4ea99e6c0611c3827735_Out_3, _Smoothstep_87f8055d79104aeab092ae8a9aa36fea_Out_3);
            float3 _Lerp_c9a656bec6d446fc9281cf65211c19e5_Out_3;
            Unity_Lerp_float3(_blendrnmCustomFunction_80ece8cf7f4f4658b304ac674b395bf3_Out_2, _Transform_85dc59b8e1f4427abd83c0afa7f15262_Out_1, (_Smoothstep_87f8055d79104aeab092ae8a9aa36fea_Out_3.xxx), _Lerp_c9a656bec6d446fc9281cf65211c19e5_Out_3);
            surface.NormalTS = _Lerp_c9a656bec6d446fc9281cf65211c19e5_Out_3;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
            
        
            // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
            float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);
        
            // use bitangent on the fly like in hdrp
            // IMPORTANT! If we ever support Flip on double sided materials ensure bitangent and tangent are NOT flipped.
            float crossSign = (input.tangentWS.w > 0.0 ? 1.0 : -1.0)* GetOddNegativeScale();
            float3 bitang = crossSign * cross(input.normalWS.xyz, input.tangentWS.xyz);
        
            output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
            // to pr               eserve mikktspace compliance we use same scale renormFactor as was used on the normal.
            // This                is explained in section 2.2 in "surface gradient based bump mapping framework"
            output.WorldSpaceTangent = renormFactor * input.tangentWS.xyz;
            output.WorldSpaceBiTangent = renormFactor * bitang;
        
            output.WorldSpacePosition = input.positionWS;
            output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"
        
        ENDHLSL
        }
        Pass
        {
            Name "Meta"
            Tags
            {
                "LightMode" = "Meta"
            }
        
        // Render State
        Cull Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        #pragma shader_feature _ EDITOR_VISUALIZATION
        // GraphKeywords: <None>
        
        // Defines
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_TEXCOORD1
        #define VARYINGS_NEED_TEXCOORD2
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_META
        #define _FOG_FRAGMENT 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 texCoord0;
             float4 texCoord1;
             float4 texCoord2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpaceNormal;
             float3 WorldSpacePosition;
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float3 interp1 : INTERP1;
             float4 interp2 : INTERP2;
             float4 interp3 : INTERP3;
             float4 interp4 : INTERP4;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.texCoord0;
            output.interp3.xyzw =  input.texCoord1;
            output.interp4.xyzw =  input.texCoord2;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.texCoord0 = input.interp2.xyzw;
            output.texCoord1 = input.interp3.xyzw;
            output.texCoord2 = input.interp4.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _TopAlbedo_TexelSize;
        float4 _TopNormal_TexelSize;
        float4 _TopMetallicRough_TexelSize;
        float _TopMetallic;
        float _TopGlossiness;
        float4 _Noise_TexelSize;
        float4 _MainTex_TexelSize;
        float4 _BumpMap_TexelSize;
        float4 _DetailBump_TexelSize;
        float _DetailScale;
        float4 _OcclusionMap_TexelSize;
        float4 _MetallicRough_TexelSize;
        float _Metallic;
        float _Glossiness;
        float _OcclusionStrength;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_TopAlbedo);
        SAMPLER(sampler_TopAlbedo);
        TEXTURE2D(_TopNormal);
        SAMPLER(sampler_TopNormal);
        TEXTURE2D(_TopMetallicRough);
        SAMPLER(sampler_TopMetallicRough);
        TEXTURE2D(_Noise);
        SAMPLER(sampler_Noise);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        TEXTURE2D(_BumpMap);
        SAMPLER(sampler_BumpMap);
        TEXTURE2D(_DetailBump);
        SAMPLER(sampler_DetailBump);
        TEXTURE2D(_OcclusionMap);
        SAMPLER(sampler_OcclusionMap);
        TEXTURE2D(_MetallicRough);
        SAMPLER(sampler_MetallicRough);
        float _TopScale;
        float _noiseScale;
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 Emission;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_43c517f37e4644129a3c62f9b44c4cc3_Out_0 = UnityBuildTexture2DStructNoScale(_MainTex);
            float4 _SampleTexture2D_39cbc473170e41df85ee0f0a83ef6576_RGBA_0 = SAMPLE_TEXTURE2D(_Property_43c517f37e4644129a3c62f9b44c4cc3_Out_0.tex, _Property_43c517f37e4644129a3c62f9b44c4cc3_Out_0.samplerstate, _Property_43c517f37e4644129a3c62f9b44c4cc3_Out_0.GetTransformedUV(IN.uv0.xy));
            float _SampleTexture2D_39cbc473170e41df85ee0f0a83ef6576_R_4 = _SampleTexture2D_39cbc473170e41df85ee0f0a83ef6576_RGBA_0.r;
            float _SampleTexture2D_39cbc473170e41df85ee0f0a83ef6576_G_5 = _SampleTexture2D_39cbc473170e41df85ee0f0a83ef6576_RGBA_0.g;
            float _SampleTexture2D_39cbc473170e41df85ee0f0a83ef6576_B_6 = _SampleTexture2D_39cbc473170e41df85ee0f0a83ef6576_RGBA_0.b;
            float _SampleTexture2D_39cbc473170e41df85ee0f0a83ef6576_A_7 = _SampleTexture2D_39cbc473170e41df85ee0f0a83ef6576_RGBA_0.a;
            UnityTexture2D _Property_e25deacfb3324ff694a822d7d2782220_Out_0 = UnityBuildTexture2DStructNoScale(_TopAlbedo);
            float _Split_73415ceb64e243dd9b6cdbed882c419e_R_1 = IN.WorldSpacePosition[0];
            float _Split_73415ceb64e243dd9b6cdbed882c419e_G_2 = IN.WorldSpacePosition[1];
            float _Split_73415ceb64e243dd9b6cdbed882c419e_B_3 = IN.WorldSpacePosition[2];
            float _Split_73415ceb64e243dd9b6cdbed882c419e_A_4 = 0;
            float2 _Vector2_5f4c26f1391b4632bf69806499d07368_Out_0 = float2(_Split_73415ceb64e243dd9b6cdbed882c419e_R_1, _Split_73415ceb64e243dd9b6cdbed882c419e_B_3);
            float _Property_4cc655dc7833446f8e8423a5be711b34_Out_0 = _TopScale;
            float2 _Multiply_15222a5e1788439f9cea4567369a72d5_Out_2;
            Unity_Multiply_float2_float2(_Vector2_5f4c26f1391b4632bf69806499d07368_Out_0, (_Property_4cc655dc7833446f8e8423a5be711b34_Out_0.xx), _Multiply_15222a5e1788439f9cea4567369a72d5_Out_2);
            float4 _SampleTexture2D_a48fb84304c3411f9709cd397fa3863a_RGBA_0 = SAMPLE_TEXTURE2D(_Property_e25deacfb3324ff694a822d7d2782220_Out_0.tex, _Property_e25deacfb3324ff694a822d7d2782220_Out_0.samplerstate, _Property_e25deacfb3324ff694a822d7d2782220_Out_0.GetTransformedUV(_Multiply_15222a5e1788439f9cea4567369a72d5_Out_2));
            float _SampleTexture2D_a48fb84304c3411f9709cd397fa3863a_R_4 = _SampleTexture2D_a48fb84304c3411f9709cd397fa3863a_RGBA_0.r;
            float _SampleTexture2D_a48fb84304c3411f9709cd397fa3863a_G_5 = _SampleTexture2D_a48fb84304c3411f9709cd397fa3863a_RGBA_0.g;
            float _SampleTexture2D_a48fb84304c3411f9709cd397fa3863a_B_6 = _SampleTexture2D_a48fb84304c3411f9709cd397fa3863a_RGBA_0.b;
            float _SampleTexture2D_a48fb84304c3411f9709cd397fa3863a_A_7 = _SampleTexture2D_a48fb84304c3411f9709cd397fa3863a_RGBA_0.a;
            UnityTexture2D _Property_4bdc709e69274a8abd70923126c48288_Out_0 = UnityBuildTexture2DStructNoScale(_Noise);
            float _Property_6b0c37a327bd4d6cb692e37ecd028405_Out_0 = _noiseScale;
            float2 _Multiply_fe25618f7cdf431e8c9baf94f854e2fe_Out_2;
            Unity_Multiply_float2_float2(_Multiply_15222a5e1788439f9cea4567369a72d5_Out_2, (_Property_6b0c37a327bd4d6cb692e37ecd028405_Out_0.xx), _Multiply_fe25618f7cdf431e8c9baf94f854e2fe_Out_2);
            float4 _SampleTexture2D_635f4dc215c440f8b6eec0882db2d3aa_RGBA_0 = SAMPLE_TEXTURE2D(_Property_4bdc709e69274a8abd70923126c48288_Out_0.tex, _Property_4bdc709e69274a8abd70923126c48288_Out_0.samplerstate, _Property_4bdc709e69274a8abd70923126c48288_Out_0.GetTransformedUV(_Multiply_fe25618f7cdf431e8c9baf94f854e2fe_Out_2));
            float _SampleTexture2D_635f4dc215c440f8b6eec0882db2d3aa_R_4 = _SampleTexture2D_635f4dc215c440f8b6eec0882db2d3aa_RGBA_0.r;
            float _SampleTexture2D_635f4dc215c440f8b6eec0882db2d3aa_G_5 = _SampleTexture2D_635f4dc215c440f8b6eec0882db2d3aa_RGBA_0.g;
            float _SampleTexture2D_635f4dc215c440f8b6eec0882db2d3aa_B_6 = _SampleTexture2D_635f4dc215c440f8b6eec0882db2d3aa_RGBA_0.b;
            float _SampleTexture2D_635f4dc215c440f8b6eec0882db2d3aa_A_7 = _SampleTexture2D_635f4dc215c440f8b6eec0882db2d3aa_RGBA_0.a;
            float _Split_2fa854d8373b43319e3815f773f182a3_R_1 = IN.WorldSpaceNormal[0];
            float _Split_2fa854d8373b43319e3815f773f182a3_G_2 = IN.WorldSpaceNormal[1];
            float _Split_2fa854d8373b43319e3815f773f182a3_B_3 = IN.WorldSpaceNormal[2];
            float _Split_2fa854d8373b43319e3815f773f182a3_A_4 = 0;
            float _Clamp_8d87bc8399b744c8b4ded4378bcce6e2_Out_3;
            Unity_Clamp_float(_Split_2fa854d8373b43319e3815f773f182a3_G_2, 0, 1, _Clamp_8d87bc8399b744c8b4ded4378bcce6e2_Out_3);
            float _Smoothstep_8d527e2955cd4ea99e6c0611c3827735_Out_3;
            Unity_Smoothstep_float(_SampleTexture2D_635f4dc215c440f8b6eec0882db2d3aa_R_4, 1, _Clamp_8d87bc8399b744c8b4ded4378bcce6e2_Out_3, _Smoothstep_8d527e2955cd4ea99e6c0611c3827735_Out_3);
            float _Smoothstep_87f8055d79104aeab092ae8a9aa36fea_Out_3;
            Unity_Smoothstep_float(0.1, 0.2, _Smoothstep_8d527e2955cd4ea99e6c0611c3827735_Out_3, _Smoothstep_87f8055d79104aeab092ae8a9aa36fea_Out_3);
            float4 _Lerp_45fd290440944ec2a7bed0c07e3c9b69_Out_3;
            Unity_Lerp_float4(_SampleTexture2D_39cbc473170e41df85ee0f0a83ef6576_RGBA_0, _SampleTexture2D_a48fb84304c3411f9709cd397fa3863a_RGBA_0, (_Smoothstep_87f8055d79104aeab092ae8a9aa36fea_Out_3.xxxx), _Lerp_45fd290440944ec2a7bed0c07e3c9b69_Out_3);
            surface.BaseColor = (_Lerp_45fd290440944ec2a7bed0c07e3c9b69_Out_3.xyz);
            surface.Emission = float3(0, 0, 0);
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
            
        
            // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
            float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);
        
        
            output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
        
        
            output.WorldSpacePosition = input.positionWS;
            output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"
        
        ENDHLSL
        }
        Pass
        {
            // Name: <None>
            Tags
            {
                "LightMode" = "Universal2D"
            }
        
        // Render State
        Cull Back
        Blend One Zero
        ZTest LEqual
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_2D
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpaceNormal;
             float3 WorldSpacePosition;
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float3 interp1 : INTERP1;
             float4 interp2 : INTERP2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.texCoord0 = input.interp2.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _TopAlbedo_TexelSize;
        float4 _TopNormal_TexelSize;
        float4 _TopMetallicRough_TexelSize;
        float _TopMetallic;
        float _TopGlossiness;
        float4 _Noise_TexelSize;
        float4 _MainTex_TexelSize;
        float4 _BumpMap_TexelSize;
        float4 _DetailBump_TexelSize;
        float _DetailScale;
        float4 _OcclusionMap_TexelSize;
        float4 _MetallicRough_TexelSize;
        float _Metallic;
        float _Glossiness;
        float _OcclusionStrength;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_TopAlbedo);
        SAMPLER(sampler_TopAlbedo);
        TEXTURE2D(_TopNormal);
        SAMPLER(sampler_TopNormal);
        TEXTURE2D(_TopMetallicRough);
        SAMPLER(sampler_TopMetallicRough);
        TEXTURE2D(_Noise);
        SAMPLER(sampler_Noise);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        TEXTURE2D(_BumpMap);
        SAMPLER(sampler_BumpMap);
        TEXTURE2D(_DetailBump);
        SAMPLER(sampler_DetailBump);
        TEXTURE2D(_OcclusionMap);
        SAMPLER(sampler_OcclusionMap);
        TEXTURE2D(_MetallicRough);
        SAMPLER(sampler_MetallicRough);
        float _TopScale;
        float _noiseScale;
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_43c517f37e4644129a3c62f9b44c4cc3_Out_0 = UnityBuildTexture2DStructNoScale(_MainTex);
            float4 _SampleTexture2D_39cbc473170e41df85ee0f0a83ef6576_RGBA_0 = SAMPLE_TEXTURE2D(_Property_43c517f37e4644129a3c62f9b44c4cc3_Out_0.tex, _Property_43c517f37e4644129a3c62f9b44c4cc3_Out_0.samplerstate, _Property_43c517f37e4644129a3c62f9b44c4cc3_Out_0.GetTransformedUV(IN.uv0.xy));
            float _SampleTexture2D_39cbc473170e41df85ee0f0a83ef6576_R_4 = _SampleTexture2D_39cbc473170e41df85ee0f0a83ef6576_RGBA_0.r;
            float _SampleTexture2D_39cbc473170e41df85ee0f0a83ef6576_G_5 = _SampleTexture2D_39cbc473170e41df85ee0f0a83ef6576_RGBA_0.g;
            float _SampleTexture2D_39cbc473170e41df85ee0f0a83ef6576_B_6 = _SampleTexture2D_39cbc473170e41df85ee0f0a83ef6576_RGBA_0.b;
            float _SampleTexture2D_39cbc473170e41df85ee0f0a83ef6576_A_7 = _SampleTexture2D_39cbc473170e41df85ee0f0a83ef6576_RGBA_0.a;
            UnityTexture2D _Property_e25deacfb3324ff694a822d7d2782220_Out_0 = UnityBuildTexture2DStructNoScale(_TopAlbedo);
            float _Split_73415ceb64e243dd9b6cdbed882c419e_R_1 = IN.WorldSpacePosition[0];
            float _Split_73415ceb64e243dd9b6cdbed882c419e_G_2 = IN.WorldSpacePosition[1];
            float _Split_73415ceb64e243dd9b6cdbed882c419e_B_3 = IN.WorldSpacePosition[2];
            float _Split_73415ceb64e243dd9b6cdbed882c419e_A_4 = 0;
            float2 _Vector2_5f4c26f1391b4632bf69806499d07368_Out_0 = float2(_Split_73415ceb64e243dd9b6cdbed882c419e_R_1, _Split_73415ceb64e243dd9b6cdbed882c419e_B_3);
            float _Property_4cc655dc7833446f8e8423a5be711b34_Out_0 = _TopScale;
            float2 _Multiply_15222a5e1788439f9cea4567369a72d5_Out_2;
            Unity_Multiply_float2_float2(_Vector2_5f4c26f1391b4632bf69806499d07368_Out_0, (_Property_4cc655dc7833446f8e8423a5be711b34_Out_0.xx), _Multiply_15222a5e1788439f9cea4567369a72d5_Out_2);
            float4 _SampleTexture2D_a48fb84304c3411f9709cd397fa3863a_RGBA_0 = SAMPLE_TEXTURE2D(_Property_e25deacfb3324ff694a822d7d2782220_Out_0.tex, _Property_e25deacfb3324ff694a822d7d2782220_Out_0.samplerstate, _Property_e25deacfb3324ff694a822d7d2782220_Out_0.GetTransformedUV(_Multiply_15222a5e1788439f9cea4567369a72d5_Out_2));
            float _SampleTexture2D_a48fb84304c3411f9709cd397fa3863a_R_4 = _SampleTexture2D_a48fb84304c3411f9709cd397fa3863a_RGBA_0.r;
            float _SampleTexture2D_a48fb84304c3411f9709cd397fa3863a_G_5 = _SampleTexture2D_a48fb84304c3411f9709cd397fa3863a_RGBA_0.g;
            float _SampleTexture2D_a48fb84304c3411f9709cd397fa3863a_B_6 = _SampleTexture2D_a48fb84304c3411f9709cd397fa3863a_RGBA_0.b;
            float _SampleTexture2D_a48fb84304c3411f9709cd397fa3863a_A_7 = _SampleTexture2D_a48fb84304c3411f9709cd397fa3863a_RGBA_0.a;
            UnityTexture2D _Property_4bdc709e69274a8abd70923126c48288_Out_0 = UnityBuildTexture2DStructNoScale(_Noise);
            float _Property_6b0c37a327bd4d6cb692e37ecd028405_Out_0 = _noiseScale;
            float2 _Multiply_fe25618f7cdf431e8c9baf94f854e2fe_Out_2;
            Unity_Multiply_float2_float2(_Multiply_15222a5e1788439f9cea4567369a72d5_Out_2, (_Property_6b0c37a327bd4d6cb692e37ecd028405_Out_0.xx), _Multiply_fe25618f7cdf431e8c9baf94f854e2fe_Out_2);
            float4 _SampleTexture2D_635f4dc215c440f8b6eec0882db2d3aa_RGBA_0 = SAMPLE_TEXTURE2D(_Property_4bdc709e69274a8abd70923126c48288_Out_0.tex, _Property_4bdc709e69274a8abd70923126c48288_Out_0.samplerstate, _Property_4bdc709e69274a8abd70923126c48288_Out_0.GetTransformedUV(_Multiply_fe25618f7cdf431e8c9baf94f854e2fe_Out_2));
            float _SampleTexture2D_635f4dc215c440f8b6eec0882db2d3aa_R_4 = _SampleTexture2D_635f4dc215c440f8b6eec0882db2d3aa_RGBA_0.r;
            float _SampleTexture2D_635f4dc215c440f8b6eec0882db2d3aa_G_5 = _SampleTexture2D_635f4dc215c440f8b6eec0882db2d3aa_RGBA_0.g;
            float _SampleTexture2D_635f4dc215c440f8b6eec0882db2d3aa_B_6 = _SampleTexture2D_635f4dc215c440f8b6eec0882db2d3aa_RGBA_0.b;
            float _SampleTexture2D_635f4dc215c440f8b6eec0882db2d3aa_A_7 = _SampleTexture2D_635f4dc215c440f8b6eec0882db2d3aa_RGBA_0.a;
            float _Split_2fa854d8373b43319e3815f773f182a3_R_1 = IN.WorldSpaceNormal[0];
            float _Split_2fa854d8373b43319e3815f773f182a3_G_2 = IN.WorldSpaceNormal[1];
            float _Split_2fa854d8373b43319e3815f773f182a3_B_3 = IN.WorldSpaceNormal[2];
            float _Split_2fa854d8373b43319e3815f773f182a3_A_4 = 0;
            float _Clamp_8d87bc8399b744c8b4ded4378bcce6e2_Out_3;
            Unity_Clamp_float(_Split_2fa854d8373b43319e3815f773f182a3_G_2, 0, 1, _Clamp_8d87bc8399b744c8b4ded4378bcce6e2_Out_3);
            float _Smoothstep_8d527e2955cd4ea99e6c0611c3827735_Out_3;
            Unity_Smoothstep_float(_SampleTexture2D_635f4dc215c440f8b6eec0882db2d3aa_R_4, 1, _Clamp_8d87bc8399b744c8b4ded4378bcce6e2_Out_3, _Smoothstep_8d527e2955cd4ea99e6c0611c3827735_Out_3);
            float _Smoothstep_87f8055d79104aeab092ae8a9aa36fea_Out_3;
            Unity_Smoothstep_float(0.1, 0.2, _Smoothstep_8d527e2955cd4ea99e6c0611c3827735_Out_3, _Smoothstep_87f8055d79104aeab092ae8a9aa36fea_Out_3);
            float4 _Lerp_45fd290440944ec2a7bed0c07e3c9b69_Out_3;
            Unity_Lerp_float4(_SampleTexture2D_39cbc473170e41df85ee0f0a83ef6576_RGBA_0, _SampleTexture2D_a48fb84304c3411f9709cd397fa3863a_RGBA_0, (_Smoothstep_87f8055d79104aeab092ae8a9aa36fea_Out_3.xxxx), _Lerp_45fd290440944ec2a7bed0c07e3c9b69_Out_3);
            surface.BaseColor = (_Lerp_45fd290440944ec2a7bed0c07e3c9b69_Out_3.xyz);
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
            
        
            // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
            float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);
        
        
            output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
        
        
            output.WorldSpacePosition = input.positionWS;
            output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"
        
        ENDHLSL
        }
        Pass
        {
            Name "SceneSelectionPass"
            Tags
            {
                "LightMode" = "SceneSelectionPass"
            }
        
            // Render State
            Cull Off
        
            // Debug
            // <None>
        
            // --------------------------------------------------
            // Pass
        
            HLSLPROGRAM
        
            // Pragmas
            #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma vertex vert
        #pragma fragment frag
        
            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>
        
            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>
        
            // Defines
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENESELECTIONPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
            // Includes
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreInclude' */
        
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
            // --------------------------------------------------
            // Structs and Packing
        
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
            struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
            // --------------------------------------------------
            // Graph
        
            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 _TopAlbedo_TexelSize;
        float4 _TopNormal_TexelSize;
        float4 _TopMetallicRough_TexelSize;
        float _TopMetallic;
        float _TopGlossiness;
        float4 _Noise_TexelSize;
        float4 _MainTex_TexelSize;
        float4 _BumpMap_TexelSize;
        float4 _DetailBump_TexelSize;
        float _DetailScale;
        float4 _OcclusionMap_TexelSize;
        float4 _MetallicRough_TexelSize;
        float _Metallic;
        float _Glossiness;
        float _OcclusionStrength;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_TopAlbedo);
        SAMPLER(sampler_TopAlbedo);
        TEXTURE2D(_TopNormal);
        SAMPLER(sampler_TopNormal);
        TEXTURE2D(_TopMetallicRough);
        SAMPLER(sampler_TopMetallicRough);
        TEXTURE2D(_Noise);
        SAMPLER(sampler_Noise);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        TEXTURE2D(_BumpMap);
        SAMPLER(sampler_BumpMap);
        TEXTURE2D(_DetailBump);
        SAMPLER(sampler_DetailBump);
        TEXTURE2D(_OcclusionMap);
        SAMPLER(sampler_OcclusionMap);
        TEXTURE2D(_MetallicRough);
        SAMPLER(sampler_MetallicRough);
        float _TopScale;
        float _noiseScale;
        
            // Graph Includes
            // GraphIncludes: <None>
        
            // -- Property used by ScenePickingPass
            #ifdef SCENEPICKINGPASS
            float4 _SelectionID;
            #endif
        
            // -- Properties used by SceneSelectionPass
            #ifdef SCENESELECTIONPASS
            int _ObjectId;
            int _PassValue;
            #endif
        
            // Graph Functions
            // GraphFunctions: <None>
        
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
            #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
            // Graph Pixel
            struct SurfaceDescription
        {
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            return surface;
        }
        
            // --------------------------------------------------
            // Build Graph Inputs
        
            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
            
        
        
        
        
        
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN                output.FaceSign =                                   IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
            return output;
        }
        
            // --------------------------------------------------
            // Main
        
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
        
            ENDHLSL
        }
        Pass
        {
            Name "ScenePickingPass"
            Tags
            {
                "LightMode" = "Picking"
            }
        
            // Render State
            Cull Back
        
            // Debug
            // <None>
        
            // --------------------------------------------------
            // Pass
        
            HLSLPROGRAM
        
            // Pragmas
            #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma vertex vert
        #pragma fragment frag
        
            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>
        
            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>
        
            // Defines
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENEPICKINGPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
            // Includes
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreInclude' */
        
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
            // --------------------------------------------------
            // Structs and Packing
        
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
            struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
            // --------------------------------------------------
            // Graph
        
            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 _TopAlbedo_TexelSize;
        float4 _TopNormal_TexelSize;
        float4 _TopMetallicRough_TexelSize;
        float _TopMetallic;
        float _TopGlossiness;
        float4 _Noise_TexelSize;
        float4 _MainTex_TexelSize;
        float4 _BumpMap_TexelSize;
        float4 _DetailBump_TexelSize;
        float _DetailScale;
        float4 _OcclusionMap_TexelSize;
        float4 _MetallicRough_TexelSize;
        float _Metallic;
        float _Glossiness;
        float _OcclusionStrength;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_TopAlbedo);
        SAMPLER(sampler_TopAlbedo);
        TEXTURE2D(_TopNormal);
        SAMPLER(sampler_TopNormal);
        TEXTURE2D(_TopMetallicRough);
        SAMPLER(sampler_TopMetallicRough);
        TEXTURE2D(_Noise);
        SAMPLER(sampler_Noise);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        TEXTURE2D(_BumpMap);
        SAMPLER(sampler_BumpMap);
        TEXTURE2D(_DetailBump);
        SAMPLER(sampler_DetailBump);
        TEXTURE2D(_OcclusionMap);
        SAMPLER(sampler_OcclusionMap);
        TEXTURE2D(_MetallicRough);
        SAMPLER(sampler_MetallicRough);
        float _TopScale;
        float _noiseScale;
        
            // Graph Includes
            // GraphIncludes: <None>
        
            // -- Property used by ScenePickingPass
            #ifdef SCENEPICKINGPASS
            float4 _SelectionID;
            #endif
        
            // -- Properties used by SceneSelectionPass
            #ifdef SCENESELECTIONPASS
            int _ObjectId;
            int _PassValue;
            #endif
        
            // Graph Functions
            // GraphFunctions: <None>
        
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
            #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
            // Graph Pixel
            struct SurfaceDescription
        {
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            return surface;
        }
        
            // --------------------------------------------------
            // Build Graph Inputs
        
            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
            
        
        
        
        
        
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN                output.FaceSign =                                   IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
            return output;
        }
        
            // --------------------------------------------------
            // Main
        
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
        
            ENDHLSL
        }
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Opaque"
            "UniversalMaterialType" = "Lit"
            "Queue"="Geometry"
            "ShaderGraphShader"="true"
            "ShaderGraphTargetId"="UniversalLitSubTarget"
        }
        Pass
        {
            Name "Universal Forward"
            Tags
            {
                "LightMode" = "UniversalForward"
            }
        
        // Render State
        Cull Back
        Blend One Zero
        ZTest LEqual
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma instancing_options renderinglayer
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        #pragma multi_compile _ _SCREEN_SPACE_OCCLUSION
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DYNAMICLIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
        #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
        #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
        #pragma multi_compile _ _REFLECTION_PROBE_BLENDING
        #pragma multi_compile _ _REFLECTION_PROBE_BOX_PROJECTION
        #pragma multi_compile _ _SHADOWS_SOFT
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
        #pragma multi_compile _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        #pragma multi_compile _ _LIGHT_LAYERS
        #pragma multi_compile _ DEBUG_DISPLAY
        #pragma multi_compile _ _LIGHT_COOKIES
        #pragma multi_compile _ _CLUSTERED_RENDERING
        // GraphKeywords: <None>
        
        // Defines
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_VIEWDIRECTION_WS
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #define VARYINGS_NEED_SHADOW_COORD
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_FORWARD
        #define _FOG_FRAGMENT 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 tangentWS;
             float4 texCoord0;
             float3 viewDirectionWS;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh;
            #endif
             float4 fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpaceNormal;
             float3 TangentSpaceNormal;
             float3 WorldSpaceTangent;
             float3 WorldSpaceBiTangent;
             float3 WorldSpacePosition;
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float3 interp1 : INTERP1;
             float4 interp2 : INTERP2;
             float4 interp3 : INTERP3;
             float3 interp4 : INTERP4;
             float2 interp5 : INTERP5;
             float2 interp6 : INTERP6;
             float3 interp7 : INTERP7;
             float4 interp8 : INTERP8;
             float4 interp9 : INTERP9;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            output.interp3.xyzw =  input.texCoord0;
            output.interp4.xyz =  input.viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            output.interp5.xy =  input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.interp6.xy =  input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.interp7.xyz =  input.sh;
            #endif
            output.interp8.xyzw =  input.fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.interp9.xyzw =  input.shadowCoord;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            output.texCoord0 = input.interp3.xyzw;
            output.viewDirectionWS = input.interp4.xyz;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.interp5.xy;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.interp6.xy;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.interp7.xyz;
            #endif
            output.fogFactorAndVertexLight = input.interp8.xyzw;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.interp9.xyzw;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _TopAlbedo_TexelSize;
        float4 _TopNormal_TexelSize;
        float4 _TopMetallicRough_TexelSize;
        float _TopMetallic;
        float _TopGlossiness;
        float4 _Noise_TexelSize;
        float4 _MainTex_TexelSize;
        float4 _BumpMap_TexelSize;
        float4 _DetailBump_TexelSize;
        float _DetailScale;
        float4 _OcclusionMap_TexelSize;
        float4 _MetallicRough_TexelSize;
        float _Metallic;
        float _Glossiness;
        float _OcclusionStrength;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_TopAlbedo);
        SAMPLER(sampler_TopAlbedo);
        TEXTURE2D(_TopNormal);
        SAMPLER(sampler_TopNormal);
        TEXTURE2D(_TopMetallicRough);
        SAMPLER(sampler_TopMetallicRough);
        TEXTURE2D(_Noise);
        SAMPLER(sampler_Noise);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        TEXTURE2D(_BumpMap);
        SAMPLER(sampler_BumpMap);
        TEXTURE2D(_DetailBump);
        SAMPLER(sampler_DetailBump);
        TEXTURE2D(_OcclusionMap);
        SAMPLER(sampler_OcclusionMap);
        TEXTURE2D(_MetallicRough);
        SAMPLER(sampler_MetallicRough);
        float _TopScale;
        float _noiseScale;
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_NormalUnpack_float(float4 In, out float3 Out)
        {
                        Out = UnpackNormal(In);
                    }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void blend_rnm_float(float3 n1, float3 n2, out float3 Out){
            n1.z += 1;
            
            n2.xy = -n2.xy;
            
            Out = n1 * dot(n1, n2) / n1.z - n2;
        }
        
        void Unity_Absolute_float3(float3 In, out float3 Out)
        {
            Out = abs(In);
        }
        
        void Unity_Lerp_float3(float3 A, float3 B, float3 T, out float3 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Lerp_float(float A, float B, float T, out float Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Blend_Overlay_float(float Base, float Blend, out float Out, float Opacity)
        {
            float result1 = 1.0 - 2.0 * (1.0 - Base) * (1.0 - Blend);
            float result2 = 2.0 * Base * Blend;
            float zeroOrOne = step(Base, 0.5);
            Out = result2 * zeroOrOne + (1 - zeroOrOne) * result1;
            Out = lerp(Base, Out, Opacity);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 NormalTS;
            float3 Emission;
            float Metallic;
            float Smoothness;
            float Occlusion;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_43c517f37e4644129a3c62f9b44c4cc3_Out_0 = UnityBuildTexture2DStructNoScale(_MainTex);
            float4 _SampleTexture2D_39cbc473170e41df85ee0f0a83ef6576_RGBA_0 = SAMPLE_TEXTURE2D(_Property_43c517f37e4644129a3c62f9b44c4cc3_Out_0.tex, _Property_43c517f37e4644129a3c62f9b44c4cc3_Out_0.samplerstate, _Property_43c517f37e4644129a3c62f9b44c4cc3_Out_0.GetTransformedUV(IN.uv0.xy));
            float _SampleTexture2D_39cbc473170e41df85ee0f0a83ef6576_R_4 = _SampleTexture2D_39cbc473170e41df85ee0f0a83ef6576_RGBA_0.r;
            float _SampleTexture2D_39cbc473170e41df85ee0f0a83ef6576_G_5 = _SampleTexture2D_39cbc473170e41df85ee0f0a83ef6576_RGBA_0.g;
            float _SampleTexture2D_39cbc473170e41df85ee0f0a83ef6576_B_6 = _SampleTexture2D_39cbc473170e41df85ee0f0a83ef6576_RGBA_0.b;
            float _SampleTexture2D_39cbc473170e41df85ee0f0a83ef6576_A_7 = _SampleTexture2D_39cbc473170e41df85ee0f0a83ef6576_RGBA_0.a;
            UnityTexture2D _Property_e25deacfb3324ff694a822d7d2782220_Out_0 = UnityBuildTexture2DStructNoScale(_TopAlbedo);
            float _Split_73415ceb64e243dd9b6cdbed882c419e_R_1 = IN.WorldSpacePosition[0];
            float _Split_73415ceb64e243dd9b6cdbed882c419e_G_2 = IN.WorldSpacePosition[1];
            float _Split_73415ceb64e243dd9b6cdbed882c419e_B_3 = IN.WorldSpacePosition[2];
            float _Split_73415ceb64e243dd9b6cdbed882c419e_A_4 = 0;
            float2 _Vector2_5f4c26f1391b4632bf69806499d07368_Out_0 = float2(_Split_73415ceb64e243dd9b6cdbed882c419e_R_1, _Split_73415ceb64e243dd9b6cdbed882c419e_B_3);
            float _Property_4cc655dc7833446f8e8423a5be711b34_Out_0 = _TopScale;
            float2 _Multiply_15222a5e1788439f9cea4567369a72d5_Out_2;
            Unity_Multiply_float2_float2(_Vector2_5f4c26f1391b4632bf69806499d07368_Out_0, (_Property_4cc655dc7833446f8e8423a5be711b34_Out_0.xx), _Multiply_15222a5e1788439f9cea4567369a72d5_Out_2);
            float4 _SampleTexture2D_a48fb84304c3411f9709cd397fa3863a_RGBA_0 = SAMPLE_TEXTURE2D(_Property_e25deacfb3324ff694a822d7d2782220_Out_0.tex, _Property_e25deacfb3324ff694a822d7d2782220_Out_0.samplerstate, _Property_e25deacfb3324ff694a822d7d2782220_Out_0.GetTransformedUV(_Multiply_15222a5e1788439f9cea4567369a72d5_Out_2));
            float _SampleTexture2D_a48fb84304c3411f9709cd397fa3863a_R_4 = _SampleTexture2D_a48fb84304c3411f9709cd397fa3863a_RGBA_0.r;
            float _SampleTexture2D_a48fb84304c3411f9709cd397fa3863a_G_5 = _SampleTexture2D_a48fb84304c3411f9709cd397fa3863a_RGBA_0.g;
            float _SampleTexture2D_a48fb84304c3411f9709cd397fa3863a_B_6 = _SampleTexture2D_a48fb84304c3411f9709cd397fa3863a_RGBA_0.b;
            float _SampleTexture2D_a48fb84304c3411f9709cd397fa3863a_A_7 = _SampleTexture2D_a48fb84304c3411f9709cd397fa3863a_RGBA_0.a;
            UnityTexture2D _Property_4bdc709e69274a8abd70923126c48288_Out_0 = UnityBuildTexture2DStructNoScale(_Noise);
            float _Property_6b0c37a327bd4d6cb692e37ecd028405_Out_0 = _noiseScale;
            float2 _Multiply_fe25618f7cdf431e8c9baf94f854e2fe_Out_2;
            Unity_Multiply_float2_float2(_Multiply_15222a5e1788439f9cea4567369a72d5_Out_2, (_Property_6b0c37a327bd4d6cb692e37ecd028405_Out_0.xx), _Multiply_fe25618f7cdf431e8c9baf94f854e2fe_Out_2);
            float4 _SampleTexture2D_635f4dc215c440f8b6eec0882db2d3aa_RGBA_0 = SAMPLE_TEXTURE2D(_Property_4bdc709e69274a8abd70923126c48288_Out_0.tex, _Property_4bdc709e69274a8abd70923126c48288_Out_0.samplerstate, _Property_4bdc709e69274a8abd70923126c48288_Out_0.GetTransformedUV(_Multiply_fe25618f7cdf431e8c9baf94f854e2fe_Out_2));
            float _SampleTexture2D_635f4dc215c440f8b6eec0882db2d3aa_R_4 = _SampleTexture2D_635f4dc215c440f8b6eec0882db2d3aa_RGBA_0.r;
            float _SampleTexture2D_635f4dc215c440f8b6eec0882db2d3aa_G_5 = _SampleTexture2D_635f4dc215c440f8b6eec0882db2d3aa_RGBA_0.g;
            float _SampleTexture2D_635f4dc215c440f8b6eec0882db2d3aa_B_6 = _SampleTexture2D_635f4dc215c440f8b6eec0882db2d3aa_RGBA_0.b;
            float _SampleTexture2D_635f4dc215c440f8b6eec0882db2d3aa_A_7 = _SampleTexture2D_635f4dc215c440f8b6eec0882db2d3aa_RGBA_0.a;
            float _Split_2fa854d8373b43319e3815f773f182a3_R_1 = IN.WorldSpaceNormal[0];
            float _Split_2fa854d8373b43319e3815f773f182a3_G_2 = IN.WorldSpaceNormal[1];
            float _Split_2fa854d8373b43319e3815f773f182a3_B_3 = IN.WorldSpaceNormal[2];
            float _Split_2fa854d8373b43319e3815f773f182a3_A_4 = 0;
            float _Clamp_8d87bc8399b744c8b4ded4378bcce6e2_Out_3;
            Unity_Clamp_float(_Split_2fa854d8373b43319e3815f773f182a3_G_2, 0, 1, _Clamp_8d87bc8399b744c8b4ded4378bcce6e2_Out_3);
            float _Smoothstep_8d527e2955cd4ea99e6c0611c3827735_Out_3;
            Unity_Smoothstep_float(_SampleTexture2D_635f4dc215c440f8b6eec0882db2d3aa_R_4, 1, _Clamp_8d87bc8399b744c8b4ded4378bcce6e2_Out_3, _Smoothstep_8d527e2955cd4ea99e6c0611c3827735_Out_3);
            float _Smoothstep_87f8055d79104aeab092ae8a9aa36fea_Out_3;
            Unity_Smoothstep_float(0.1, 0.2, _Smoothstep_8d527e2955cd4ea99e6c0611c3827735_Out_3, _Smoothstep_87f8055d79104aeab092ae8a9aa36fea_Out_3);
            float4 _Lerp_45fd290440944ec2a7bed0c07e3c9b69_Out_3;
            Unity_Lerp_float4(_SampleTexture2D_39cbc473170e41df85ee0f0a83ef6576_RGBA_0, _SampleTexture2D_a48fb84304c3411f9709cd397fa3863a_RGBA_0, (_Smoothstep_87f8055d79104aeab092ae8a9aa36fea_Out_3.xxxx), _Lerp_45fd290440944ec2a7bed0c07e3c9b69_Out_3);
            UnityTexture2D _Property_a27ac9c53e69461a82c212b5187b0104_Out_0 = UnityBuildTexture2DStructNoScale(_BumpMap);
            float4 _SampleTexture2D_943cec569c7b4a03895335215ba3311f_RGBA_0 = SAMPLE_TEXTURE2D(_Property_a27ac9c53e69461a82c212b5187b0104_Out_0.tex, _Property_a27ac9c53e69461a82c212b5187b0104_Out_0.samplerstate, _Property_a27ac9c53e69461a82c212b5187b0104_Out_0.GetTransformedUV(IN.uv0.xy));
            float _SampleTexture2D_943cec569c7b4a03895335215ba3311f_R_4 = _SampleTexture2D_943cec569c7b4a03895335215ba3311f_RGBA_0.r;
            float _SampleTexture2D_943cec569c7b4a03895335215ba3311f_G_5 = _SampleTexture2D_943cec569c7b4a03895335215ba3311f_RGBA_0.g;
            float _SampleTexture2D_943cec569c7b4a03895335215ba3311f_B_6 = _SampleTexture2D_943cec569c7b4a03895335215ba3311f_RGBA_0.b;
            float _SampleTexture2D_943cec569c7b4a03895335215ba3311f_A_7 = _SampleTexture2D_943cec569c7b4a03895335215ba3311f_RGBA_0.a;
            float3 _NormalUnpack_901dd2e193ba41e59ca415ff2571b164_Out_1;
            Unity_NormalUnpack_float(_SampleTexture2D_943cec569c7b4a03895335215ba3311f_RGBA_0, _NormalUnpack_901dd2e193ba41e59ca415ff2571b164_Out_1);
            UnityTexture2D _Property_dc790173492f4c8dae6b8e9b6a9b4a46_Out_0 = UnityBuildTexture2DStructNoScale(_DetailBump);
            float4 _UV_133bb460e44d444c993cc22603aa6b6c_Out_0 = IN.uv0;
            float _Property_795999a212424e2d898087c63cf42c6a_Out_0 = _DetailScale;
            float4 _Multiply_cc4f87f5571d405ab75fe99748a2a6b5_Out_2;
            Unity_Multiply_float4_float4(_UV_133bb460e44d444c993cc22603aa6b6c_Out_0, (_Property_795999a212424e2d898087c63cf42c6a_Out_0.xxxx), _Multiply_cc4f87f5571d405ab75fe99748a2a6b5_Out_2);
            float4 _SampleTexture2D_4149636f70a648d194cfb2f4bc674e1b_RGBA_0 = SAMPLE_TEXTURE2D(_Property_dc790173492f4c8dae6b8e9b6a9b4a46_Out_0.tex, _Property_dc790173492f4c8dae6b8e9b6a9b4a46_Out_0.samplerstate, _Property_dc790173492f4c8dae6b8e9b6a9b4a46_Out_0.GetTransformedUV((_Multiply_cc4f87f5571d405ab75fe99748a2a6b5_Out_2.xy)));
            float _SampleTexture2D_4149636f70a648d194cfb2f4bc674e1b_R_4 = _SampleTexture2D_4149636f70a648d194cfb2f4bc674e1b_RGBA_0.r;
            float _SampleTexture2D_4149636f70a648d194cfb2f4bc674e1b_G_5 = _SampleTexture2D_4149636f70a648d194cfb2f4bc674e1b_RGBA_0.g;
            float _SampleTexture2D_4149636f70a648d194cfb2f4bc674e1b_B_6 = _SampleTexture2D_4149636f70a648d194cfb2f4bc674e1b_RGBA_0.b;
            float _SampleTexture2D_4149636f70a648d194cfb2f4bc674e1b_A_7 = _SampleTexture2D_4149636f70a648d194cfb2f4bc674e1b_RGBA_0.a;
            float3 _NormalUnpack_9f89177866b84dda99b829ef9bb74c7d_Out_1;
            Unity_NormalUnpack_float(_SampleTexture2D_4149636f70a648d194cfb2f4bc674e1b_RGBA_0, _NormalUnpack_9f89177866b84dda99b829ef9bb74c7d_Out_1);
            float3 _blendrnmCustomFunction_80ece8cf7f4f4658b304ac674b395bf3_Out_2;
            blend_rnm_float(_NormalUnpack_901dd2e193ba41e59ca415ff2571b164_Out_1, _NormalUnpack_9f89177866b84dda99b829ef9bb74c7d_Out_1, _blendrnmCustomFunction_80ece8cf7f4f4658b304ac674b395bf3_Out_2);
            float _Split_1c9b34a4135b4b309f09c88a8130b0fb_R_1 = IN.WorldSpaceNormal[0];
            float _Split_1c9b34a4135b4b309f09c88a8130b0fb_G_2 = IN.WorldSpaceNormal[1];
            float _Split_1c9b34a4135b4b309f09c88a8130b0fb_B_3 = IN.WorldSpaceNormal[2];
            float _Split_1c9b34a4135b4b309f09c88a8130b0fb_A_4 = 0;
            float3 _Absolute_faa09bddaa9b4a9a9695fc00c1fdd222_Out_1;
            Unity_Absolute_float3(IN.WorldSpaceNormal, _Absolute_faa09bddaa9b4a9a9695fc00c1fdd222_Out_1);
            float3 _Vector3_45a95e02f7e44117b8b512938753a000_Out_0 = float3(_Split_1c9b34a4135b4b309f09c88a8130b0fb_R_1, _Split_1c9b34a4135b4b309f09c88a8130b0fb_B_3, (_Absolute_faa09bddaa9b4a9a9695fc00c1fdd222_Out_1).x);
            UnityTexture2D _Property_7d1394ed1b0245d39df9cf3d018c7b08_Out_0 = UnityBuildTexture2DStructNoScale(_TopNormal);
            float4 _SampleTexture2D_dac00903c04645979af2a2f7b1ccdd74_RGBA_0 = SAMPLE_TEXTURE2D(_Property_7d1394ed1b0245d39df9cf3d018c7b08_Out_0.tex, _Property_7d1394ed1b0245d39df9cf3d018c7b08_Out_0.samplerstate, _Property_7d1394ed1b0245d39df9cf3d018c7b08_Out_0.GetTransformedUV(_Multiply_15222a5e1788439f9cea4567369a72d5_Out_2));
            float _SampleTexture2D_dac00903c04645979af2a2f7b1ccdd74_R_4 = _SampleTexture2D_dac00903c04645979af2a2f7b1ccdd74_RGBA_0.r;
            float _SampleTexture2D_dac00903c04645979af2a2f7b1ccdd74_G_5 = _SampleTexture2D_dac00903c04645979af2a2f7b1ccdd74_RGBA_0.g;
            float _SampleTexture2D_dac00903c04645979af2a2f7b1ccdd74_B_6 = _SampleTexture2D_dac00903c04645979af2a2f7b1ccdd74_RGBA_0.b;
            float _SampleTexture2D_dac00903c04645979af2a2f7b1ccdd74_A_7 = _SampleTexture2D_dac00903c04645979af2a2f7b1ccdd74_RGBA_0.a;
            float3 _NormalUnpack_b99686ccbda846ccb4d56a24d0c50799_Out_1;
            Unity_NormalUnpack_float(_SampleTexture2D_dac00903c04645979af2a2f7b1ccdd74_RGBA_0, _NormalUnpack_b99686ccbda846ccb4d56a24d0c50799_Out_1);
            float3 _blendrnmCustomFunction_34849db80d0e42ba94ed4cbabdc3add6_Out_2;
            blend_rnm_float(_Vector3_45a95e02f7e44117b8b512938753a000_Out_0, _NormalUnpack_b99686ccbda846ccb4d56a24d0c50799_Out_1, _blendrnmCustomFunction_34849db80d0e42ba94ed4cbabdc3add6_Out_2);
            float3x3 Transform_85dc59b8e1f4427abd83c0afa7f15262_tangentTransform_World = float3x3(IN.WorldSpaceTangent, IN.WorldSpaceBiTangent, IN.WorldSpaceNormal);
            float3 _Transform_85dc59b8e1f4427abd83c0afa7f15262_Out_1 = TransformWorldToTangent(_blendrnmCustomFunction_34849db80d0e42ba94ed4cbabdc3add6_Out_2.xyz, Transform_85dc59b8e1f4427abd83c0afa7f15262_tangentTransform_World);
            float3 _Lerp_c9a656bec6d446fc9281cf65211c19e5_Out_3;
            Unity_Lerp_float3(_blendrnmCustomFunction_80ece8cf7f4f4658b304ac674b395bf3_Out_2, _Transform_85dc59b8e1f4427abd83c0afa7f15262_Out_1, (_Smoothstep_87f8055d79104aeab092ae8a9aa36fea_Out_3.xxx), _Lerp_c9a656bec6d446fc9281cf65211c19e5_Out_3);
            UnityTexture2D _Property_adeae3eb29db4484aacd0df533beeb84_Out_0 = UnityBuildTexture2DStructNoScale(_MetallicRough);
            float4 _SampleTexture2D_90d08b6dea154ba086a89e9c4fa90889_RGBA_0 = SAMPLE_TEXTURE2D(_Property_adeae3eb29db4484aacd0df533beeb84_Out_0.tex, _Property_adeae3eb29db4484aacd0df533beeb84_Out_0.samplerstate, _Property_adeae3eb29db4484aacd0df533beeb84_Out_0.GetTransformedUV(IN.uv0.xy));
            float _SampleTexture2D_90d08b6dea154ba086a89e9c4fa90889_R_4 = _SampleTexture2D_90d08b6dea154ba086a89e9c4fa90889_RGBA_0.r;
            float _SampleTexture2D_90d08b6dea154ba086a89e9c4fa90889_G_5 = _SampleTexture2D_90d08b6dea154ba086a89e9c4fa90889_RGBA_0.g;
            float _SampleTexture2D_90d08b6dea154ba086a89e9c4fa90889_B_6 = _SampleTexture2D_90d08b6dea154ba086a89e9c4fa90889_RGBA_0.b;
            float _SampleTexture2D_90d08b6dea154ba086a89e9c4fa90889_A_7 = _SampleTexture2D_90d08b6dea154ba086a89e9c4fa90889_RGBA_0.a;
            float _Property_a455d08c3216492788a35af588e7d59c_Out_0 = _Metallic;
            float _Multiply_be21cf394ee14c70883f2664ceadfa1e_Out_2;
            Unity_Multiply_float_float(_SampleTexture2D_90d08b6dea154ba086a89e9c4fa90889_R_4, _Property_a455d08c3216492788a35af588e7d59c_Out_0, _Multiply_be21cf394ee14c70883f2664ceadfa1e_Out_2);
            float _Property_75c543340504427c915199ab104372ff_Out_0 = _TopMetallic;
            float _Multiply_c5c4fb340ac44cb2a01710361efeba15_Out_2;
            Unity_Multiply_float_float(_SampleTexture2D_635f4dc215c440f8b6eec0882db2d3aa_R_4, _Property_75c543340504427c915199ab104372ff_Out_0, _Multiply_c5c4fb340ac44cb2a01710361efeba15_Out_2);
            float _Lerp_b4930116db9040b5bb31c1df912919d1_Out_3;
            Unity_Lerp_float(_Multiply_be21cf394ee14c70883f2664ceadfa1e_Out_2, _Multiply_c5c4fb340ac44cb2a01710361efeba15_Out_2, _Smoothstep_87f8055d79104aeab092ae8a9aa36fea_Out_3, _Lerp_b4930116db9040b5bb31c1df912919d1_Out_3);
            float _Property_e33fdaf769234c808d8b15a4d4c37cfa_Out_0 = _Glossiness;
            float _Multiply_ff4016ca0c924f7ba52435684ab9062e_Out_2;
            Unity_Multiply_float_float(_SampleTexture2D_90d08b6dea154ba086a89e9c4fa90889_A_7, _Property_e33fdaf769234c808d8b15a4d4c37cfa_Out_0, _Multiply_ff4016ca0c924f7ba52435684ab9062e_Out_2);
            UnityTexture2D _Property_81de6ddbfe474f97a08cf1e76917e9c5_Out_0 = UnityBuildTexture2DStructNoScale(_TopMetallicRough);
            float4 _SampleTexture2D_4256ce8787af4f87b77f164fea21fe56_RGBA_0 = SAMPLE_TEXTURE2D(_Property_81de6ddbfe474f97a08cf1e76917e9c5_Out_0.tex, _Property_81de6ddbfe474f97a08cf1e76917e9c5_Out_0.samplerstate, _Property_81de6ddbfe474f97a08cf1e76917e9c5_Out_0.GetTransformedUV(IN.uv0.xy));
            float _SampleTexture2D_4256ce8787af4f87b77f164fea21fe56_R_4 = _SampleTexture2D_4256ce8787af4f87b77f164fea21fe56_RGBA_0.r;
            float _SampleTexture2D_4256ce8787af4f87b77f164fea21fe56_G_5 = _SampleTexture2D_4256ce8787af4f87b77f164fea21fe56_RGBA_0.g;
            float _SampleTexture2D_4256ce8787af4f87b77f164fea21fe56_B_6 = _SampleTexture2D_4256ce8787af4f87b77f164fea21fe56_RGBA_0.b;
            float _SampleTexture2D_4256ce8787af4f87b77f164fea21fe56_A_7 = _SampleTexture2D_4256ce8787af4f87b77f164fea21fe56_RGBA_0.a;
            float _Property_2fb63e5a04854cc287bd40e62e8a065d_Out_0 = _TopGlossiness;
            float _Multiply_06baa96b04654f0698dac0b4c0e005d8_Out_2;
            Unity_Multiply_float_float(_SampleTexture2D_4256ce8787af4f87b77f164fea21fe56_A_7, _Property_2fb63e5a04854cc287bd40e62e8a065d_Out_0, _Multiply_06baa96b04654f0698dac0b4c0e005d8_Out_2);
            float _Blend_8594f3141c25440b8a89512b16231a9f_Out_2;
            Unity_Blend_Overlay_float(_Multiply_ff4016ca0c924f7ba52435684ab9062e_Out_2, _Multiply_06baa96b04654f0698dac0b4c0e005d8_Out_2, _Blend_8594f3141c25440b8a89512b16231a9f_Out_2, _Smoothstep_87f8055d79104aeab092ae8a9aa36fea_Out_3);
            UnityTexture2D _Property_b0ef4fae6d054745adbbddb7b2a40bf1_Out_0 = UnityBuildTexture2DStructNoScale(_OcclusionMap);
            float4 _SampleTexture2D_9e10038709b147ef8dfc91ee1f818f38_RGBA_0 = SAMPLE_TEXTURE2D(_Property_b0ef4fae6d054745adbbddb7b2a40bf1_Out_0.tex, _Property_b0ef4fae6d054745adbbddb7b2a40bf1_Out_0.samplerstate, _Property_b0ef4fae6d054745adbbddb7b2a40bf1_Out_0.GetTransformedUV(IN.uv0.xy));
            float _SampleTexture2D_9e10038709b147ef8dfc91ee1f818f38_R_4 = _SampleTexture2D_9e10038709b147ef8dfc91ee1f818f38_RGBA_0.r;
            float _SampleTexture2D_9e10038709b147ef8dfc91ee1f818f38_G_5 = _SampleTexture2D_9e10038709b147ef8dfc91ee1f818f38_RGBA_0.g;
            float _SampleTexture2D_9e10038709b147ef8dfc91ee1f818f38_B_6 = _SampleTexture2D_9e10038709b147ef8dfc91ee1f818f38_RGBA_0.b;
            float _SampleTexture2D_9e10038709b147ef8dfc91ee1f818f38_A_7 = _SampleTexture2D_9e10038709b147ef8dfc91ee1f818f38_RGBA_0.a;
            float _Property_73daf17ddc69480f84893ab863305ada_Out_0 = _OcclusionStrength;
            float _Lerp_89a62424edfb44fda4ab08c8cb63acb6_Out_3;
            Unity_Lerp_float(1, _SampleTexture2D_9e10038709b147ef8dfc91ee1f818f38_R_4, _Property_73daf17ddc69480f84893ab863305ada_Out_0, _Lerp_89a62424edfb44fda4ab08c8cb63acb6_Out_3);
            surface.BaseColor = (_Lerp_45fd290440944ec2a7bed0c07e3c9b69_Out_3.xyz);
            surface.NormalTS = _Lerp_c9a656bec6d446fc9281cf65211c19e5_Out_3;
            surface.Emission = float3(0, 0, 0);
            surface.Metallic = _Lerp_b4930116db9040b5bb31c1df912919d1_Out_3;
            surface.Smoothness = _Blend_8594f3141c25440b8a89512b16231a9f_Out_2;
            surface.Occlusion = _Lerp_89a62424edfb44fda4ab08c8cb63acb6_Out_3;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
            
        
            // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
            float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);
        
            // use bitangent on the fly like in hdrp
            // IMPORTANT! If we ever support Flip on double sided materials ensure bitangent and tangent are NOT flipped.
            float crossSign = (input.tangentWS.w > 0.0 ? 1.0 : -1.0)* GetOddNegativeScale();
            float3 bitang = crossSign * cross(input.normalWS.xyz, input.tangentWS.xyz);
        
            output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
            // to pr               eserve mikktspace compliance we use same scale renormFactor as was used on the normal.
            // This                is explained in section 2.2 in "surface gradient based bump mapping framework"
            output.WorldSpaceTangent = renormFactor * input.tangentWS.xyz;
            output.WorldSpaceBiTangent = renormFactor * bitang;
        
            output.WorldSpacePosition = input.positionWS;
            output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"
        
        ENDHLSL
        }
        Pass
        {
            Name "ShadowCaster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }
        
        // Render State
        Cull Back
        ZTest LEqual
        ZWrite On
        ColorMask 0
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        #pragma multi_compile _ _CASTING_PUNCTUAL_LIGHT_SHADOW
        // GraphKeywords: <None>
        
        // Defines
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_SHADOWCASTER
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _TopAlbedo_TexelSize;
        float4 _TopNormal_TexelSize;
        float4 _TopMetallicRough_TexelSize;
        float _TopMetallic;
        float _TopGlossiness;
        float4 _Noise_TexelSize;
        float4 _MainTex_TexelSize;
        float4 _BumpMap_TexelSize;
        float4 _DetailBump_TexelSize;
        float _DetailScale;
        float4 _OcclusionMap_TexelSize;
        float4 _MetallicRough_TexelSize;
        float _Metallic;
        float _Glossiness;
        float _OcclusionStrength;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_TopAlbedo);
        SAMPLER(sampler_TopAlbedo);
        TEXTURE2D(_TopNormal);
        SAMPLER(sampler_TopNormal);
        TEXTURE2D(_TopMetallicRough);
        SAMPLER(sampler_TopMetallicRough);
        TEXTURE2D(_Noise);
        SAMPLER(sampler_Noise);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        TEXTURE2D(_BumpMap);
        SAMPLER(sampler_BumpMap);
        TEXTURE2D(_DetailBump);
        SAMPLER(sampler_DetailBump);
        TEXTURE2D(_OcclusionMap);
        SAMPLER(sampler_OcclusionMap);
        TEXTURE2D(_MetallicRough);
        SAMPLER(sampler_MetallicRough);
        float _TopScale;
        float _noiseScale;
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        // GraphFunctions: <None>
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
            
        
        
        
        
        
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"
        
        ENDHLSL
        }
        Pass
        {
            Name "DepthOnly"
            Tags
            {
                "LightMode" = "DepthOnly"
            }
        
        // Render State
        Cull Back
        ZTest LEqual
        ZWrite On
        ColorMask 0
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _TopAlbedo_TexelSize;
        float4 _TopNormal_TexelSize;
        float4 _TopMetallicRough_TexelSize;
        float _TopMetallic;
        float _TopGlossiness;
        float4 _Noise_TexelSize;
        float4 _MainTex_TexelSize;
        float4 _BumpMap_TexelSize;
        float4 _DetailBump_TexelSize;
        float _DetailScale;
        float4 _OcclusionMap_TexelSize;
        float4 _MetallicRough_TexelSize;
        float _Metallic;
        float _Glossiness;
        float _OcclusionStrength;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_TopAlbedo);
        SAMPLER(sampler_TopAlbedo);
        TEXTURE2D(_TopNormal);
        SAMPLER(sampler_TopNormal);
        TEXTURE2D(_TopMetallicRough);
        SAMPLER(sampler_TopMetallicRough);
        TEXTURE2D(_Noise);
        SAMPLER(sampler_Noise);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        TEXTURE2D(_BumpMap);
        SAMPLER(sampler_BumpMap);
        TEXTURE2D(_DetailBump);
        SAMPLER(sampler_DetailBump);
        TEXTURE2D(_OcclusionMap);
        SAMPLER(sampler_OcclusionMap);
        TEXTURE2D(_MetallicRough);
        SAMPLER(sampler_MetallicRough);
        float _TopScale;
        float _noiseScale;
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        // GraphFunctions: <None>
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
            
        
        
        
        
        
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"
        
        ENDHLSL
        }
        Pass
        {
            Name "DepthNormals"
            Tags
            {
                "LightMode" = "DepthNormals"
            }
        
        // Render State
        Cull Back
        ZTest LEqual
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHNORMALS
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 tangentWS;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpaceNormal;
             float3 TangentSpaceNormal;
             float3 WorldSpaceTangent;
             float3 WorldSpaceBiTangent;
             float3 WorldSpacePosition;
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float3 interp1 : INTERP1;
             float4 interp2 : INTERP2;
             float4 interp3 : INTERP3;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            output.interp3.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            output.texCoord0 = input.interp3.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _TopAlbedo_TexelSize;
        float4 _TopNormal_TexelSize;
        float4 _TopMetallicRough_TexelSize;
        float _TopMetallic;
        float _TopGlossiness;
        float4 _Noise_TexelSize;
        float4 _MainTex_TexelSize;
        float4 _BumpMap_TexelSize;
        float4 _DetailBump_TexelSize;
        float _DetailScale;
        float4 _OcclusionMap_TexelSize;
        float4 _MetallicRough_TexelSize;
        float _Metallic;
        float _Glossiness;
        float _OcclusionStrength;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_TopAlbedo);
        SAMPLER(sampler_TopAlbedo);
        TEXTURE2D(_TopNormal);
        SAMPLER(sampler_TopNormal);
        TEXTURE2D(_TopMetallicRough);
        SAMPLER(sampler_TopMetallicRough);
        TEXTURE2D(_Noise);
        SAMPLER(sampler_Noise);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        TEXTURE2D(_BumpMap);
        SAMPLER(sampler_BumpMap);
        TEXTURE2D(_DetailBump);
        SAMPLER(sampler_DetailBump);
        TEXTURE2D(_OcclusionMap);
        SAMPLER(sampler_OcclusionMap);
        TEXTURE2D(_MetallicRough);
        SAMPLER(sampler_MetallicRough);
        float _TopScale;
        float _noiseScale;
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_NormalUnpack_float(float4 In, out float3 Out)
        {
                        Out = UnpackNormal(In);
                    }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void blend_rnm_float(float3 n1, float3 n2, out float3 Out){
            n1.z += 1;
            
            n2.xy = -n2.xy;
            
            Out = n1 * dot(n1, n2) / n1.z - n2;
        }
        
        void Unity_Absolute_float3(float3 In, out float3 Out)
        {
            Out = abs(In);
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Lerp_float3(float3 A, float3 B, float3 T, out float3 Out)
        {
            Out = lerp(A, B, T);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 NormalTS;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_a27ac9c53e69461a82c212b5187b0104_Out_0 = UnityBuildTexture2DStructNoScale(_BumpMap);
            float4 _SampleTexture2D_943cec569c7b4a03895335215ba3311f_RGBA_0 = SAMPLE_TEXTURE2D(_Property_a27ac9c53e69461a82c212b5187b0104_Out_0.tex, _Property_a27ac9c53e69461a82c212b5187b0104_Out_0.samplerstate, _Property_a27ac9c53e69461a82c212b5187b0104_Out_0.GetTransformedUV(IN.uv0.xy));
            float _SampleTexture2D_943cec569c7b4a03895335215ba3311f_R_4 = _SampleTexture2D_943cec569c7b4a03895335215ba3311f_RGBA_0.r;
            float _SampleTexture2D_943cec569c7b4a03895335215ba3311f_G_5 = _SampleTexture2D_943cec569c7b4a03895335215ba3311f_RGBA_0.g;
            float _SampleTexture2D_943cec569c7b4a03895335215ba3311f_B_6 = _SampleTexture2D_943cec569c7b4a03895335215ba3311f_RGBA_0.b;
            float _SampleTexture2D_943cec569c7b4a03895335215ba3311f_A_7 = _SampleTexture2D_943cec569c7b4a03895335215ba3311f_RGBA_0.a;
            float3 _NormalUnpack_901dd2e193ba41e59ca415ff2571b164_Out_1;
            Unity_NormalUnpack_float(_SampleTexture2D_943cec569c7b4a03895335215ba3311f_RGBA_0, _NormalUnpack_901dd2e193ba41e59ca415ff2571b164_Out_1);
            UnityTexture2D _Property_dc790173492f4c8dae6b8e9b6a9b4a46_Out_0 = UnityBuildTexture2DStructNoScale(_DetailBump);
            float4 _UV_133bb460e44d444c993cc22603aa6b6c_Out_0 = IN.uv0;
            float _Property_795999a212424e2d898087c63cf42c6a_Out_0 = _DetailScale;
            float4 _Multiply_cc4f87f5571d405ab75fe99748a2a6b5_Out_2;
            Unity_Multiply_float4_float4(_UV_133bb460e44d444c993cc22603aa6b6c_Out_0, (_Property_795999a212424e2d898087c63cf42c6a_Out_0.xxxx), _Multiply_cc4f87f5571d405ab75fe99748a2a6b5_Out_2);
            float4 _SampleTexture2D_4149636f70a648d194cfb2f4bc674e1b_RGBA_0 = SAMPLE_TEXTURE2D(_Property_dc790173492f4c8dae6b8e9b6a9b4a46_Out_0.tex, _Property_dc790173492f4c8dae6b8e9b6a9b4a46_Out_0.samplerstate, _Property_dc790173492f4c8dae6b8e9b6a9b4a46_Out_0.GetTransformedUV((_Multiply_cc4f87f5571d405ab75fe99748a2a6b5_Out_2.xy)));
            float _SampleTexture2D_4149636f70a648d194cfb2f4bc674e1b_R_4 = _SampleTexture2D_4149636f70a648d194cfb2f4bc674e1b_RGBA_0.r;
            float _SampleTexture2D_4149636f70a648d194cfb2f4bc674e1b_G_5 = _SampleTexture2D_4149636f70a648d194cfb2f4bc674e1b_RGBA_0.g;
            float _SampleTexture2D_4149636f70a648d194cfb2f4bc674e1b_B_6 = _SampleTexture2D_4149636f70a648d194cfb2f4bc674e1b_RGBA_0.b;
            float _SampleTexture2D_4149636f70a648d194cfb2f4bc674e1b_A_7 = _SampleTexture2D_4149636f70a648d194cfb2f4bc674e1b_RGBA_0.a;
            float3 _NormalUnpack_9f89177866b84dda99b829ef9bb74c7d_Out_1;
            Unity_NormalUnpack_float(_SampleTexture2D_4149636f70a648d194cfb2f4bc674e1b_RGBA_0, _NormalUnpack_9f89177866b84dda99b829ef9bb74c7d_Out_1);
            float3 _blendrnmCustomFunction_80ece8cf7f4f4658b304ac674b395bf3_Out_2;
            blend_rnm_float(_NormalUnpack_901dd2e193ba41e59ca415ff2571b164_Out_1, _NormalUnpack_9f89177866b84dda99b829ef9bb74c7d_Out_1, _blendrnmCustomFunction_80ece8cf7f4f4658b304ac674b395bf3_Out_2);
            float _Split_1c9b34a4135b4b309f09c88a8130b0fb_R_1 = IN.WorldSpaceNormal[0];
            float _Split_1c9b34a4135b4b309f09c88a8130b0fb_G_2 = IN.WorldSpaceNormal[1];
            float _Split_1c9b34a4135b4b309f09c88a8130b0fb_B_3 = IN.WorldSpaceNormal[2];
            float _Split_1c9b34a4135b4b309f09c88a8130b0fb_A_4 = 0;
            float3 _Absolute_faa09bddaa9b4a9a9695fc00c1fdd222_Out_1;
            Unity_Absolute_float3(IN.WorldSpaceNormal, _Absolute_faa09bddaa9b4a9a9695fc00c1fdd222_Out_1);
            float3 _Vector3_45a95e02f7e44117b8b512938753a000_Out_0 = float3(_Split_1c9b34a4135b4b309f09c88a8130b0fb_R_1, _Split_1c9b34a4135b4b309f09c88a8130b0fb_B_3, (_Absolute_faa09bddaa9b4a9a9695fc00c1fdd222_Out_1).x);
            UnityTexture2D _Property_7d1394ed1b0245d39df9cf3d018c7b08_Out_0 = UnityBuildTexture2DStructNoScale(_TopNormal);
            float _Split_73415ceb64e243dd9b6cdbed882c419e_R_1 = IN.WorldSpacePosition[0];
            float _Split_73415ceb64e243dd9b6cdbed882c419e_G_2 = IN.WorldSpacePosition[1];
            float _Split_73415ceb64e243dd9b6cdbed882c419e_B_3 = IN.WorldSpacePosition[2];
            float _Split_73415ceb64e243dd9b6cdbed882c419e_A_4 = 0;
            float2 _Vector2_5f4c26f1391b4632bf69806499d07368_Out_0 = float2(_Split_73415ceb64e243dd9b6cdbed882c419e_R_1, _Split_73415ceb64e243dd9b6cdbed882c419e_B_3);
            float _Property_4cc655dc7833446f8e8423a5be711b34_Out_0 = _TopScale;
            float2 _Multiply_15222a5e1788439f9cea4567369a72d5_Out_2;
            Unity_Multiply_float2_float2(_Vector2_5f4c26f1391b4632bf69806499d07368_Out_0, (_Property_4cc655dc7833446f8e8423a5be711b34_Out_0.xx), _Multiply_15222a5e1788439f9cea4567369a72d5_Out_2);
            float4 _SampleTexture2D_dac00903c04645979af2a2f7b1ccdd74_RGBA_0 = SAMPLE_TEXTURE2D(_Property_7d1394ed1b0245d39df9cf3d018c7b08_Out_0.tex, _Property_7d1394ed1b0245d39df9cf3d018c7b08_Out_0.samplerstate, _Property_7d1394ed1b0245d39df9cf3d018c7b08_Out_0.GetTransformedUV(_Multiply_15222a5e1788439f9cea4567369a72d5_Out_2));
            float _SampleTexture2D_dac00903c04645979af2a2f7b1ccdd74_R_4 = _SampleTexture2D_dac00903c04645979af2a2f7b1ccdd74_RGBA_0.r;
            float _SampleTexture2D_dac00903c04645979af2a2f7b1ccdd74_G_5 = _SampleTexture2D_dac00903c04645979af2a2f7b1ccdd74_RGBA_0.g;
            float _SampleTexture2D_dac00903c04645979af2a2f7b1ccdd74_B_6 = _SampleTexture2D_dac00903c04645979af2a2f7b1ccdd74_RGBA_0.b;
            float _SampleTexture2D_dac00903c04645979af2a2f7b1ccdd74_A_7 = _SampleTexture2D_dac00903c04645979af2a2f7b1ccdd74_RGBA_0.a;
            float3 _NormalUnpack_b99686ccbda846ccb4d56a24d0c50799_Out_1;
            Unity_NormalUnpack_float(_SampleTexture2D_dac00903c04645979af2a2f7b1ccdd74_RGBA_0, _NormalUnpack_b99686ccbda846ccb4d56a24d0c50799_Out_1);
            float3 _blendrnmCustomFunction_34849db80d0e42ba94ed4cbabdc3add6_Out_2;
            blend_rnm_float(_Vector3_45a95e02f7e44117b8b512938753a000_Out_0, _NormalUnpack_b99686ccbda846ccb4d56a24d0c50799_Out_1, _blendrnmCustomFunction_34849db80d0e42ba94ed4cbabdc3add6_Out_2);
            float3x3 Transform_85dc59b8e1f4427abd83c0afa7f15262_tangentTransform_World = float3x3(IN.WorldSpaceTangent, IN.WorldSpaceBiTangent, IN.WorldSpaceNormal);
            float3 _Transform_85dc59b8e1f4427abd83c0afa7f15262_Out_1 = TransformWorldToTangent(_blendrnmCustomFunction_34849db80d0e42ba94ed4cbabdc3add6_Out_2.xyz, Transform_85dc59b8e1f4427abd83c0afa7f15262_tangentTransform_World);
            UnityTexture2D _Property_4bdc709e69274a8abd70923126c48288_Out_0 = UnityBuildTexture2DStructNoScale(_Noise);
            float _Property_6b0c37a327bd4d6cb692e37ecd028405_Out_0 = _noiseScale;
            float2 _Multiply_fe25618f7cdf431e8c9baf94f854e2fe_Out_2;
            Unity_Multiply_float2_float2(_Multiply_15222a5e1788439f9cea4567369a72d5_Out_2, (_Property_6b0c37a327bd4d6cb692e37ecd028405_Out_0.xx), _Multiply_fe25618f7cdf431e8c9baf94f854e2fe_Out_2);
            float4 _SampleTexture2D_635f4dc215c440f8b6eec0882db2d3aa_RGBA_0 = SAMPLE_TEXTURE2D(_Property_4bdc709e69274a8abd70923126c48288_Out_0.tex, _Property_4bdc709e69274a8abd70923126c48288_Out_0.samplerstate, _Property_4bdc709e69274a8abd70923126c48288_Out_0.GetTransformedUV(_Multiply_fe25618f7cdf431e8c9baf94f854e2fe_Out_2));
            float _SampleTexture2D_635f4dc215c440f8b6eec0882db2d3aa_R_4 = _SampleTexture2D_635f4dc215c440f8b6eec0882db2d3aa_RGBA_0.r;
            float _SampleTexture2D_635f4dc215c440f8b6eec0882db2d3aa_G_5 = _SampleTexture2D_635f4dc215c440f8b6eec0882db2d3aa_RGBA_0.g;
            float _SampleTexture2D_635f4dc215c440f8b6eec0882db2d3aa_B_6 = _SampleTexture2D_635f4dc215c440f8b6eec0882db2d3aa_RGBA_0.b;
            float _SampleTexture2D_635f4dc215c440f8b6eec0882db2d3aa_A_7 = _SampleTexture2D_635f4dc215c440f8b6eec0882db2d3aa_RGBA_0.a;
            float _Split_2fa854d8373b43319e3815f773f182a3_R_1 = IN.WorldSpaceNormal[0];
            float _Split_2fa854d8373b43319e3815f773f182a3_G_2 = IN.WorldSpaceNormal[1];
            float _Split_2fa854d8373b43319e3815f773f182a3_B_3 = IN.WorldSpaceNormal[2];
            float _Split_2fa854d8373b43319e3815f773f182a3_A_4 = 0;
            float _Clamp_8d87bc8399b744c8b4ded4378bcce6e2_Out_3;
            Unity_Clamp_float(_Split_2fa854d8373b43319e3815f773f182a3_G_2, 0, 1, _Clamp_8d87bc8399b744c8b4ded4378bcce6e2_Out_3);
            float _Smoothstep_8d527e2955cd4ea99e6c0611c3827735_Out_3;
            Unity_Smoothstep_float(_SampleTexture2D_635f4dc215c440f8b6eec0882db2d3aa_R_4, 1, _Clamp_8d87bc8399b744c8b4ded4378bcce6e2_Out_3, _Smoothstep_8d527e2955cd4ea99e6c0611c3827735_Out_3);
            float _Smoothstep_87f8055d79104aeab092ae8a9aa36fea_Out_3;
            Unity_Smoothstep_float(0.1, 0.2, _Smoothstep_8d527e2955cd4ea99e6c0611c3827735_Out_3, _Smoothstep_87f8055d79104aeab092ae8a9aa36fea_Out_3);
            float3 _Lerp_c9a656bec6d446fc9281cf65211c19e5_Out_3;
            Unity_Lerp_float3(_blendrnmCustomFunction_80ece8cf7f4f4658b304ac674b395bf3_Out_2, _Transform_85dc59b8e1f4427abd83c0afa7f15262_Out_1, (_Smoothstep_87f8055d79104aeab092ae8a9aa36fea_Out_3.xxx), _Lerp_c9a656bec6d446fc9281cf65211c19e5_Out_3);
            surface.NormalTS = _Lerp_c9a656bec6d446fc9281cf65211c19e5_Out_3;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
            
        
            // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
            float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);
        
            // use bitangent on the fly like in hdrp
            // IMPORTANT! If we ever support Flip on double sided materials ensure bitangent and tangent are NOT flipped.
            float crossSign = (input.tangentWS.w > 0.0 ? 1.0 : -1.0)* GetOddNegativeScale();
            float3 bitang = crossSign * cross(input.normalWS.xyz, input.tangentWS.xyz);
        
            output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
            // to pr               eserve mikktspace compliance we use same scale renormFactor as was used on the normal.
            // This                is explained in section 2.2 in "surface gradient based bump mapping framework"
            output.WorldSpaceTangent = renormFactor * input.tangentWS.xyz;
            output.WorldSpaceBiTangent = renormFactor * bitang;
        
            output.WorldSpacePosition = input.positionWS;
            output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"
        
        ENDHLSL
        }
        Pass
        {
            Name "Meta"
            Tags
            {
                "LightMode" = "Meta"
            }
        
        // Render State
        Cull Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        #pragma shader_feature _ EDITOR_VISUALIZATION
        // GraphKeywords: <None>
        
        // Defines
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_TEXCOORD1
        #define VARYINGS_NEED_TEXCOORD2
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_META
        #define _FOG_FRAGMENT 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 texCoord0;
             float4 texCoord1;
             float4 texCoord2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpaceNormal;
             float3 WorldSpacePosition;
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float3 interp1 : INTERP1;
             float4 interp2 : INTERP2;
             float4 interp3 : INTERP3;
             float4 interp4 : INTERP4;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.texCoord0;
            output.interp3.xyzw =  input.texCoord1;
            output.interp4.xyzw =  input.texCoord2;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.texCoord0 = input.interp2.xyzw;
            output.texCoord1 = input.interp3.xyzw;
            output.texCoord2 = input.interp4.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _TopAlbedo_TexelSize;
        float4 _TopNormal_TexelSize;
        float4 _TopMetallicRough_TexelSize;
        float _TopMetallic;
        float _TopGlossiness;
        float4 _Noise_TexelSize;
        float4 _MainTex_TexelSize;
        float4 _BumpMap_TexelSize;
        float4 _DetailBump_TexelSize;
        float _DetailScale;
        float4 _OcclusionMap_TexelSize;
        float4 _MetallicRough_TexelSize;
        float _Metallic;
        float _Glossiness;
        float _OcclusionStrength;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_TopAlbedo);
        SAMPLER(sampler_TopAlbedo);
        TEXTURE2D(_TopNormal);
        SAMPLER(sampler_TopNormal);
        TEXTURE2D(_TopMetallicRough);
        SAMPLER(sampler_TopMetallicRough);
        TEXTURE2D(_Noise);
        SAMPLER(sampler_Noise);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        TEXTURE2D(_BumpMap);
        SAMPLER(sampler_BumpMap);
        TEXTURE2D(_DetailBump);
        SAMPLER(sampler_DetailBump);
        TEXTURE2D(_OcclusionMap);
        SAMPLER(sampler_OcclusionMap);
        TEXTURE2D(_MetallicRough);
        SAMPLER(sampler_MetallicRough);
        float _TopScale;
        float _noiseScale;
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 Emission;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_43c517f37e4644129a3c62f9b44c4cc3_Out_0 = UnityBuildTexture2DStructNoScale(_MainTex);
            float4 _SampleTexture2D_39cbc473170e41df85ee0f0a83ef6576_RGBA_0 = SAMPLE_TEXTURE2D(_Property_43c517f37e4644129a3c62f9b44c4cc3_Out_0.tex, _Property_43c517f37e4644129a3c62f9b44c4cc3_Out_0.samplerstate, _Property_43c517f37e4644129a3c62f9b44c4cc3_Out_0.GetTransformedUV(IN.uv0.xy));
            float _SampleTexture2D_39cbc473170e41df85ee0f0a83ef6576_R_4 = _SampleTexture2D_39cbc473170e41df85ee0f0a83ef6576_RGBA_0.r;
            float _SampleTexture2D_39cbc473170e41df85ee0f0a83ef6576_G_5 = _SampleTexture2D_39cbc473170e41df85ee0f0a83ef6576_RGBA_0.g;
            float _SampleTexture2D_39cbc473170e41df85ee0f0a83ef6576_B_6 = _SampleTexture2D_39cbc473170e41df85ee0f0a83ef6576_RGBA_0.b;
            float _SampleTexture2D_39cbc473170e41df85ee0f0a83ef6576_A_7 = _SampleTexture2D_39cbc473170e41df85ee0f0a83ef6576_RGBA_0.a;
            UnityTexture2D _Property_e25deacfb3324ff694a822d7d2782220_Out_0 = UnityBuildTexture2DStructNoScale(_TopAlbedo);
            float _Split_73415ceb64e243dd9b6cdbed882c419e_R_1 = IN.WorldSpacePosition[0];
            float _Split_73415ceb64e243dd9b6cdbed882c419e_G_2 = IN.WorldSpacePosition[1];
            float _Split_73415ceb64e243dd9b6cdbed882c419e_B_3 = IN.WorldSpacePosition[2];
            float _Split_73415ceb64e243dd9b6cdbed882c419e_A_4 = 0;
            float2 _Vector2_5f4c26f1391b4632bf69806499d07368_Out_0 = float2(_Split_73415ceb64e243dd9b6cdbed882c419e_R_1, _Split_73415ceb64e243dd9b6cdbed882c419e_B_3);
            float _Property_4cc655dc7833446f8e8423a5be711b34_Out_0 = _TopScale;
            float2 _Multiply_15222a5e1788439f9cea4567369a72d5_Out_2;
            Unity_Multiply_float2_float2(_Vector2_5f4c26f1391b4632bf69806499d07368_Out_0, (_Property_4cc655dc7833446f8e8423a5be711b34_Out_0.xx), _Multiply_15222a5e1788439f9cea4567369a72d5_Out_2);
            float4 _SampleTexture2D_a48fb84304c3411f9709cd397fa3863a_RGBA_0 = SAMPLE_TEXTURE2D(_Property_e25deacfb3324ff694a822d7d2782220_Out_0.tex, _Property_e25deacfb3324ff694a822d7d2782220_Out_0.samplerstate, _Property_e25deacfb3324ff694a822d7d2782220_Out_0.GetTransformedUV(_Multiply_15222a5e1788439f9cea4567369a72d5_Out_2));
            float _SampleTexture2D_a48fb84304c3411f9709cd397fa3863a_R_4 = _SampleTexture2D_a48fb84304c3411f9709cd397fa3863a_RGBA_0.r;
            float _SampleTexture2D_a48fb84304c3411f9709cd397fa3863a_G_5 = _SampleTexture2D_a48fb84304c3411f9709cd397fa3863a_RGBA_0.g;
            float _SampleTexture2D_a48fb84304c3411f9709cd397fa3863a_B_6 = _SampleTexture2D_a48fb84304c3411f9709cd397fa3863a_RGBA_0.b;
            float _SampleTexture2D_a48fb84304c3411f9709cd397fa3863a_A_7 = _SampleTexture2D_a48fb84304c3411f9709cd397fa3863a_RGBA_0.a;
            UnityTexture2D _Property_4bdc709e69274a8abd70923126c48288_Out_0 = UnityBuildTexture2DStructNoScale(_Noise);
            float _Property_6b0c37a327bd4d6cb692e37ecd028405_Out_0 = _noiseScale;
            float2 _Multiply_fe25618f7cdf431e8c9baf94f854e2fe_Out_2;
            Unity_Multiply_float2_float2(_Multiply_15222a5e1788439f9cea4567369a72d5_Out_2, (_Property_6b0c37a327bd4d6cb692e37ecd028405_Out_0.xx), _Multiply_fe25618f7cdf431e8c9baf94f854e2fe_Out_2);
            float4 _SampleTexture2D_635f4dc215c440f8b6eec0882db2d3aa_RGBA_0 = SAMPLE_TEXTURE2D(_Property_4bdc709e69274a8abd70923126c48288_Out_0.tex, _Property_4bdc709e69274a8abd70923126c48288_Out_0.samplerstate, _Property_4bdc709e69274a8abd70923126c48288_Out_0.GetTransformedUV(_Multiply_fe25618f7cdf431e8c9baf94f854e2fe_Out_2));
            float _SampleTexture2D_635f4dc215c440f8b6eec0882db2d3aa_R_4 = _SampleTexture2D_635f4dc215c440f8b6eec0882db2d3aa_RGBA_0.r;
            float _SampleTexture2D_635f4dc215c440f8b6eec0882db2d3aa_G_5 = _SampleTexture2D_635f4dc215c440f8b6eec0882db2d3aa_RGBA_0.g;
            float _SampleTexture2D_635f4dc215c440f8b6eec0882db2d3aa_B_6 = _SampleTexture2D_635f4dc215c440f8b6eec0882db2d3aa_RGBA_0.b;
            float _SampleTexture2D_635f4dc215c440f8b6eec0882db2d3aa_A_7 = _SampleTexture2D_635f4dc215c440f8b6eec0882db2d3aa_RGBA_0.a;
            float _Split_2fa854d8373b43319e3815f773f182a3_R_1 = IN.WorldSpaceNormal[0];
            float _Split_2fa854d8373b43319e3815f773f182a3_G_2 = IN.WorldSpaceNormal[1];
            float _Split_2fa854d8373b43319e3815f773f182a3_B_3 = IN.WorldSpaceNormal[2];
            float _Split_2fa854d8373b43319e3815f773f182a3_A_4 = 0;
            float _Clamp_8d87bc8399b744c8b4ded4378bcce6e2_Out_3;
            Unity_Clamp_float(_Split_2fa854d8373b43319e3815f773f182a3_G_2, 0, 1, _Clamp_8d87bc8399b744c8b4ded4378bcce6e2_Out_3);
            float _Smoothstep_8d527e2955cd4ea99e6c0611c3827735_Out_3;
            Unity_Smoothstep_float(_SampleTexture2D_635f4dc215c440f8b6eec0882db2d3aa_R_4, 1, _Clamp_8d87bc8399b744c8b4ded4378bcce6e2_Out_3, _Smoothstep_8d527e2955cd4ea99e6c0611c3827735_Out_3);
            float _Smoothstep_87f8055d79104aeab092ae8a9aa36fea_Out_3;
            Unity_Smoothstep_float(0.1, 0.2, _Smoothstep_8d527e2955cd4ea99e6c0611c3827735_Out_3, _Smoothstep_87f8055d79104aeab092ae8a9aa36fea_Out_3);
            float4 _Lerp_45fd290440944ec2a7bed0c07e3c9b69_Out_3;
            Unity_Lerp_float4(_SampleTexture2D_39cbc473170e41df85ee0f0a83ef6576_RGBA_0, _SampleTexture2D_a48fb84304c3411f9709cd397fa3863a_RGBA_0, (_Smoothstep_87f8055d79104aeab092ae8a9aa36fea_Out_3.xxxx), _Lerp_45fd290440944ec2a7bed0c07e3c9b69_Out_3);
            surface.BaseColor = (_Lerp_45fd290440944ec2a7bed0c07e3c9b69_Out_3.xyz);
            surface.Emission = float3(0, 0, 0);
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
            
        
            // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
            float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);
        
        
            output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
        
        
            output.WorldSpacePosition = input.positionWS;
            output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"
        
        ENDHLSL
        }
        Pass
        {
            // Name: <None>
            Tags
            {
                "LightMode" = "Universal2D"
            }
        
        // Render State
        Cull Back
        Blend One Zero
        ZTest LEqual
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_2D
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpaceNormal;
             float3 WorldSpacePosition;
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float3 interp1 : INTERP1;
             float4 interp2 : INTERP2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.texCoord0 = input.interp2.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _TopAlbedo_TexelSize;
        float4 _TopNormal_TexelSize;
        float4 _TopMetallicRough_TexelSize;
        float _TopMetallic;
        float _TopGlossiness;
        float4 _Noise_TexelSize;
        float4 _MainTex_TexelSize;
        float4 _BumpMap_TexelSize;
        float4 _DetailBump_TexelSize;
        float _DetailScale;
        float4 _OcclusionMap_TexelSize;
        float4 _MetallicRough_TexelSize;
        float _Metallic;
        float _Glossiness;
        float _OcclusionStrength;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_TopAlbedo);
        SAMPLER(sampler_TopAlbedo);
        TEXTURE2D(_TopNormal);
        SAMPLER(sampler_TopNormal);
        TEXTURE2D(_TopMetallicRough);
        SAMPLER(sampler_TopMetallicRough);
        TEXTURE2D(_Noise);
        SAMPLER(sampler_Noise);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        TEXTURE2D(_BumpMap);
        SAMPLER(sampler_BumpMap);
        TEXTURE2D(_DetailBump);
        SAMPLER(sampler_DetailBump);
        TEXTURE2D(_OcclusionMap);
        SAMPLER(sampler_OcclusionMap);
        TEXTURE2D(_MetallicRough);
        SAMPLER(sampler_MetallicRough);
        float _TopScale;
        float _noiseScale;
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_43c517f37e4644129a3c62f9b44c4cc3_Out_0 = UnityBuildTexture2DStructNoScale(_MainTex);
            float4 _SampleTexture2D_39cbc473170e41df85ee0f0a83ef6576_RGBA_0 = SAMPLE_TEXTURE2D(_Property_43c517f37e4644129a3c62f9b44c4cc3_Out_0.tex, _Property_43c517f37e4644129a3c62f9b44c4cc3_Out_0.samplerstate, _Property_43c517f37e4644129a3c62f9b44c4cc3_Out_0.GetTransformedUV(IN.uv0.xy));
            float _SampleTexture2D_39cbc473170e41df85ee0f0a83ef6576_R_4 = _SampleTexture2D_39cbc473170e41df85ee0f0a83ef6576_RGBA_0.r;
            float _SampleTexture2D_39cbc473170e41df85ee0f0a83ef6576_G_5 = _SampleTexture2D_39cbc473170e41df85ee0f0a83ef6576_RGBA_0.g;
            float _SampleTexture2D_39cbc473170e41df85ee0f0a83ef6576_B_6 = _SampleTexture2D_39cbc473170e41df85ee0f0a83ef6576_RGBA_0.b;
            float _SampleTexture2D_39cbc473170e41df85ee0f0a83ef6576_A_7 = _SampleTexture2D_39cbc473170e41df85ee0f0a83ef6576_RGBA_0.a;
            UnityTexture2D _Property_e25deacfb3324ff694a822d7d2782220_Out_0 = UnityBuildTexture2DStructNoScale(_TopAlbedo);
            float _Split_73415ceb64e243dd9b6cdbed882c419e_R_1 = IN.WorldSpacePosition[0];
            float _Split_73415ceb64e243dd9b6cdbed882c419e_G_2 = IN.WorldSpacePosition[1];
            float _Split_73415ceb64e243dd9b6cdbed882c419e_B_3 = IN.WorldSpacePosition[2];
            float _Split_73415ceb64e243dd9b6cdbed882c419e_A_4 = 0;
            float2 _Vector2_5f4c26f1391b4632bf69806499d07368_Out_0 = float2(_Split_73415ceb64e243dd9b6cdbed882c419e_R_1, _Split_73415ceb64e243dd9b6cdbed882c419e_B_3);
            float _Property_4cc655dc7833446f8e8423a5be711b34_Out_0 = _TopScale;
            float2 _Multiply_15222a5e1788439f9cea4567369a72d5_Out_2;
            Unity_Multiply_float2_float2(_Vector2_5f4c26f1391b4632bf69806499d07368_Out_0, (_Property_4cc655dc7833446f8e8423a5be711b34_Out_0.xx), _Multiply_15222a5e1788439f9cea4567369a72d5_Out_2);
            float4 _SampleTexture2D_a48fb84304c3411f9709cd397fa3863a_RGBA_0 = SAMPLE_TEXTURE2D(_Property_e25deacfb3324ff694a822d7d2782220_Out_0.tex, _Property_e25deacfb3324ff694a822d7d2782220_Out_0.samplerstate, _Property_e25deacfb3324ff694a822d7d2782220_Out_0.GetTransformedUV(_Multiply_15222a5e1788439f9cea4567369a72d5_Out_2));
            float _SampleTexture2D_a48fb84304c3411f9709cd397fa3863a_R_4 = _SampleTexture2D_a48fb84304c3411f9709cd397fa3863a_RGBA_0.r;
            float _SampleTexture2D_a48fb84304c3411f9709cd397fa3863a_G_5 = _SampleTexture2D_a48fb84304c3411f9709cd397fa3863a_RGBA_0.g;
            float _SampleTexture2D_a48fb84304c3411f9709cd397fa3863a_B_6 = _SampleTexture2D_a48fb84304c3411f9709cd397fa3863a_RGBA_0.b;
            float _SampleTexture2D_a48fb84304c3411f9709cd397fa3863a_A_7 = _SampleTexture2D_a48fb84304c3411f9709cd397fa3863a_RGBA_0.a;
            UnityTexture2D _Property_4bdc709e69274a8abd70923126c48288_Out_0 = UnityBuildTexture2DStructNoScale(_Noise);
            float _Property_6b0c37a327bd4d6cb692e37ecd028405_Out_0 = _noiseScale;
            float2 _Multiply_fe25618f7cdf431e8c9baf94f854e2fe_Out_2;
            Unity_Multiply_float2_float2(_Multiply_15222a5e1788439f9cea4567369a72d5_Out_2, (_Property_6b0c37a327bd4d6cb692e37ecd028405_Out_0.xx), _Multiply_fe25618f7cdf431e8c9baf94f854e2fe_Out_2);
            float4 _SampleTexture2D_635f4dc215c440f8b6eec0882db2d3aa_RGBA_0 = SAMPLE_TEXTURE2D(_Property_4bdc709e69274a8abd70923126c48288_Out_0.tex, _Property_4bdc709e69274a8abd70923126c48288_Out_0.samplerstate, _Property_4bdc709e69274a8abd70923126c48288_Out_0.GetTransformedUV(_Multiply_fe25618f7cdf431e8c9baf94f854e2fe_Out_2));
            float _SampleTexture2D_635f4dc215c440f8b6eec0882db2d3aa_R_4 = _SampleTexture2D_635f4dc215c440f8b6eec0882db2d3aa_RGBA_0.r;
            float _SampleTexture2D_635f4dc215c440f8b6eec0882db2d3aa_G_5 = _SampleTexture2D_635f4dc215c440f8b6eec0882db2d3aa_RGBA_0.g;
            float _SampleTexture2D_635f4dc215c440f8b6eec0882db2d3aa_B_6 = _SampleTexture2D_635f4dc215c440f8b6eec0882db2d3aa_RGBA_0.b;
            float _SampleTexture2D_635f4dc215c440f8b6eec0882db2d3aa_A_7 = _SampleTexture2D_635f4dc215c440f8b6eec0882db2d3aa_RGBA_0.a;
            float _Split_2fa854d8373b43319e3815f773f182a3_R_1 = IN.WorldSpaceNormal[0];
            float _Split_2fa854d8373b43319e3815f773f182a3_G_2 = IN.WorldSpaceNormal[1];
            float _Split_2fa854d8373b43319e3815f773f182a3_B_3 = IN.WorldSpaceNormal[2];
            float _Split_2fa854d8373b43319e3815f773f182a3_A_4 = 0;
            float _Clamp_8d87bc8399b744c8b4ded4378bcce6e2_Out_3;
            Unity_Clamp_float(_Split_2fa854d8373b43319e3815f773f182a3_G_2, 0, 1, _Clamp_8d87bc8399b744c8b4ded4378bcce6e2_Out_3);
            float _Smoothstep_8d527e2955cd4ea99e6c0611c3827735_Out_3;
            Unity_Smoothstep_float(_SampleTexture2D_635f4dc215c440f8b6eec0882db2d3aa_R_4, 1, _Clamp_8d87bc8399b744c8b4ded4378bcce6e2_Out_3, _Smoothstep_8d527e2955cd4ea99e6c0611c3827735_Out_3);
            float _Smoothstep_87f8055d79104aeab092ae8a9aa36fea_Out_3;
            Unity_Smoothstep_float(0.1, 0.2, _Smoothstep_8d527e2955cd4ea99e6c0611c3827735_Out_3, _Smoothstep_87f8055d79104aeab092ae8a9aa36fea_Out_3);
            float4 _Lerp_45fd290440944ec2a7bed0c07e3c9b69_Out_3;
            Unity_Lerp_float4(_SampleTexture2D_39cbc473170e41df85ee0f0a83ef6576_RGBA_0, _SampleTexture2D_a48fb84304c3411f9709cd397fa3863a_RGBA_0, (_Smoothstep_87f8055d79104aeab092ae8a9aa36fea_Out_3.xxxx), _Lerp_45fd290440944ec2a7bed0c07e3c9b69_Out_3);
            surface.BaseColor = (_Lerp_45fd290440944ec2a7bed0c07e3c9b69_Out_3.xyz);
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
            
        
            // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
            float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);
        
        
            output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
        
        
            output.WorldSpacePosition = input.positionWS;
            output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"
        
        ENDHLSL
        }
        Pass
        {
            Name "SceneSelectionPass"
            Tags
            {
                "LightMode" = "SceneSelectionPass"
            }
        
            // Render State
            Cull Off
        
            // Debug
            // <None>
        
            // --------------------------------------------------
            // Pass
        
            HLSLPROGRAM
        
            // Pragmas
            #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>
        
            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>
        
            // Defines
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENESELECTIONPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
            // Includes
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreInclude' */
        
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
            // --------------------------------------------------
            // Structs and Packing
        
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
            struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
            // --------------------------------------------------
            // Graph
        
            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 _TopAlbedo_TexelSize;
        float4 _TopNormal_TexelSize;
        float4 _TopMetallicRough_TexelSize;
        float _TopMetallic;
        float _TopGlossiness;
        float4 _Noise_TexelSize;
        float4 _MainTex_TexelSize;
        float4 _BumpMap_TexelSize;
        float4 _DetailBump_TexelSize;
        float _DetailScale;
        float4 _OcclusionMap_TexelSize;
        float4 _MetallicRough_TexelSize;
        float _Metallic;
        float _Glossiness;
        float _OcclusionStrength;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_TopAlbedo);
        SAMPLER(sampler_TopAlbedo);
        TEXTURE2D(_TopNormal);
        SAMPLER(sampler_TopNormal);
        TEXTURE2D(_TopMetallicRough);
        SAMPLER(sampler_TopMetallicRough);
        TEXTURE2D(_Noise);
        SAMPLER(sampler_Noise);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        TEXTURE2D(_BumpMap);
        SAMPLER(sampler_BumpMap);
        TEXTURE2D(_DetailBump);
        SAMPLER(sampler_DetailBump);
        TEXTURE2D(_OcclusionMap);
        SAMPLER(sampler_OcclusionMap);
        TEXTURE2D(_MetallicRough);
        SAMPLER(sampler_MetallicRough);
        float _TopScale;
        float _noiseScale;
        
            // Graph Includes
            // GraphIncludes: <None>
        
            // -- Property used by ScenePickingPass
            #ifdef SCENEPICKINGPASS
            float4 _SelectionID;
            #endif
        
            // -- Properties used by SceneSelectionPass
            #ifdef SCENESELECTIONPASS
            int _ObjectId;
            int _PassValue;
            #endif
        
            // Graph Functions
            // GraphFunctions: <None>
        
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
            #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
            // Graph Pixel
            struct SurfaceDescription
        {
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            return surface;
        }
        
            // --------------------------------------------------
            // Build Graph Inputs
        
            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
            
        
        
        
        
        
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN                output.FaceSign =                                   IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
            return output;
        }
        
            // --------------------------------------------------
            // Main
        
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
        
            ENDHLSL
        }
        Pass
        {
            Name "ScenePickingPass"
            Tags
            {
                "LightMode" = "Picking"
            }
        
            // Render State
            Cull Back
        
            // Debug
            // <None>
        
            // --------------------------------------------------
            // Pass
        
            HLSLPROGRAM
        
            // Pragmas
            #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>
        
            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>
        
            // Defines
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENEPICKINGPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
            // Includes
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreInclude' */
        
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
            // --------------------------------------------------
            // Structs and Packing
        
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
            struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
            // --------------------------------------------------
            // Graph
        
            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 _TopAlbedo_TexelSize;
        float4 _TopNormal_TexelSize;
        float4 _TopMetallicRough_TexelSize;
        float _TopMetallic;
        float _TopGlossiness;
        float4 _Noise_TexelSize;
        float4 _MainTex_TexelSize;
        float4 _BumpMap_TexelSize;
        float4 _DetailBump_TexelSize;
        float _DetailScale;
        float4 _OcclusionMap_TexelSize;
        float4 _MetallicRough_TexelSize;
        float _Metallic;
        float _Glossiness;
        float _OcclusionStrength;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_TopAlbedo);
        SAMPLER(sampler_TopAlbedo);
        TEXTURE2D(_TopNormal);
        SAMPLER(sampler_TopNormal);
        TEXTURE2D(_TopMetallicRough);
        SAMPLER(sampler_TopMetallicRough);
        TEXTURE2D(_Noise);
        SAMPLER(sampler_Noise);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        TEXTURE2D(_BumpMap);
        SAMPLER(sampler_BumpMap);
        TEXTURE2D(_DetailBump);
        SAMPLER(sampler_DetailBump);
        TEXTURE2D(_OcclusionMap);
        SAMPLER(sampler_OcclusionMap);
        TEXTURE2D(_MetallicRough);
        SAMPLER(sampler_MetallicRough);
        float _TopScale;
        float _noiseScale;
        
            // Graph Includes
            // GraphIncludes: <None>
        
            // -- Property used by ScenePickingPass
            #ifdef SCENEPICKINGPASS
            float4 _SelectionID;
            #endif
        
            // -- Properties used by SceneSelectionPass
            #ifdef SCENESELECTIONPASS
            int _ObjectId;
            int _PassValue;
            #endif
        
            // Graph Functions
            // GraphFunctions: <None>
        
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
            #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
            // Graph Pixel
            struct SurfaceDescription
        {
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            return surface;
        }
        
            // --------------------------------------------------
            // Build Graph Inputs
        
            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
            
        
        
        
        
        
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN                output.FaceSign =                                   IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
            return output;
        }
        
            // --------------------------------------------------
            // Main
        
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
        
            ENDHLSL
        }
    }
    CustomEditorForRenderPipeline "UnityEditor.ShaderGraphLitGUI" "UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset"
    CustomEditor "UnityEditor.ShaderGraph.GenericShaderGraphMaterialGUI"
    FallBack "Hidden/Shader Graph/FallbackError"
}