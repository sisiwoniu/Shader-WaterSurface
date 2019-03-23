//テッセレーションなしバージョン
Shader "Unlit/SimpleWave"
{
    Properties
    {	
		[NoScaleOffset]
        _MainTex("Texture", 2D) = "white" {}
		_Speed("Speed", Range(0.1, 10)) = 1
		_Height("Height", Range(-1, 1)) = 1
		_Amount("Amount", Range(-1, 1)) = 1
		_Foam("Foamness", Range(0.1, 3)) = 1
		_FoamCol("FoamLineCol", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Transparent" "IgnoreProjector"="True" }

		Cull Back

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

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
				float4 w_pos : TEXCOORD1;
            };

            sampler2D _MainTex;
			sampler2D _CameraDepthTexture;
			half _Speed;
			half _Height;
			half _Amount;
			half _Foam;
			fixed4 _FoamCol;

            v2f vert (appdata v)
            {
                v2f o;

				//揺らす
				v.vertex.y = sin(_Time.y * _Speed + (v.vertex.x * v.vertex.z * _Amount)) * _Height + v.vertex.y;

                o.vertex = UnityObjectToClipPos(v.vertex);

				o.w_pos = ComputeScreenPos(o.vertex);

                o.uv = v.uv;

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
				
				//SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(i.w_pos)) == tex2Dproj(_CameraDepthTexture, i.w_pos)
				half depth = LinearEyeDepth(tex2Dproj(_CameraDepthTexture, i.w_pos));

				// == 1 - saturate(_Foam * (depth - i.w_pos.w))
				half t = saturate(_Foam * (depth - i.w_pos.w)) * -1 + 1;

				col = _FoamCol * t + col;

                return col;
            }
            ENDCG
        }
    }
}
