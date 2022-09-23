// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

Shader "Custom/MySprite"
{
    Properties
    {
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
        _Color ("Tint", Color) = (1,1,1,1)
        [MaterialToggle] PixelSnap ("Pixel snap", Float) = 0
        [HideInInspector] _RendererColor ("RendererColor", Color) = (1,1,1,1)
        [HideInInspector] _Flip ("Flip", Vector) = (1,1,1,1)
        [PerRendererData] _AlphaTex ("External Alpha", 2D) = "white" {}
        [PerRendererData] _EnableExternalAlpha("Enable External Alpha", Float) = 0
        _R("RED", Range(0, 1)) = 0
        _G("GREEN", Range(0, 1)) = 0
        _B("BLUE", Range(0, 1)) = 0
        // (0부터 1까지의 범위를 갖습니다.) 스프라이트의 출력 범위를 정할때 사용하는 값
        _FillU("U RATE", Range(0, 1)) = 1
        _FillV("V RATE", Range(0, 1)) = 1

        [Toggle] _InvertV("Invert V", Float) = 0
        [Toggle] _InvertU("Invert U", Float) = 0

        // 플라즈마 쉐이더에 적용할 속성입니다.
        _Speed("Speed", Range(1, 100)) = 7.3

        // 픽셀의 분포도를 다르게 할 스케일 값.
        _Scale1("Scale 1", Range(0.1, 10)) = 0.26
        _Scale2("Scale 2", Range(0.1, 10)) = 0.62
        _Scale3("Scale 3", Range(0.1, 10)) = 0.2
        _Scale4("Scale 4", Range(0.1, 10)) = 0.49
         [Toggle] _Plasma("Plasma Effect", Float) = 0
        _PlasmaPower("Plasma Power", Range(0, 1) ) = 0.2

        // - 디졸브 쉐이더에 적용할 속성값입니다. - 

        // 적용할 수치값
        _DissolveAmount("Dissolve Amount", Range(0, 1)) = 0
        // 디졸브 영역을 설정할 텍스처
        _DissolveTex("Dissolve Texture", 2D) = "white" {}
        // 사라질 영역에 대한 색상값을 표현하기 위한 텍스처
        _DissolveRampTex("Dissolve Ramp Texture", 2D) = "white" {}
        // 색상값 영역을 지정하기 위한 변수
        _DissolveRampSize("Dissolve Ramp Size", Float) = 0.2

        // 디졸브를 사용할 여부
        [Toggle] _Dissolve("Dissolve Effect", Float) = 0

    }

    SubShader
    {
        Tags
        {
            "Queue"="Transparent"
            "IgnoreProjector"="True"
            "RenderType"="Transparent"
            "PreviewType"="Plane"
            "CanUseSpriteAtlas"="True"
        }

        Cull Off
        Lighting Off
        ZWrite Off
        Blend One OneMinusSrcAlpha

        Pass
        {
        CGPROGRAM
        // 정점을 계산하는 함수의 이름은 SpriteVert
            #pragma vertex SpriteVert
        // 픽셀을 계산하는 함수의 이름은 SpriteFrag
            #pragma fragment SpriteFrag
            #pragma target 2.0
            #pragma multi_compile_instancing
            #pragma multi_compile_local _ PIXELSNAP_ON
            #pragma multi_compile _ ETC1_EXTERNAL_ALPHA
            #include "MySpriteCG.cginc"
        ENDCG
        }
    }
}
