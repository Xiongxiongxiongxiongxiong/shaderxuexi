using System;
using System.Collections;
using System.Collections.Generic;

using UnityEditor;
using UnityEngine;
using UnityEngine.UI;

public class MyShaderGUI01 : ShaderGUI
{
    private MaterialEditor _editor;

    private MaterialProperty[] _properties;

    private bool clip;
//绘制方法
    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] props)
    {
        
        var material = materialEditor.target as Material;
        
        if (material ==null)
        {
            return;
        }
        base.OnGUI(materialEditor,props);
        var ifEmissionGIOn = EditorGUILayout.Toggle("开启自发光GI",
            material.globalIlluminationFlags == MaterialGlobalIlluminationFlags.AnyEmissive);
        if (ifEmissionGIOn)
        {
            material.globalIlluminationFlags = MaterialGlobalIlluminationFlags.AnyEmissive;
        }
        else
        {
            material.globalIlluminationFlags = MaterialGlobalIlluminationFlags.BakedEmissive;
        }
       //拿到材质球面板上得开关
     //  var a = FindProperty("_AlphaClip", props);
         clip = material.GetFloat("_AlphaClip")==1;
         var a = material.GetTexture("_BaseMap");
         var m = material.GetTexture("_MetallicGlossMap");
         // if (a !=null)
         // {
             string[] guids=  AssetDatabase.FindAssets("t:texture2D", new string[] {"Assets/shaderPrefabs"});
             Texture2D[] b = new Texture2D[guids.Length];
             for (int i = 0; i < guids.Length; i++)
             {
                 string path = AssetDatabase.GUIDToAssetPath(guids[i]);
                 Texture2D f = AssetDatabase.LoadAssetAtPath<Texture2D>(path);

                 b[i] = AssetDatabase.LoadAssetAtPath<Texture2D>(path);

                 
                 

                 
                 Debug.Log(b[i]);
                 
                 material.SetTexture("_BaseMap",b[1]);
             }
             
             
             
             
        // }
        // GUIContent aLabel = new GUIContent(a.displayName);
        //
        // _editor.TexturePropertySingleLine(aLabel, a);
        //
     //   clip = EditorGUILayout.Toggle("c", clip);

        if (clip)
        {
            material.EnableKeyword("_ALPHATEST_ON");
        }
        else
        {
            material.DisableKeyword("_ALPHATEST_ON");
        }
        
        
       // _editor.TexturePropertySingleLine(b);
        //GUI绘制一个开关面板
      //   var ifclip = Array.IndexOf(material.shaderKeywords, "_ALPHATEST_ON") != -1;
        
        EditorGUI.BeginChangeCheck();
       
       //让开关和shader得宏关联起来
     //  clip  = EditorGUILayout.Toggle("_ALPHATEST_ON",clip);
       //如果开运行宏，关不运行宏
     //  MaterialProperty    Cutoff = FindProperty("_Cutoff", props);
     
     MaterialProperty hiddenProperty = FindProperty("_Cutoff", props);
     // if (clip)
     // {
     //     material.EnableKeyword("_ALPHATEST_ON");
     //     // EditorGUI.BeginChangeCheck();
     //     // EditorGUI.showMixedValue = hiddenProperty.hasMixedValue;
     //     // EditorGUI.BeginDisabledGroup(true);
     // }
     //
     // //  material.DisableKeyword("_Cutoff");
     //
     // else
     // {
     //     material.DisableKeyword("_ALPHATEST_ON");
     //     if (hiddenProperty != null)
     //     {
     //         //   EditorGUIUtility.set
     //         materialEditor.ShaderProperty(hiddenProperty, hiddenProperty.displayName);
     //       //  EditorGUIUtility.SetEnabled(true);
     //         
     //     }
     //     
     // }
                
        
            
            
          
            // if (hiddenProperty != null)
            // {
            //     EditorGUI.BeginChangeCheck();
            //     EditorGUI.showMixedValue = hiddenProperty.hasMixedValue;
            //     EditorGUI.BeginDisabledGroup(true);
            //     materialEditor.ShaderProperty(hiddenProperty, hiddenProperty.displayName);
            //     EditorGUI.EndDisabledGroup();
            //     EditorGUI.showMixedValue = false;
            //     if (EditorGUI.EndChangeCheck())
            //     {
            //         // 如果隐藏属性的值改变了，你可以在这里添加你的代码
            //     }
            // }
            

    }
    
    
    

    
    
}
