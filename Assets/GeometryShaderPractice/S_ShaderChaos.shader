// The shader name and folder as displayed in the shader picker dialogue in a material.
Shader "Custom/S_ShaderChaos"
{
    Properties
    {
        // Shader properties which are editable in the material.
        _MainTex ("Texture", 2D) = "white" {}
        _Smoothness("Smoothness", Float) = .5
        [Toggle] _CelShadeTest("CelShadeTest", Float) = 1
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" }
        LOD 100

        // Forward lit pass. The main pass which renders colors.
        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode" = "UniversalForward"}
            Cull Back

            HLSLPROGRAM

            // List required dependencies.
            #pragma prefer_hlslcc gles
            #pragma require geometry

            // List required lighting and shadow keywords.
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_SCREEN
            #pragma multi_compile _ _ADDITIONAL_LIGHTS
            #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile _ _SHADOWS_SOFT
            #pragma multi_compile _ _FORWARD_PLUS

            
            // Register functions.
            #pragma vertex Vertex
            //#pragma geometry Geometry
            #pragma fragment Fragment

            #include "ShaderChaos.hlsl"

            ENDHLSL
        }

        Pass
        {
            Name "ShadowCasting"
            Tags{ "LightMode" = "ShadowCaster" }
            Cull Back
        }
    }
}
