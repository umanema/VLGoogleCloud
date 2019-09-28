//@author: vux
//@help: template for standard shaders
//@tags: template
//@credits: 

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

RWStructuredBuffer<Point> Output : BACKBUFFER;

float3 Force;
float Time;

float3 Move (Point p)
{
	float3 pos = p.pos + Force*p.col;
	pos.x += sin(Time* p.col.r)  * 0.00001;
	pos.y += cos(Time* p.col.g)  * 0.00001;
	pos.z += cos(Time* p.col.b)  * 0.00001;
	return pos; 
}

[numthreads(16, 8, 1)]
void Emit(uint3 DTid: SV_DispatchThreadID)
{
	Output[DTid.y*Size.x + DTid.x].pos = Move(Output[DTid.y*Size.x + DTid.x]);
}



technique10 Emition
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, Emit() ) );
	}
}




