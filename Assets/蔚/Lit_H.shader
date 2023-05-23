Shader "Universal Render Pipeline/Lit_h"
{
    Properties
    {
         _BaseMap("主纹理", 2D) = "white" {}
         _BaseColor("主纹理颜色", Color) = (1,1,1,1)
         _MaskMap("遮罩",2D) ="white"{}
        _Smoothness("光滑度", Range(0.0, 1.0)) = 0.5
        _Metallic("金属强度", Range(0.0, 5.0)) = 0.0
        _MetallicGlossMap("金属粗糙图", 2D) = "white" {}
        _SpecColor("高光颜色", Color) = (0.2, 0.2, 0.2)
        [ToggleOff] _EnvironmentReflections("是否开启环境反射", Float) = 1.0
        _BumpScale("法线强度", Float) = 1.0
        _BumpMap("法线图", 2D) = "bump" {}
        _Parallax("视差强度", Range(0.005, 0.08)) = 0.005
        _OcclusionStrength("AO强度", Range(0.0, 1.0)) = 1.0
        [HDR] _EmissionColor("自发光颜色", Color) = (0,0,0)
        _EmissionMap("自发光遮罩图", 2D) = "white" {}
         _Cubemap    ("RGB:环境贴图", cube)              = "_Skybox" {}
          _CubemapMip ("环境球Mip", Range(0, 7))          = 0
        _CubemapRange("环境贴图范围",range(0,10))=1
     //   _Factor ("描边大小",range(0,10))=0.1
      [HDR]  _B("边缘光颜色",color)=(1,1,1,1)
        _H("描边贴图",2D)= "white" {}
        _SSS("SSS图",2D) = "white"{}
        _SSSStrength("3S强度",range(0,6))=1
     //   _ssssssss("消融速度",range(0,1))=0.5
        
        _DissolveMap("消融贴图", 2D) = "white"{}
        _DissolveCol1("消融颜色1",color)=(1,1,1,1)
        _DissolveCol2("消融颜色2",color)=(1,1,1,1)
        _DissolveOffset("消融边界",float)=1
      //  _Dissolvetan("消融时间",float)=0
        
      //  _Surface("__surface", Float) = 0.0
       // _Blend("__blend", Float) = 0.0
       [Enum(UnityEngine.Rendering.CullMode)] _Cull("剔除", Float) = 2.0
        [ToggleUI] _AlphaClip("透切开关", Float) = 0.0
        [ToggleUI] _Fo("开关", Float) = 0.0
        [HideInInspector] _Cutoff("透切阈值", Range(0.0, 1.0)) = 0.5
        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend("混合源乘子", Float) = 1.0
        [Enum(UnityEngine.Rendering.BlendMode)]  _DstBlend("混合目标乘子", Float) = 0.0
         [Enum(UnityEngine.Rendering.BlendOp)] _BlendOp("运算符",Float) = 0
         [Enum(off,0,on,1)] _ZWrite("深度", Float) = 1.0
        [Enum(UnityEngine.Rendering.CompareFunction)] _ZTestMode("Ztest",Float) = 0
        [Enum(UnityEngine.Rendering.ColorWriteMask)] _ColorMask("颜色的遮罩",Float) = 0
    }

    SubShader
    {
        Tags{
//            "RenderPipeline"="UniversalRenderPipeline"
//            "RenderType"="Transparent"
//            "IgnoreProjector"="True"
//            "Queue"="Transparent"}
            
            "RenderType" = "Opaque" 
            "RenderPipeline" = "UniversalPipeline"
             "UniversalMaterialType" = "Lit" 
            "IgnoreProjector" = "True" "ShaderModel"="4.5"}
        LOD 300
        Pass
        {
            Name "ForwardLit"
            Tags{"LightMode" = "UniversalForward"}
           // Blend One OneMinusSrcAlpha
            BlendOp[_BlendOp]
            Blend[_SrcBlend][_DstBlend]
            ZWrite[_ZWrite]
            Cull[_Cull]
            ZTest[_ZTestMode]
            ColorMask[_ColorMask]
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
            #pragma shader_feature_local_fragment _OCCLUSIONMAP
            #pragma shader_feature_local_fragment _ENVIRONMENTREFLECTIONS_OFF
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
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
            #pragma shader_feature _ _Fo _Diss
            #pragma multi_compile_fog
            #pragma vertex LitPassVertex
            #pragma fragment LitPassFragment 
            #include "LitInput.hlsl"
            //            #include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
            #include "Lighting.hlsl"
            TEXTURE2D(_MaskMap);
            SAMPLER(sampler_MaskMap);
            uniform float4 _MaskMap_ST;
            TEXTURE2D(_SSS);
            SAMPLER(sampler_SSS);
            uniform float4 _SSS_ST;
            uniform  float _SSSStrength;
            uniform  float   _ssssssss;
            uniform float    _CubemapMip;
            uniform float    _CubemapRange;
            uniform float3    _B;
            uniform samplerCUBE _Cubemap;
            TEXTURE2D(_DissolveMap);
            SAMPLER(sampler_DissolveMap);
            uniform half4 _DissolveMap_ST;
            uniform float4 _DissolveCol1;
            uniform float4 _DissolveCol2;
            uniform float _DissolveOffset;
            uniform float _Dissolvetan;
struct Attributes
{
    float4 positionOS   : POSITION;
    float3 normalOS     : NORMAL;
    float4 tangentOS    : TANGENT;
    float2 texcoord     : TEXCOORD0;
    float2 staticLightmapUV   : TEXCOORD1;
};
struct Varyings
{
    float2 uv                       : TEXCOORD0;
    float3 positionWS               : TEXCOORD1;
    float3 normalWS                 : TEXCOORD2;
    half4 tangentWS                : TEXCOORD3;    // xyz: tangent, w: sign
    float3 viewDirWS                : TEXCOORD4;
    half  fogFactor                 : TEXCOORD5;
    float4 shadowCoord              : TEXCOORD6;
    half3 viewDirTS                : TEXCOORD7;
    DECLARE_LIGHTMAP_OR_SH(staticLightmapUV, vertexSH, 8);
    float4 positionCS               : SV_POSITION;
     half2 uv1 : TEXCOORD9;    //输出消融
};
Varyings LitPassVertex(Attributes input)
{
    Varyings output = (Varyings)0;
    VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
    VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);
    half3 vertexLight = VertexLighting(vertexInput.positionWS, normalInput.normalWS);
    output.uv = TRANSFORM_TEX(input.texcoord, _BaseMap);
    output.uv1 = TRANSFORM_TEX(input.texcoord, _DissolveMap);
    output.normalWS = normalInput.normalWS;
    real sign = input.tangentOS.w * GetOddNegativeScale();
    output.tangentWS = half4(normalInput.tangentWS.xyz, sign);
    output.viewDirWS = GetWorldSpaceNormalizeViewDir(vertexInput.positionWS);
    output.viewDirTS = GetViewDirectionTangentSpace(output.tangentWS, output.normalWS, output.viewDirWS);
    OUTPUT_LIGHTMAP_UV(input.staticLightmapUV, unity_LightmapST, output.staticLightmapUV);
    OUTPUT_SH(output.normalWS.xyz, output.vertexSH);
    output.fogFactor = ComputeFogFactor(vertexInput.positionCS.z);
    output.positionWS = vertexInput.positionWS;
    output.shadowCoord = GetShadowCoord(vertexInput);
    output.positionCS = vertexInput.positionCS;
    return output;
}
half4 LitPassFragment(Varyings input) : SV_Target
{
    half3 viewDirWS = input.viewDirWS;
    half3 viewDirTS = input.viewDirTS;
     
    ApplyPerPixelDisplacement(viewDirTS, input.uv);
    SurfaceData surfaceData;
    half4 albedoAlpha =  SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap,input. uv);
    surfaceData.alpha = albedoAlpha.a;
    half4 specGloss=half4(SAMPLE_METALLICSPECULAR(input.uv));
     half4 maskmap =  SAMPLE_TEXTURE2D(_MaskMap, sampler_MaskMap,input. uv);
    half occ = maskmap.r;
    half AO= LerpWhiteTo(occ, _OcclusionStrength);
    surfaceData.albedo = albedoAlpha.rgb * _BaseColor.rgb;
    surfaceData.metallic = specGloss.r*_Metallic;
    surfaceData.specular = -specGloss.g;
    surfaceData.smoothness = specGloss.g*_Smoothness;
    surfaceData.normalTS =UnpackNormalScale(SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap,input. uv),_BumpScale);
    surfaceData.occlusion = AO;
    surfaceData.emission = SAMPLE_TEXTURE2D(_EmissionMap, sampler_EmissionMap,input. uv)*_EmissionColor;// TEXTURE2D_ARGS(_EmissionMap, sampler_EmissionMap);
   

    surfaceData.clearCoatMask       = half(0.0);
    surfaceData.clearCoatSmoothness = half(0.0);





    
    InputData inputData;
    inputData.positionWS = input.positionWS;
    //法线 
    float sgn = input.tangentWS.w;      // should be either +1 or -1
    float3 bitangent = sgn * cross(input.normalWS.xyz, input.tangentWS.xyz);
    half3x3 tangentToWorld = half3x3(input.tangentWS.xyz, bitangent.xyz, input.normalWS.xyz);
    inputData.tangentToWorld = tangentToWorld;
    inputData.normalWS = TransformTangentToWorld(surfaceData.normalTS, tangentToWorld);
    inputData.normalWS = NormalizeNormalPerPixel(inputData.normalWS);
    float3 vrDirWS = reflect(-viewDirWS,inputData. normalWS);
     float3 var_Cubemap = texCUBElod(_Cubemap, float4(vrDirWS, _CubemapMip)).rgb;
     float3 fresnel = pow(max(0.0, 1.0 - dot(viewDirWS, inputData. normalWS)), _CubemapRange)*0.5;
    inputData.viewDirectionWS = viewDirWS;
//实时光阴影
#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
    inputData.shadowCoord = input.shadowCoord;
#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
    inputData.shadowCoord = TransformWorldToShadowCoord(inputData.positionWS);
#else
    inputData.shadowCoord = float4(0, 0, 0, 0);
#endif
    inputData.fogCoord = InitializeInputDataFog(float4(input.positionWS, 1.0), input.fogFactor);
//光照烘培
    inputData.bakedGI = SAMPLE_GI(input.staticLightmapUV, input.vertexSH, inputData.normalWS);
    //法线的屏幕UV转换
    inputData.normalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(input.positionCS);
    //shadowmask的采样
    inputData.shadowMask = SAMPLE_SHADOWMASK(input.staticLightmapUV);
    #if defined(DEBUG_DISPLAY)
    //静态阴影
    #if defined(LIGHTMAP_ON)
    inputData.staticLightmapUV = input.staticLightmapUV;
    #else
    inputData.vertexSH = input.vertexSH;
    #endif
    #endif
    
    SETUP_DEBUG_TEXTURE_DATA(inputData, input.uv, _BaseMap);
#ifdef _DBUFFER
    ApplyDecalToSurfaceData(input.positionCS, surfaceData, inputData);
#endif
 BRDFData brdfData;
    InitializeBRDFData(surfaceData, brdfData);
    BRDFData brdfDataClearCoat = CreateClearCoatBRDFData(surfaceData, brdfData);
    half4 shadowMask = CalculateShadowMask(inputData);
    AmbientOcclusionFactor aoFactor = CreateAmbientOcclusionFactor(inputData, surfaceData);
    uint meshRenderingLayers = GetMeshRenderingLightLayer();
    Light mainLight = GetMainLight(inputData, shadowMask, aoFactor);
    MixRealtimeAndBakedGI(mainLight, inputData.normalWS, inputData.bakedGI);

    
    LightingData lightingData = CreateLightingData(inputData, surfaceData);

    
    lightingData.giColor = GlobalIllumination(brdfData, brdfDataClearCoat, surfaceData.clearCoatMask,
                                              inputData.bakedGI, aoFactor.indirectAmbientOcclusion, inputData.positionWS,
                                              inputData.normalWS, inputData.viewDirectionWS);
    if (IsMatchingLightLayer(mainLight.layerMask, meshRenderingLayers))
    {

        
        // lightingData.mainLightColor = LightingPhysicallyBased(brdfData, brdfDataClearCoat,
        //                                                       mainLight,
        //                                                       inputData.normalWS, inputData.viewDirectionWS,
        //                                                       surfaceData.clearCoatMask, false);


        // lightingData.mainLightColor = LightingPhysicallyBased
        //     (brdfData, brdfDataClearCoat, mainLight.color, mainLight.direction,
        //     mainLight.distanceAttenuation * mainLight.shadowAttenuation,
        //     inputData.normalWS, inputData.viewDirectionWS, surfaceData.clearCoatMask, false);
 //half NdotL = saturate(dot(inputData.normalWS, mainLight.direction));
        half NdotL = dot(inputData.normalWS, mainLight.direction);
    half halfLambert = NdotL*0.5+0.5;

    half3 var_DiffWarpTex =  SAMPLE_TEXTURE2D(_SSS, sampler_SSS,half2(halfLambert, 0.2));  
        
    half3 NL = lerp(halfLambert,var_DiffWarpTex,_SSSStrength);
        
    half3 radiance = mainLight.color *  NL*(mainLight.distanceAttenuation * mainLight.shadowAttenuation );

    half3 brdf = brdfData.diffuse;
#ifndef _SPECULARHIGHLIGHTS_OFF
    [branch] if (!false)
    {
        brdf += brdfData.specular * DirectBRDFSpecular(brdfData, inputData.normalWS, mainLight.direction, inputData.viewDirectionWS);
#if defined(_CLEARCOAT) || defined(_CLEARCOATMAP)
        half brdfCoat = kDielectricSpec.r * DirectBRDFSpecular(brdfDataClearCoat, normalWS, lightDirectionWS, viewDirectionWS);
            half NoV = saturate(dot(normalWS, viewDirectionWS));
            half coatFresnel = kDielectricSpec.x + kDielectricSpec.a * Pow4(1.0 - NoV);
        brdf = brdf * (1.0 - clearCoatMask * coatFresnel) + brdfCoat * clearCoatMask;
#endif // _CLEARCOAT
    }
#endif // _SPECULARHIGHLIGHTS_OFF
        
     lightingData.mainLightColor= brdf * radiance;
    }
    #if defined(_ADDITIONAL_LIGHTS)
    uint pixelLightCount = GetAdditionalLightsCount();
    
    #if USE_CLUSTERED_LIGHTING
    for (uint lightIndex = 0; lightIndex < min(_AdditionalLightsDirectionalCount, MAX_VISIBLE_LIGHTS); lightIndex++)
    {
        Light light = GetAdditionalLight(lightIndex, inputData, shadowMask, aoFactor);
    
        if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers))
        {
            lightingData.additionalLightsColor += LightingPhysicallyBased(brdfData, brdfDataClearCoat, light,
                                                                          inputData.normalWS, inputData.viewDirectionWS,
                                                                          surfaceData.clearCoatMask, false);
        }
    }
    #endif
    
    LIGHT_LOOP_BEGIN(pixelLightCount)
        Light light = GetAdditionalLight(lightIndex, inputData, shadowMask, aoFactor);
    
        if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers))
        {
            lightingData.additionalLightsColor += LightingPhysicallyBased(brdfData, brdfDataClearCoat, light,
                                                                          inputData.normalWS, inputData.viewDirectionWS,
                                                                          surfaceData.clearCoatMask, false);
        }
    LIGHT_LOOP_END
    #endif
    #if defined(_ADDITIONAL_LIGHTS_VERTEX)
    lightingData.vertexLightingColor += inputData.vertexLighting * brdfData.diffuse;
    #endif
    
   half3 color =CalculateLightingColor(lightingData, 1);
    clip( albedoAlpha.a - _Cutoff );
