Shader "Unlit/HealthBar"
{
    Properties
    {
        [NoScaleOffset]_MainTex ("Texture", 2D) = "white" {}
        _Health ("Health", Range(0,1)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queu"="Transparent" }
        LOD 100

        Pass
        {
            ZWrite off // we dont want transparent objets to write to depthbuffer because they may discard themselfs

            // src * srcAlpha + dst * (1 - srcAlpha) (this is actually a lerp)
            // source is color output of this shader 
            // destination is exsisting color in the frame buffer
            Blend SrcAlpha OneMinusSrcAlpha // Alpha Blending

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

            sampler2D _MainTex;
            float _Health;

            Interplators vert (MeshData v)
            {
                Interplators o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            float InverseLerp(float a, float b, float v)
            {
                return (v-a) / (b-a);
            }

            float4 frag (Interplators i) : SV_Target
            {
                // sample the texture
                //float4 col = tex2D(_MainTex, i.uv);


                //clip(healthBarMask - 0.5); // If the value is less than 0 don't render it.
                // I used this because ı want to make background transparent
                // Disadvantage of clip against alpha blend is we can make a fragment only 0 or 1 

                //float thresholdHealthcolor = saturate(InverseLerp(0.2, 0.8, _Health));    // If our Health value is lesser or equal than 0.2 make it 0
                // And if our health is gerater or equal than 0.8 make it 1
                //and also we saturated it because inverse lerp function may return negative values below 0.2

                //float3 healthBarColor = lerp(float3(1,0,0),float3(0,1,0), thresholdHealthcolor); // lerping between red and green
                //float3 bgcolor = float3(0,0,0);
                //float3 outputColor = lerp(bgcolor, healthBarColor,healthBarMask);

                float healthBarMask = _Health > i.uv.x; // If the uv value of the fragment is smaller than Helath make it white
                float3 healthBarColor = tex2D(_MainTex, float2 (_Health, i.uv.y));


                return float4(healthBarColor * healthBarMask, 1);
                //return float4 (i.uv,0,0);
            }
            ENDCG
        }
    }
}
