
Shader "Custom/Character/CharacterGearX" 
{
	Properties
	{
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_SSSTex("SSS (RGB)", 2D) = "white" {}
		_ILMTex("ILM (RGBA)", 2D) = "white" {}
		_Outline("Outline width", Range(.0, 2)) = 0.5
		_OutlineColor("Outline Color", Color) = (1,1,1,1)
		[HideInInspector]_GlowColor("Glow Color", Color) = (0,0,0,1)
		_Brightness("Brightness", Range(0, 2)) = 1
		_ShadowContrast("Shadow Contrast", Range(0, 5)) = 1
        [HideInInspector] _ShadowCenterX("ShadowCenterX", Float) = 0
        [HideInInspector] _ShadowCenterZ("ShadowCenterZ", Float) = 0
		[HideInInspector] _GroundHeight("Ground Height", Float) = 0
		[HideInInspector]_ShadowMap("ShadowMap", 2D) = "white" {}
		[HideInInspector][Toggle]_ShadowMapOn("ShadowMapOn",Float) = 0
	}

	CGINCLUDE
	#include "UnityCG.cginc"
	uniform sampler2D _MainTex;
	uniform sampler2D _SSSTex;
	uniform float4 _MainTex_ST;
	uniform fixed4 _GlowColor;
	uniform fixed4 _HDR_COL;
	uniform float _Brightness;
	uniform float _BrightForColorMask;
	ENDCG

	SubShader
	{
		Tags { "Queue" = "Transparent-2" "RenderType" = "Opaque" "LightMode" = "ForwardBase" }
		Lod 100

		// ----------------------------------------------------------
		// -- outline --
		Pass
		{
			Name "OUTLINE"

			Cull Front
			ZWrite On
			//ColorMask RGB
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile __ _GRAY

			uniform float _Outline;
			uniform float4 _OutlineColor;

			struct v2f 
			{
				float4 pos : POSITION;
				half2 uv : TEXCOORD0;
			};

			v2f vert(appdata_base v) 
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				float3 norm = mul((float3x3)UNITY_MATRIX_IT_MV, v.normal);
				float2 offset = TransformViewToProjection(norm.xy);
				o.pos.xy += offset * _Outline;
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				return o;
			}

			half4 frag(v2f i) : COLOR 
			{
				_Brightness *= _BrightForColorMask;
				fixed4 cLight = tex2D(_MainTex, i.uv);
				fixed4 cSSS = tex2D(_SSSTex, i.uv);
				fixed4 cDark = cLight * cSSS;
				cDark = cDark * 0.5f;
				cDark.a = 1;
				cDark.rgb += _GlowColor.rgb;
				#if _GRAY 
					cDark.rgb = length(cDark.rgb) * 0.5;
				#endif
					cDark.rgb *= _OutlineColor.rgb;
					cDark.rgb *= _Brightness;
				return cDark;
			}
			ENDCG
		}

		// ----------------------------------------------------------
		// -- main --
		Pass
		{
			Name "MAIN"
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile __ _GRAY
			uniform sampler2D _ILMTex;
			uniform float _ShadowContrast;
			uniform sampler2D _ShadowMap;
			float4x4 _VP_Proj;
			float _ShadowMapOn;

			struct v2f 
			{
				float4 pos: POSITION;
				half2 uv : TEXCOORD0;
				float3 normal : TEXCOORD1;
				float3 lightDir: TEXCOORD2;
				float4 proj : TEXCOORD3;
			};

			v2f vert(appdata_base v) 
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.normal = UnityObjectToWorldNormal(v.normal);
				o.lightDir = normalize(_WorldSpaceLightPos0.xyz);
				if (_ShadowMapOn)
				{
					float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
					o.proj = mul(_VP_Proj, worldPos);
					o.proj = ComputeScreenPos(o.proj);
				}
				return o;
			}

			fixed4 frag(v2f i) : COLOR 
			{
				_Brightness *= _BrightForColorMask;
				fixed4 cMain = tex2D(_MainTex, i.uv);
				fixed4 cSSS = tex2D(_SSSTex, i.uv);
				fixed4 cILM = tex2D(_ILMTex, i.uv);

				fixed3 brightColor = cMain.rgb;
				fixed3 shadowColor = cMain.rgb * cSSS.rgb;

				fixed specularIntensity = cILM.r;
				half shadowThreshold = 1 - cILM.g * (0.5 * _ShadowContrast + 0.5);
				fixed specularSize = 1 - cILM.b;

				fixed4 c = fixed4(0, 0, 0, 1);
				half diff = dot(i.lightDir, i.normal);
				diff -= shadowThreshold;

				if (diff < 0)
				{
					if (specularIntensity <= 0.5f && diff < -(specularSize + 0.5f))
						c.rgb = shadowColor * (0.5f + specularIntensity);
					else
						c.rgb = shadowColor;
				}
				else
				{
					if (specularSize < 1 && specularIntensity >= 0.5f && diff * 1.8f > specularSize)
						c.rgb = brightColor * (0.5f + specularIntensity);
					else
						c.rgb = brightColor;
				}

				c.rgb += _GlowColor.rgb;
				#if _GRAY 
					c.rgb = length(c.rgb) * 0.5;
				#endif

				if (_ShadowMapOn)
				{
					fixed4 shadow = tex2D(_ShadowMap, (i.proj.xy / i.proj.w));
					c.rgb *= max(shadow.r, 0.5);
				}
				c.rgb *= _Brightness ;
				return c;	
			}
			ENDCG
		}

		// ----------------------------------------------------------
		// -- shadow --
		Pass
		{
			Name "SHADOW"
			//用使用模板测试以保证alpha显示正确
			Stencil
			{
				Ref 0
				Comp equal
				Pass incrSat
				Fail keep
				ZFail keep
			}

			//透明混合模式
			Blend SrcAlpha OneMinusSrcAlpha
			//关闭深度写入
			ZWrite off
			//深度稍微偏移防止阴影与地面穿插
			Offset -1 , 0

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile __ _NOSHADOW

			struct appdata
			{
				float4 vertex : POSITION;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float4 color : COLOR;
			};

			float4 _LightDir;
			float4 _ShadowColor;
			float _ShadowFalloff;
            float _ShadowCenterX;
            float _ShadowCenterZ;
			float _GroundHeight;

			float3 ShadowProjectPos(float4 vertPos)
			{
				float3 shadowPos;
				#if _NOSHADOW
					shadowPos.xyz = 0;
				#else
				    //得到顶点的世界空间坐标
					float3 worldPos = mul(unity_ObjectToWorld, vertPos).xyz;
				    //灯光方向
				    float3 lightDir = normalize(_LightDir.xyz);
				    //阴影的世界空间坐标（低于地面的部分不做改变）
				    shadowPos.y = min(worldPos.y, _GroundHeight);
				    shadowPos.xz = worldPos.xz - lightDir.xz * max(0 , worldPos.y - _GroundHeight) / lightDir.y;
				#endif
				return shadowPos;
			}

			v2f vert(appdata v)
			{
				v2f o;
				#if _NOSHADOW
				    o.vertex.xyzw = 0;
				    o.color.rgba = 0;
				#else
				    //得到阴影的世界空间坐标
				    float3 shadowPos = ShadowProjectPos(v.vertex);
				    //转换到裁切空间
				    o.vertex = UnityWorldToClipPos(shadowPos);
				    //得到中心点世界坐标
                    //float3 center = float3(unity_ObjectToWorld[0].w, _GroundHeight, unity_ObjectToWorld[2].w);
				    float3 center = float3(_ShadowCenterX, _GroundHeight, _ShadowCenterZ);
				    //计算阴影衰减
				    float falloff = 1 - saturate(distance(shadowPos, center) * _ShadowFalloff);
				    //阴影颜色
				    o.color = _ShadowColor;
				    o.color.a *= falloff;
				#endif
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				#if _NOSHADOW
					clip(-1);
				#endif
				return i.color;
			}
			ENDCG
		}
	}

	FallBack "Diffuse"
}