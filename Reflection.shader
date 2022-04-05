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
                // ビュー座標
                float4 svpos : SV_POSITION;
                // 法線
                float3 normal : TEXCOORD2;
                // ワールド座標
                float3 wpos : TEXCOORD3;
            };

            v2f vert (appdata_base v)
            {
                v2f o;
                o.svpos = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.wpos = mul(unity_ObjectToWorld, v.vertex).xyz;
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 c = 0;
                // ビュー方向  ワールド座標はフラグメントシェーダー内で補完されている？
                float3 dir = normalize(UnityWorldSpaceViewDir(i.wpos));
                // 反射方向
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
