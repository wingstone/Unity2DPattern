Shader "Custom/StarPattern"
{
    Properties
    {
        _UVScale("UVScale", Range(1, 10)) = 2
        _Redius1("Redius1(out corner)", Range(0, 1)) = 0.5
        _Redius2("Redius2(in corner)", Range(0, 10)) = 0.2
        _Number("Number(in corner)", Range(3, 10)) = 3
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

            half _Redius1;
            half _Redius2;
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
                float an = UNITY_PI/float(_Number);     //为一个拐角对应圆心角的一半

                half2 p = i.uv;
                half angle = atan2(p.y, p.x);
                angle *= sign(p.y);     //atan2函数计算出来的角度全是正值，需要对y<0的情况进行反向
                float bn = fmod(angle,2.0*an) - an;
                p = length(p)*half2(cos(bn),abs(sin(bn)));      //从极坐标变换至直角坐标，并关于外角平分线对称，接下来就是求点到线段的距离场

                //outCurner为外角点的坐标，并将p转换为外角点到改点的矢量
                half2 outCurner = _Redius1*half2(cos(an),sin(an));
                p -= outCurner;       

                //下面处理到边的距离，iq限制了内角的范围，我们将其扩展一下，并用in cornner redius来表示~
                //这里使用点到直线的距离来计算
                half2 oi = half2(_Redius2, 0) - outCurner;
                dist = length(p - oi*dot(oi,p)/dot(oi,oi));
                //采用cross的方法来判断朝向
                half s = sign(oi.x*p.y - oi.y*p.x);
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
