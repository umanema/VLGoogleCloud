//@author: vux
//@help: basic pixel based lightning with directional light
//@tags: shading, blinn
//@credits: vvvv group

struct Point
{
	float3 pos;
	float3 iPos;
	float3 nPos;
	float3 scale;
	float3 iScale;
	float3 nScale;
	float3 col;
	float3 iCol;
	float3 nCol;
};

StructuredBuffer<Point> Points;

struct vsInput
{
    float4 posObject : POSITION;
	float4 normalObject : NORMAL;
	uint ii : SV_InstanceID;
};

struct psInput
{
    float4 posScreen : SV_Position;
    float3 LightDirV: TEXCOORD0;
    float3 NormV: TEXCOORD1;
    float3 ViewDirV: TEXCOORD2;
	float4 col : COLOR;
};

struct vsInputTextured
{
    float4 posObject : POSITION;
	float4 normalObject : NORMAL;
	float4 uv: TEXCOORD0;
};

struct psInputTextured
{
    float4 posScreen : SV_Position;
    float4 uv: TEXCOORD0;
    float3 LightDirV: TEXCOORD1;
    float3 NormV: TEXCOORD2;
    float3 ViewDirV: TEXCOORD3;
};

Texture2D inputTexture <string uiname="Texture";>;

SamplerState linearSampler <string uiname="Sampler State";>
{
    Filter = MIN_MAG_MIP_LINEAR;
    AddressU = Clamp;
    AddressV = Clamp;
}; 

cbuffer cbPerDraw : register(b0)
{
	float4x4 tLAV: LAYERVIEW;
	float4x4 tV : VIEW;
	float4x4 tP: PROJECTION;
	float4x4 tLVP: LAYERVIEWPROJECTION;
};

cbuffer cbPerObj : register( b1 )
{
	float4x4 tW : WORLD;
	float4x4 tWV: WORLDLAYERVIEW;
	float4x4 tWIT: WORLDINVERSETRANSPOSE;
	
	float Alpha <float uimin=0.0; float uimax=1.0;> = 1; 
	float4 cAmb <bool color=true;String uiname="Color";> = { 1.0f,1.0f,1.0f,1.0f };
	float4x4 tColor <string uiname="Color Transform";>;
};

cbuffer cbTextureData : register(b2)
{
	float4x4 tTex <string uiname="Texture Transform"; bool uvspace=true; >;
};

#include "PhongDirectional.fxh"

float Scale (float3 nPos)
{
	return distance(float3(0,0,0),nPos);
}

psInputTextured VS_Textured(float4 PosO: POSITION,float3 NormO: NORMAL, float4 TexCd : TEXCOORD0)
{
    psInputTextured output;
  	
    //inverse light direction in view space
    output.LightDirV = normalize(-mul(float4(lDir,0.0f), tV).xyz);
    
    //normal in view space
    output.NormV = normalize(mul(mul(NormO, (float3x3)tWIT),(float3x3)tLAV).xyz);

    //position (projected)
    output.posScreen  = mul(PosO, mul(tW, tLVP));
    output.uv = mul(TexCd, tTex);
    output.ViewDirV = -normalize(mul(PosO, tWV).xyz);
    return output;
}

psInput VS(float4 PosO: POSITION,float3 NormO: NORMAL, uint ii : SV_InstanceID )
{
    psInput output;
	uint pi = ii;
	float3 nPos = Points[pi].pos;
	float3 nScale = Points[pi].scale;
    //inverse light direction in view space
    output.LightDirV = normalize(-mul(float4(lDir,0.0f), tV).xyz);
     
    //normal in view space
    output.NormV = normalize(mul(mul(NormO, (float3x3)tWIT),(float3x3)tLAV).xyz);
    //position (projected)
	float scale = Scale(nScale);
	float4x4 t =
	{
		scale, 0, 0, 0,
		0, scale, 0, 0,
		0, 0, scale, 0,
		0, 0, 0, 1
	};
    output.posScreen  = mul(PosO+float4(nPos/scale, 1), mul(tW*t, tLVP));
    //output.posScreen  = mul(PosO+float4(nPos, 1), mul(tW, tLVP));
    output.ViewDirV = -normalize(mul(PosO, tWV).xyz);
	output.col = float4(Points[pi].col, 1);
    return output;
}

float4 PS_Textured(psInputTextured input): SV_Target
{
    float4 col = inputTexture.Sample(linearSampler, input.uv.xy);
    col.rgb *= PhongDirectional(input.NormV, input.ViewDirV, input.LightDirV).xyz;
    col.a *= Alpha;
    return mul(col, tColor);
}

float4 PS(psInput input): SV_Target
{
    float4 col = input.col;
    col.rgb *= PhongDirectional(input.NormV, input.ViewDirV, input.LightDirV).xyz;
    col.a *= Alpha;
    return mul(col, tColor);
}



technique10 GouraudDirectional <string noTexCdFallback="GouraudDirectionalNotexture"; >
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, VS_Textured() ) );
		SetPixelShader( CompileShader( ps_4_0, PS_Textured() ) );
	}
}

technique11 GouraudDirectionalNotexture
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, VS() ) );
		SetPixelShader( CompileShader( ps_4_0, PS() ) );
	}
}

