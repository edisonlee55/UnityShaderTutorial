Shader "Unlit/MeowUnlitShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _TintColor ("Tint Color", Color) = (1,1,1,1)
        _Transparency("Transparency", Float) = 0.25
        [Toggle(ENABLED_HUE)]
        _HueEnabled("Enable Hue", Float) = 0
        _HueBaseColor("Hue Base Color", Color) = (0.7, 0, 0, 1)
        _HueDegreesOffset("Hue Degrees Offset", Range(0, 360)) = 0
    }
    SubShader
    {
        Tags
        {
            "Queue"="Transparent" "RenderType"="Transparent"
        }
        LOD 100

        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            // Uncomment to debug shader in DirectX 11 (remove in production)
            // #pragma enable_d3d11_debug_symbols

            #pragma shader_feature ENABLED_HUE

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _TintColor;
            float4 _tex2D;
            float _Transparency;
            float4 _HueBaseColor;
            float _HueDegreesOffset;

            // From Unity Shader Graph Package - Hue Node
            // https://docs.unity3d.com/Packages/com.unity.shadergraph@12.1/manual/Hue-Node.html
            void Unity_Hue_Degrees_float(float3 In, float Offset, out float3 Out)
            {
                float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
                float4 P = lerp(float4(In.bg, K.wz), float4(In.gb, K.xy), step(In.b, In.g));
                float4 Q = lerp(float4(P.xyw, In.r), float4(In.r, P.yzx), step(P.x, In.r));
                float D = Q.x - min(Q.w, Q.y);
                float E = 1e-10;
                float3 hsv = float3(abs(Q.z + (Q.w - Q.y) / (6.0 * D + E)), D / (Q.x + E), Q.x);

                float hue = hsv.x + Offset / 360;
                hsv.x = (hue < 0)
                            ? hue + 1
                            : (hue > 1)
                            ? hue - 1
                            : hue;

                float4 K2 = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
                float3 P2 = abs(frac(hsv.xxx + K2.xyz) * 6.0 - K2.www);
                Out = hsv.z * lerp(K2.xxx, saturate(P2 - K2.xxx), hsv.y);
            }

            v2f vert(appdata v)
            {
                v2f o;
                v.vertex.x += sin(_Time * 75 + v.vertex.y * 0.75);
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                #ifdef ENABLED_HUE
                float4 _HueColor;
                Unity_Hue_Degrees_float(_HueBaseColor.rgb, _HueDegreesOffset, _HueColor.rgb);
                #endif

                // sample the texture
                _tex2D = tex2D(_MainTex, i.uv);

                #ifdef ENABLED_HUE
                fixed4 col = _tex2D + _TintColor + _HueColor;
                #else
                fixed4 col = _tex2D + _TintColor;
                #endif

                col.a = _Transparency;
                return col;
            }
            ENDCG
        }
    }
}