uniform extern float4x4 gWorld;
uniform extern float4x4 gWorldInverseTranspose;
uniform extern float4x4 gWVP;

uniform extern float4 gAmbientMtrl;
uniform extern float4 gAmbientLight;
uniform extern float4 gDiffuseMtrl;
uniform extern float4 gDiffuseLight;
uniform extern float4 gSpecularMtrl;
uniform extern float4 gSpecularLight;
uniform extern float  gSpecularPower;
uniform extern float3 gLightVecW;
uniform extern float3 gEyePosW;

struct OutputVS
{
	float4 posH  : POSITION0;
	float4 color : COLOR0;
};

OutputVS DiffuseVS(float3 posL : POSITION0, float3 normalL : NORMAL0)
{
	OutputVS outVS = (OutputVS)0;

	// Transform normal to world space
	float3 normalW = mul(float4(normalL, 0.0f), gWorldInverseTranspose).xyz;
	normalW = normalize(normalW);

	// Transform vertex position to world space
	float3 posW = mul(float4(posL, 1.0f), gWorld).xyz;

	// =============================================

	// Compute the vector from the vertex to the eye position
	float3 toEye = normalize(gEyePosW - posW);

	// Compute the reflection vector
	float3 r = reflect(-gLightVecW, normalW);

	// Determine how much (if any) specular light makes it into the eye
	float t = pow(max(dot(r, toEye), 0.0f), gSpecularPower);

	// Determine the diffuse light intensity that strikes the vertex
	float s = max(dot(gLightVecW, normalW), 0.0f);

	// Compute the ambient, diffuse, and specular terms separately
	float3 spec    = t*(gSpecularMtrl*gSpecularLight).rgb;
	float3 diffuse = s*(gDiffuseMtrl*gDiffuseLight).rgb;
	float3 ambient = gAmbientMtrl*gAmbientLight;

	// Sum all the terms together and copy over the diffuse alpha
	outVS.color.rgb = ambient + diffuse + spec;
	outVS.color.a   = gDiffuseMtrl.a;
	// =============================================

	// Transform to homogeneous clip space
	outVS.posH = mul(float4(posL, 1.0f), gWVP);

	return outVS;
}

float4 DiffusePS(float4 c : COLOR0) : COLOR
{
	return c;
}

technique DiffuseTech
{
	pass P0
	{
		vertexShader = compile vs_2_0 DiffuseVS();
		pixelShader  = compile ps_2_0 DiffusePS();
	}
}

