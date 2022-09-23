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
        // (0���� 1������ ������ �����ϴ�.) ��������Ʈ�� ��� ������ ���Ҷ� ����ϴ� ��
        _FillU("U RATE", Range(0, 1)) = 1
        _FillV("V RATE", Range(0, 1)) = 1

        [Toggle] _InvertV("Invert V", Float) = 0
        [Toggle] _InvertU("Invert U", Float) = 0

        // �ö�� ���̴��� ������ �Ӽ��Դϴ�.
        _Speed("Speed", Range(1, 100)) = 7.3

        // �ȼ��� �������� �ٸ��� �� ������ ��.
        _Scale1("Scale 1", Range(0.1, 10)) = 0.26
        _Scale2("Scale 2", Range(0.1, 10)) = 0.62
        _Scale3("Scale 3", Range(0.1, 10)) = 0.2
        _Scale4("Scale 4", Range(0.1, 10)) = 0.49
         [Toggle] _Plasma("Plasma Effect", Float) = 0
        _PlasmaPower("Plasma Power", Range(0, 1) ) = 0.2

        // - ������ ���̴��� ������ �Ӽ����Դϴ�. - 

        // ������ ��ġ��
        _DissolveAmount("Dissolve Amount", Range(0, 1)) = 0
        // ������ ������ ������ �ؽ�ó
        _DissolveTex("Dissolve Texture", 2D) = "white" {}
        // ����� ������ ���� ������ ǥ���ϱ� ���� �ؽ�ó
        _DissolveRampTex("Dissolve Ramp Texture", 2D) = "white" {}
        // ���� ������ �����ϱ� ���� ����
        _DissolveRampSize("Dissolve Ramp Size", Float) = 0.2

        // �����긦 ����� ����
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
        // ������ ����ϴ� �Լ��� �̸��� SpriteVert
            #pragma vertex SpriteVert
        // �ȼ��� ����ϴ� �Լ��� �̸��� SpriteFrag
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
