// Learning material used:
//  - NOTE: I named this file BlinnPhongShading but I haven't confirmed fully whether or not this uses that shading calculation.
//  - https://www.youtube.com/watch?v=7C-mA08mp8o (original custom lighting tutorial for forward render path).
//    - NOTE that I only watched up to the additional lights section.
//  - https://github.com/rsofia/CustomLightingForwardPlus (Improvements to the original to support forward+ render path).
#ifndef CUSTOMLIGHTING_INCLUDED
#define CUSTOMLIGHTING_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

struct CustomShadingArgs
{
    float4 shadowCoord;
    float3 positionWS;
    float3 positionCS;
    float3 albedo;
    float3 normalWS;
    float3 viewDirectionWS;
    float smoothness;
    bool celShadeTest;
};

// Translate a [0, 1] smoothness value to an exponent.
float GetSmoothnessPower(float rawSmoothness)
{
    return exp2(10 * rawSmoothness + 1);
}

float3 LightingFormula(CustomShadingArgs args, Light light)
{
    float3 radiance = light.color * (light.distanceAttenuation * light.shadowAttenuation);
    
    float diffuse = saturate(dot(args.normalWS, light.direction));
    
    // Show cel shade test if checked.
    if (args.celShadeTest)
    {
        if (diffuse > .5)
        {
            radiance = light.color;
        }
        else
        {
            radiance = float3(0, 0, 0);
        }
    }
    
    float specularDot = saturate(dot(args.normalWS, normalize(light.direction + args.viewDirectionWS))); // Calculate specular.
    float specular = pow(specularDot, GetSmoothnessPower(args.smoothness));
    specular *= diffuse; // Multiply with diffuse result so that unlit diffuse sections don't have specular highlight.
    
    float3 color = args.albedo * radiance * (diffuse + specular);
    
    return color;
}

float3 BlinnPhongShading(CustomShadingArgs args)
{
    float shadowMask = 1;
    Light mainLight = GetMainLight(args.shadowCoord, args.positionWS, shadowMask);
    
    float3 color = 0;
    color += LightingFormula(args, mainLight);
    
    #ifdef _FORWARD_PLUS
        #ifdef _ADDITIONAL_LIGHTS
            // Shade additional cone and point lights. Functions int URP/ShaderLibrary/Lighting.hlsl    
            InputData inputData = (InputData)0;
            inputData.positionWS = args.positionWS;
            inputData.normalWS = args.normalWS;
            inputData.viewDirectionWS = args.viewDirectionWS;
            inputData.shadowCoord = args.shadowCoord;
    
            // Forward+ rendering culls additional lights at certain distance. Make sure to use clip position to account for this.
            float4 screenPos = float4(args.positionCS.x, (_ScaledScreenParams.y - args.positionCS.y), 0, 0);
            inputData.normalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(screenPos);
    
            uint numAdditionalLights = GetAdditionalLightsCount();
            LIGHT_LOOP_BEGIN(numAdditionalLights)
                Light light = GetAdditionalLight(lightIndex, args.positionWS, shadowMask);
                color += LightingFormula(args, light);
            LIGHT_LOOP_END
        #endif
    #endif  //end _FORWARD_PLUS
    
    return color;
}

#endif
