using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class xiaorong : MonoBehaviour
{
    // Start is called before the first frame update
    private SkinnedMeshRenderer[] m;
    private Material mat;
    void Start()
    {
        
         m = FindObjectsOfType<SkinnedMeshRenderer>();
        for (int i = 0; i < m.Length; i++)
        {
            mat = m[i].material;
        }
        Debug.Log(mat.name);
    }

    // Update is called once per frame
    void Update()
    {

           Shader.SetGlobalFloat("_Dissolvetan",Mathf.Sin(Time.time)*300-300);
           Debug.Log(Mathf.Sin(Time.time)*300-300);
            
    }
}
