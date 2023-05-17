Shader "AP01/L11/HLSL_OldSchoolPro_yuansheng" {
    Properties {
        [Header(Texture)]
            _MainTex    ("RGB:基础颜色 A:环境遮罩", 2D)     = "white" {}
            [Normal] _NormTex	("RGB:法线贴图", 2D)                = "bump" {}
            _MaskMap    ("遮罩", 2D)     = "gray" {}
            _SSS("SSS",2d) = "white" {}
            _EmitTex    ("RGB:自发光贴图", 2d)                = "black" {}
            _Cubemap    ("RGB:环境贴图", cube)              = "_Skybox" {}
        [Header(Diffuse)]
            _MainCol    ("基本色",      Color)              = (0.5, 0.5, 0.5, 1.0)
            _EnvDiffInt ("环境漫反射强度",  Range(0, 1))    = 0.2
            _EnvUpCol   ("环境天顶颜色", Color)             = (1.0, 1.0, 1.0, 1.0)
            _EnvSideCol ("环境水平颜色", Color)             = (0.5, 0.5, 0.5, 1.0)
            _EnvDownCol ("环境地表颜色", Color)             = (0.0, 0.0, 0.0, 0.0)
                _SpecTexCol ("黄金色", Color) = (0.5,0.5,0.5,1)
     //   _SpecTexCol("高光颜色",color) = (1,1,1,1)
        [Header(Specular)]
            [PowerSlider(2)] _SpecPow    ("高光次幂",    Range(1, 90))       = 30
            _EnvSpecInt ("环境镜面反射强度", Range(0, 5))   = 0.2
            _En ("明暗范围", Range(0, 5))   = 0.2
            _FresnelPow ("菲涅尔次幂", Range(0, 5))         = 1
            _CubemapMip ("环境球Mip", Range(0, 7))          = 0
            _ShadowContrast("阴影强度",range(0,10))=1
                _Factor ("描边大小",range(0,10))=0.1
        [Header(Emission)]
            [HideInInspect] _EmitInt    ("自发光强度", range(1, 10))         = 1
        
        
        
                _LightDir ("灯光相对模型位置",Vector) = (41,160,-20,0)  //灯光相对模型位置
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
           // uniform sampler2D _MainTex; uniform float4 _MainTex_ST;
          //  uniform sampler2D _NormTex;
          //  uniform sampler2D _SpecTex;
        //    uniform sampler2D _EmitTex;
            uniform samplerCUBE _Cubemap;
            
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

             TEXTURE2D(_MaskMap);
            SAMPLER(sampler_MaskMap);
                         TEXTURE2D(_NormTex);
            SAMPLER(sampler_NormTex);
                                     TEXTURE2D(_SSS);
            SAMPLER(sampler_SSS);
            // Diffuse
                        CBUFFER_START(UnityPerMaterial)
            uniform float4 _MainTex_ST;
            uniform float4 _Cubemap_ST;
            uniform float4 _MaskMap_ST;
            
            uniform float3 _MainCol;
            uniform float _EnvDiffInt;
            uniform float3 _EnvUpCol;
            uniform float3 _EnvSideCol;
            uniform float3 _EnvDownCol;
            // Specular
            uniform float _SpecPow;
            uniform float _FresnelPow;
            uniform float _EnvSpecInt;
            uniform float _En;
            uniform float _CubemapMip;
          uniform float  _ShadowContrast;
            // Emission
            uniform float _EmitInt;
            uniform float3 _SpecTexCol;
             CBUFFER_END
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
                    o.uv0 =  TRANSFORM_TEX( v.uv0,_MainTex  )  ;                       // 传递UV
                    o.posWS = mul(unity_ObjectToWorld, v.vertex);   // 顶点位置 OS>WS
                    o.nDirWS = TransformObjectToWorldNormal(v.normal);  // 法线方向 OS>WS
                    o.tDirWS = normalize(mul(unity_ObjectToWorld, float4(v.tangent.xyz, 0.0)).xyz); // 切线方向 OS>WS
                    o.bDirWS = normalize(cross(o.nDirWS, o.tDirWS) * v.tangent.w);  // 副切线方向
                return o;                                           // 返回输出结构
            }
            // 输出结构>>>像素
            float4 frag(VertexOutput i) : COLOR {
                // 准备向量
                float3 nDirTS = UnpackNormal(SAMPLE_TEXTURE2D(_NormTex,sampler_NormTex,i.uv0).rgba).rgb;
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
              
                
                half3 lDirWS = normalize(mainLight.direction);
                
                float3 lrDirWS = reflect(-lDirWS, nDirWS);
                // 准备点积结果
                float ndotl = dot(nDirWS, lDirWS);
                float vdotr = dot(vDirWS, lrDirWS);
                float vdotn = dot(vDirWS, nDirWS);
                // 采样纹理
                float4 var_MainTex = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,i.uv0).rgba;
                float4 var_MaskMap = SAMPLE_TEXTURE2D(_MaskMap,sampler_MaskMap,i.uv0).rgba;
                float4 var_SSS = SAMPLE_TEXTURE2D(_SSS,sampler_SSS,i.uv0).rgba;
               // float3 var_EmitTex = tex2D(_EmitTex, i.uv0).rgb;
           //     half3 diffCol = lerp(var_MainTex, half3(0.0, 0.0, 0.0), var_MaskMap.r);

                half shadowThreshold = 1 - var_MaskMap.g * (0.5 * _ShadowContrast + 0.5);
               // step(0.5,shadowThreshold);
                 // half  ShadowAtten = smoothstep(0.3,0.6,mainLight.shadowAttenuation);//
                  half  ShadowAtten =lerp(1, mainLight.shadowAttenuation,shadowThreshold);
              //  ShadowAtten=step(0.5,ShadowAtten);
                float3 var_Cubemap = texCUBElod(_Cubemap, float4(vrDirWS, _CubemapMip)).rgb;
                // 光照模型(直接光照部分)
                float3 baseCol = var_MainTex * _MainCol;
                float lambert =  ndotl*0.5+0.5;// max(0.0, ndotl);
                lambert = step(0.5,lambert);
                //float specCol = half3(1,1,1);// var_SpecTex.rgb;
                float specPow = lerp(1, _SpecPow, 1-var_MaskMap.b);
               // float3 phong  =step(0.5, pow(max(0.0,vdotr),specPow))*_SpecTexCol*var_MaskMap.r;
                float3 phong  = pow(max(0.0,vdotr),specPow)*_SpecTexCol*var_MaskMap.a;
                 // phong =lerp(0,phong,var_MaskMap.r)*var_MaskMap.a;
                half3 Diffuse = lerp(baseCol,1,lambert);//明暗交界硬边
                // half3 Diffuse = smoothstep(0.2,0.21,lambert*var_MaskMap.g);//明暗交界硬边

                
               // float3 dirLighting = ( baseCol * lambert   + phong) * _MainLightColor * ShadowAtten*occlusion;
                float3 dirLighting = ( baseCol * Diffuse   + phong) * _MainLightColor * ShadowAtten;
                
                // 光照模型(环境光照部分)
             //   float3 envCol01 = TriColAmbient(nDirWS, _EnvUpCol, _EnvSideCol, _EnvDownCol);
                
                float3 fresnel = pow(max(0.0, 1.0 - vdotn), _FresnelPow);    // 菲涅尔
               half3 fresnel01 = lerp(dirLighting,dirLighting*var_SSS,fresnel);
                                    //环境漫发射
                float upMask = max(0.0 , nDirWS.g);
                float downMask = max(0.0 , -nDirWS.g);
                float sideMask = 1 - upMask - downMask;
                float3 envCol = upMask * _EnvUpCol + downMask * _EnvDownCol + sideMask*_EnvSideCol ;
                    //环境镜面反射
             //   float fresnel = pow(max( 0.0 , 1.0-ndotv) , _Fresnelpow);
            //    float3 occ = var_MainTex.a;

                    //环境混合反射
                float3 envlighting = (baseCol * envCol * _EnvDiffInt +var_Cubemap * fresnel01 * _EnvSpecInt ) ;
                half Ma = var_MaskMap.b;
           //     float3 envLighting = (baseCol  * _EnvDiffInt + var_Cubemap * fresnel * _EnvSpecInt ) ;
                // 光照模型(自发光部分)
               // float3 emission = var_EmitTex * _EmitInt * (sin(_Time.z) * 0.5 + 0.5);
                // 返回结果
                float3 finalRGB = dirLighting + envlighting;// + emission;
                return float4(fresnel01 , 1.0);
            }
            ENDHLSL
        }

