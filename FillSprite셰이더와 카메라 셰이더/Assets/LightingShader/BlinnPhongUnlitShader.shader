Shader "Unlit/BlinnPhongUnlitShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
            #include "UnityLightingCommon.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                // 표면에 수직인 벡터를 요청합니다.
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;

                // 광원과, 카메라 벡터의 덧셈 결과
                float3 halfVec : TEXCOORD1;
                // 광원과 표면의 내적 결과
                float3 diffuse : TEXCOORD2;
                float3 normal : NORMAL;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                // 시선벡터 ( 유니티 좌표계 )
                float3 viewDir = normalize(_WorldSpaceCameraPos);
                // 광원벡터 ( 유니티 좌표계 ) 
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);

                // 표면에 수직인 벡터 ( 유니티 좌표계로 변경 )
                float3 normal = UnityObjectToWorldNormal(v.normal);
                // 광원과 카메라의 중간 벡터를 구합니다.
                o.halfVec = normalize(lightDir + viewDir);
                o.diffuse = dot(lightDir, normal);
                o.normal = normal;
                // 모델링의 정점 좌표를 유니티의 스크린 좌표값으로 변경하는 함수입니다.
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float3 diffuse = saturate(i.diffuse);
                float3 halfVec = normalize(i.halfVec);
                float3 viewDir = normalize(_WorldSpaceCameraPos);
                float3 normal = normalize(i.normal);
                float3 specular = 0;
                if (diffuse.x > 0)
                {
                    specular = saturate(dot(halfVec, normal));
                    specular = pow(specular, 20);
                }
                

                return float4( float3(0.1, 0.1, 0.1) + specular, 1 );
            }
            ENDCG
        }
    }
}
