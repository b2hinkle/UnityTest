#ifndef BlinnPhongShading_INCLUDED
#define BlinnPhongShading_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

struct BlinnPhongShadingArgs
{
    float4 shadowCoord;
    float3 positionWS;
    float3 albedo;
    float3 normalWS;
    float3 viewDirectionWS;
    float smoothness;
};

// Translate a [0, 1] smoothness value to an exponent.
float GetSmoothnessPower(float rawSmoothness)
{
    return exp2(10 * rawSmoothness + 1);
}

float3 LightingFormula(BlinnPhongShadingArgs args, Light light)
{
    float3 radiance = light.color * light.shadowAttenuation;
    
    float diffuse = saturate(dot(args.normalWS, light.direction));
    float specularDot = saturate(dot(args.normalWS, normalize(light.direction + args.viewDirectionWS))); // Calculate specular.
    float specular = pow(specularDot, GetSmoothnessPower(args.smoothness));
    specular *= diffuse; // Multiply with diffuse result so that unlit diffuse sections don't have specular highlight.
    
    float3 color = args.albedo * radiance * (diffuse + specular);
    
    return color;
}

float3 BlinnPhongShading(BlinnPhongShadingArgs args)
{
    float shadowMask = 1;
    Light mainLight = GetMainLight(args.shadowCoord, args.positionWS, shadowMask);
    
    float3 color = 0;
    color += LightingFormula(args, mainLight);
    
    return color;
}

#endif
