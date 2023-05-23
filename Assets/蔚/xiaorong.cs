using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class xiaorong : MonoBehaviour
{
    // Start is called before the first frame update
    private SkinnedMeshRenderer[] m;
    private Material mat;

    private GameObject ga;
    // public float _Dissolvetan;

    void Start()
    {
        
         m = FindObjectsOfType<SkinnedMeshRenderer>();
        for (int i = 0; i < m.Length; i++)
        {
            mat = m[i].material;
        }

       var gar = AssetDatabase.FindAssets("t:GameObject", new [] { "Assets/蔚"});
       Debug.Log(gar.Length);
       foreach (var gat in gar)
       {
           var path = AssetDatabase.GUIDToAssetPath(gat);
          Debug.Log(path);
           var model = AssetDatabase.LoadAssetAtPath<GameObject>(path);
           ModelImporter models = AssetImporter.GetAtPath(path) as ModelImporter;
           models.isReadable = true;

       }
       
        
        
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetKey(KeyCode.A))
        {
            Shader.SetGlobalFloat("_Dissolvetan", Mathf.Sin(Time.time) * 300 - 300);
        }
        if (Input.GetKey(KeyCode.B))
        {
            Shader.SetGlobalFloat("_Dissolvetan", -600);
        }
        
            
    }
}
