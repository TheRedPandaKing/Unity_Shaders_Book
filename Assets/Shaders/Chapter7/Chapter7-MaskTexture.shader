Shader "Unity Shaders Book/Chapter 7/Mask Texture" {
    Properties{
        _Color("Color Tinnt", Color) = (1, 1, 1, 1)
        _MainTex("Main Tex", 2D) = "white"{}
        _BumpMap("Normal Map", 2D) = "bump"{}
        _BumpScale("Bump Scale", Float) = 1.0
        _SpecularMask("Specular Mask", 2D) = "white"{}
        _SpeculerScale ("Specular Scale", Float) = 1.0
        _Specular ("Specular", Color) = (1, 1, 1, 1)
        _Gloss("Gloss", Range(8.0, 256)) = 20
    }
    SubShader{
        Pass{
            Tags{"LightMode" = "ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"
            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpMap;
            float4 _BumpMap_ST;
            float _BumpScale;
            sampler2D _SpecularMask;
            float _SpeculerScale;
            fixed4 _Specular;
            float _Gloss;
            struct a2v{
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float4 texcoord : TEXCOORD0;
            };
            struct v2f{
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 LightDir : TEXCOORD1;
                float3 ViewDir : TEXCOORD2;
            };
            v2f vert(a2v v){
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;

                TANGENT_SPACE_ROTATION;

                o.LightDir = mul(rotation, ObjSpaceLightDir(v.vertex)).xyz;
                o.ViewDir = mul(rotation, ObjSpaceViewDir(v.vertex)).xyz;
                return o;
            }
            fixed4 frag(v2f i) : SV_Target{
                fixed3 tangentLightDir = normalize(i.LightDir);
                fixed3 tangentViewDir = normalize(i.ViewDir);
                fixed3 tangentNormal = UnpackNormal(tex2D(_BumpMap, i.uv));
                tangentNormal.xy *= _BumpScale;
                tangentNormal.z = sqrt(1 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));

                fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
                fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(tangentNormal, tangentLightDir));
                fixed3 halfDir = normalize(tangentLightDir + tangentViewDir);
                fixed specularMask = tex2D(_SpecularMask, i.uv).r * _SpeculerScale;
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot (tangentNormal, halfDir)),_Gloss) * specularMask;
                // return fixed4(ambient + diffuse + specular, 1);
                return fixed4(ambient + diffuse + specular, 1);
            }
            ENDCG
        }
    }
    FallBack "Specular"
}
