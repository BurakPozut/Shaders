Shader "Unlit/SDF_Example"
{
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct MeshData
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Interplators
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };


            Interplators vert (MeshData v)
            {
                Interplators o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv * 2 - 1;    // Remaped the uv's to the center 0
                return o;
            }

            fixed4 frag (Interplators i) : SV_Target
            {
                float dist = length(i.uv) - 0.3;
                //return step(0,dist);    // threshold
                return float4(dist.xxx,0);
            }
            ENDCG
        }
    }
}
