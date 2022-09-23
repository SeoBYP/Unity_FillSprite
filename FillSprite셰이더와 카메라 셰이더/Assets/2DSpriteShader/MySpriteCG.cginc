// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

#ifndef UNITY_SPRITES_INCLUDED
#define UNITY_SPRITES_INCLUDED

#include "UnityCG.cginc"

#ifdef UNITY_INSTANCING_ENABLED

    UNITY_INSTANCING_BUFFER_START(PerDrawSprite)
        // SpriteRenderer.Color while Non-Batched/Instanced.
        UNITY_DEFINE_INSTANCED_PROP(fixed4, unity_SpriteRendererColorArray)
        // this could be smaller but that's how bit each entry is regardless of type
        UNITY_DEFINE_INSTANCED_PROP(fixed2, unity_SpriteFlipArray)
    UNITY_INSTANCING_BUFFER_END(PerDrawSprite)

    #define _RendererColor  UNITY_ACCESS_INSTANCED_PROP(PerDrawSprite, unity_SpriteRendererColorArray)
    #define _Flip           UNITY_ACCESS_INSTANCED_PROP(PerDrawSprite, unity_SpriteFlipArray)

#endif // instancing

CBUFFER_START(UnityPerDrawSprite)
#ifndef UNITY_INSTANCING_ENABLED
    fixed4 _RendererColor;
    fixed2 _Flip;
#endif
    float _EnableExternalAlpha;
CBUFFER_END

// Material Color.
fixed4 _Color;
sampler2D _MainTex;
sampler2D _AlphaTex;

// rgb 값을 적용하기 위한 변수
float _R;
float _G;
float _B;

// uv값을 조절하기 위한 변수
float _FillU;
float _FillV;

float _InvertV;
float _InvertU;

// 플라즈마를 적용할 스피드 값
float _Speed;

// 플라즈마를 적용할 비율( 스케일 )
float _Scale1;
float _Scale2;
float _Scale3;
float _Scale4;

// 플라즈마 상태값 ( 적용여부 )
float _Plasma;

// 플라즈마 파워 ( 적용할 비율 )
float _PlasmaPower;

// -디졸브에 사용할 변수 목록
float _DissolveAmount;
sampler2D _DissolveTex;
float _DissolveRampSize;
sampler2D _DissolveRampTex;

// 디졸브를 적용할 것인가에 대한 여부
float _Dissolve;

struct appdata_t
{
    float4 vertex   : POSITION;
    float4 color    : COLOR;
    float2 texcoord : TEXCOORD0;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct v2f
{
    float4 vertex   : SV_POSITION;
    fixed4 color    : COLOR;
    float2 texcoord : TEXCOORD0;
    UNITY_VERTEX_OUTPUT_STEREO
};

inline float4 UnityFlipSprite(in float3 pos, in fixed2 flip)
{
    return float4(pos.xy * flip, pos.z, 1.0);
}

v2f SpriteVert(appdata_t IN)
{
    v2f OUT;

    UNITY_SETUP_INSTANCE_ID (IN);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);

    OUT.vertex = UnityFlipSprite(IN.vertex, _Flip);
    OUT.vertex = UnityObjectToClipPos(OUT.vertex);
    OUT.texcoord = IN.texcoord;
    OUT.color = IN.color * _Color * _RendererColor;

    #ifdef PIXELSNAP_ON
    OUT.vertex = UnityPixelSnap (OUT.vertex);
    #endif

    return OUT;
}

float3 AddRGB(float3 color)
{
    color.r += _R;
    color.g += _G;
    color.b += _B;
    return color;
}

