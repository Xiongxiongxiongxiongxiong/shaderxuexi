Shader "AP01/L11/HLSL_OldSchoolPro" {
    Properties {
        [Header(Texture)]
            _MainTex    ("RGB:基础颜色 A:环境遮罩", 2D)     = "white" {}
            [Normal] _NormTex	("RGB:法线贴图", 2D)                = "bump" {}
            _SpecTex    ("RGB:高光颜色 A:高光次幂", 2D)     = "gray" {}
            _EmitTex    ("RGB:自发光贴图", 2d)                = "black" {}
            _Cubemap    ("RGB:环境贴图", cube)              = "_Skybox" {}
        [Header(Diffuse)]
            _MainCol    ("基本色",      Color)              = (0.5, 0.5, 0.5, 1.0)
            _EnvDiffInt ("环境漫反射强度",  Range(0, 1))    = 0.2
            _EnvUpCol   ("环境天顶颜色", Color)             = (1.0, 1.0, 1.0, 1.0)
            _EnvSideCol ("环境水平颜色", Color)             = (0.5, 0.5, 0.5, 1.0)
            _EnvDownCol ("环境地表颜色", Color)             = (0.0, 0.0, 0.0, 0.0)
        [Header(Specular)]
            [PowerSlider(2)] _SpecPow    ("高光次幂",    Range(1, 90))       = 30
            _EnvSpecInt ("环境镜面反射强度", Range(0, 5))   = 0.2
            _FresnelPow ("菲涅尔次幂", Range(0, 5))         = 1
            _CubemapMip ("环境球Mip", Range(0, 7))          = 0
        _Factor ("描边大小",range(0,10))=0.1
        [Header(Emission)]
            [HideInInspect] _EmitInt    ("自发光强度", range(1, 10))         = 1
    }
    SubShader {
        Tags {
            "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" 
        }
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode" = "UniversalForward"
            }
            Cull Off
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS  
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
			#pragma multi_compile _ Anti_Aliasing_ON

            #pragma multi_compile _ _SHADOWS_SOFT  //开启软阴影
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
            #pragma target 3.0
            // 输入参数
            // Texture
            uniform sampler2D _MainTex; uniform float4 _MainTex_ST;
            uniform sampler2D _NormTex;
            uniform sampler2D _SpecTex;
            uniform sampler2D _EmitTex;
            uniform samplerCUBE _Cubemap;
            // Diffuse
            uniform float3 _MainCol;
            uniform float _EnvDiffInt;
            uniform float3 _EnvUpCol;
            uniform float3 _EnvSideCol;
            uniform float3 _EnvDownCol;
            // Specular
            uniform float _SpecPow;
            uniform float _FresnelPow;
            uniform float _EnvSpecInt;
            uniform float _CubemapMip;
            // Emission
            uniform float _EmitInt;
            // 输入结构
            struct VertexInput {
                float4 vertex   : POSITION;   // 顶点信息 Get✔
                float2 uv0      : TEXCOORD0;  // UV信息 Get✔
                float4 normal   : NORMAL;     // 法线信息 Get✔
                float4 tangent  : TANGENT;    // 切线信息 Get✔
            };
            // 输出结构
            struct VertexOutput {
                float4 pos    : SV_POSITION;  // 屏幕顶点位置
                float2 uv0      : TEXCOORD0;  // UV0
                float4 posWS    : TEXCOORD1;  // 世界空间顶点位置
                float3 nDirWS   : TEXCOORD2;  // 世界空间法线方向
                float3 tDirWS   : TEXCOORD3;  // 世界空间切线方向
                float3 bDirWS   : TEXCOORD4;  // 世界空间副切线方向

            };
            // 输入结构>>>顶点Shader>>>输出结构
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;                   // 新建输出结构
                    o.pos = TransformObjectToHClip( v.vertex );       // 顶点位置 OS>CS
                    o.uv0 = v.uv0 * _MainTex_ST.xy + _MainTex_ST.zw;                                  // 传递UV
                    o.posWS = mul(unity_ObjectToWorld, v.vertex);   // 顶点位置 OS>WS
                    o.nDirWS = TransformObjectToWorldNormal(v.normal);  // 法线方向 OS>WS
                    o.tDirWS = normalize(mul(unity_ObjectToWorld, float4(v.tangent.xyz, 0.0)).xyz); // 切线方向 OS>WS
                    o.bDirWS = normalize(cross(o.nDirWS, o.tDirWS) * v.tangent.w);  // 副切线方向
                return o;                                           // 返回输出结构
            }
            // 输出结构>>>像素
            float4 frag(VertexOutput i) : COLOR {
                // 准备向量
                float3 nDirTS = UnpackNormal(tex2D(_NormTex, i.uv0)).rgb;
                float3x3 TBN = float3x3(i.tDirWS, i.bDirWS, i.nDirWS);
                float3 nDirWS = normalize(mul(nDirTS, TBN));
                float3 vDirWS = normalize(_WorldSpaceCameraPos.xyz - i.posWS.xyz);
                float3 vrDirWS = reflect(-vDirWS, nDirWS);

              // Ambient
                
                float4 SHADOW_COORDS = TransformWorldToShadowCoord(i.posWS);
              //  half4 shadowMask = CalculateShadowMask(inputData);
              //  AmbientOcclusionFactor aoFactor = CreateAmbientOcclusionFactor(inputData, surfaceData)
                Light mainLight = GetMainLight(SHADOW_COORDS);
              //  half shadow = MainLightRealtimeShadow(SHADOW_COORDS);
                half  ShadowAtten = mainLight.shadowAttenuation;
                
                half3 lDirWS = normalize(mainLight.direction);
                
                float3 lrDirWS = reflect(-lDirWS, nDirWS);
                // 准备点积结果
                float ndotl = dot(nDirWS, lDirWS);
                float vdotr = dot(vDirWS, lrDirWS);
                float vdotn = dot(vDirWS, nDirWS);
                // 采样纹理
                float4 var_MainTex = tex2D(_MainTex, i.uv0);
                float4 var_SpecTex = tex2D(_SpecTex, i.uv0);
                float3 var_EmitTex = tex2D(_EmitTex, i.uv0).rgb;
                float3 var_Cubemap = texCUBElod(_Cubemap, float4(vrDirWS, lerp(_CubemapMip, 0.0, var_SpecTex.a))).rgb;
                // 光照模型(直接光照部分)
                float3 baseCol = var_MainTex.rgb * _MainCol;
                float lambert = max(0.0, ndotl);
                float specCol = var_SpecTex.rgb;
                float specPow = lerp(1, _SpecPow, var_SpecTex.a);
                float phong = pow(max(0.0, vdotr), specPow);

                float3 dirLighting = (baseCol * lambert + specCol * phong) * _MainLightColor * ShadowAtten;
                // 光照模型(环境光照部分)
             //   float3 envCol01 = TriColAmbient(nDirWS, _EnvUpCol, _EnvSideCol, _EnvDownCol);
                
                float fresnel = pow(max(0.0, 1.0 - vdotn), _FresnelPow);    // 菲涅尔
                float occlusion = var_MainTex.a;
                float3 envLighting = (baseCol  * _EnvDiffInt + var_Cubemap * fresnel * _EnvSpecInt * var_SpecTex.a) * occlusion;
                // 光照模型(自发光部分)
                float3 emission = var_EmitTex * _EmitInt * (sin(_Time.z) * 0.5 + 0.5);
                // 返回结果
                float3 finalRGB = dirLighting + envLighting + emission;
                return float4(finalRGB, 1.0);
            }
            ENDHLSL
        }
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
             sampler2D _MainTex;
 
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
                half4 col = tex2D(_MainTex, i.uv);
                clip(col.a - 0.001);
#endif
                return 0;
            }
 
            ENDHLSL
        }
                Pass
	{
		Cull Front //剔除前面
        Offset 100,1
	    ZWrite On
		HLSLPROGRAM
        #pragma vertex vert
        #pragma fragment frag
		#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
		struct VertexInput
		    {
                float4 vertex   : POSITION;   // 顶点信息 Get✔
                float4 normal   : NORMAL;     // 法线信息 Get✔
            };
		struct VertexOutput
         	{
		        float4 vertex :POSITION;
         	};
 
	    float _Factor;
	    half4 _OutLineColor;
 
	VertexOutput vert(VertexInput v)
	{
		VertexOutput o;
		//将顶点沿法线方向向外扩展一下
		v.vertex.xyz += v.normal * _Factor*0.1;
		o.vertex = TransformObjectToHClip( v.vertex ); 
 
		return o;
	}
 
	half4 frag(VertexOutput v) :COLOR
	{
		//只显示描边的颜色
		return _OutLineColor;
	}
		ENDHLSL
	}
    }

}