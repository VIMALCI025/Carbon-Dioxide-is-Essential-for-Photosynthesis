Shader "Custom/FresnelOverlayURP_XR"
{
    Properties
    {
        _FresnelColor ("Fresnel Color", Color) = (1,1,0,1)
        _FresnelPower ("Fresnel Power", Range(0.5,8)) = 4
        _Intensity ("Intensity", Range(0,5)) = 2
        _Alpha ("Overlay Alpha", Range(0,1)) = 1
    }

    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "Queue"="Transparent"
            "RenderType"="Transparent"
        }

        Pass
        {
            Name "FresnelOverlay"

            Blend SrcAlpha One
            ZWrite Off
            Cull Back

            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            // XR Support
            #pragma multi_compile_instancing
            #pragma multi_compile _ DOTS_INSTANCING_ON

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;

                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float3 normalWS : TEXCOORD0;
                float3 viewDirWS : TEXCOORD1;

                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            CBUFFER_START(UnityPerMaterial)
                float4 _FresnelColor;
                float _FresnelPower;
                float _Intensity;
                float _Alpha;
            CBUFFER_END

            Varyings vert(Attributes IN)
            {
                Varyings OUT;

                UNITY_SETUP_INSTANCE_ID(IN);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);

                VertexPositionInputs pos =
                    GetVertexPositionInputs(IN.positionOS.xyz);

                OUT.positionHCS = pos.positionCS;

                OUT.normalWS =
                    TransformObjectToWorldNormal(IN.normalOS);

                OUT.viewDirWS =
                    normalize(GetCameraPositionWS() - pos.positionWS);

                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);

                float3 normal = normalize(IN.normalWS);
                float3 viewDir = normalize(IN.viewDirWS);

                float fresnel =
                    pow(1.0 - saturate(dot(normal, viewDir)), _FresnelPower);

                float glow = fresnel * _Intensity;

                float3 color = _FresnelColor.rgb * glow;

                return float4(color, fresnel * _Alpha);
            }

            ENDHLSL
        }
    }
}