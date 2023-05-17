using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using System.IO;
public class chazhao : Editor
{
    
    [MenuItem("Tool/ASS File Finder")]
    public static void chazhaowenjian()
    {
        Dictionary<string, string> dis = new Dictionary<string, string>();
        Dictionary<string, int> dist = new Dictionary<string, int>();
        string[] Scenes=  AssetDatabase.FindAssets("", new string[] {"Assets/原神"});


        for (int i = 0; i < Scenes.Length; i++)
        {
            string path = AssetDatabase.GUIDToAssetPath(Scenes[i]);
            var key = AssetDatabase.LoadAssetAtPath<UnityEngine.Object>(path).name;
      //      string t = (string)AssetDatabase.LoadAssetAtPath(path, typeof(string)).name;
      var s = AssetDatabase.LoadAllAssetsAtPath(path);
      var g = AssetDatabase.LoadAssetAtPath(path,typeof(Object));
      var y = AssetDatabase.LoadAssetAtPath<Object>(path).name;
      Debug.Log(y);

      // if (Directory.Exists(Scenes[i]))
      // {
      //     continue;
      // }
      
      if (dist.ContainsKey(y))
      {
          dist[y]++;
          y = y + "_" + dist[y];
      }else
      {
          dist.Add(y,0);
      }
      // for (int j = 0; j < s.Length; j++)
      // {
      //     var d = s[j].name;
      //     Debug.Log(d);
      // }
            
            dis.Add(y,path);
        
        }
        
        
        
        
    }
    
    
    
}
