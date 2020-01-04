Shader "Custom/RhombusPattern"
{
    Properties
    {
        _UVScale("UVScale", Range(1, 10)) = 2
        _FactorX("FactorX", Range(0, 1)) = 0.5
        _FactorY("FactorY", Range(0, 1)) = 0.5
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

            half _FactorX;
            half _FactorY;
            half _BevelWidth;

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
                对象限取对称，即可在第一象限直接计算当前点到线段的绝对距离场；
                然后判断当前点是否在菱形内，对距离场取正负即可；
                */
                half2 v = abs(i.uv);
                //计算点到线段的距离
                half2 pv = v - half2(0, _FactorY);
                half2 pp = half2(_FactorX, -_FactorY);
                //iq的方法为以菱形边的中点为起点进行投影，因此投影因子为(-1,1)
                //这里以Y轴上顶点为起点进行投影，投影因子为(0, 1)
                half projectFactor = clamp(dot(pp, pv)/dot(pp,pp), 0, 1);   
                dist = length(pv - pp*projectFactor);

                //直接使用直线方程判断点是否位菱形内，即是否在直线的内侧
                half s = sign(v.x*_FactorY + v.y*_FactorX - _FactorX*_FactorY);
                dist *= s;

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
