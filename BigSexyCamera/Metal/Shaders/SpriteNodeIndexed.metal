//
//  SpriteNodeIndexed.metal
//  RebuildEarth
//
//  Created by Nicky Taylor on 2/12/23.
//

#include <metal_stdlib>
#include <simd/simd.h>

using namespace metal;

#define SpriteNodeIndexedVertexIndexData 0
#define SpriteNodeIndexedVertexIndexUniforms 1

#define SpriteNodeIndexedFragmentIndexTexture 0
#define SpriteNodeIndexedFragmentIndexSampler 1
#define SpriteNodeIndexedFragmentIndexUniforms 2

typedef struct {
    matrix_float4x4 projectionMatrix;
    matrix_float4x4 modelViewMatrix;
} SpriteNodeIndexedVertexUniforms;

typedef struct {
    float r;
    float g;
    float b;
    float a;
} SpriteNodeIndexedFragmentUniforms;

typedef struct {
    float4 position [[position]];
    float2 textureCoord;
} SpriteNodeIndexedColorInOut;

typedef struct {
    float4 position [[position]];
    float2 textureCoord;
    float4 color;
} SpriteNodeColoredIndexedColorInOut;


typedef struct {
    packed_float2 position [[]];
    packed_float2 textureCoord [[]];
} SpriteNodeIndexedVertex2D;

typedef struct {
    packed_float3 position [[]];
    packed_float2 textureCoord [[]];
} SpriteNodeIndexedVertex3D;

typedef struct {
    packed_float2 position [[]];
    packed_float2 textureCoord [[]];
    packed_float4 color [[]];
} SpriteNodeColoredIndexedVertex2D;

typedef struct {
    packed_float3 position [[]];
    packed_float2 textureCoord [[]];
    packed_float4 color [[]];
} SpriteNodeColoredIndexedVertex3D;

vertex SpriteNodeIndexedColorInOut sprite_node_indexed_2d_vertex(constant SpriteNodeIndexedVertex2D *verts [[buffer(SpriteNodeIndexedVertexIndexData)]],
                                                                   ushort vid [[vertex_id]],
                                                                   constant SpriteNodeIndexedVertexUniforms & uniforms [[ buffer(SpriteNodeIndexedVertexIndexUniforms) ]]) {
    SpriteNodeIndexedColorInOut out;
    float4 position = float4(verts[vid].position, 0.0, 1.0);
    out.position = uniforms.projectionMatrix * uniforms.modelViewMatrix * position;
    out.textureCoord = verts[vid].textureCoord;
    return out;
}

fragment float4 sprite_node_indexed_2d_fragment(SpriteNodeIndexedColorInOut in [[stage_in]],
                                                constant SpriteNodeIndexedFragmentUniforms & uniforms [[buffer(SpriteNodeIndexedFragmentIndexUniforms)]],
                                                texture2d<half> colorMap [[ texture(SpriteNodeIndexedFragmentIndexTexture) ]],
                                                sampler colorSampler [[ sampler(SpriteNodeIndexedFragmentIndexSampler) ]]) {
    half4 colorSample = colorMap.sample(colorSampler, in.textureCoord.xy);
    float4 result = float4(colorSample.r * uniforms.r,
                           colorSample.g * uniforms.g,
                           colorSample.b * uniforms.b,
                           colorSample.a * uniforms.a);
    return result;
}


vertex SpriteNodeColoredIndexedColorInOut sprite_node_colored_indexed_2d_vertex(constant SpriteNodeColoredIndexedVertex2D *verts [[buffer(SpriteNodeIndexedVertexIndexData)]],
                                                                   ushort vid [[vertex_id]],
                                                                   constant SpriteNodeIndexedVertexUniforms & uniforms [[ buffer(SpriteNodeIndexedVertexIndexUniforms) ]]) {
    SpriteNodeColoredIndexedColorInOut out;
    float4 position = float4(verts[vid].position, 0.0, 1.0);
    out.position = uniforms.projectionMatrix * uniforms.modelViewMatrix * position;
    out.textureCoord = verts[vid].textureCoord;
    out.color = verts[vid].color;
    return out;
}

