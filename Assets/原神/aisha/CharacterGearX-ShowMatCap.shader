
Shader "Custom/CW/CharacterGearX-MatCap" 
{
	Properties
	{
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_SSSTex("SSS (RGB)", 2D) = "white" {}
		_ILMTex("ILM (RGBA)", 2D) = "white" {}
		_ShadowContrast("Shadow Contrast", Range(0.0, 5)) = 1
		_SpecularCol("SpecularCol", Color) = (1,1,1,0.9)
		_Outline("Outline width", Range(.0, 2)) = 0.5
		_OutlineColor("Outline Color", Color) = (1,1,1,1)
		[HideInInspector]_GlowColor("Glow Color1", Color) = (0,0,0,1)
		_Brightness("Brightness", Range(0, 2)) = 1
        [HideInInspector] _ShadowCenterX("ShadowCenterX", Float) = 0
        [HideInInspector] _ShadowCenterZ("ShadowCenterZ", Float) = 0
		[HideInInspector] _GroundHeight("Ground Height", Float) = 0
		_SpecValue("Spec Tex Value", Range(0,5)) = 3
		_MatCapColor("MatCapColor", Color) = (1,1,1,1)
		_MatCapSpec("MatCap Spec (RGB)", 2D) = "white" {}
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
		Tags { "Queue" = "Transparent-2" "RenderType" = "CharacterGearX-MatCap" "LightMode" = "ForwardBase" }
		Lod 100
		
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

			uniform float _Outline;
			uniform float4 _OutlineColor;

			struct v2f 
			{
				float4 pos : POSITION;
				half2 uv : TEXCOORD0;
			};

			// fixed Luminance(fixed4 color)
			// {
			// 	return  0.2125 * color.r + 0.7154 * color.g + 0.0721 * color.b;
			// }

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
			uniform sampler2D _MatCapSpec;
			uniform fixed4 _MatCapColor;
			uniform float _SpecValue;
			struct v2f 
			{
				float4 pos: POSITION;
				half2 uv : TEXCOORD0;
				float3 normal : TEXCOORD1;
				float3 lightDir: TEXCOORD2;
				float2  TtoV : TEXCOORD3;
			};

			v2f vert(appdata_tan v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

				o.normal = UnityObjectToWorldNormal(v.normal);
				o.lightDir = normalize(_WorldSpaceLightPos0.xyz);

				float3 binormal = cross(v.normal, v.tangent.xyz) * v.tangent.w;
				float3x3 rotation = float3x3(v.tangent.xyz, binormal, v.normal);				

				o.TtoV.x = normalize(mul(rotation, UNITY_MATRIX_IT_MV[0].xyz)).z;
				o.TtoV.y = normalize(mul(rotation, UNITY_MATRIX_IT_MV[1].xyz)).z;
				return o;
			}

			fixed4 frag(v2f i) : COLOR 
			{
				float bright = _Brightness * _BrightForColorMask;
				fixed4 cMain = tex2D(_MainTex, i.uv);
				fixed4 cSSS = tex2D(_SSSTex, i.uv);
				fixed4 cILM = tex2D(_ILMTex, i.uv);
				half2 vn;
				vn = i.TtoV;
				vn = vn * 0.5 + 0.5;
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
				
		//		#if _GRAY 
					//c.rgb = length(c.rgb) * 0.5;
			//	#endif

				c.rgb *= bright;

		//		if (_BrightForColorMask < 0.8 && diff >= 0 && specularIntensity >= 0.95f && diff * 1.75f > _SpecularCol.a && _Brightness >= _Close_Glow_Value_)
			//	{
			//		c.rgb *= 1.5f;
			//	}
			//	c *= 1 + cILM.b * (tex2D(_MatCapSpec, vn) * _MatCapColor *_SpecValue - 1);
				c.rgb = saturate(c.rgb);
				return diff;	
			}
			ENDCG
		}		
	}
	FallBack "Diffuse"
}