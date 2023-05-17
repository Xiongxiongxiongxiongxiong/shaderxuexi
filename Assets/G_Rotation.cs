using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class G_Rotation : MonoBehaviour
{
    // Start is called before the first frame update


    // Update is called once per frame
  //  public GameObject g1, g2, g3;
 //   private Vector3 player01, player02, player03;
    // private void Start()
    // {
    //     player01 = g1.transform.localPosition;
    //     player02 =g2. transform.localPosition;
    //     player03 = g3.transform.localPosition;
    // }

    void Update()
    {
        transform.Rotate(Vector3.up,Time.deltaTime*15);

        // g1.transform.localPosition = player01 + Vector3.up * Time.deltaTime;
        // g2.transform.localPosition = player01 + Vector3.up * Time.deltaTime;
        // g3.transform.localPosition = player01 + Vector3.up * Time.deltaTime;


    }
}