fragment float4 sprite_node_colored_indexed_2d_fragment(SpriteNodeColoredIndexedColorInOut in [[stage_in]],
                                                constant SpriteNodeIndexedFragmentUniforms & uniforms [[buffer(SpriteNodeIndexedFragmentIndexUniforms)]],
                                                texture2d<half> colorMap [[ texture(SpriteNodeIndexedFragmentIndexTexture) ]],
                                                sampler colorSampler [[ sampler(SpriteNodeIndexedFragmentIndexSampler) ]]) {
    half4 colorSample = colorMap.sample(colorSampler, in.textureCoord.xy);
    float4 result = float4(colorSample.r * uniforms.r * in.color[0],
                           colorSample.g * uniforms.g * in.color[1],
                           colorSample.b * uniforms.b * in.color[2],
                           colorSample.a * uniforms.a * in.color[3]);
    return result;
}


vertex SpriteNodeIndexedColorInOut sprite_node_indexed_3d_vertex(constant SpriteNodeIndexedVertex3D *verts [[buffer(SpriteNodeIndexedVertexIndexData)]],
                                                                   ushort vid [[vertex_id]],
                                                                   constant SpriteNodeIndexedVertexUniforms & uniforms [[ buffer(SpriteNodeIndexedVertexIndexUniforms) ]]) {
    SpriteNodeIndexedColorInOut out;
    float4 position = float4(verts[vid].position, 1.0);
    out.position = uniforms.projectionMatrix * uniforms.modelViewMatrix * position;
    out.textureCoord = verts[vid].textureCoord;
    return out;
}

fragment float4 sprite_node_indexed_3d_fragment(SpriteNodeIndexedColorInOut in [[stage_in]],
                                                constant SpriteNodeIndexedFragmentUniforms & uniforms [[buffer(SpriteNodeIndexedFragmentIndexUniforms)]],
                                                texture2d<half> colorMap [[ texture(SpriteNodeIndexedFragmentIndexTexture) ]],
                                                sampler colorSampler [[ sampler(SpriteNodeIndexedFragmentIndexSampler) ]]) {
    half4 colorSample = colorMap.sample(colorSampler, in.textureCoord.xy);
    float4 result = float4(colorSample.r * uniforms.r,
                           colorSample.g * uniforms.g,
                           colorSample.b * uniforms.b,
                           colorSample.a * uniforms.a);
    return result;
}

vertex SpriteNodeColoredIndexedColorInOut sprite_node_colored_indexed_3d_vertex(constant SpriteNodeColoredIndexedVertex3D *verts [[buffer(SpriteNodeIndexedVertexIndexData)]],
                                                                    ushort vid [[vertex_id]],
                                                                   constant SpriteNodeIndexedVertexUniforms & uniforms [[ buffer(SpriteNodeIndexedVertexIndexUniforms) ]]) {
    SpriteNodeColoredIndexedColorInOut out;
    float4 position = float4(verts[vid].position, 1.0);
    out.position = uniforms.projectionMatrix * uniforms.modelViewMatrix * position;
    out.textureCoord = verts[vid].textureCoord;
    out.color = verts[vid].color;
    return out;
}

fragment float4 sprite_node_colored_indexed_3d_fragment(SpriteNodeColoredIndexedColorInOut in [[stage_in]],
                                                constant SpriteNodeIndexedFragmentUniforms & uniforms [[buffer(SpriteNodeIndexedFragmentIndexUniforms)]],
                                                texture2d<half> colorMap [[ texture(SpriteNodeIndexedFragmentIndexTexture) ]],
                                                sampler colorSampler [[ sampler(SpriteNodeIndexedFragmentIndexSampler) ]]) {
    half4 colorSample = colorMap.sample(colorSampler, in.textureCoord.xy);
    float4 result = float4(colorSample.r * uniforms.r * in.color[0],
                           colorSample.g * uniforms.g * in.color[1],
                           colorSample.b * uniforms.b * in.color[2],
                           colorSample.a * uniforms.a * in.color[3]);
    return result;
}
