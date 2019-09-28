//@author: vux
//@help: template for standard shaders
//@tags: template
//@credits: 
#define PI 3.141592

int2 Size;
bool Next;

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

RWStructuredBuffer<Point> Output : BACKBUFFER;

float Interpolation;

Point Interpolate (Point pP, Point nP)
{
	Point mP;
	mP.pos = lerp(pP.pos,nP.pos,Interpolation);
	mP.scale = lerp(pP.pos,nP.pos,Interpolation);
	mP.col = lerp(pP.col,nP.col,Interpolation);
	return mP;
}

[numthreads(16, 8, 1)]
void Emit(uint3 DTid: SV_DispatchThreadID)
{
	
	if (Next) {
		Output[DTid.y*Size.x + DTid.x].pos = lerp(Output[DTid.y*Size.x + DTid.x].pos,
											  	  Output[DTid.y*Size.x + DTid.x].nPos,
											  	  Interpolation);
		Output[DTid.y*Size.x + DTid.x].col = lerp(Output[DTid.y*Size.x + DTid.x].col,
												  Output[DTid.y*Size.x + DTid.x].nCol,
												  Interpolation);
		Output[DTid.y*Size.x + DTid.x].scale = lerp(Output[DTid.y*Size.x + DTid.x].scale,
												  	Output[DTid.y*Size.x + DTid.x].nScale,
												  	Interpolation);
	} else {
		Output[DTid.y*Size.x + DTid.x].pos = lerp(Output[DTid.y*Size.x + DTid.x].pos,
											      Output[DTid.y*Size.x + DTid.x].iPos,
											      Interpolation);
		Output[DTid.y*Size.x + DTid.x].col = lerp(Output[DTid.y*Size.x + DTid.x].col,
												  Output[DTid.y*Size.x + DTid.x].iCol,
											      Interpolation);
		Output[DTid.y*Size.x + DTid.x].scale = lerp(Output[DTid.y*Size.x + DTid.x].scale,
												    Output[DTid.y*Size.x + DTid.x].iScale,
											        Interpolation);
	}
	
}



technique10 Emition
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, Emit() ) );
	}
}




