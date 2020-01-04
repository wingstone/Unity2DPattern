Shader "Custom/CubePatternExample"
{
    Properties
    {
        _UVScale("UVScale", Range(1, 10)) = 2
        _Width("Width", Range(0, 1)) = 0.5
        [Toggle]_ShowDistance("Show Distance", Int) = 0
        [Toggle]_Exact("Exact Distance", Int) = 0
        [Header(Beveling Control)]
        [Toggle]_UseBeveling("Use Beveling(Power default is 2, 2 is Euler distance)", Int) = 0
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
            #pragma shader_feature _EXACT_ON 
            #pragma shader_feature _SHOWDISTANCE_ON 
            #pragma shader_feature _USEBEVELING_ON

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
            half _Height;
            half _Power;
            half _BevelLength;

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
#ifdef _EXACT_ON

#ifdef _USEBEVELING_ON
                half bevel = min(_Width, _BevelLength);
                half2 d = abs(i.uv) - _Width + bevel;
                half2 outLen = max2( d, 0);
                dist = pow( pow(outLen.x, _Power) + pow(outLen.y, _Power), 1/_Power) + min(max(d.x, d.y), 0) - bevel;
#else
                /*********思路*********
                精确距离场：
                外部距离场：length(max2( d, 0))：减去宽度后，分别取XY的正数，然后求距离；这样上下左右计算出到边的距离，其他为到角的距离；
                内部距离场：min(max(d.x, d.y), 0)：减去宽度后，取负数距离的大值即可；
                */
                half2 d = abs(i.uv) - _Width;
                dist = length(max2( d, 0))  + min(max(d.x, d.y), 0);
#endif

#else
                /*********思路*********
                非精确距离场：
                外部距离场：max(max(d.x, d.y), 0)：减去宽度后，取正数距离的小值即可；
                内部距离场：同上的内部距离场
                */
                half2 d = abs(i.uv) - _Width;
                dist = max(max(d.x, d.y), 0)  + min(max(d.x, d.y), 0);
#endif

#ifdef _SHOWDISTANCE_ON
                
                color = pal( dist );
#else
                color = smoothstep(0, 0.02, dist);
#endif

                return half4(color, 1);
            }
            ENDHLSL
        }
    }
}
