
Shader "Custom/CW/CharacterGearX-Normal" 
{
	Properties
	{
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_SSSTex("SSS (RGB)", 2D) = "white" {}
		_ILMTex("ILM (RGBA)", 2D) = "white" {}
		_ShadowContrast("Shadow Contrast", Range(0.0, 5)) = 1
		_SpecularCol("SpecularCol", Color) = (1,1,1,0.9)
		_OutlineWidth_("OutlineWidth", Range(0, 10)) = 0.8
		_OutlineCol("Outline Color", Color) = (1,1,1,1)
		[HideInInspector]_GlowColor("Glow Color1", Color) = (0,0,0,1)
		_Brightness("Brightness", Range(0, 2)) = 1
        [HideInInspector] _ShadowCenterX("ShadowCenterX", Float) = 0
        [HideInInspector] _ShadowCenterZ("ShadowCenterZ", Float) = 0
		[HideInInspector] _GroundHeight("Ground Height", Float) = 0
	}

	CGINCLUDE
	#include "UnityCG.cginc"
	uniform sampler2D _MainTex;
	uniform sampler2D _SSSTex;
	uniform float4 _MainTex_ST;
	uniform fixed4 _GlowColor;
	uniform float _Brightness;
	uniform float _BrightForColorMask;
	#ifndef _Close_Glow_Value_
		#define _Close_Glow_Value_ 0.8
	#endif
	ENDCG

	SubShader
	{
		Tags { "Queue" = "Transparent-2" "RenderType" = "CharacterGearX-Normal" "LightMode" = "ForwardBase" }
		Lod 100
		
		// ----------------------------------------------------------
		// -- outline --
		Pass
		{
			Name "OUTLINE"
			ZWrite On
			Cull Front
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile __ _GRAY

			uniform float4 _OutlineCol;
			uniform float _OutlineWidth_;
			struct v2f
			{
				float4 pos : POSITION;
				half2 uv : TEXCOORD0;
			};

			fixed Luminance(fixed4 color)
			{
				return  0.2125 * color.r + 0.7154 * color.g + 0.0721 * color.b;
			}

			v2f vert(appdata_base v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				float3 clipNormal = mul((float3x3) UNITY_MATRIX_VP, mul((float3x3) UNITY_MATRIX_M, v.normal));
				float2 offset = normalize(clipNormal.xy) / _ScreenParams.xy * _OutlineWidth_ * o.pos.w * 2;
				o.pos.xy += offset;
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
					cDark.rgb *= _OutlineCol.rgb;
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
			uniform float4 _SpecularCol;

			struct v2f 
			{
				float4 pos: POSITION;
				half2 uv : TEXCOORD0;
				float3 normal : TEXCOORD1;
				float3 lightDir: TEXCOORD2;
			};

			v2f vert(appdata_base v) 
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

				o.normal = UnityObjectToWorldNormal(v.normal);
				o.lightDir = normalize(_WorldSpaceLightPos0.xyz);
				return o;
			}

			fixed4 frag(v2f i) : COLOR 
			{
				float bright = _Brightness * _BrightForColorMask;
				fixed4 cMain = tex2D(_MainTex, i.uv);
				fixed4 cSSS = tex2D(_SSSTex, i.uv);
				fixed4 cILM = tex2D(_ILMTex, i.uv);

				fixed3 brightColor = cMain.rgb;
				fixed3 shadowColor = cMain.rgb * cSSS.rgb;

				fixed specularIntensity = cILM.r;
				half shadowThreshold = 1 - cILM.g * (0.5 * _ShadowContrast + 0.5);

				fixed4 c = fixed4(0, 0, 0, 1);
				i.lightDir = normalize(i.lightDir);
				i.normal = normalize(i.normal);

				half diff = dot(i.lightDir, i.normal);
				diff -= shadowThreshold;

				
				if (diff < 0)
				{
					c.rgb = shadowColor;
				}
				else
				{
					if (specularIntensity >= 0.95f && diff * 1.75f > _SpecularCol.a && bright >= _Close_Glow_Value_)
						c.rgb = brightColor.rgb * 3.5f * _SpecularCol.rgb;
					else
						c.rgb = brightColor;
				}
				c.rgb += _GlowColor.rgb;
				#if _GRAY 
					c.rgb = length(c.rgb) * 0.5;
				#endif

				c.rgb *= bright;

				if (_BrightForColorMask < 0.8 && diff >= 0 && specularIntensity >= 0.95f && diff * 1.75f > _SpecularCol.a && _Brightness >= _Close_Glow_Value_)
				{
					c.rgb *= 1.5f;
				}
				c.rgb = saturate(c.rgb);
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