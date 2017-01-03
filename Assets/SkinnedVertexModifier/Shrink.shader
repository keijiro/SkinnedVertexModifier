Shader "Skinned Vertex Modifier/Shrink"
{
    Properties
    {
        _MainTex("Albedo", 2D) = "gray"{}
        _Color("Color", Color) = (1, 1, 1)
        _Smoothness("Smoothness", Range(0, 1)) = 0
        _Metallic("Metallic", Range(0, 1)) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Cull Off

        CGPROGRAM

        #pragma surface surf Standard nolightmap addshadow vertex:vert
        #pragma target 3.0

        struct Input
        {
            float2 uv_MainTex;
            float facing : VFACE;
        };

        sampler2D _MainTex;
        half3 _Color;
        half _Smoothness;
        half _Metallic;

        void vert(inout appdata_full v)
        {
            float3 binormal = cross(v.normal, v.tangent.xyz) * v.tangent.w;

            float3 center = v.vertex.xyz +
                            v.tangent.xyz * v.texcoord1.x +
                            binormal * v.texcoord1.y;

            float anim = sin(_Time.y * 4 + center.x * 2) * 0.4 + 0.4;

            v.vertex.xyz = lerp(v.vertex.xyz, center, anim);
        }

        void surf(Input IN, inout SurfaceOutputStandard o)
        {
            o.Albedo = tex2D(_MainTex, IN.uv_MainTex).rgb * _Color;
            o.Metallic = _Metallic;
            o.Smoothness = _Smoothness;
            o.Normal = float3(0, 0, IN.facing > 0 ? 1 : -1);
        }

        ENDCG
    }
}
