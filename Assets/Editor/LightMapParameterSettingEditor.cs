using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class LightMapParameterSettingEditor : Editor
{
    [MenuItem("Tool / SetupLightingMapScale ")]
    static void SetupLightingMapScale()
    {
        MeshRenderer[] mrs=  GameObject.FindObjectsOfType<MeshRenderer>();


     //  Debug.Log(  LightmapSettings.lightmaps.Length );
       // return;

        foreach (var mr in mrs)
        {
           

            Vector4 tillingoffset = mr.lightmapScaleOffset;
            Material[] mats = mr.sharedMaterials;
            foreach (var m in mats)
            {
                Debug.Log(mr+"      "+ m);

                if (m.HasProperty("_BakedMap"))
                {
                    m.SetVector("_Tilling", new Vector2(tillingoffset.x, tillingoffset.y));
                    m.SetVector("_Offset", new Vector2(tillingoffset.z, tillingoffset.w));


                    Texture2D bakedmap = LightmapSettings.lightmaps[mr.lightmapIndex].lightmapColor;
                    m.SetTexture("_BakedMap", bakedmap);

                    Debug.Log($"<color=#00ffff>{mr.name} has material {m.name}, tilling and offset is {tillingoffset} </color>");
                }
               

                

            }

            


        }

    }

    
    [MenuItem("Tool / SetEnvColor")]
    static void SetEnvColor()
    {

        string[] guids=  AssetDatabase.FindAssets("t:Material", new string[] {"Assets/Export/Player"});
     
        
        for (int i = 0; i < guids.Length; i++)
        {
            string path = AssetDatabase.GUIDToAssetPath(guids[i]);
            
            Debug.Log(path);
            
           Material m= AssetDatabase.LoadAssetAtPath<Material>(path);
           m.SetColor("_EnviromentColor",new Color(0.9f,0.8f,0.8f));
        }
        
        
      

    }


}
