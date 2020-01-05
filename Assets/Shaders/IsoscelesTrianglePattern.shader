Shader "Custom/IsoscelesTrianglePattern"
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
                等腰三角形精确距离场：
                对X轴取对称，位于底边正下方的距离场为y值得绝对值，其他区域的距离场为点到斜边的距离，然后根据点是否在斜边内侧来计算正负；
                */
                half2 uv = i.uv;
                uv.x = abs(uv.x);
                //计算点到斜线段的距离，这一步可以采用数值方法计算，这里采用通用方法
                half2 pv = uv - half2(0, _FactorY);
                half2 pp = half2(_FactorX, -_FactorY);
                //以Y轴上顶点为起点进行投影，投影因子为(0, 1)
                half projectFactor = clamp(dot(pp, pv)/dot(pp,pp), 0, 1);   
                dist = length(pv - pp*projectFactor);

                //考虑点到底边的距离
                dist = min(dist, length( half2( max(uv.x - _FactorX, 0), uv.y) ) );

                //判断点是否在斜线的内侧
                half s = sign(uv.x*_FactorY + uv.y*_FactorX - _FactorX*_FactorY);

                //考虑底边的内外侧
                s = max(s, -sign(uv.y));
                
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
