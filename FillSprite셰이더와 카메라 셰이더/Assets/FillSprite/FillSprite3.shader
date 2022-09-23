Shader "Unlit/FillSprite3"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Fill("Fill Rate", Range(0, 1)) = 1
        _BaseColor("Color", Color) = (1, 1, 1, 1)
        _LineTex("Line Texture", 2D) = "white" {}
        _NoiseTex("Noise Texture", 2D) = "white" {}
        _Overlay("Overlay (Add)", 2D) = "white" {}
        _Outline("Outline (Add)", 2D) = "white" {}
        _SmokeTex("Smoke Texture", 2D) = "white" {}
        _Gradient("Gradient (Add)", 2D) = "white" {}
        _Particles("Particles Texture", 2D) = "white" {}

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

        // Pass�� ������ �Ѵٴ� �ǹ̵� ������ ����Ѵٴ� �ǹ̸� ���� �˴ϴ�.
        // ù��° �н� : �Ϲ� �̹��� ���
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
            sampler2D _NoiseTex;
            sampler2D _Overlay;
            sampler2D _Outline;
            sampler2D _SmokeTex;
            sampler2D _Gradient;
            sampler2D _Particles;
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

                float CutVal = max(0, fillSign);
                
                col += max(0, fillSign);
                col.rgb *= uva.rgb;



                float4 outlineCol = tex2D(_Outline, i.uv);
                outlineCol.rgb *= outlineCol.a;
                col.rgb += (outlineCol.rgb + (1 - outlineCol.a) * col.rgb) * 0.3;

                // ���� �ؽ�ó�� ������ ����ũ �ؽ�ó������ ��ǥ������ ����մϴ�.
                col.rgb *= tex2D(_SmokeTex, uva.rg - _Time.x) * 0.8;

                // ����ڰ� ������ ���������� ���� �ȼ��� ���� �ִ� �ؽ�ó�� uv���� �۴ٸ�
                // ������ �� �߰��� �� �ֵ��� ó���ϴ� �ڵ��Դϴ�.
                if (CutVal > 0)
                {
                    float4 particleColor = tex2D(_Particles, uva.rg - _Time.x);
                    particleColor.rgb *= particleColor.a;

                    col.rgb += tex2D(_SmokeTex, uva.rg - _Time.x) * 0.5;
                    col.rgb += tex2D(_Gradient, i.uv).rgb * 0.8;
                    col.rgb += particleColor.rgb;
                }

                // ���� ������ �߰��մϴ�.
                float4 overlayCol = tex2D(_Overlay, i.uv);
                overlayCol.rgb *= overlayCol.a;
                col.rgb += overlayCol.rgb;
                col *= uva.a;
                return col;
            }
            ENDCG
        }
        // �ι�° �н� : ���� �̹��� ���
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
            sampler2D _NoiseTex;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }
            // ****** �������� �̹����� ����տ� ��ġ�Ǿ�� �մϴ�. ****/
            // �ȼ��� ������ŭ ȣ��Ǵ� �Լ��Դϴ�.
            // �ȼ��� �����ϴ� uv ��ǥ���� ������� �ʽ��ϴ�.
            // �ȼ��� �������� uv ��ǥ( �����ϰ� �ִ� �ؽ�ó������ ��ǥ )
            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 uva = tex2D(_MainTex, i.uv);
                float4 col = float4(0, 0, 0, 0);
                float fillSign = sign(_Fill - i.uv.y);

                // ���� �÷��� ���� �ؽ�ó�� ���İ��� �����մϴ�.
                // ����ڰ� ������ ���� 1���� �۴ٸ� �׶��� �����ؽ�ó�� ������ ����մϴ�.
                if (_Fill < 1)
                {
                    // i.uv.x = 0.2 + 0.01
                    // i.uv.x = 0.2 + 0.02
                    // i.uv.x = 0.2 + 0.03
                    // ������ ���� : ���� �ȼ��� �����ϰ� �ִ� �ؽ�ó�� ��ǥ
                    // �ð��� �帧�� ���� uv��ǥ���� �����ϴ� �ڵ��Դϴ�.
                    float2 uv = float2(i.uv.x + _Time.y, i.uv.y + sin(_Time.y));

                    // ���� �ȼ��� �����ϰ� �ִ� �ؽ�ó�� ��ǥ�� �������� �ð����� �����Ͽ� ������ �ؽ�ó 
                    // ��ǥ���� ���մϴ�.

                    // ���� ��ǥ���� �����Ͽ� �ٸ� �ؽ�ó�� ������ �޾ƿɴϴ�.
                    float4 noisePixel = tex2D(_NoiseTex, uv);
                    uv.x = i.uv.x + 0.1 * noisePixel.x;
                    uv.y = i.uv.y + 0.1 * noisePixel.y - _Fill - 0.07;

                    // -������ �߰��ϴ� �ڵ��Դϴ�/
                    float4 lineTexel = tex2D(_LineTex, uv );

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
