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

        // �ȼ��� ����ó���ϰڴٴ� �ĺ� �ڵ��Դϴ�.
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
                // ��ũ�� ������ ����� ��ǥ���� �ǹ��Ѵٶ�� �����Ͻø� �˴ϴ�.
                float4 vertex : SV_POSITION;
                // TEXCOORD���� �ؽ�ó�� ��ǥ���� �ǹ��մϴ�.
                // �׷��� ���̴������� TEXCOORD �ĺ����� �ܼ��� ���尪�� �ĺ��ϴ� �뵵��
                // ����ϱ⵵ �մϴ�.
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
                // _WorldSpaceCameraPos ���� ����Ƽ�� ��ġ�Ǿ� �ִ� ī�޶��� ��ġ���� ����ŵ�ϴ�.
                float3 viewDir = normalize(_WorldSpaceCameraPos);

                // ���� ����Ƽ�ſ� ��ġ�Ǿ� �ִ� ������ ��ġ
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);

                // ���� ���̴��� ���� ������ �ִ� Transform�� ������ �����ݴϴ�.
                // ���� ��� ���ͷ� �����մϴ�. ( ǥ�鿡 ������ ���� )
                float3 normal = normalize( UnityObjectToWorldNormal(v.normal) );

                // ���� ���͸� ���մϴ�.
                float3 projection = dot(lightDir, normal) * normal;

                // ���� ���͸� �ι� �����մϴ�.
                projection *= 2;

                // ���� ���Ϳ��� ������ ��ġ�� ���� �ݻ� ���͸� ���� �� �ֽ��ϴ�.
                float3 refl = projection - lightDir;

                // ����� ���� �����մϴ�.
                o.reflection = refl;

                // ������ ǥ���� ���� ���͸� �����Ͽ� ���� �ݻ�Ǵ� ���� ǥ���ϱ� ����
                // �����մϴ�.
                o.diffuse = dot(lightDir, normal);

                // vert�Լ��� �Ű������� ������ ���� ��ǥ����
                // 3d ������ ������� �𵨸��� ���� ��ǥ��
                // UnityObjectToClipPos �Լ��� ���� ���׸���� ���� ���� ������ 
                // Transform�� �����Ͽ� ��ũ����ǥ������ �ٲ��ִ� ������ �����մϴ�.
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            // �ȼ��� ������ŭ ȣ��Ǵ� �Լ��Դϴ�.
            fixed4 frag(v2f i) : SV_Target
            {

                float3 diffuse = saturate(i.diffuse);
                float3 reflection = normalize(i.reflection);
                float3 viewDir = normalize(_WorldSpaceCameraPos);

                float3 specular = 0;
                // �� �ݻ籤�� �������� �ʴ� ǥ�鿡�� ���� ���� �ʴ´ٴ� ���̹Ƿ�
                // �� �ݻ籤�� ������ �ʿ䰡 �����ϴ�.
                if (diffuse.x > 0)
                {
                    // saturate : 0���϶�� ���� 0���� �����ִ� �Լ��Դϴ�.
                    // dot : �� ���� �����ϴ� �Լ��Դϴ�.
                    // normalize : ������ ���̸� 1�� �����ִ� �Լ��Դϴ�.
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
