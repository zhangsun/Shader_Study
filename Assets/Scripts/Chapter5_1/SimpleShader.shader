// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/SimpleShader"
{
	Properties
	{
	  _Color("Color Tint",color) = (1.0,1.0,1.0,1.0)
	}
		SubShader
	{
		Tags { "RenderType" = "Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert   //他们将告诉Unity，那个函数包含了顶点着色器的代码
			#pragma fragment frag  //他们将告诉unity，frag函数包含了片元着色器的代码
			// make fog work

		fixed4 _Color;

		struct a2v    //a表示应用，v表示顶点着色器   a2v的意思就是把数据从应用阶段传到顶点着色器中
		{
		   float4 vertex:POSITION;       //POSITION 语义告诉Unity，用模型空间的顶点坐标填充vertex变量
		   float3 normal:NORMAL;         // NORMAL 语义告诉Unity，用模型空间的法线方向填充normal变量
		   float4 texcoord:TEXCOORD0;    //TEXCOORD0语义告诉Unity，用模型的第一套纹理坐标填充texcoord变量
		};


		struct v2f
		{
			float4 pos :SV_POSITION;   //SV_POSITION 语义告诉Unity，pos里面包含了顶点在裁剪空间的位置信息
			fixed3 color : COLOR0;  //COLOR0语义可以用于存储颜色信息
		};
        //POSITION  、SV_POSITION都是CG/HLSL中的语义，他们是不可以省略的，这些语义将告诉系统用户需要哪些输入值，以及用户的输出是什么。
		//POSITION告诉Unity，把模型的顶点坐标填充到输入参数v中，
		//SV_POSITION将告诉Unity，顶点着色器的输出是裁剪坐标空间的顶点坐标   
		   v2f vert(a2v v)//:SV_POSITION
	       {
			   v2f o;
		       o.pos = UnityObjectToClipPos(v.vertex);// UnityObjectToClipPos(v.vertex);
			   o.color = v.normal *0.5 + fixed3(0.5, 0.5, 0.5);
			   return o;
           }


		//SV_Target 也是HLSL中的一个系统语义，它等同于告诉渲染器，把用户的输出颜色存储到一个渲染目标(render target)中，这里将输出到默认的帧缓存中。
		   fixed4 frag(v2f i):SV_Target
		   {
			   fixed3 c = i.color;
		       c  *= _Color.rgb;
			   return fixed4(c,1.0);
		   }
            ENDCG
        }
    }
}
