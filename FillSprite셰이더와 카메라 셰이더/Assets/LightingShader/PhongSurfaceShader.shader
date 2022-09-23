Shader "Custom/PhongSurfaceShader"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200
        CGPROGRAM
        #pragma surface surf MyPhong
        #pragma target 3.0
        sampler2D _MainTex;
        struct Input{
            float2 uv_MainTex;
        };
        fixed4 _Color;
        // �ȼ��� ������ŭ ȣ��Ǵ� �Լ��Դϴ�.
        void surf (Input IN, inout SurfaceOutput o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            o.Alpha = c.a;
        }
        // SurfaceOutput s : surf�Լ����� ����� �����
        // half3 lightDir : ǥ�鿡�� ������ ���ϴ� ����
        // half atten : ���� ����
        // half3 viewDir : ǥ�鿡�� ī�޶� ���ϴ� ����
        
        // half4 Lighting- �Լ��� �̸� - (SurfaceOutput s, half3 lightDir, half atten) ���İ�
        // half4 Lighting- �Լ��� �̸� - (SurfaceOutput s, half3 lightDir, half3 viewDir, half atten)
        // -1 ~ 1
        // -1*0.5 + 0.5 = 0
        // 1 * 0.5 + 0.5 = 

        float4 LightingMyPhong(SurfaceOutput s, float3 lightDir, float3 viewDir, float atten)
        { 
            float3 refDir = reflect(-lightDir, s.Normal);
            // ������ ������� -1���� 1������ ������ �����ϴ�.
            //float phongDot = max(0, (dot(refDir, viewDir)));
            float phongDot = dot(refDir, viewDir) * 0.5 + 0.5;
            s.Albedo += pow(phongDot, 20);

            return float4(s.Albedo, s.Alpha);
        }

        ENDCG
    }
    FallBack "Diffuse"
}
