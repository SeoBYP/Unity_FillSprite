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
        // 알파 연산을 할때는 기본적으로 깊이 버퍼를 꺼주셔야 합니다.
        ZWrite Off
        // 앞 뒤를 모두 그리도록 설정하빈다.
        Cull Off

        //  
        Lighting Off

        // 기본적인 알파블렌딩
        Blend One OneMinusSrcAlpha

        // Pass는 연산을 한다는 의미도 갖지만 출력한다는 의미를 갖게 됩니다.
        // 첫번째 패스 : 일반 이미지 출력
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
            // 픽셀의 개수만큼 호출되는 함수입니다.
            // 픽셀은 저마다의 uv 좌표( 참고하고 있는 텍스처에서의 좌표 )
            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 uva = tex2D(_MainTex, i.uv);
                float4 col = float4(0, 0, 0, 0);
                
                // 사용자가 지정한 값이 현재 픽셀의 uv 좌표값보다 작다면 음수
                // 크다면 양수를 리턴하도록 처리합니다.
                float fillSign = sign(_Fill - i.uv.y);

                float CutVal = max(0, fillSign);
                
                col += max(0, fillSign);
                col.rgb *= uva.rgb;



                float4 outlineCol = tex2D(_Outline, i.uv);
                outlineCol.rgb *= outlineCol.a;
                col.rgb += (outlineCol.rgb + (1 - outlineCol.a) * col.rgb) * 0.3;

                // 메인 텍스처의 색상을 스모크 텍스처에서의 좌표값으로 사용합니다.
                col.rgb *= tex2D(_SmokeTex, uva.rg - _Time.x) * 0.8;

                // 사용자가 지정한 범위값보다 현재 픽셀이 갖고 있는 텍스처의 uv값이 작다면
                // 색상을 더 추가할 수 있도록 처리하는 코드입니다.
                if (CutVal > 0)
                {
                    float4 particleColor = tex2D(_Particles, uva.rg - _Time.x);
                    particleColor.rgb *= particleColor.a;

                    col.rgb += tex2D(_SmokeTex, uva.rg - _Time.x) * 0.5;
                    col.rgb += tex2D(_Gradient, i.uv).rgb * 0.8;
                    col.rgb += particleColor.rgb;
                }

                // 덮개 색상을 추가합니다.
                float4 overlayCol = tex2D(_Overlay, i.uv);
                overlayCol.rgb *= overlayCol.a;
                col.rgb += overlayCol.rgb;
                col *= uva.a;
                return col;
            }
            ENDCG
        }
        // 두번째 패스 : 물결 이미지 출력
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
            // ****** 오버레이 이미지가 가장앞에 배치되어야 합니다. ****/
            // 픽셀의 개수만큼 호출되는 함수입니다.
            // 픽셀이 참고하는 uv 좌표값은 변경되지 않습니다.
            // 픽셀은 저마다의 uv 좌표( 참고하고 있는 텍스처에서의 좌표 )
            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 uva = tex2D(_MainTex, i.uv);
                float4 col = float4(0, 0, 0, 0);
                float fillSign = sign(_Fill - i.uv.y);

                // 라인 컬러에 라인 텍스처의 알파값을 적용합니다.
                // 사용자가 지정한 값이 1보다 작다면 그때만 라인텍스처의 색상을 출력합니다.
                if (_Fill < 1)
                {
                    // i.uv.x = 0.2 + 0.01
                    // i.uv.x = 0.2 + 0.02
                    // i.uv.x = 0.2 + 0.03
                    // 연산의 기준 : 현재 픽셀이 참고하고 있는 텍스처의 좌표
                    // 시간의 흐름에 따라서 uv좌표값을 변경하는 코드입니다.
                    float2 uv = float2(i.uv.x + _Time.y, i.uv.y + sin(_Time.y));

                    // 현재 픽셀이 참고하고 있는 텍스처의 좌표를 기준으로 시간값을 적용하여 임의의 텍스처 
                    // 좌표값을 구합니다.

                    // 구한 좌표값을 참고하여 다른 텍스처의 색상값을 받아옵니다.
                    float4 noisePixel = tex2D(_NoiseTex, uv);
                    uv.x = i.uv.x + 0.1 * noisePixel.x;
                    uv.y = i.uv.y + 0.1 * noisePixel.y - _Fill - 0.07;

                    // -라인을 추가하는 코드입니다/
                    float4 lineTexel = tex2D(_LineTex, uv );

                    float4 lineCol = float4(0, 0, 0, 0);
                    lineCol += max(0, fillSign);

                    lineCol.rgb *= lineTexel.rgb;

                    lineCol.rgb *= lineTexel.a;

                    col.rgb += lineCol.rgb;
                }


                // -라인을 추가하는 코드입니다/
                col *= uva.a;

                return col;
            }
            ENDCG
        }
    }
}
