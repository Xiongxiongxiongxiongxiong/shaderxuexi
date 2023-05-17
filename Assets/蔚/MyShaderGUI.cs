using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using UnityEngine.UI;

public enum 分支
{
    边缘光, 描边, 原版PBR
}

public class MyShaderGUI : ShaderGUI
{
    
    private 分支 LC;
    private Slider slider;
    private float F;
//绘制方法
    // MaterialEditor materialEditor;//当前材质面板
    // MaterialProperty[] props;//当前shader的properties
    private Material material;
    private string[] keywords;
    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] props)
    {
        
         material = materialEditor.target as Material;
         keywords = material.shaderKeywords;
        
        if (material ==null)
        {
            return;
        }
        
        
        EditorGUI.BeginChangeCheck();
        LC = (分支)EditorGUILayout.EnumPopup("分支", LC);
        if (EditorGUI.EndChangeCheck()) { 
            SetKeyWorld(LC);	
        }

        base.OnGUI(materialEditor,props);
        var ifEmissionGIOn = EditorGUILayout.Toggle("开启自发光GI",
            material.globalIlluminationFlags == MaterialGlobalIlluminationFlags.AnyEmissive);
        if (ifEmissionGIOn)
        {
            material.globalIlluminationFlags = MaterialGlobalIlluminationFlags.AnyEmissive;
           // material.globalIlluminationFlags = MaterialGlobalIlluminationFlags.
        }
        else
        {
            material.globalIlluminationFlags = MaterialGlobalIlluminationFlags.BakedEmissive;
        }
        
       //拿到材质球面板上得开关
        var clip = material.GetFloat("_AlphaClip")==1;

        //GUI绘制一个开关面板
        
        //显示贴图
     //查找属性为_Cubemap的贴图属性
     MaterialProperty _CubeMap= FindProperty("_Cubemap", props, true);
     //
     GUIContent content = new GUIContent(_CubeMap.displayName, _CubeMap.textureValue, "cube Map");//tips 是说明文字，鼠标悬停属性名称时显示
     materialEditor.ShaderProperty(_CubeMap,content);
     
    

     //枚举的循环检查方法
      void SetKeyWorld(分支 settings)
     {
         var a = GameObject.FindObjectsOfType<SkinnedMeshRenderer>();
         switch (settings)
         {
             case 分支.边缘光:
                 material.DisableKeyword(分支.原版PBR.ToString());
                 material.DisableKeyword(分支.描边.ToString());
                 material.EnableKeyword(分支.边缘光.ToString());
                 material.EnableKeyword("_Fo");
                 material.DisableKeyword("_Diss");
                 // for (int i = 0; i < a.Length; i++)
                 // {
                 //     var m = a[i];
                 //
                 //    // m.material.SetFloat("_Factor",0);
                 //    
                 // }

                 Shader.SetGlobalFloat("_Factor", 0);
                 break;
             case 分支.描边:
                 material.DisableKeyword(分支.边缘光.ToString());
                 material.DisableKeyword(分支.原版PBR.ToString());
                 material.EnableKeyword(分支.描边.ToString());

                  material.DisableKeyword("_Fo");
                 material.DisableKeyword("_Diss");
                 // 绘制滑动条
                 // for (int i = 0; i < a.Length; i++)
                 // {
                 //     var m = a[i];
                 //
                 //    // m.material.SetFloat("_Factor",0.07f);
                 //    
                 //     
                 // }
                 Shader.SetGlobalFloat("_Factor", 0.07f);
                 break;
             case 分支.原版PBR:
                 material.DisableKeyword(分支.边缘光.ToString());
                 material.DisableKeyword(分支.描边.ToString());
                 material.EnableKeyword(分支.原版PBR.ToString());
                 material.EnableKeyword("_Diss");
                 // for (int i = 0; i < a.Length; i++)
                 // {
                 //     var m = a[i];
                 //
                 //     m.material.SetFloat("_Factor",0);
                 // }
                 Shader.SetGlobalFloat("_Factor", 0);
                 material.DisableKeyword("_Fo");
                 break;
         }

     }

     
     
     
     
     
     
     
     MaterialProperty hiddenProperty = FindProperty("_Cutoff", props);

     if (clip)
     {
         material.EnableKeyword("_ALPHATEST_ON");
            if (hiddenProperty != null)
            {
                //   EditorGUIUtility.set
                materialEditor.ShaderProperty(hiddenProperty, hiddenProperty.displayName);
                //  EditorGUIUtility.SetEnabled(true);

            }
            // EditorGUI.BeginChangeCheck();
            // EditorGUI.showMixedValue = hiddenProperty.hasMixedValue;
            // EditorGUI.BeginDisabledGroup(true);
        }

     //  material.DisableKeyword("_Cutoff");

     else
     {
         material.DisableKeyword("_ALPHATEST_ON");

         
     }

        
            
          
 
  
     

            

    }
    
    
    

    
    
}
