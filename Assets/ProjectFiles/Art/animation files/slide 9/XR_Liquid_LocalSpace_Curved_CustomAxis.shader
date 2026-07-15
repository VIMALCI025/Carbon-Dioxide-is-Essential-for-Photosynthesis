Shader "Custom/XR_Liquid_LocalSpace_Curved_CustomAxis"
{
    Properties
    {
        _Color ("Liquid Color", Color) = (0.5,0,1,0.8)
        _TopColor ("Surface Color", Color) = (0.7,0.2,1,1)

        _FillAmount ("Fill Amount", Range(0,1)) = 0.5

        _MinAxis ("Min Axis Value", Float) = -0.5
        _MaxAxis ("Max Axis Value", Float) = 0.5

        _BendStrength ("Surface Bend Strength", Range(0,0.5)) = 0.15

        _FillAxis ("Fill Axis (XYZ)", Vector) = (0,1,0,0)
    }

    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent" }
        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite Off
        Cull Back

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            float _FillAmount;
            float _MinAxis;
            float _MaxAxis;
            float _BendStrength;

            float4 _FillAxis;

            fixed4 _Color;
            fixed4 _TopColor;

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 localPos : TEXCOORD0;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.localPos = v.vertex.xyz;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // 🔥 Normalize axis direction
                float3 axisDir = normalize(_FillAxis.xyz);

                // Project vertex onto selected axis
                float axisValue = dot(i.localPos, axisDir);

                float normalizedHeight = saturate(
                    (axisValue - _MinAxis) / (_MaxAxis - _MinAxis)
                );

                float liquidLevel = _FillAmount;

                // 🔥 Create perpendicular plane for bending
                float3 perpendicular = i.localPos - axisDir * axisValue;

                float radius = length(perpendicular);

                float bend = _BendStrength * radius * radius;

                float curvedLevel = liquidLevel - bend;

                float edgeWidth = 0.01;

                float alpha = smoothstep(
                    curvedLevel + edgeWidth,
                    curvedLevel - edgeWidth,
                    normalizedHeight
                );

                if (alpha <= 0)
                    discard;

                float3 finalColor = lerp(_Color.rgb, _TopColor.rgb, alpha);

                return float4(finalColor, alpha * _Color.a);
            }
            ENDCG
        }
    }
}