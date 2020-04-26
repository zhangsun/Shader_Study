// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Chapter7/NormalMapTangentSpace"
{
    Properties
    {
        _Color("Color Tint",Color) = (1,1,1,1)
		_MainTex("Main Tex",2D) = "white"{}
	/*	_BumpMap("Normal Map",2D) = "bump"{}*/
			_BumpMap("Normal Map", 2D) = "bump" {}
		_BumpScale("Bump Scale",float) = 1.0   //用于控制凸凹程度，当它为0时，意味着该法线纹理不会对光照产生任何影响
		_Specular("Specular",Color) = (1,1,1,1)
		_Gloss("Gloss",Range(8.0,256)) = 20

	}
		SubShader
		{
			//LightMode 标签是Pass标签的一中，它用于定义该Pass在Unity的光照流水线中的角色
		Tags { "LightMode" = "ForwardBase" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag


			#include "Lighting.cginc"


			/*fixed4 _Color;
			sampler2D _MainTex;*/
			////纹理类型的属性，在Unity中，我们需要使用   “纹理名_ST”的方式来声明某个纹理的属性  ，其中ST是缩放（Scale）和平移（translation)的缩写
			//_MainTex_ST可以让我们得到该纹理属性的缩放和平移值，_MainTex_ST.xy存储的是缩放值，而_MainTex_ST.zw存储的是偏移值。这些值可以在材质面板的纹理属性中调节
		/*	float4 _MainTex_ST;   

			sampler2D _BumpMap;
			float4 _BumpMap_ST;

			float _BumpScale;
			fixed4 _Specular;
			float  _Gloss;*/
			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _BumpMap;
			float4 _BumpMap_ST;
			float _BumpScale;
			fixed4 _Specular;
			float _Gloss;

            struct a2v
            {
                float4 vertex : POSITION;
				
				float3 normal : NORMAL;
				float4 tangent :TANGENT;
				float4 texcoord : TEXCOORD0;
     
            };

            struct v2f
            {
				float4 pos :SV_POSITION;
			
				float4 uv :TEXCOORD0;
				float3 lightDir :TEXCOORD1;
				float3 viewDir :TEXCOORD2;
            };

         

            v2f vert (a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
				o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy +_BumpMap_ST.zw;
		
				//float3 binormal = cross(normalize(v.normal), normalize(v.tangent.xyz))*v.tangent.w;

				//float3x3 rotation = float3x3(v.tangent.xyz, binormal, v.normal);

				TANGENT_SPACE_ROTATION;

				o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex)).xyz;
				o.viewDir = mul(rotation, ObjSpaceViewDir(v.vertex)).xyz;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				fixed3 tangentLightDir = normalize(i.lightDir);
				fixed3 tangentViewDir = normalize(i.viewDir);

				fixed4 packedNormal = tex2D(_BumpMap, i.uv.zw);
				fixed3 tangentNormal;

				tangentNormal = UnpackNormal(packedNormal);
				tangentNormal.xy *= _BumpScale;
				tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));

				fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

				fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(tangentNormal, tangentLightDir));

				fixed halfDir = normalize(tangentLightDir + tangentViewDir);
				fixed specular = _LightColor0.rgb *_Specular.rgb *pow(max(0, dot(tangentNormal, halfDir)), _Gloss);
				
				


                return fixed4(ambient +diffuse+specular,1.0);
            }
            ENDCG
        }
    }
}
