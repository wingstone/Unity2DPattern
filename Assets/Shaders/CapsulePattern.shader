Shader "Custom/CapsulePattern"
{
    Properties
    {
        _UVScale("UVScale", Range(1, 10)) = 2
        _Width("Redius", Range(0, 1)) = 0.2
        _Length("Length", Range(0, 1)) = 0.5
        [Toggle]_ShowDistance("Show Distance(Exact Distance Field)", Int) = 0
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

            half _Width;
            half _Length;
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
                i.uv.x = max(abs(i.uv.x) - _Length, 0);
                dist = pow(abs(i.uv.x), _Power) + pow(abs(i.uv.y), _Power);
                dist = pow(dist, 1/_Power) - _Width;
#else
                /*********思路*********
                精确距离场：
                对X轴取对称，减去线的一半长度，直接计算圆的距离场即可；
                原理：线上下方的距离场与两端距两端点的距离一样；
                */
                i.uv.x = max(abs(i.uv.x) - _Length, 0);
                dist = length(i.uv) - _Width;
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
