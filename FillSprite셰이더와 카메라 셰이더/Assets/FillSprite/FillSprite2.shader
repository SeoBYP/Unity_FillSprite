Shader "Unlit/FillSprite2"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Fill("Fill Rate", Range(0, 1)) = 1
        _BaseColor("Color", Color) = (1, 1, 1, 1)
        _LineTex("Line Texture", 2D) = "white" {}
        _NoiseTex("Noise Texture", 2D) = "white" {}
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
                col += max(0, fillSign);
                col.rgb *= uva.rgb;
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
            // 픽셀의 개수만큼 호출되는 함수입니다.
            // 픽셀이 참고하는 uv 좌표값은 변경되지 않습니다.
            // 픽셀은 저마다의 uv 좌표( 참고하고 있는 텍스처에서의 좌표 )
            fixed4 frag(v2f i) : SV_Target
            {
                // _MainTex의 색상값은 이미 출력되어 있기때문에 
                // 다시 연산할 필요가 없습니다. 재연산하고 있는 코드를 어떻게 바꾸면 좋을지 
                // 고민해보세요.~
                // 
                fixed4 uva = tex2D(_MainTex, i.uv);
                float4 col = float4(0, 0, 0, 0);
                float fillSign = sign(_Fill - i.uv.y);
                col += max(0, fillSign);

                col.rgb *= uva.rgb;

                // // -라인을 추가하는 코드입니다/
                //float4 lineTexel = tex2D(_LineTex, i.uv);
                //lineTexel.rgb *= lineTexel.a;
                //return lineTexel;


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
                    uv.y = i.uv.y + 0.1 * noisePixel.y - _Fill - 0.06;

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
