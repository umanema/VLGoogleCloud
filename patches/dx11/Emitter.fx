//@author: vux
//@help: template for standard shaders
//@tags: template
//@credits: 
#define PI 3.141592

bool Reset;

int2 Size;

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

Texture2D<float4> pRGB;
Texture2D<float4> nRGB;

StructuredBuffer<float> PrevDepth;
StructuredBuffer<float> NextDepth;


RWStructuredBuffer<Point> Output : BACKBUFFER;

float3 CalculatePosition (int x, int y, StructuredBuffer<float> Depth)
{
	float xnormalize = (Size.x-x-1.0f)/(Size.x-1.0f);
    float ynormalize =(Size.y-y-1.0f)/(Size.y-1.0f);
    
    float theta = xnormalize * (2 * PI) + (PI / 2);
    float phi = ynormalize * PI;
    
    float depth = Depth[y*Size.x + x];
    
    float3 pos;
    pos.x = sin(phi) * cos(theta);
    pos.z = sin(phi) * sin(theta);
    pos.y = -cos(phi);
    
    if (depth != 0) {
        pos = pos*depth;
        
    } else {
        pos = pos*2.0f;
    }
	return pos;
}

[numthreads(16, 8, 1)]
void Emit(uint3 DTid: SV_DispatchThreadID)
{
	if (Reset)
	{		
		Output[DTid.y*Size.x + DTid.x].pos = CalculatePosition(DTid.x, DTid.y, PrevDepth);
		Output[DTid.y*Size.x + DTid.x].iPos = CalculatePosition(DTid.x, DTid.y, PrevDepth);
		Output[DTid.y*Size.x + DTid.x].nPos = CalculatePosition(DTid.x, DTid.y, NextDepth);
		Output[DTid.y*Size.x + DTid.x].scale = CalculatePosition(DTid.x, DTid.y, PrevDepth);
		Output[DTid.y*Size.x + DTid.x].iScale = CalculatePosition(DTid.x, DTid.y, PrevDepth);
		Output[DTid.y*Size.x + DTid.x].nScale = CalculatePosition(DTid.x, DTid.y, NextDepth);
		Output[DTid.y*Size.x + DTid.x].col = pRGB[DTid.xy].rgb;
		Output[DTid.y*Size.x + DTid.x].iCol = pRGB[DTid.xy].rgb;
		Output[DTid.y*Size.x + DTid.x].nCol = nRGB[DTid.xy].rgb;
	}
}



technique10 Emition
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, Emit() ) );
	}
}




