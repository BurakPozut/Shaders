Shader "Unlit/FlashHealthBar"
{
    Properties
    {
        [NoScaleOffset]_MainTex ("Texture", 2D) = "white" {}
        _Health ("Health", Range(0,1)) = 1
        _BorderSize("Border Size", Range(0,0.5)) = 0.1
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
            float _BorderSize;

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
                // To make a rounded rectangle, imagine a line in the center of the rectangle then substract pixels by the closest point on the line
                float2 coords = i.uv;
                coords.x*=8;

                // Clamp the X coordinate between 0,5 - 7,5 becuse i dont want out line to go infinite and Y coordinate is constant 0,5
                float2 pointOnLine = float2(clamp(coords.x ,0.5, 7.5), 0.5); 

                float sdf = distance(coords , pointOnLine) * 2 - 1;
                clip(-sdf);

                float borderSdf = sdf + _BorderSize;


                // Did this for anti-alliasing
                float pd = fwidth(borderSdf); // screeen space partial derivative (partial derivative)

                float borderMask = 1-saturate(borderSdf / pd);  // Inverted borderSdf cause other way borders were white and i can't mul. with white

                //return float4(borderMask.xxx,1);

 

                float healthBarMask = _Health > i.uv.x; // If the uv value of the fragment is smaller than Helath make it white

                float3 healthBarColor = tex2D(_MainTex, float2 (_Health, i.uv.y));

                if(_Health < 0.3)
                {
                    float flash = cos(_Time.y * 4) * 0.4 + 1;   // We add 1 because we dont want it to go below 0 
                    healthBarColor *= flash;

                }

                return float4(healthBarColor * healthBarMask * borderMask, 1);  // Multiplied with bordar mask so corners will be black
                //return float4 (i.uv,0,0);
            }
            ENDCG
        }
    }
}
