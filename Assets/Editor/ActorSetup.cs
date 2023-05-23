using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class ActorSetup : Editor
{
    [MenuItem("Tool / ActorSetup")]
    static void ProcessBones()
    {


        var actor = Selection.activeGameObject;

        if (actor.GetComponent<Animation>() == null)
        {
           var anim= actor.AddComponent<Animation>();
           
        }

        if(actor.transform.Find("SkinRoot")==null)
        {
            new GameObject("SkinRoot").transform.parent= actor.transform;
        }


        FindBones(actor);


    }

   static   void FindBones(GameObject go)
    {
        SkinnedMeshRenderer[] smrs = go.GetComponentsInChildren<SkinnedMeshRenderer>();

        foreach(SkinnedMeshRenderer smr in smrs)
        {
            Transform rootBone = go.transform.Find("Bip001");

            Debug.Log(rootBone.childCount);

            Transform newRootBone = FindChild(rootBone, smr.rootBone.name);
            Debug.Log(smr + "       " + newRootBone);

            smr.rootBone = newRootBone;


            List<Transform> bones = new List<Transform>();
            foreach (var item in smr.bones)
            {
                Transform t = FindChild(rootBone, item.name);
                if (t)
                    bones.Add(t);
            }

            smr.bones = bones.ToArray();
        }

       



    }


   static Transform FindChild(Transform bone, string child)
    {

        if (bone.name == child) return bone;

        int count = bone.childCount;

        if (count == 0)
            return null;
        else
        {

            Transform[] childs = new Transform[count];
            for (int i = 0; i < count; i++)
            {
                childs[i] = bone.GetChild(i);
            }
            foreach (var item in childs)
            {
                Transform t = FindChild(item, child);
                if (t)
                    return t;

            }
        }

        return null;
    }
}
