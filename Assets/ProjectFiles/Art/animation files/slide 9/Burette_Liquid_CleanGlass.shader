Shader "Custom/Burette_Liquid_CleanGlass"
{
    Properties
    {
        _Color ("Liquid Color", Color) = (0.38, 0.15, 0.50, 0.28)

        _FillAmount ("Fill Amount (0-1)", Range(0,1)) = 0.5

        _MinAxis ("Min Axis Value", Float) = -0.5
        _MaxAxis ("Max Axis Value", Float) = 0.5

        _Axis ("Axis (0=X,1=Y,2=Z)", Float) = 1

        _Invert ("Invert Direction", Float) = 1
    }

    SubShader
    {
        Tags { "Queue"="Transparent+2" "RenderType"="Transparent" }

        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite Off
        Cull Off

        Pass
        {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            float _FillAmount;
            float _MinAxis;
            float _MaxAxis;
            float _Axis;
            float _Invert;

            fixed4 _Color;

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 localPos : TEXCOORD0;
            };

            v2f vert(appdata v)
            {
                v2f o;

                o.pos = UnityObjectToClipPos(v.vertex);
                o.localPos = v.vertex.xyz;

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float axisValue;

                // Select axis
                if (_Axis < 0.5)
                    axisValue = i.localPos.x;
                else if (_Axis < 1.5)
                    axisValue = i.localPos.y;
                else
                    axisValue = i.localPos.z;

                float normalizedHeight;

                // Normal direction
                normalizedHeight = saturate(
                    (axisValue - _MinAxis) / (_MaxAxis - _MinAxis)
                );

                // Optional inversion
                if (_Invert > 0.5)
                {
                    normalizedHeight = 1.0 - normalizedHeight;
                }

                // Clip liquid
                if (normalizedHeight > _FillAmount)
                    discard;

                return _Color;
            }

            ENDCG
        }
    }
}