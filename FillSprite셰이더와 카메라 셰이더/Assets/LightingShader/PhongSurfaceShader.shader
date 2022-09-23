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
        // 픽셀의 개수만큼 호출되는 함수입니다.
        void surf (Input IN, inout SurfaceOutput o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            o.Alpha = c.a;
        }
        // SurfaceOutput s : surf함수에서 연산된 결과값
        // half3 lightDir : 표면에서 광원을 향하는 벡터
        // half atten : 빛의 감쇠
        // half3 viewDir : 표면에서 카메라를 향하는 벡터
        
        // half4 Lighting- 함수의 이름 - (SurfaceOutput s, half3 lightDir, half atten) 형식과
        // half4 Lighting- 함수의 이름 - (SurfaceOutput s, half3 lightDir, half3 viewDir, half atten)
        // -1 ~ 1
        // -1*0.5 + 0.5 = 0
        // 1 * 0.5 + 0.5 = 

        float4 LightingMyPhong(SurfaceOutput s, float3 lightDir, float3 viewDir, float atten)
        { 
            float3 refDir = reflect(-lightDir, s.Normal);
            // 내적한 결과값은 -1에서 1까지의 범위를 갖습니다.
            //float phongDot = max(0, (dot(refDir, viewDir)));
            float phongDot = dot(refDir, viewDir) * 0.5 + 0.5;
            s.Albedo += pow(phongDot, 20);

            return float4(s.Albedo, s.Alpha);
        }

        ENDCG
    }
    FallBack "Diffuse"
}