#if _Diss
    
                float var_DissolveMap1 = SAMPLE_TEXTURE2D(_DissolveMap, sampler_DissolveMap,input.uv1).r*_Dissolvetan*2;  
                float var_DissolveMap2 =SAMPLE_TEXTURE2D(_DissolveMap, sampler_DissolveMap,input.uv1).g*_Dissolvetan*2;
                half   var_DissolveMap=var_DissolveMap2+var_DissolveMap1;
                color = lerp(color,_DissolveCol1,saturate(var_DissolveMap+_DissolveOffset+1));
               color = lerp(color,_DissolveCol2,saturate(var_DissolveMap+_DissolveOffset+0.1));
              //  var_MainTex.a = lerp(   var_MainTex.a,   -var_DissolveMap-_DissolveOffset+10-i.pos.y,0.01             );
                 half a =  -var_DissolveMap-_DissolveOffset+1;
          //    step( _ssssssss +0.1);
              float var_DissolveMap00 = SAMPLE_TEXTURE2D(_DissolveMap, sampler_DissolveMap,input.uv1);
               albedoAlpha.a=var_DissolveMap00;
    clip(a);
#endif
    
    #if _Fo
    color.rgb +=fresnel*_B;
    #else
     color.rgb= color.rgb;
    #endif
    
        color.rgb = MixFog(color.rgb, inputData.fogCoord)+var_Cubemap*fresnel;
   // #endif
    return        half4(color,albedoAlpha.a);
}
            ENDHLSL
        }

