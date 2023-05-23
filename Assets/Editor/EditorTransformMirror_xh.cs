using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
public class EditorTransformMirror_xh : EditorWindow
{
    private static EditorTransformMirror_xh window;

    private static bool Z_dis, Y_dis, X_dis, Z_dis_off, Y_dis_off, X_dis_off;

    [MenuItem("Sbin/ EditorTransformMirror_xh")]
    static void Init()
    {
        window = EditorWindow.CreateInstance<EditorTransformMirror_xh>();
        window.Show();

    }

    private void OnGUI()
    {

        GUILayout.Label("select gameobjects in current scene, then execute mirror tranform with special axis:x ,y ,z");
        X_dis = EditorGUILayout.Toggle("X- mirror", X_dis);

        Y_dis = EditorGUILayout.Toggle("Y- mirror", Y_dis);

        Z_dis = EditorGUILayout.Toggle("Z- mirror", Z_dis);

        X_dis_off = EditorGUILayout.Toggle("X- on", X_dis_off);
        Y_dis_off = EditorGUILayout.Toggle("Y- on", Y_dis_off);

        Z_dis_off = EditorGUILayout.Toggle("Z- on", Z_dis_off);

        if (GUILayout.Button("GO"))
        {
            GameObject[] selectedObjs = Selection.gameObjects;
            for (int i = 0; i < selectedObjs.Length; i++)
            {
                Transform trans = selectedObjs[i].transform;
                Vector3 pos = trans.position;

                // trans.position = new Vector3(pos.x*( X_dis?-1:1), pos.y*( Y_dis?-1:1), pos.z*( Z_dis?-1:1));
                trans.position = new Vector3(POSX(), POSY(), POSZ());


                float POSX()
                {

                    float P = 0;
                    if (X_dis_off)
                    {
                        P = pos.x + (X_dis ? (float)Math.Sqrt(71.5f)/2 : -(float)Math.Sqrt(71.5f))/2;
                    }
                    else
                    {
                        P = pos.x;
                    }
                    return P;
                }

                float POSY()
                {
                    float Y = 0;
                    if (Y_dis_off)
                    {
                        Y = pos.y + (Y_dis ? -3 : 3);
                    }
                    else
                    {
                        Y = pos.y;
                    }
                    return Y;
                }

                float POSZ()
                {
                    var a = (float)Math.Pow(72, 1 / 2);
                    float Z = 0;
                    if (Z_dis_off)
                    {
                        
                        Z = pos.z + (Z_dis ? (float)Math.Sqrt(71.5f)/2 : -(float)Math.Sqrt(71.5f))/2;
                    }
                    else
                    {
                        Z = pos.z;
                    }
                    return Z;
                }





            }
        }

    }
}
