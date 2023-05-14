//
//  Sprite.metal
//  RebuildEarth
//
//  Created by Nicky Taylor on 2/12/23.
//

#include <metal_stdlib>
#include <simd/simd.h>

using namespace metal;

#define SpriteVertexIndexPosition 0
#define SpriteVertexIndexTextureCoord 1
#define SpriteVertexIndexUniforms 2

#define SpriteFragmentIndexTexture 0
#define SpriteFragmentIndexSampler 1
#define SpriteFragmentIndexUniforms 2

#define SpriteYCBCRFragmentIndexTextureY 0
#define SpriteYCBCRFragmentIndexTextureCBCR 1
#define SpriteYCBCRFragmentIndexSampler 2
#define SpriteYCBCRFragmentIndexUniforms 3

typedef struct {
    matrix_float4x4 projectionMatrix;
    matrix_float4x4 modelViewMatrix;
} SpriteVertexUniforms;

typedef struct {
    float r;
    float g;
    float b;
    float a;
} SpriteFragmentUniforms;

typedef struct {
    float2 position [[attribute(SpriteVertexIndexPosition)]];
    float2 textureCoord [[attribute(SpriteVertexIndexTextureCoord)]];
} SpriteVertex2D;

typedef struct {
    float3 position [[attribute(SpriteVertexIndexPosition)]];
    float2 textureCoord [[attribute(SpriteVertexIndexTextureCoord)]];
} SpriteVertex3D;

typedef struct {
    float4 position [[position]];
    float2 textureCoord;
} SpriteColorInOut;

vertex SpriteColorInOut sprite_2d_vertex(SpriteVertex2D verts [[stage_in]], constant SpriteVertexUniforms & uniforms [[ buffer(SpriteVertexIndexUniforms) ]]) {
    SpriteColorInOut out;
    float4 position = float4(verts.position, 0.0, 1.0);
    out.position = uniforms.projectionMatrix * uniforms.modelViewMatrix * position;
    out.textureCoord = verts.textureCoord;
    return out;
}

fragment float4 sprite_2d_fragment(SpriteColorInOut in [[stage_in]],
                                constant SpriteFragmentUniforms & uniforms [[ buffer(SpriteFragmentIndexUniforms) ]],
                                texture2d<half> colorMap [[ texture(SpriteFragmentIndexTexture) ]],
                                sampler colorSampler [[ sampler(SpriteFragmentIndexSampler) ]]) {
    half4 colorSample = colorMap.sample(colorSampler, in.textureCoord.xy);
    float4 result = float4(colorSample.r * uniforms.r,
                           colorSample.g * uniforms.g,
                           colorSample.b * uniforms.b,
                           colorSample.a * uniforms.a);
    return result;
}

fragment float4 sprite_2d_ycbcr_fragment(SpriteColorInOut in [[stage_in]],
                                         constant SpriteFragmentUniforms & uniforms [[ buffer(SpriteYCBCRFragmentIndexUniforms) ]],
                                         texture2d<float, access::sample> colorMapY [[ texture(SpriteYCBCRFragmentIndexTextureY) ]],
                                         texture2d<float, access::sample> colorMapCBCR [[ texture(SpriteYCBCRFragmentIndexTextureCBCR) ]],
                                         sampler colorSampler [[ sampler(SpriteYCBCRFragmentIndexSampler) ]]) {
    
    /*
    const half4x4 ycbcrToRGBTransform = half4x4(
                                                half4(+1.0000f, +1.0000f, +1.0000f, +0.0000f),
                                                half4(+0.0000f, -0.3441f, +1.7720f, +0.0000f),
                                                half4(+1.4020f, -0.7141f, +0.0000f, +0.0000f),
                                                half4(-0.7010f, +0.5291f, -0.8860f, +1.0000f)
    );
    */
        
        // Sample Y and CbCr textures to get the YCbCr color at the given texture coordinate.
    
    /*
    half sampleY = colorMapY.sample(colorSampler, in.textureCoord).r;
    half2 sampleCBCR = colorMapCBCR.sample(colorSampler, in.textureCoord).rg;
    
    half4 ycbcr = half4(sampleY, sampleCBCR, 1.0);
    half4 colorSample = ycbcrToRGBTransform * ycbcr;
    */
    
    constexpr sampler textureSampler(coord::pixel, address::clamp_to_edge, filter::linear);
        
    
    float y = colorMapY.sample(textureSampler, in.textureCoord).r;
    float uv = colorMapCBCR.sample(textureSampler, in.textureCoord).r;// - half2(0.5h, 0.5h);
    // Convert YUV to RGB inline.
    //half4 rgbaResult = half4(y + 1.402h * uv.y, y - 0.7141h * uv.y - 0.3441h * uv.x, y + 1.772h * uv.x, 1.0h);
    
    y += uv;
    y = max(0.0, y);
    y = min(1.0, y);
    
    //half4 rgbaResult = half4(uv[0], uv[1], 1.0, 1.0h);
    float4 rgbaResult = float4(y, y, 1.0, 1.0h);
    
    
    
    /*
    
    
    
    //    float4 ycbcr = float4(sampleY, sampleCBCR[0], sampleCBCR[1], 1.0);
        
        

    
    //half4 colorSample = colorMapY.sample(colorSampler, in.textureCoord.xy);
    
    
    
    
    */
    
    /*
    float4 result = float4(uniforms.r,
                           uniforms.g,
                           uniforms.b,
                           uniforms.a);
    */
    
    //float r = clamp(colorSample.r * uniforms.r, 0.0, 1.0);
    
    //
    
    return float4(rgbaResult);
}

