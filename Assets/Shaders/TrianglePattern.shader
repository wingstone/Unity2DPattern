Shader "Custom/TrianglePattern"
{
    Properties
    {
        _UVScale("UVScale", Range(1, 10)) = 2
        _Point1("Point1(X, Y)", Vector) = (0,0,0,0)
        _Point2("Point2(X, Y)", Vector) = (0.5,0.5,0,0)
        _Point3("Point3(X, Y)", Vector) = (-0.3,-0.5,0)
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

            half2 _Point1;
            half2 _Point2;
            half2 _Point3;
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
                直接计算当前点到三条线段的距离，取最小值即可获得绝对值距离场；
                然后使用同向法判断当前点是否在三角形内，给绝对值距离场取正负即可；
                */
                half2 pp1 = _Point2 - _Point1;
                half2 pp2 = _Point3 - _Point2;
                half2 pp3 = _Point1 - _Point3;
                half2 pv1 = i.uv - _Point1;
                half2 pv2 = i.uv - _Point2;
                half2 pv3 = i.uv - _Point3;
                //计算点到三条直线的距离
                half projectFactor1 = clamp(dot(pp1, pv1)/dot(pp1,pp1), 0, 1);
                half dist1 = length(pv1 - pp1*projectFactor1);
                half projectFactor2 = clamp(dot(pp2, pv2)/dot(pp2,pp2), 0, 1);
                half dist2 = length(pv2 - pp2*projectFactor2);
                half projectFactor3 = clamp(dot(pp3, pv3)/dot(pp3,pp3), 0, 1);
                half dist3 = length(pv3 - pp3*projectFactor3);
                dist = min(dist1, min(dist2, dist3));
                //使用同向法计算点是否位于三角形内
                half s = sign(crossValue(pp1, pp3));
                half s1 = s*sign(crossValue(pv1, pp1));
                half s2 = s*sign(crossValue(pv2, pp2));
                half s3 = s*sign(crossValue(pv3, pp3));
                s = min(s1, min(s2, s3));
                dist *= sign(-s);

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
