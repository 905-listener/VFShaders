Shader "905/Reflection"
{
    Properties
    {
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Tags {"LightMode"="ForwardBase"}
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct v2f
            {
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD2;
                float3 pos : TEXCOORD3;
            };

            v2f vert (appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.pos = mul(unity_ObjectToWorld, v.vertex).xyz;
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 c = 0;
                float3 dir = normalize(UnityWorldSpaceViewDir(i.pos));
                float3 refl = reflect(-dir, i.normal);
                float4 skyData = UNITY_SAMPLE_TEXCUBE(unity_SpecCube0, refl);
                float3 skyColor = DecodeHDR(skyData, unity_SpecCube0_HDR);
                c.rgb = skyColor; 
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return c;
            }
            ENDHLSL
        }
    }
}
