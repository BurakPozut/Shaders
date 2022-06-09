Shader "Unlit/Shader1"
{
    Properties
    {
        _ColorA("Color A", Color) = (1,1,1,1)
        _ColorB("Color B", Color) = (1,1,1,1)
        _ColorStart("Color Start", Range(0,1)) = 0
        _ColorEnd ("Color End",Range(0,1)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" 
        "Queue" = "Transparent"}
        LOD 100

        Pass
        {
            
            Cull off    //Does render both polygons facing and backwards
            ZWrite Off  // Depth buffer, We turned it down because we want our object to be transparent
            Blend One One // Additive
            //Blend DstColor Zero // Multiply

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Value;


            #define TAU 6.28318530718
            float4 _ColorA;
            float4 _ColorB;

            float _ColorStart;
            float _ColorEnd;
            // float _Scale;
            // float _Offset;
            

            struct MeshData // per-vertex mesh data
            {
                float4 vertex : POSITION;   // vertex position
                float3 normals : NORMAL;
                float4 tangent : TANGENT;
                float2 uv0 : TEXCOORD0;  // uv0 coordinates
                float2 uv1 : TEXCOORD1; // uv1 coordinates
            };

            struct Interpolators  // data get spassed from vertex shader to fragment sahder
            {
                //float2 uv : TEXCOORD0;  
                float4 vertex : SV_POSITION;    // clip space position for each vertex
                float3 normal : TEXCOORD0;
                float2 uv : TEXCOORD1;
            };

            

            Interpolators vert (MeshData v)
            {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);  // convert it's local space to clip space
                o.normal = v.normals;    // just pass through
                o.uv = v.uv0; //(v.uv0 + _Offset) * _Scale;
                return o;
            }


            float InverseLerp(float a, float b,float v){
                return (v-a)/(b-a);
            }

            fixed4 frag (Interpolators i) : SV_Target
            {
                //float t = saturate(InverseLerp(_ColorStart, _ColorEnd,i.uv.x));
                //float t = abs(frac(i.uv.x *5) * 2-1);

                

                float xOffset = cos(i.uv.x* TAU * 8) *0.01;
                float t = cos((i.uv.y + xOffset - _Time.y *0.1f) * TAU * 5);
                t *= (1-(i.uv.y))*0.3f; // we did this so as we go up to the mesh it will start to dissappear

                float TopBottomRemover = (abs(i.normal.y)<0.9); // If Vertex's normal is bigger than 0.9 then dont show it. With this code we remowed top and bottom lids of the cylinder
                float waves = t * TopBottomRemover;

                float4 gradient = lerp(_ColorA, _ColorB, i.uv.y);   // Lerp beetween two colors
                return gradient *waves;

                // float4 outColor = lerp(_ColorA, _ColorB, t);    // blend between two colors based on the X UV coordinate
                // return outColor;               
            }
            ENDCG
        }
    }
}
