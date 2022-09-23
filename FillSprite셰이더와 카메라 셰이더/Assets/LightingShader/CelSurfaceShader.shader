Shader "Custom/CelSurfaceShader"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _NumCels("Number Of Cels", Range(0, 11)) = 1

    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        
        #pragma surface surf MyCel 

        
        #pragma target 3.0

        sampler2D _MainTex;
        float _NumCels;
        fixed4 _Color;

        struct Input
        {
            float2 uv_MainTex;
        };

        half4 LightingMyCel(SurfaceOutput s, half3 lightDir, half atten)
        {
            half lDot = dot(s.Normal, lightDir);

            lDot = floor(lDot * _NumCels) / _NumCels;

            s.Albedo = s.Albedo * lDot * atten * _LightColor0.rgb;
            return half4(s.Albedo, s.Alpha);
        }

        void surf (Input IN, inout SurfaceOutput o)
        {
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
