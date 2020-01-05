Shader "Custom/StarPattern"
{
    Properties
    {
        _UVScale("UVScale", Range(1, 10)) = 2
        _Redius("Redius", Range(0, 1)) = 0.5
        _Factor("Factor(2-Number)", Range(2, 10)) = 2
        _Number("Number", Range(3, 10)) = 5
        [Toggle]_ShowDistance("Show Distance(Exact Distance Field)", Int) = 0
        [Header(Beveling Control)]
        [Toggle]_UseBeveling("Use Beveling", Int) = 0
        _BevelWidth("Bevel Width", Range(0,1)) = 0.2
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

            half _Redius;
            half _Factor;
            half _Number;

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
                将点转换至极坐标空间，然后取mod，只计算一个角的距离场即可
                */
                // next 4 lines can be precomputed for a given shape
                float an = 3.141593/float(_Number);
                float en = 3.141593/_Factor;  // m is between 2 and n
                half2  acs = half2(cos(an),sin(an));
                half2  ecs = half2(cos(en),sin(en)); // ecs=half2(0,1) for regular polygon,

                half2 p = i.uv;
                float bn = fmod(atan2(p.x,p.y),2.0*an) - an;
                p = length(p)*half2(cos(bn),abs(sin(bn)));
                p -= _Redius*acs;
                p += ecs*clamp( -dot(p,ecs), 0.0, _Redius*acs.y/ecs.y);

                dist = length(p)*sign(p.x);

#ifdef _USEBEVELING_ON
                dist -= _BevelWidth;
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
