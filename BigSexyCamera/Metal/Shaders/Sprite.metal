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
