using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Invert : MonoBehaviour
{
    public Material effectMaterial;

    // source ���� ���� ������ �Ϸ�Ǿ� ��µ� ������ ����ִ� �ؽ�ó
    // destination�� ȭ�鿡 ��µ� �ؽ�ó
    // effectMaterial ���� source �ؽ�ó�� �޾Ƽ� 2������ ������ �ʿ��Ҷ� ���Ǵ� ���׸���

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if( effectMaterial == null )
            return;

        Graphics.Blit(source, destination, effectMaterial);
    }

}
