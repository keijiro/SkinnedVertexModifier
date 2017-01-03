Shader "Skinned Vertex Modifier/Noise"
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

        CGPROGRAM

        #pragma surface surf Standard nolightmap addshadow vertex:vert
        #pragma target 3.0

        #include "SimplexNoiseGrad3D.cginc"

        struct Input
        {
            float2 uv_MainTex;
        };

        sampler2D _MainTex;
        half3 _Color;
        half _Smoothness;
        half _Metallic;

        float3 ApplyNoise(float3 p)
        {
            float3 np = p * 2 + float3(0, _Time.y, 0);
            return p + snoise_grad(np) * 0.02;
        }

        void vert(inout appdata_full v)
        {
            float3 binormal = cross(v.normal, v.tangent.xyz) * v.tangent.w;

            float3 p = v.vertex.xyz;

            // Left-hand neighbor vertex position
            float3 p_l = v.vertex.xyz +
                         v.tangent.xyz * v.texcoord2.x +
                         binormal * v.texcoord2.y;

            // Right-hand neighbor vertex position
            float3 p_r = v.vertex.xyz +
                         v.tangent.xyz * v.texcoord2.z +
                         binormal * v.texcoord2.w;

            // Modify the vertex positions by the noise field.
            p = ApplyNoise(p);
            p_l = ApplyNoise(p_l);
            p_r = ApplyNoise(p_r);

            v.vertex.xyz = p;

            // Recalculate the normal from the modified vertex positions.
            v.normal = normalize(cross(p_l - p, p_r - p));
        }

        void surf(Input IN, inout SurfaceOutputStandard o)
        {
            o.Albedo = tex2D(_MainTex, IN.uv_MainTex).rgb * _Color;
            o.Metallic = _Metallic;
            o.Smoothness = _Smoothness;
        }

        ENDCG
    }
}
