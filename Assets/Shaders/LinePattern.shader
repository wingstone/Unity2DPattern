Shader "Custom/LinePattern"
{
    Properties
    {
        _UVScale("UVScale", Range(1, 10)) = 2
        _Point1("Point1(X, Y)", Vector) = (0,0,0,0)
        _Point2("Point2(X, Y)", Vector) = (0.5,0.5,0,0)
        _Width("_Width", Range(0, 1)) = 0.2
        [Toggle]_ShowDistance("Show Distance(Exact Distance Field)", Int) = 0
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

            half2 _Point1;
            half2 _Point2;
            half _Width;
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

                /*********思路*********
                精确距离场：
                先计算当前点在线段上的投影点，超过线段范围投影至端点上，然后计算当前点都投影点的距离即可
                */
                half2 pp1 = _Point2 - _Point1;
                half2 pv1 = i.uv - _Point1;
                half projectFactor = clamp(dot(pp1, pv1)/dot(pp1,pp1), 0, 1);
                dist = length(pv1 - pp1*projectFactor) - _Width;

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
