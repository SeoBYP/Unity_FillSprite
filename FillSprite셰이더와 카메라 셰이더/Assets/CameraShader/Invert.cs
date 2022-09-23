using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Invert : MonoBehaviour
{
    public Material effectMaterial;

    // source 값은 현재 연산이 완료되어 출력될 색상을 담고있는 텍스처
    // destination은 화면에 출력될 텍스처
    // effectMaterial 값은 source 텍스처를 받아서 2차적인 가공이 필요할때 사용되는 머테리얼

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if( effectMaterial == null )
            return;

        Graphics.Blit(source, destination, effectMaterial);
    }

}
