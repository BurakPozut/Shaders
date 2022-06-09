Shader "Unlit/LightingTest"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Gloss ("Gloss", Range(0,1)) = 1
        _Color("Color", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags {"RenderType"="Opaque"}
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "UnityLightingCommon.cginc"
            #include "AutoLight.cginc"

            struct MeshData
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct Interpolators
            {
                float2 uv : TEXCOORD0;
                float3 normal : TEXCOORD1;
                float4 vertex : SV_POSITION;
                float3 wPos : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Gloss;
            float4 _Color;

            Interpolators vert (MeshData v)
            {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.wPos = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            fixed4 frag (Interpolators i) : SV_Target
            {
                // sample the texture
                //fixed4 col = tex2D(_MainTex, i.uv);
             
                // diffuse lighting (lambertion)
                float3 N = normalize(i.normal); // Normalizing the normal vause we dont want to see the normals

                float3 L =  _WorldSpaceLightPos0.xyz;   // Gives us direction of the light 
                
                float3 lambert = saturate(dot(N,L));

                // We dot product the lighting and normal vectors and if our normal is greater or equal than out light vector it will give 0
                float3 diffuseLight = saturate(dot(N,L)) * _LightColor0.xyz;    


                //sepcular lighting

                float3 V = normalize(_WorldSpaceCameraPos - i.wPos);

                //float3 R = reflect(-L, N);    // used for just phong

                // Blinn-Phong Half vector (Using this will give us a more realistic look because reflections becomes less uniform)
                float3 H = normalize(L + V);
                //float3 specularLight = saturate(dot(V, R));
                float3 specularLight = saturate(dot(H, N)) * (lambert >0);


                // Mapping the gloss value because gloos value is exponential, if we want to make smaller highlights increase the number we are multiplying gloss
                float specularExponent = exp2(_Gloss * 6 + 2);  

                specularLight = pow(specularLight, specularExponent) * _Gloss; // Specular exponent (added _Gloss cause energy conservation)
                specularLight *= _LightColor0.xyz;


                //float fresnel = ((1-dot(V, N))*0.2)*(cos(_Time.y*2));
                float fresnel = step(0.8,1-dot(V, N));
                return fresnel;
                //return float4(specularLight, 1);
                //return float4(diffuseLight * _Color + specularLight + fresnel,1);

            }
            ENDCG
        }
    }
}
