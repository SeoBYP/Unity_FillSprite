Shader "Custom/Plasma"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Speed("Speed", Range(1, 100) ) = 7.3

        // 픽셀의 분포도를 다르게 할 스케일 값.
        _Scale1("Scale 1", Range(0.1, 10)) = 0.26
        _Scale2("Scale 2", Range(0.1, 10)) = 0.62
        _Scale3("Scale 3", Range(0.1, 10)) = 0.2
        _Scale4("Scale 4", Range(0.1, 10)) = 0.49

    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        
        #pragma surface surf Lambert 

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;


        // Surface셰이더에서는 반드시 구조체의 이름이 Input이어야 합니다.
        // Input구조체의 내부 값은 사용자가 필요한 정보를 요청하는 공간이다.!
        struct Input
        {
            float2 uv_MainTex;
            float3 worldPos;
        };

        fixed4 _Color;
        float _Speed;
        float _Scale1;
        float _Scale2;
        float _Scale3;
        float _Scale4;

        //void surf (Input IN, inout SurfaceOutput o)
        //{
        //    fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
        //    o.Albedo = c.rgb;
        //    o.Alpha = c.a;
        //}
        // Time.time
        // 1)
        //void surf(Input IN, inout SurfaceOutput o)
        //{
        //    // _Time.x 계속 증가되는 시간값 * 6
        //    float c = sin(_Time.x * _Speed);
        //    o.Albedo.r = c;
        //    o.Albedo.g = c;
        //    o.Albedo.b = c;
        //}
        // 2)
        //void surf(Input IN, inout SurfaceOutput o)
        //{
        //    
        //    // x, y, z
        //    // _Time.x 계속 증가되는 시간값 * 6
        //    // 두번째는 sin함수를 사용하되 기준값을 x좌표로서 설정하였습니다.
        //    // sin함수 또한 되돌려주는 값이 -1에서 1 사이의 값이기 때문에
        //    // 이것을 색으로 출력하면 어두운 색과 밝은 색이 교차되어 보이게 됩니다.
        //    float c = sin(IN.worldPos.x * _Scale1);
        //    o.Albedo.r = c;
        //    o.Albedo.g = c;
        //    o.Albedo.b = c;
        //}

        // 세번째는 시간값을 더해 색상이 우측에서 좌측으로 이동되도록 구성한 예제입니다.
        //void surf(Input IN, inout SurfaceOutput o)
        //{

        //    // x, y, z
        //    // _Time.x 계속 증가되는 시간값 * 6
        //    // 두번째는 sin함수를 사용하되 기준값을 x좌표로서 설정하였습니다.
        //    // sin함수 또한 되돌려주는 값이 -1에서 1 사이의 값이기 때문에
        //    // 이것을 색으로 출력하면 어두운 색과 밝은 색이 교차되어 보이게 됩니다.
        //    float t = _Time.x * _Speed;
        //    float c = sin(IN.worldPos.x * _Scale1 + t);
        //    o.Albedo.r = c;
        //    o.Albedo.g = c;
        //    o.Albedo.b = c;
        //}

        // 네번째는 y 위치값을 기준으로 계산한 값을 추가해 본 예제입니다.
        //void surf(Input IN, inout SurfaceOutput o)
        //{

        //    // x, y, z
        //    // _Time.x 계속 증가되는 시간값 * 6
        //    // 두번째는 sin함수를 사용하되 기준값을 x좌표로서 설정하였습니다.
        //    // sin함수 또한 되돌려주는 값이 -1에서 1 사이의 값이기 때문에
        //    // 이것을 색으로 출력하면 어두운 색과 밝은 색이 교차되어 보이게 됩니다.
        //    float t = _Time.x * _Speed;
        //    float c = sin(IN.worldPos.x * _Scale1 + t);
        //    c += sin(IN.worldPos.y * _Scale2 + t);
        //    o.Albedo.r = c;
        //    o.Albedo.g = c;
        //    o.Albedo.b = c;
        //}

        // 다섯번째는 x, y위치값을 기준으로 하고
        // 각 좌표에 sin, cos함수를 사용하여 위치를 변경시켜본 예제입니다.
        //void surf(Input IN, inout SurfaceOutput o)
        //{

        //    // x, y, z
        //    // _Time.x 계속 증가되는 시간값 * 6
        //    // 두번째는 sin함수를 사용하되 기준값을 x좌표로서 설정하였습니다.
        //    // sin함수 또한 되돌려주는 값이 -1에서 1 사이의 값이기 때문에
        //    // 이것을 색으로 출력하면 어두운 색과 밝은 색이 교차되어 보이게 됩니다.
        //    float t = _Time.x * _Speed;
        //    float c = sin(IN.worldPos.x * _Scale1 + t);
        //    c += sin(IN.worldPos.y * _Scale2 + t);
        //    c += sin(IN.worldPos.x * sin(t) + IN.worldPos.y * cos(t));

        //    o.Albedo.r = c;
        //    o.Albedo.g = c;
        //    o.Albedo.b = c;
        //}

        // 여섯번째는
        // sin, cos함수에 시간의 범위를 다르게 하여 물결치는 효과를 적용해 본 예제입니다.
        
        //void surf(Input IN, inout SurfaceOutput o)
        //{

        //    // x, y, z
        //    // _Time.x 계속 증가되는 시간값 * 6
        //    // 두번째는 sin함수를 사용하되 기준값을 x좌표로서 설정하였습니다.
        //    // sin함수 또한 되돌려주는 값이 -1에서 1 사이의 값이기 때문에
        //    // 이것을 색으로 출력하면 어두운 색과 밝은 색이 교차되어 보이게 됩니다.
        //    float t = _Time.x * _Speed;
        //    float c = sin(IN.worldPos.x * _Scale1 + t);
        //    c += sin(IN.worldPos.y * _Scale2 + t);
        //    c += sin(IN.worldPos.x * sin(t/2) + IN.worldPos.y * cos(t/3));

        //    o.Albedo.r = c;
        //    o.Albedo.g = c;
        //    o.Albedo.b = c;
        //}

        // 7번째 예제 회전시키는 연산에 범위를 적용해 본 예제입니다.
        //void surf(Input IN, inout SurfaceOutput o)
        //{

        //    // x, y, z
        //    // _Time.x 계속 증가되는 시간값 * 6
        //    // 두번째는 sin함수를 사용하되 기준값을 x좌표로서 설정하였습니다.
        //    // sin함수 또한 되돌려주는 값이 -1에서 1 사이의 값이기 때문에
        //    // 이것을 색으로 출력하면 어두운 색과 밝은 색이 교차되어 보이게 됩니다.
        //    float t = _Time.x * _Speed;
        //    float c = sin(IN.worldPos.x * _Scale1 + t);
        //    c += sin(IN.worldPos.y * _Scale2 + t);
        //    c += sin( _Scale3 *( IN.worldPos.x * sin(t / 2) + IN.worldPos.y * cos(t / 3) ));

        //    o.Albedo.r = c;
        //    o.Albedo.g = c;
        //    o.Albedo.b = c;
        //}

        // 8번째
        void surf(Input IN, inout SurfaceOutput o)
        {

            // x, y, z
            // _Time.x 계속 증가되는 시간값 * 6
            // 두번째는 sin함수를 사용하되 기준값을 x좌표로서 설정하였습니다.
            // sin함수 또한 되돌려주는 값이 -1에서 1 사이의 값이기 때문에
            // 이것을 색으로 출력하면 어두운 색과 밝은 색이 교차되어 보이게 됩니다.
            float t = _Time.x * _Speed;
            float c = sin(IN.worldPos.x * _Scale1 + t);
            c += sin(IN.worldPos.y * _Scale2 + t);
            c += sin(_Scale3 * (IN.worldPos.x * sin(t / 2) + IN.worldPos.y * cos(t / 3)) + t);
            float c1 = pow(IN.worldPos.x + 0.5 * sin(t / 5), 2);
            float c2 = pow(IN.worldPos.y + 0.5 * sin(t / 3), 2);

            c += sin(sqrt(_Scale4 * (c1 + c2) + t));

            o.Albedo.r = sin(c / 4.0f * 3.141596);
            o.Albedo.g = sin(c / 4.0f * 3.141596 + 2 * 3.141596 / 4);
            o.Albedo.b = sin(c / 4.0f * 3.141596 + 4 * 3.141596 / 4);

            //o.Albedo.r = sin(pow(c, 2));
            //o.Albedo.g = sin(pow(c, 6));
            //o.Albedo.b = sqrt( sin(pow(c, 2)) ) + cos(pow(c, 3));

            o.Albedo *= _Color;

        }

        ENDCG
    }
    FallBack "Diffuse"
}
