Shader "Custom/CubePattern"
{
    Properties
    {
        _Length("Length", Range(0, 1)) = 0.5
        _UVScale("UVScale", Range(1, 10)) = 2
        [Toggle]_ShowDistance("Show Distance", Int) = 0
        [Toggle]_UseBeveling("Use Beveling", Int) = 0
        _Power("Power", Range(0.1, 10)) = 2
        _BevelLength("Bevel Length", Range(0,1)) = 0.2
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma shader_feature _SHOWDISTANCE_ON 
            #pragma shader_feature _USEBEVELING_ON

            #include "UnityCG.cginc"

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

            sampler2D _MainTex;
            float4 _MainTex_ST;
            half _Length;
            half _UVScale;

            half _Power;
            half _BevelLength;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = (v.uv - half2(0.5, 0.5))*_UVScale;
                return o;
            }

            half3 pal( in float t, in half3 a, in half3 b, in half3 c, in half3 d ){
                return a + b*cos( 6.28318*(c*t+d) );
            }

            half2 max2(half2 a, half2 b)
            {
                return half2(max(a.x, b.x), max(a.y,b.y));
            }

            half2 min2(half2 a, half2 b)
            {
                return half2(min(a.x, b.x), min(a.y,b.y));
            }

            half4 frag (v2f i) : SV_Target
            {
                half3 color = 0;

                half dist = 0;

#ifdef _USEBEVELING_ON
                half bevel = min(_Length, _BevelLength);
                half2 d = abs(i.uv) - _Length + bevel;
                half2 outLen = max2( d, 0);
                dist = pow( pow(outLen.x, _Power) + pow(outLen.y, _Power), 1/_Power) + min(max(d.x, d.y), 0) - bevel;
#else
                half2 d = abs(i.uv) - _Length;
                dist = length(max2( d, 0))  + min(max(d.x, d.y), 0);
#endif

#ifdef _SHOWDISTANCE_ON
                
                color = pal( abs(dist), half3(0.5,0.5,0.5),half3(0.5,0.5,0.5),half3(1.0,1.0,1.0),half3(0.0,0.10,0.20) );;
#else
                color = step(0, dist);
#endif

                return half4(color, 1);
            }
            ENDHLSL
        }
    }
}
