Shader "Custom/EclipsePattern"
{
    Properties
    {
        _UVScale("UVScale", Range(1, 10)) = 2
        _Radius("Redius", Range(0, 1)) = 0.5
        _X("X", Range(0.1, 10)) = 1
        _Y("Y", Range(0.1, 10)) = 1
        [Toggle]_ShowDistance("Show Distance(Not Exact Distance Field)", Int) = 0
        [Header(Power Control)]
        [Toggle]_UsePower("Use Power(Power default is 2, 2 is Euler distance)", Int) = 0
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
            #include "FunctionUtil.cginc"

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
            half _UVScale;

            half _Radius;
            half _X;
            half _Y;
            half _Power;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = (v.uv - half2(0.5, 0.5))*_UVScale;
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                half3 color = 0;

                half dist = 0;

#ifdef _USEPOWER_ON
                dist = pow(abs(i.uv.x/_X), _Power) + pow(abs(i.uv.y/_Y), _Power);
                dist = pow(dist, 1/_Power) - _Radius;
#else
                half x = i.uv.x/_X;
                half y = i.uv.y/_Y;
                
                dist = sqrt(x*x + y*y) - _Radius;
#endif

#ifdef _SHOWDISTANCE_ON
                
                color = pal( dist );;
#else
                color = smoothstep(0, 0.02, dist);
#endif

                return half4(color, 1);
            }
            ENDCG
        }
    }
}