//        Pass
//        {
//            Name "ShadowCaster"
//            Tags{"LightMode" = "ShadowCaster"}
//
//            ZWrite On
//            ZTest LEqual
//            ColorMask 0
//            Cull[_Cull]
//
//            HLSLPROGRAM
//            #pragma exclude_renderers gles gles3 glcore
//            #pragma target 4.5
//
//            // -------------------------------------
//            // Material Keywords
//            #pragma shader_feature_local_fragment _ALPHATEST_ON
//            #pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
//
//            //--------------------------------------
//            // GPU Instancing
//            #pragma multi_compile_instancing
//            #pragma multi_compile _ DOTS_INSTANCING_ON
//
//            // -------------------------------------
//            // Universal Pipeline keywords
//
//            // This is used during shadow map generation to differentiate between directional and punctual light shadows, as they use different formulas to apply Normal Bias
//            #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
//
//            #pragma vertex ShadowPassVertex
//            #pragma fragment ShadowPassFragment
//
//            #include "LitInput.hlsl"
//            #include "Packages/com.unity.render-pipelines.universal/Shaders/ShadowCasterPass.hlsl"
//            ENDHLSL
//        }

                pass
        {
 
            Name "ShadowCast"
 
			Tags{ "LightMode" = "ShadowCaster" }
 
             HLSLPROGRAM
             #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
            #pragma vertex vert
            #pragma fragment frag
 
             //开启ALPHA 测试，主要是做镂空
            #pragma shader_feature _ALPHATEST_ON
 
 
            struct a2v {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };
            struct v2f {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };
 
            // 以下三个 uniform 在 URP shadows.hlsl 相关代码中可以看到没有放到 CBuffer 块中，所以我们只要在 定义为不同的 uniform 即可
             float3 _LightDirection;
             sampler2D _BaseMap;
 
            v2f vert(a2v v)
            {
                v2f o = (v2f)0;
                float3 worldPos = TransformObjectToWorld(v.vertex.xyz);
                half3 normalWS = TransformObjectToWorldNormal(v.normal);
 
 
                worldPos = ApplyShadowBias(worldPos,normalWS,_LightDirection);
                o.vertex = TransformWorldToHClip(worldPos);
 
       //          #if UNITY_REVERSED_Z
    			// o.vertex.z = min(o.vertex.z, o.vertex.w * UNITY_NEAR_CLIP_VALUE);
       //         #else
    			// o.vertex.z = max(o.vertex.z, o.vertex.w * UNITY_NEAR_CLIP_VALUE);
       //         #endif
                o.uv = v.uv;
                return o;
 
            }
 
            half4 frag(v2f i) : SV_Target
            {
                //支持透明镂空阴影
#if _ALPHATEST_ON
                half4 col = tex2D(_BaseMap, i.uv);
                 clip(col.a - 0.001);
#endif
                return 0;
            }
 
            ENDHLSL
        }
     //   #if defined (_Diss)
     
        Pass
	{
		Cull Front //剔除前面
        Offset 100,1
	  //  ZWrite On
		HLSLPROGRAM
        #pragma vertex vert
        #pragma fragment frag
		#pragma shader_feature  _Diss
		#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
		struct VertexInput
		    {
                float4 vertex   : POSITION;   // 顶点信息 Get✔
                float4 normal   : NORMAL;     // 法线信息 Get✔
                float2 uv :TEXCOORD0;
            };
		struct VertexOutput
         	{
		        float4 vertex :POSITION;
		    float2 uv :TEXCOORD0;
         	};
 
	    float _Factor;
	    half4 _OutLineColor;
		             TEXTURE2D(_H);
            SAMPLER(sampler_H);
              uniform float4 _H_ST;
 
	VertexOutput vert(VertexInput v)
	{
		VertexOutput o;
		//将顶点沿法线方向向外扩展一下

	 //    				float3 norm = mul((float3x3)UNITY_MATRIX_IT_MV, v.normal);
		// 		float2 offset = mul((float2x2)UNITY_MATRIX_P, norm.xy);
		// o.vertex = TransformObjectToHClip( v.vertex );
	 //    	o.vertex.xy += offset * _Factor*0.001;

	    v.vertex.xyz += v.normal * _Factor*0.001;
	    o.vertex = TransformObjectToHClip( v.vertex );
        o.uv = v.uv;
		return o;
	}
 
	half4 frag(VertexOutput v) :COLOR
	{
		//只显示描边的颜色
		half4 h =  SAMPLE_TEXTURE2D(_H, sampler_H,v.uv);
	    
    //             float var_DissolveMap1 = tex2D(_DissolveMap ,input.uv1).r*_Dissolvetan;
    //             float var_DissolveMap2 = tex2D(_DissolveMap ,input.uv1).g*_Dissolvetan;
    //             half   var_DissolveMap=var_DissolveMap2+var_DissolveMap1;
    //             _OutLineColor = lerp(_OutLineColor,_DissolveCol1,saturate(var_DissolveMap+_DissolveOffset+10));
    //             _OutLineColor = lerp(_OutLineColor,_DissolveCol2,saturate(var_DissolveMap+_DissolveOffset+1));
    //           //  var_MainTex.a = lerp(   var_MainTex.a,   -var_DissolveMap-_DissolveOffset+10-i.pos.y,0.01             );
    //              half a =  -var_DissolveMap-_DissolveOffset+10;
    //             
   //  clip(0);
	    #if _Diss
	     clip(h.a -0.5);
	    return half4(h.rgb,h.a);

	    
#endif
	   // clip(h.a -0.5);
	  //  return half4(h.rgb,h.a);
	    return 0;

	}
		ENDHLSL
	}

 // #endif
        
        // This pass it not used during regular rendering, only for lightmap baking.
