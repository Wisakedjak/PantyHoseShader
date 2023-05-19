Shader "Kirk/Pantyhose" {
    Properties{
        _Denier("Denier", Range(5,120)) = 25.0
        _DenierTex("Density Texture", 2D) = "black"{}
        _Smoothness("Smoothness", Range(0,1)) = 0.1
        _Metallic("Metallic",Range(0,1)) = 0.1
        [Enum(Strong,6,Normal,12,Weak,20)] _RimPower("Rim Power", float) = 12
        _FresnelScale("Fresnel Scale",Range(0, 6)) = 1
        _SkinTint("Skin Color Tint", Color) = (1,0.9,0.8,1)
        _SkinTex("Skin Color", 2D) = "white" {}
        _StockingTint("Stocking Color Tint", Color) = (1,1,1,1)
        _StockingTex("Stocking Color", 2D) = "white"{}
        _NormalTex("Normal", 2D) = "bump"{}
    }
        SubShader{
            Tags{ "RenderType" = "Opaque" }

            CGPROGRAM
            #pragma surface surf Standard fullforwardshadows
            #pragma target 3.0

            struct Input {
                float2 uv_SkinTex;
                float2 uv_StockingTex;
                float2 uv_DenierTex;
                float2 uv_NormalTex;
                float3 viewDir;
            };

            float _RimPower;
            float _Denier;
            float _Smoothness;
            float _Metallic;
            float _FresnelScale;
            float4 _SkinTint;
            float4 _StockingTint;
            sampler2D _DenierTex;
            sampler2D _SkinTex;
            sampler2D _StockingTex;
            sampler2D _NormalTex;

            void surf(Input IN, inout SurfaceOutputStandard o) {
                o.Normal = UnpackNormal(tex2D(_NormalTex, IN.uv_NormalTex)); //Get the normal
                             float4 skinColor = tex2D(_SkinTex, IN.uv_SkinTex) * _SkinTint; //Inner color
                             float4 stockingColor = tex2D(_StockingTex, IN.uv_StockingTex) * _StockingTint; //Outer color
                             float rim = pow(1 - dot(normalize(IN.viewDir), o.Normal), _RimPower / 10); //Edge light
                 float fresnel = pow(1.0 - max(0,dot(normalize(IN.viewDir), o.Normal)),_FresnelScale); //Fresnel
                             float denier = (_Denier - 5) / 115; //Danier parameters
                             float density = max(rim, (denier * (1 - tex2D(_DenierTex, IN.uv_DenierTex)))); //lerp parameter

                o.Albedo = lerp(skinColor, stockingColor, density);
                o.Albedo = o.Albedo * (1 - fresnel);
                o.Metallic = _Metallic;
                o.Smoothness = _Smoothness;
            }
        ENDCG
    }
        FallBack "Diffuse"
}