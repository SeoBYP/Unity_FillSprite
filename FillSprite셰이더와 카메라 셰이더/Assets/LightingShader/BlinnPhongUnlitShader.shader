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
                // ǥ�鿡 ������ ���͸� ��û�մϴ�.
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;

                // ������, ī�޶� ������ ���� ���
                float3 halfVec : TEXCOORD1;
                // ������ ǥ���� ���� ���
                float3 diffuse : TEXCOORD2;
                float3 normal : NORMAL;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                // �ü����� ( ����Ƽ ��ǥ�� )
                float3 viewDir = normalize(_WorldSpaceCameraPos);
                // �������� ( ����Ƽ ��ǥ�� ) 
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);

                // ǥ�鿡 ������ ���� ( ����Ƽ ��ǥ��� ���� )
                float3 normal = UnityObjectToWorldNormal(v.normal);
                // ������ ī�޶��� �߰� ���͸� ���մϴ�.
                o.halfVec = normalize(lightDir + viewDir);
                o.diffuse = dot(lightDir, normal);
                o.normal = normal;
                // �𵨸��� ���� ��ǥ�� ����Ƽ�� ��ũ�� ��ǥ������ �����ϴ� �Լ��Դϴ�.
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
