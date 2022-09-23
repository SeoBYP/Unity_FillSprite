Shader "Unlit/PhongUnlitShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        // 픽셀을 연산처리하겠다는 식별 코드입니다.
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
                float4 vertex   : POSITION;
                float2 uv       : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                // 스크린 값으로 변경된 좌표값을 의미한다라고 생각하시면 됩니다.
                float4 vertex : SV_POSITION;
                // TEXCOORD값은 텍스처의 좌표값을 의미합니다.
                // 그런데 셰이더에서는 TEXCOORD 식별값을 단순히 저장값을 식별하는 용도로
                // 사용하기도 합니다.
                float3 reflection   : TEXCOORD1;
                float3 diffuse      : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            //Contents
            // GridLayoutGroup
            // ContentSizeFitter  

            v2f vert (appdata v)
            {
                v2f o;
                // _WorldSpaceCameraPos 현재 유니티에 배치되어 있는 카메라의 위치값을 가리킵니다.
                float3 viewDir = normalize(_WorldSpaceCameraPos);

                // 현재 유니티신에 배치되어 있는 광원의 위치
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);

                // 현재 셰이더와 같은 계층에 있는 Transform과 정점을 곱해줍니다.
                // 월드 노멀 벡터로 변경합니다. ( 표면에 수직인 벡터 )
                float3 normal = normalize( UnityObjectToWorldNormal(v.normal) );

                // 투영 벡터를 구합니다.
                float3 projection = dot(lightDir, normal) * normal;

                // 투영 벡터를 두배 누적합니다.
                projection *= 2;

                // 투영 벡터에서 광원의 위치를 빼면 반사 벡터를 구할 수 있습니다.
                float3 refl = projection - lightDir;

                // 연산된 값을 저장합니다.
                o.reflection = refl;

                // 광원과 표면의 법선 벡터를 내적하여 고르게 반사되는 빛을 표현하기 위해
                // 저장합니다.
                o.diffuse = dot(lightDir, normal);

                // vert함수의 매개변수로 들어오는 정점 좌표값은
                // 3d 툴에서 만들어진 모델링에 대한 좌표값
                // UnityObjectToClipPos 함수는 현재 머테리얼과 같은 계층 계층의 
                // Transform을 참고하여 스크린좌표값으로 바꿔주는 역할을 수행합니다.
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            // 픽셀의 개수만큼 호출되는 함수입니다.
            fixed4 frag(v2f i) : SV_Target
            {

                float3 diffuse = saturate(i.diffuse);
                float3 reflection = normalize(i.reflection);
                float3 viewDir = normalize(_WorldSpaceCameraPos);

                float3 specular = 0;
                // 난 반사광이 존재하지 않는 표면에는 빛이 닿지 않는다는 것이므로
                // 정 반사광을 연산할 필요가 없습니다.
                if (diffuse.x > 0)
                {
                    // saturate : 0이하라면 값을 0으로 맞춰주는 함수입니다.
                    // dot : 두 값을 내적하는 함수입니다.
                    // normalize : 벡터의 길이를 1로 맞춰주는 함수입니다.
                    specular = saturate(dot(reflection, viewDir));
                    specular = pow(specular, 20);
                }
                float3 ambient = float3(0.1, 0.1, 0.1);
                return float4(specular + ambient, 1);

            }
            ENDCG
        }


    }
}
