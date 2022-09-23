Shader "Custom/Dissolve"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _DissolveAmount("Dissolve Amount", Range(0, 1)) = 0
        _DissolveTex("Dissolve Texture", 2D) = "white" {}
        _DissolveRampTex("Dissolve Ramp Texture", 2D) = "white" {}
        _DissolveRampSize("Dissolve Ramp Size", Float) = 0.2
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue" = "Transparent"}
        LOD 200
        Blend One OneMinusSrcAlpha

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Lambert alpha:auto
        #pragma target 3.0

        sampler2D _MainTex;
        float _DissolveAmount;
        sampler2D _DissolveTex;
        float _DissolveRampSize;
        sampler2D _DissolveRampTex;

        struct Input
        {
            float2 uv_MainTex;
        };
        fixed4 _Color;
        void surf (Input IN, inout SurfaceOutput o)
        {
            float dissolveColor = tex2D(_DissolveTex, IN.uv_MainTex);
            
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            o.Alpha = c.a;

            // Ŭ�� �Լ��� ������ ������ �Ǹ� �ȼ��� ������ �ʵ��� ó���ϴ� �Լ��Դϴ�.
            //clip(o.Albedo - _DissolveAmount);
            clip(dissolveColor - _DissolveAmount);

            // smoothstep�Լ��� ù��° �Ű������� ����, �ι�° �Ű������� ����, ����° �Ű������� �� ��� ��
            // ���������۴ٸ� 0���� �ǵ����ְ�, �������� ũ�ٸ� 1���� �ǵ����ִ� �Լ��Դϴ�.

            // ���� ������ �����ϰ�, ���� �������� ���� ���� 0
            // ���� �������� Ŭ ���� 1
            float ramp = smoothstep(_DissolveAmount, _DissolveAmount + _DissolveRampSize, dissolveColor);
            float3 rampColor = tex2D(_DissolveRampTex, float2(ramp, 0));
            float3 rampContribution = rampColor * (1 - ramp);

            o.Albedo += rampContribution;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
