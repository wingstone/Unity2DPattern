Shader "Custom/CirclePattern"
{
    Properties
    {
        _Radius("Redius", Range(0, 1)) = 0.5
        _UVScale("UVScale", Range(1, 10)) = 2
        [Toggle]_ShowDistance("Show Distance", Int) = 0
        [Toggle]_UsePower("Use Power", Int) = 0
        _Power("Power", Range(0.1, 10)) = 2
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma shader_feature _SHOWDISTANCE_ON 
            #pragma shader_feature _USEPOWER_ON

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
            half _Radius;
            half _UVScale;

            half _Power;

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

            half4 frag (v2f i) : SV_Target
            {
                half3 color = 0;

                half dist = 0;

#ifdef _USEPOWER_ON
                dist = pow(abs(i.uv.x), _Power) + pow(abs(i.uv.y), _Power);
                dist = pow(dist, 1/_Power) - _Radius;
#else
                dist = length(i.uv) - _Radius;
#endif

#ifdef _SHOWDISTANCE_ON
                
                color = pal( abs(dist), half3(0.5,0.5,0.5),half3(0.5,0.5,0.5),half3(1.0,1.0,1.0),half3(0.0,0.10,0.20) );;
#else
                color = step(0, dist);
#endif

                return half4(color, 1);
            }
            ENDCG
        }
    }
}
