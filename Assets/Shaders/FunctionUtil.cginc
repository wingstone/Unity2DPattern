#ifndef _FUNCTIONUTIL_
#define _FUNCTIONUTIL_

//根据t显示color gradient
half3 pal( in float t, in half3 a, in half3 b, in half3 c, in half3 d ){
    return a + b*cos( 6.28318*(c*t+d) );
}

half3 pal( in float t){
    t *= 2;
    half3 color = abs(sin(t*15)) * ( saturate(t) * half3(0.9,0.86,0.59) + saturate(-t) * half3(0.57,0.73,0.77) ); //gradient
    color += smoothstep(0, 0.02, 0.03 - abs(t)); //bound
    return color;
}

//max、min函数扩展
half2 max2(half2 a, half2 b)
{
    return half2(max(a.x, b.x), max(a.y,b.y));
}

half2 min2(half2 a, half2 b)
{
    return half2(min(a.x, b.x), min(a.y,b.y));
}

half crossValue(half2 vec1, half2 vec2)
{
    return vec1.x * vec2.y - vec1.y *vec2.x;
}

#endif