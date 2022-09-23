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

// rgb ���� �����ϱ� ���� ����
float _R;
float _G;
float _B;

// uv���� �����ϱ� ���� ����
float _FillU;
float _FillV;

float _InvertV;
float _InvertU;

// �ö���� ������ ���ǵ� ��
float _Speed;

// �ö���� ������ ����( ������ )
float _Scale1;
float _Scale2;
float _Scale3;
float _Scale4;

// �ö�� ���°� ( ���뿩�� )
float _Plasma;

// �ö�� �Ŀ� ( ������ ���� )
float _PlasmaPower;

// -�����꿡 ����� ���� ���
float _DissolveAmount;
sampler2D _DissolveTex;
float _DissolveRampSize;
sampler2D _DissolveRampTex;

// �����긦 ������ ���ΰ��� ���� ����
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

// ������ ���̴��� �����ϱ� ���� �Լ�
float3 Dissolve(v2f IN)
{
    float dissolveColor = tex2D(_DissolveTex, IN.texcoord);

    clip(dissolveColor - _DissolveAmount);

    // smoothstep�Լ��� ù��° �Ű������� ����, �ι�° �Ű������� ����, ����° �Ű������� �� ��� ��
    // ���������۴ٸ� 0���� �ǵ����ְ�, �������� ũ�ٸ� 1���� �ǵ����ִ� �Լ��Դϴ�.

    // ���� ������ �����ϰ�, ���� �������� ���� ���� 0
    // ���� �������� Ŭ ���� 1
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

// ���� ���̴� �Լ��� ������ �������� �ȼ������� �����Ǿ� �ȼ��� ������ŭ ȣ��Ǵ� �Լ�
// �ȼ� ���̴� �Լ� ( �ȼ��� ������ŭ ȣ��Ǵ� �Լ� )
fixed4 SpriteFrag(v2f IN) : SV_Target
{
    // �ؽ�ó�� ������ ����ϴ�.
    fixed4 uva = SampleSpriteTexture (IN.texcoord) * IN.color;
    
    // �����ϰ� ������ ������� �������� ( ����ó���� �ϱ� ���ؼ��� ) ���İ��� ������ 
    // ��� ������ 0���� �����Ǿ� �־�� �մϴ�.
    float4 color = float4(0, 0, 0, 0);

    float uSign = 0; // �ؽ�ó�� x ��ǥ��
    float vSign = 0;
    
    // sign �Լ��� 0 �̻��̶�� 1�� ���� �����ϰ�, 0 �̸��̶�� -1�� ���� 
    // �����ϴ� �Լ��Դϴ�
    
    // IN.texcoord.y == 0.6
    // _FillV = 0.5
    if( _InvertV > 0 )
        //  0.5 - (1 - 0.6) == 0.3 -> 1���� ���Ϲް� �ȴ�.
        vSign = sign(_FillV - (1-IN.texcoord.y) );
    else
        // (0.5 - 0.6) == -0.1 -> -1���� ���Ϲް� �ȴ�.
        vSign = sign(_FillV - IN.texcoord.y);

    if (_InvertU > 0)
        uSign = sign(_FillU - (1 - IN.texcoord.x));
    else
        uSign = sign(_FillU - IN.texcoord.x);
    

    float sign = vSign;

    // �� ���� �޾� �� ���߿��� ū ���� �ǵ��� �ִ� �Լ��Դϴ�.
    color += max(0, sign);

    if (_Plasma > 0)
        color.rgb += Plasma(IN);

    if (_Dissolve > 0)
        color.rgb += Dissolve(IN);

    color.rgb = AddRGB(color);

    // �Ʒ� �κ��� ������ �������ִ� �κ��̱� ������ ���� ���꿡 ���� ó���� 
    // �� �ڵ� ���ʿ� ��ġ�Ǿ�� �մϴ�.
    if (vSign < 0 || uSign < 0)
        color = 0;

    color.rgb *= uva.rgb;

    color *= uva.a;
    return color;
}

#endif // UNITY_SPRITES_INCLUDED
