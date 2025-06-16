// Learning material for this shader https://www.youtube.com/watch?v=7C-mA08mp8o
// The shader name and folder as displayed in the shader picker dialogue in a material.
Shader "Custom/S_MeshChaos"
{
    Properties
    {
        // Shader properties which are editable in the material.
        _MainTex ("Texture", 2D) = "white" {}
        _Smoothness("Smoothness", Float) = .5
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
            #pragma multi_compile _ _ADDITIONAL_LIGHTS
            #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile _ _SHADOWS_SOFT
            
            // Register functions.
            #pragma vertex Vertex
            //#pragma geometry geo
            #pragma fragment Fragment

            #include "S_MeshChaos.hlsl"

            ENDHLSL
        }
    }
}