//        Pass
//        {
//            Name "Meta"
//            Tags{"LightMode" = "Meta"}
//
//            Cull Off
//
//            HLSLPROGRAM
//            #pragma exclude_renderers gles gles3 glcore
//            #pragma target 4.5
//
//            #pragma vertex UniversalVertexMeta
//            #pragma fragment UniversalFragmentMetaLit
//
//            #pragma shader_feature EDITOR_VISUALIZATION
//            #pragma shader_feature_local_fragment _SPECULAR_SETUP
//            #pragma shader_feature_local_fragment _EMISSION
//            #pragma shader_feature_local_fragment _METALLICSPECGLOSSMAP
//            #pragma shader_feature_local_fragment _ALPHATEST_ON
//            #pragma shader_feature_local_fragment _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
//            #pragma shader_feature_local _ _DETAIL_MULX2 _DETAIL_SCALED
//
//            #pragma shader_feature_local_fragment _SPECGLOSSMAP
//
//            #include "LitInput.hlsl"
//            #include "LitMetaPass.hlsl"
//
//            ENDHLSL
//        }

    }


   // FallBack "Hidden/Universal Render Pipeline/FallbackError"
  // CustomEditor "UnityEditor.Rendering.Universal.ShaderGUI.LitShader"
   CustomEditor "MyShaderGUI"
}
