using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class Grass : MonoBehaviour
{
    public Transform playerPos;
    public Material Material;

    // Update is called once per frame
    void Update()
    {
        Material.SetVector("Vector3_a040467d2bf045a580fed073a283ead4", playerPos.position);
    }
}
