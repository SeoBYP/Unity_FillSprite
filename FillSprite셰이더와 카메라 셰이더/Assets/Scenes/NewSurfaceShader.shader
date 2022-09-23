Shader "Custom/NewSurfaceShader"
{
    // 외부에서 데이터를 얻기 위한 공간 또는 에디터에서 값을 제어하기 위한 공간
    // 실질적인 코드상에서의 변수가 아닙니다.
    // 이름과 데이터 타입이 맞는 변수를 설정해줘야 변수에 값이 전달되게 됩니다.
    Properties
    {
        _Color      ("Color",           Color       ) = (1,1,1,1)
        _MainTex    ("Albedo (RGB)",    2D          ) = "white" {}
        _Glossiness ("Smoothness",      Range(0,1)  ) = 0.5
        _Metallic   ("Metallic",        Range(0,1)  ) = 0.0
    }
        // Color = float4, fixed4, half4
            // sampler2D
            // float, half, fixed
    // 코드의 진입점
    SubShader
    {
        // 우선이 되는 기본 설정
        Tags { "RenderType"="Opaque" }
        LOD 200

        // 유니티는 코드의 설정에 대한 부분이 CG 셰이더로 구성되어 있고,
        // 렌더링에 대한 부분이 HLSL 셰이더로 구성되어 있습니다.
        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        // 렌더링 설정
        // 렌더링 설정은 순서를 지켜야 한다.
        // 1) 표면을 렌더링하는 함수의 이름 2) 광원 연산처리를 하는 함수의 이름 3) 그림자 연산처리, 4) 알파연산처리
        #pragma surface surf Lambert fullforwardshadows


        // 셰이더 버전
         // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

      

        // 픽셀을 연산할때 필요한 정보를 요청하는 공간
        struct Input
        {
            float2 uv_MainTex;
        };

        // 프로퍼티와 연결될 변수의 목록
        half _Glossiness;
        half _Metallic;
        fixed4 _Color;
        sampler2D _MainTex;

        // GPU를 사용하여 같은 머테리얼을 사용하는 물체를 묶어서 그리는 설정입니다.
        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        // 픽셀의 개수만큼 호출되는 함수입니다.
        // surface 셰이더에서는 첫번째 매개변수는 반드시 Input이라는 이름을 갖는 구조체 형식이어야 합니다.
        // 두번째 매개변수는 렌더링 설정에 맞는 구조체가 입력되어야 합니다. 
            //Standard -> SurfaceOutputStandard
            //StandardSpecular -> SurfaceOutputStandardSpecular
            //그 외적인 요소라면 -> SurfaceOutput
        void surf (Input IN, inout SurfaceOutput o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            // 빛과 연산될 색상값
            //o.Albedo = c.rgb;

            // 빛과 연산되지 않을 ( 영향을 받지 않을 ) 색상값
            o.Emission = c.rgb;

            // 최종결과 : Albedo + Emission

            // Metallic and smoothness come from slider variables
            //o.Metallic = _Metallic;
            //o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
