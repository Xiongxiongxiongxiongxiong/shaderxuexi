Shader "Hidden/RoomLutShader"
{

    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
        SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
         #pragma multi_compile_local_fragment _ _HDR_GRADING _TONEMAP_ACES _TONEMAP_NEUTRAL
            #include "UnityCG.cginc"


          
            float4x4 _viewprojMatrixInverse;
            sampler2D _CameraDepthTexture;
            sampler2D _MainTex;
            sampler2D _LutTex;

            float _Contribution;
            float _Radiu;
            
            int _LutIntensity;

           float3 _centerPos;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
               
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

          

            float3 LinearToSRGB(float3 c)
            {
                float3 sRGBLo = c * 12.92;
                float3 sRGBHi = (pow(abs(c), float3(1.0 / 2.4, 1.0 / 2.4, 1.0 / 2.4)) * 1.055) - 0.055;
                float3 sRGB = (c <= 0.0031308) ? sRGBLo : sRGBHi;
                return sRGB;
            }
            half3 SRGBToLinear(half3 c)
            {
                half3 linearRGBLo = c / 12.92;
                half3 linearRGBHi = pow(abs((c + 0.055) / 1.055), 2.4);
                half3 linearRGB = (c <= 0.04045) ? linearRGBLo : linearRGBHi;
                return linearRGB;
            }
          
            struct ParamsLogC
            {
                float cut;
                float a, b, c, d, e, f;
            };
            static const ParamsLogC LogC =
            {
                0.011361, // cut
                5.555556, // a
                0.047996, // b
                0.244161, // c
                0.386036, // d
                5.301883, // e
                0.092819  // f
            };
            float LinearToLogC_Precise(float x)
            {
                float o;
                if (x > LogC.cut)
                    o = LogC.c * log10(max(LogC.a * x + LogC.b, 0.0)) + LogC.d;
                else
                    o = LogC.e * x + LogC.f;
                return o;
            }
            // Full float precision to avoid precision artefact when using ACES tonemapping
            float3 LinearToLogC(float3 x)
            {
#if USE_PRECISE_LOGC
                return real3(
                    LinearToLogC_Precise(x.x),
                    LinearToLogC_Precise(x.y),
                    LinearToLogC_Precise(x.z)
                );
#else
                return LogC.c * log10(max(LogC.a * x + LogC.b, 0.0)) + LogC.d;
#endif
            }

            // 2D LUT grading
            // scaleOffset = (1 / lut_width, 1 / lut_height, lut_height - 1)
            float3 ApplyLut2D(sampler2D tex, float3 uvw, float3 scaleOffset)
            {
                // Strip format where `height = sqrt(width)`
                uvw.z *= scaleOffset.z;
                float shift = floor(uvw.z);
                uvw.xy = uvw.xy * scaleOffset.z * scaleOffset.xy + scaleOffset.xy * 0.5;
                uvw.x += shift * scaleOffset.y;
                uvw.xyz = lerp(
                    tex2D(tex, uvw.xy).rgb,
                    tex2D(tex, uvw.xy + float2(scaleOffset.y, 0.0)).rgb,
                    uvw.z - shift
                );
                return uvw;
            }

            float4 frag(v2f i) : SV_Target
            {
               float4 col = tex2D(_MainTex, i.uv);
               if (_LutIntensity == 0)
                   return col;
               /// <summary>
                /// 当启用HDR时， Color 可能会超过1 ， 所以要先归一化
                /// </summary>
                float3 lut = saturate( col.rgb);

                 lut = ApplyLut2D(_LutTex, lut, float3(1.0 / 1024, 1.0 / 32, 31));

               float depth=  SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv);

                float4 ray = float4(i.uv * 2 - 1, depth, 1);

                float4 wpos = mul(_viewprojMatrixInverse, ray);
                wpos.xyz = wpos.xyz / wpos.w;
              
              
                float d = 0;
             /*   if (_Style1 == 0)
                    d=length(wpos.xz - float2(-0.1761007, 0.7017678));
                else*/
                    d = length(wpos.xyz - _centerPos);

               


               
                float4 temp = lerp(col, float4(lut, 1), d / _Radiu);
                if (d < _Radiu)  return   _LutIntensity == 0 ? col : temp;
               // if (d - 0.03 <= _Radiu)  return temp+ float4(0,1,0,1)* max(0, (1 - d / 10));//float4(0, 1, 0, 1) * 2;
               // lut = lerp(col, lut, _LutIntensity);
                return  float4(lut,1);


                /// <summary>
                /// /=====================����һ
                /// </summary>
                //if (d < _Radiu) return col *( _Style2==0? 1: max(0.5, (1 - d / _Radiu)));
                //if (d - 0.03 <= _Radiu)  return col * 2 * max(0.25, (1 - d / 10));//float4(0, 1, 0, 1) * 2;
                //return  col*0.5;

                /// <summary>
                /// ������
                /// </summary>
             /*   if (d < _Radiu) return col* max(0.5, (1 - d / _Radiu));
                return col* 0.5;*/


                ////====================================================
                /*float h =1- (wpos.y -_HeightStart) / (_HeightEnd - _HeightStart);
                h = pow(h, _FogPower) * _FogStrength;
                h = saturate(h);

               float d = Linear01Depth(depth) ;
               float d2 = _FogStrength * d * 100;
               d2 = d2 * d2;
               d = 1-exp( -d2 ) ;

               half4 col = tex2D(_MainTex, i.uv);

               float intensity =  d *h *2;

               col.rgb = lerp(col.rgb, _FogColor, intensity);


                return col;*/
            }
            ENDCG
        }
    }
}
