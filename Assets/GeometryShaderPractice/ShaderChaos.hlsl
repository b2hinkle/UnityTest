// Make sure this file is not included twice.
#ifndef SHADERCHAOS_INCLUDED
#define SHADERCHAOS_INCLUDED

// Include helper functions and macros (e.g. TEXTURE2D, VertexPositionInputs).
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "CustomLighting.hlsl"

// This structure is created by the renderer and passed to the Vertex function.
// It holds data stored on the model, per vertex.
struct Attributes
{
    float4 positionOS : POSITION;  // Position in object space.
    float3 normalOS   : NORMAL;    // Normal in object space.
    float4 tangentOS  : TANGENT;   // Tangent in object space (plut bitangent sign).
    float2 uv         : TEXCOORD0; // UVs.
    
    // Other common semantics include COLOR.
};

// This structure is generated by the vertex function and passed to the fragment function.
struct VertexOutput
{
    float3 positionWS : TEXCOORD0;   // Position in world space.
    float2 uv         : TEXCOORD1;   // UVs.
    float3 normalWS   : TEXCOORD2;   // Normal in world space.
    
    float4 positionCS : SV_POSITION; // Position in clip space.
};

// Declare variables coresponding to the shaderlab properties.
// This is so that our shader code can access these properties.
// Make sure that the names match the properties in the shaderlab file (the .shader), otherwise, they won't get their values.

// Texture properties are special, they get 3 variables generated for them (which we've accounted for below).
TEXTURE2D(_MainTex);
SAMPLER(sampler_MainTex);
float4 _MainTex_ST; // _ST suffix in Unity shaders is shorthand for Scale and Translation.

float _Smoothness;
bool _CelShadeTest;

VertexOutput Vertex(Attributes input)
{
    // Initialize an output struct.
    VertexOutput output = (VertexOutput)0;
    
    // Use this URP function to convert position to world space.
    VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
    output.positionWS = vertexInput.positionWS;
    output.positionCS = vertexInput.positionCS;
    
    // Use this URP function to convert normal to world space.
    VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);
    output.normalWS = normalInput.normalWS;
    
    // TRANSFORM_TEX is a macro which scales and offsets the UVs based on the _MainTex_ST variable. The 2nd argument of the macro will expand to append the expected _ST suffex.
    output.uv = TRANSFORM_TEX(input.uv, _MainTex);
    
    return output;
}

//[maxvertexcount(21)]
//void Geometry(BuiltInTriangleIntersectionAttributes VertexOutput inputs[3], inout TriangleStream<GeometryOutput> outputStream)
//{
//    
//}

// The SV_Target semantic tells the compiler that this function outputs the pixel color.
float4 Fragment(VertexOutput input) : SV_Target
{    
    // Read the main texture.
    float3 albedo = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv).rgb;
    
    CustomShadingArgs args;
    args.albedo = albedo;
    args.normalWS = input.normalWS;
    args.viewDirectionWS = GetWorldSpaceViewDir(input.positionWS);
    args.smoothness = _Smoothness;
    args.positionWS = input.positionWS;
    args.positionCS = input.positionCS;
    args.celShadeTest = _CelShadeTest;
    
    // Calculate the main light shadow coord.
    // There are two types depending on if cascades are enabled.
    #if SHADOWS_SCREEN
        args.shadowCoord = ComputeScreenPos(input.positionCS);
    #else
        args.shadowCoord = TransformWorldToShadowCoord(input.positionWS);
    #endif

    return float4(BlinnPhongShading(args), 1);
}

#endif