float3 Plasma(v2f IN)
{
    float3 plasma = float3(0,0,0);
    float t = _Time.x * _Speed;
    float c = sin(IN.vertex.x * _Scale1 + t);
    c += sin(IN.vertex.y * _Scale2 + t);
    c += sin(_Scale3 * (IN.vertex.x * sin(t / 2) + IN.vertex.y * cos(t / 3)) + t);
    float c1 = pow(IN.vertex.x + 0.5 * sin(t / 5), 2);
    float c2 = pow(IN.vertex.y + 0.5 * sin(t / 3), 2);
    c += sin(sqrt(_Scale4 * (c1 + c2) + t));
    plasma.r = sin(c / 4.0f * 3.141596);
    plasma.g = sin(c / 4.0f * 3.141596 + 2 * 3.141596 / 4);
    plasma.b = sin(c / 4.0f * 3.141596 + 4 * 3.141596 / 4);
    return plasma * _PlasmaPower;
}

// 디졸브 셰이더를 적용하기 위한 함수
float3 Dissolve(v2f IN)
{
    float dissolveColor = tex2D(_DissolveTex, IN.texcoord);

    clip(dissolveColor - _DissolveAmount);

    // smoothstep함수는 첫번째 매개변수로 시점, 두번째 매개변수로 종점, 세번째 매개변수로 비교 대상 값
    // 시점보다작다면 0값을 되돌려주고, 종점보다 크다면 1값을 되돌려주는 함수입니다.

    // 값의 범위를 지정하고, 값의 범위보다 작을 경우는 0
    // 값의 범위보다 클 경우는 1
    float ramp = smoothstep(_DissolveAmount, _DissolveAmount + _DissolveRampSize, dissolveColor);
    float3 rampColor = tex2D(_DissolveRampTex, float2(ramp, 0));
    float3 rampContribution = rampColor * (1 - ramp);

    return rampContribution;
}


fixed4 SampleSpriteTexture (float2 uv)
{
    fixed4 color = tex2D (_MainTex, uv);

#if ETC1_EXTERNAL_ALPHA
    fixed4 alpha = tex2D (_AlphaTex, uv);
    color.a = lerp (color.a, alpha.r, _EnableExternalAlpha);
#endif

    return color;
}

// 정점 셰이더 함수가 연산이 끝났을때 픽셀단위로 보간되어 픽셀의 개수만큼 호출되는 함수
// 픽셀 셰이더 함수 ( 픽셀의 개수만큼 호출되는 함수 )
fixed4 SpriteFrag(v2f IN) : SV_Target
{
    // 텍스처의 색상을 얻습니다.
    fixed4 uva = SampleSpriteTexture (IN.texcoord) * IN.color;
    
    // 완전하게 색상을 출력하지 않으려면 ( 알파처리를 하기 위해서는 ) 알파값을 포함한 
    // 모든 색상값이 0으로 설정되어 있어야 합니다.
    float4 color = float4(0, 0, 0, 0);

    float uSign = 0; // 텍스처의 x 좌표계
    float vSign = 0;
    
    // sign 함수는 0 이상이라면 1의 값을 리턴하고, 0 미만이라면 -1의 값을 
    // 리턴하는 함수입니다
    
    // IN.texcoord.y == 0.6
    // _FillV = 0.5
    if( _InvertV > 0 )
        //  0.5 - (1 - 0.6) == 0.3 -> 1값을 리턴받게 된다.
        vSign = sign(_FillV - (1-IN.texcoord.y) );
    else
        // (0.5 - 0.6) == -0.1 -> -1값을 리턴받게 된다.
        vSign = sign(_FillV - IN.texcoord.y);

    if (_InvertU > 0)
        uSign = sign(_FillU - (1 - IN.texcoord.x));
    else
        uSign = sign(_FillU - IN.texcoord.x);
    

    float sign = vSign;

    // 두 값을 받아 두 값중에서 큰 값을 되돌려 주는 함수입니다.
    color += max(0, sign);

    if (_Plasma > 0)
        color.rgb += Plasma(IN);

    if (_Dissolve > 0)
        color.rgb += Dissolve(IN);

    color.rgb = AddRGB(color);

    // 아래 부분이 영역을 지정해주는 부분이기 때문에 색상 연산에 대한 처리는 
    // 이 코드 위쪽에 배치되어야 합니다.
    if (vSign < 0 || uSign < 0)
        color = 0;

    color.rgb *= uva.rgb;

    color *= uva.a;
    return color;
}

#endif // UNITY_SPRITES_INCLUDED
