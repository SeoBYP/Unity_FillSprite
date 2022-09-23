Shader "Unlit/FillSprite1"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Fill("Fill Rate", Range(0, 1)) = 1
        _BaseColor("Color", Color) = (1, 1, 1, 1)
        _LineTex("Line Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { 
            "RenderType"="Transparent" 
            "Queue" = "Transparent"
        }
        LOD 100
        // ���� ������ �Ҷ��� �⺻������ ���� ���۸� ���ּž� �մϴ�.
        ZWrite Off
        // �� �ڸ� ��� �׸����� �����Ϻ��.
        Cull Off

        //  
        Lighting Off

        // �⺻���� ���ĺ���
        Blend One OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float _Fill;
            float4 _BaseColor;
            sampler2D _LineTex;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }
            // �ȼ��� ������ŭ ȣ��Ǵ� �Լ��Դϴ�.
            // �ȼ��� �������� uv ��ǥ( �����ϰ� �ִ� �ؽ�ó������ ��ǥ )
            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 uva = tex2D(_MainTex, i.uv);
                float4 col = float4(0, 0, 0, 0);
                
                // ����ڰ� ������ ���� ���� �ȼ��� uv ��ǥ������ �۴ٸ� ����
                // ũ�ٸ� ����� �����ϵ��� ó���մϴ�.
                float fillSign = sign(_Fill - i.uv.y);
                col += max(0, fillSign);
                col.rgb *= uva.rgb;

                // -������ �߰��ϴ� �ڵ��Դϴ�/
                float4 lineTexel = tex2D(_LineTex, float2(i.uv.x, i.uv.y - _Fill));
                
                
                // ���� �÷��� ���� �ؽ�ó�� ���İ��� �����մϴ�.
                // ����ڰ� ������ ���� 1���� �۴ٸ� �׶��� �����ؽ�ó�� ������ ����մϴ�.
                if (_Fill < 1)
                {
                    float4 lineCol = float4(0, 0, 0, 0);
                    lineCol += max(0, fillSign);

                    lineCol.rgb *= lineTexel.rgb;

                    lineCol.rgb *= lineTexel.a;

                    col.rgb += lineCol.rgb;
                }


                // -������ �߰��ϴ� �ڵ��Դϴ�/


                col *= uva.a;

                return col;
            }
            ENDCG
        }
    }
}