//           pass
//        {
// 
//            Name "ShadowCast"
// 
//			Tags{ "LightMode" = "ShadowCaster" }
// 
//             HLSLPROGRAM
//             #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
//            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
//            #pragma vertex vert
//            #pragma fragment frag
// 
//             //开启ALPHA 测试，主要是做镂空
//            #pragma shader_feature _ALPHATEST_ON
// 
// 
//            struct a2v {
//                float4 vertex : POSITION;
//                float2 uv : TEXCOORD0;
//                float3 normal : NORMAL;
//            };
//            struct v2f {
//                float4 vertex : SV_POSITION;
//                float2 uv : TEXCOORD0;
//            };
// 
//            // 以下三个 uniform 在 URP shadows.hlsl 相关代码中可以看到没有放到 CBuffer 块中，所以我们只要在 定义为不同的 uniform 即可
//             float3 _LightDirection;
//             sampler2D _MainTex;
// 
//            v2f vert(a2v v)
//            {
//                v2f o = (v2f)0;
//                float3 worldPos = TransformObjectToWorld(v.vertex.xyz);
//                half3 normalWS = TransformObjectToWorldNormal(v.normal);
// 
// 
//                worldPos = ApplyShadowBias(worldPos,normalWS,_LightDirection);
//                o.vertex = TransformWorldToHClip(worldPos);
// 
//       //          #if UNITY_REVERSED_Z
//    			// o.vertex.z = min(o.vertex.z, o.vertex.w * UNITY_NEAR_CLIP_VALUE);
//       //         #else
//    			// o.vertex.z = max(o.vertex.z, o.vertex.w * UNITY_NEAR_CLIP_VALUE);
//       //         #endif
//                o.uv = v.uv;
//                return o;
// 
//            }
// 
//            half4 frag(v2f i) : SV_Target
//            {
//                //支持透明镂空阴影
//#if _ALPHATEST_ON
//                half4 col = tex2D(_MainTex, i.uv);
//                clip(col.a - 0.001);
//#endif
//                return 0;
//            }
// 
//            ENDHLSL
//        }
               Pass{
            Name "Shadow"
            Tags{ "LightMode" = "SRPDefaultUnlit"
                           }
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);
            CBUFFER_START(UnityPerMaterial)
            float3 _LightDir;
            float  _Cutoff;
            CBUFFER_END
            
            
            struct Attributes {
                float4 vertex	: POSITION;
                float2 uv0      : TEXCOORD0;  // UV信息 Get✔
            };

            struct Varyings {
                float4 pos	: SV_POSITION;
                float4 posWS : TEXCOORD0;       // 世界空间顶点位置
                float3 ShadowPos :TEXCOORD1 ;
                float2 uv0      : TEXCOORD2;  // UV0
            };

          static    float3 ShadowProjectPos(float4 vertex,float3 lightDir,inout float4 posWS, float3 shadowPos)
            {
                posWS = mul(unity_ObjectToWorld, vertex);   // 变换顶点位置 OS>WS
                shadowPos.y = min(0,posWS.y);
                shadowPos.xz = posWS.xz - lightDir.xz *  posWS.y / lightDir.y;
                return shadowPos;
            }
     
            float3 PlanarShadowPos(float3 posWS,float3 lightDir)
            {
                        float3 N= float3(0,1,0);
                        float3 L=normalize( lightDir);
                        float t=- dot( posWS,N)  / dot(N, L);
                        float3 P= posWS+ L* t;
                       return P;
              
            }

            
            Varyings vert(Attributes v) {
                Varyings o;
                 o.posWS = mul(unity_ObjectToWorld, v.vertex);   // 变换顶点位置 OS>WS
                o.uv0 = v.uv0; 
              //  float3 shadowPos = ShadowProjectPos(v.vertex, _LightDir,o.posWS,o.ShadowPos);
                float3 shadowPos= PlanarShadowPos(o.posWS.xyz, _LightDir);

              
               o.pos = TransformWorldToHClip(shadowPos);
                return o;
            }
            half4 frag(Varyings i) : SV_Target{
                 half4 var_MainTex = SAMPLE_TEXTURE2D(_BaseMap,sampler_BaseMap,i.uv0).rgba*float4(0.5,0.5,0.5,1)*2;
                half opacity = var_MainTex.a ;
                 clip(opacity - _Cutoff);
                return float4(var_MainTex.rgb,opacity);
            }
            ENDHLSL
        }
                        Pass
	{
	    Name "o"
            Tags{ "LightMode" = "SRPDefaultUnlit"}
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
		v.vertex.xyz += v.normal * _Factor*0.001;
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