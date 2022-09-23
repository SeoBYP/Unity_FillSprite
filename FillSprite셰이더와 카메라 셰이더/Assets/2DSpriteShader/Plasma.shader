Shader "Custom/Plasma"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Speed("Speed", Range(1, 100) ) = 7.3

        // �ȼ��� �������� �ٸ��� �� ������ ��.
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


        // Surface���̴������� �ݵ�� ����ü�� �̸��� Input�̾�� �մϴ�.
        // Input����ü�� ���� ���� ����ڰ� �ʿ��� ������ ��û�ϴ� �����̴�.!
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
        //    // _Time.x ��� �����Ǵ� �ð��� * 6
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
        //    // _Time.x ��� �����Ǵ� �ð��� * 6
        //    // �ι�°�� sin�Լ��� ����ϵ� ���ذ��� x��ǥ�μ� �����Ͽ����ϴ�.
        //    // sin�Լ� ���� �ǵ����ִ� ���� -1���� 1 ������ ���̱� ������
        //    // �̰��� ������ ����ϸ� ��ο� ���� ���� ���� �����Ǿ� ���̰� �˴ϴ�.
        //    float c = sin(IN.worldPos.x * _Scale1);
        //    o.Albedo.r = c;
        //    o.Albedo.g = c;
        //    o.Albedo.b = c;
        //}

        // ����°�� �ð����� ���� ������ �������� �������� �̵��ǵ��� ������ �����Դϴ�.
        //void surf(Input IN, inout SurfaceOutput o)
        //{

        //    // x, y, z
        //    // _Time.x ��� �����Ǵ� �ð��� * 6
        //    // �ι�°�� sin�Լ��� ����ϵ� ���ذ��� x��ǥ�μ� �����Ͽ����ϴ�.
        //    // sin�Լ� ���� �ǵ����ִ� ���� -1���� 1 ������ ���̱� ������
        //    // �̰��� ������ ����ϸ� ��ο� ���� ���� ���� �����Ǿ� ���̰� �˴ϴ�.
        //    float t = _Time.x * _Speed;
        //    float c = sin(IN.worldPos.x * _Scale1 + t);
        //    o.Albedo.r = c;
        //    o.Albedo.g = c;
        //    o.Albedo.b = c;
        //}

        // �׹�°�� y ��ġ���� �������� ����� ���� �߰��� �� �����Դϴ�.
        //void surf(Input IN, inout SurfaceOutput o)
        //{

        //    // x, y, z
        //    // _Time.x ��� �����Ǵ� �ð��� * 6
        //    // �ι�°�� sin�Լ��� ����ϵ� ���ذ��� x��ǥ�μ� �����Ͽ����ϴ�.
        //    // sin�Լ� ���� �ǵ����ִ� ���� -1���� 1 ������ ���̱� ������
        //    // �̰��� ������ ����ϸ� ��ο� ���� ���� ���� �����Ǿ� ���̰� �˴ϴ�.
        //    float t = _Time.x * _Speed;
        //    float c = sin(IN.worldPos.x * _Scale1 + t);
        //    c += sin(IN.worldPos.y * _Scale2 + t);
        //    o.Albedo.r = c;
        //    o.Albedo.g = c;
        //    o.Albedo.b = c;
        //}

        // �ټ���°�� x, y��ġ���� �������� �ϰ�
        // �� ��ǥ�� sin, cos�Լ��� ����Ͽ� ��ġ�� ������Ѻ� �����Դϴ�.
        //void surf(Input IN, inout SurfaceOutput o)
        //{

        //    // x, y, z
        //    // _Time.x ��� �����Ǵ� �ð��� * 6
        //    // �ι�°�� sin�Լ��� ����ϵ� ���ذ��� x��ǥ�μ� �����Ͽ����ϴ�.
        //    // sin�Լ� ���� �ǵ����ִ� ���� -1���� 1 ������ ���̱� ������
        //    // �̰��� ������ ����ϸ� ��ο� ���� ���� ���� �����Ǿ� ���̰� �˴ϴ�.
        //    float t = _Time.x * _Speed;
        //    float c = sin(IN.worldPos.x * _Scale1 + t);
        //    c += sin(IN.worldPos.y * _Scale2 + t);
        //    c += sin(IN.worldPos.x * sin(t) + IN.worldPos.y * cos(t));

        //    o.Albedo.r = c;
        //    o.Albedo.g = c;
        //    o.Albedo.b = c;
        //}

        // ������°��
        // sin, cos�Լ��� �ð��� ������ �ٸ��� �Ͽ� ����ġ�� ȿ���� ������ �� �����Դϴ�.
        
        //void surf(Input IN, inout SurfaceOutput o)
        //{

        //    // x, y, z
        //    // _Time.x ��� �����Ǵ� �ð��� * 6
        //    // �ι�°�� sin�Լ��� ����ϵ� ���ذ��� x��ǥ�μ� �����Ͽ����ϴ�.
        //    // sin�Լ� ���� �ǵ����ִ� ���� -1���� 1 ������ ���̱� ������
        //    // �̰��� ������ ����ϸ� ��ο� ���� ���� ���� �����Ǿ� ���̰� �˴ϴ�.
        //    float t = _Time.x * _Speed;
        //    float c = sin(IN.worldPos.x * _Scale1 + t);
        //    c += sin(IN.worldPos.y * _Scale2 + t);
        //    c += sin(IN.worldPos.x * sin(t/2) + IN.worldPos.y * cos(t/3));

        //    o.Albedo.r = c;
        //    o.Albedo.g = c;
        //    o.Albedo.b = c;
        //}

        // 7��° ���� ȸ����Ű�� ���꿡 ������ ������ �� �����Դϴ�.
        //void surf(Input IN, inout SurfaceOutput o)
        //{

        //    // x, y, z
        //    // _Time.x ��� �����Ǵ� �ð��� * 6
        //    // �ι�°�� sin�Լ��� ����ϵ� ���ذ��� x��ǥ�μ� �����Ͽ����ϴ�.
        //    // sin�Լ� ���� �ǵ����ִ� ���� -1���� 1 ������ ���̱� ������
        //    // �̰��� ������ ����ϸ� ��ο� ���� ���� ���� �����Ǿ� ���̰� �˴ϴ�.
        //    float t = _Time.x * _Speed;
        //    float c = sin(IN.worldPos.x * _Scale1 + t);
        //    c += sin(IN.worldPos.y * _Scale2 + t);
        //    c += sin( _Scale3 *( IN.worldPos.x * sin(t / 2) + IN.worldPos.y * cos(t / 3) ));

        //    o.Albedo.r = c;
        //    o.Albedo.g = c;
        //    o.Albedo.b = c;
        //}

        // 8��°
        void surf(Input IN, inout SurfaceOutput o)
        {

            // x, y, z
            // _Time.x ��� �����Ǵ� �ð��� * 6
            // �ι�°�� sin�Լ��� ����ϵ� ���ذ��� x��ǥ�μ� �����Ͽ����ϴ�.
            // sin�Լ� ���� �ǵ����ִ� ���� -1���� 1 ������ ���̱� ������
            // �̰��� ������ ����ϸ� ��ο� ���� ���� ���� �����Ǿ� ���̰� �˴ϴ�.
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