vertex SpriteColorInOut sprite_3d_vertex(SpriteVertex3D verts [[stage_in]], constant SpriteVertexUniforms & uniforms [[ buffer(SpriteVertexIndexUniforms) ]]) {
    SpriteColorInOut out;
    float4 position = float4(verts.position, 1.0);
    out.position = uniforms.projectionMatrix * uniforms.modelViewMatrix * position;
    out.textureCoord = verts.textureCoord;
    return out;
}

fragment float4 sprite_3d_fragment(SpriteColorInOut in [[stage_in]],
                                constant SpriteFragmentUniforms & uniforms [[ buffer(SpriteFragmentIndexUniforms) ]],
                                texture2d<half> colorMap [[ texture(SpriteFragmentIndexTexture) ]],
                                sampler colorSampler [[ sampler(SpriteFragmentIndexSampler) ]]) {
    half4 colorSample = colorMap.sample(colorSampler, in.textureCoord.xy);
    float4 result = float4(colorSample.r * uniforms.r,
                           colorSample.g * uniforms.g,
                           colorSample.b * uniforms.b,
                           colorSample.a * uniforms.a);
    return result;
}

fragment float4 sprite_3d_ycbcr_fragment(SpriteColorInOut in [[stage_in]],
                                constant SpriteFragmentUniforms & uniforms [[ buffer(SpriteYCBCRFragmentIndexUniforms) ]],
                                texture2d<half, access::sample> colorMapY [[ texture(SpriteYCBCRFragmentIndexTextureY) ]],
                                texture2d<half, access::sample> colorMapCBCR [[ texture(SpriteYCBCRFragmentIndexTextureCBCR) ]],
                                sampler colorSampler [[ sampler(SpriteYCBCRFragmentIndexSampler) ]]) {
    
    const half4x4 ycbcrToRGBTransform = half4x4(
                                                half4(+1.0000f, +1.0000f, +1.0000f, +0.0000f),
                                                half4(+0.0000f, -0.3441f, +1.7720f, +0.0000f),
                                                half4(+1.4020f, -0.7141f, +0.0000f, +0.0000f),
                                                half4(-0.7010f, +0.5291f, -0.8860f, +1.0000f)
    );
    
    
    half y = colorMapY.sample(colorSampler, in.textureCoord).r;
    //half2 uv = colorMapCBCR.sample(colorSampler, in.textureCoord).rg;// - half2(0.5h, 0.5h);
    // Convert YUV to RGB inline.
    //half4 rgbaResult = half4(y + 1.402h * uv.y, y - 0.7141h * uv.y - 0.3441h * uv.x, y + 1.772h * uv.x, 1.0h);
    
    //half4 rgbaResult = half4(uv[0], uv[1], 1.0, 1.0h);
    half4 rgbaResult = half4(y, y, 1.0h, 1.0h);
    
    return float4(rgbaResult);
}
