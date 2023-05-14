//
//  ShapeNodeIndexed.metal
//  RebuildEarth
//
//  Created by Nicky Taylor on 2/12/23.
//

#include <metal_stdlib>
#include <simd/simd.h>

using namespace metal;

#define ShapeNodeIndexedVertexIndexData 0
#define ShapeNodeIndexedVertexIndexUniforms 1

#define ShapeNodeIndexedFragmentIndexUniforms 0

typedef struct {
    matrix_float4x4 projectionMatrix;
    matrix_float4x4 modelViewMatrix;
} ShapeNodeIndexedVertexUniforms;

typedef struct {
    float r;
    float g;
    float b;
    float a;
} ShapeNodeIndexedFragmentUniforms;

typedef struct {
    float4 position [[position]];
} ShapeNodeIndexedColorInOut;

typedef struct {
    float4 position [[position]];
    float4 color;
} ShapeNodeColoredIndexedColorInOut;

typedef struct {
    packed_float2 position [[]];
} ShapeNodeIndexedVertex2D;

typedef struct {
    packed_float3 position [[]];
} ShapeNodeIndexedVertex3D;

typedef struct {
    packed_float2 position [[]];
    packed_float4 color [[]];
} ShapeNodeColoredIndexedVertex2D;

typedef struct {
    packed_float3 position [[]];
    packed_float4 color [[]];
} ShapeNodeColoredIndexedVertex3D;

vertex ShapeNodeIndexedColorInOut shape_node_indexed_2d_vertex(constant ShapeNodeIndexedVertex2D *verts [[buffer(ShapeNodeIndexedVertexIndexData)]],
                                                                   ushort vid [[vertex_id]],
                                                                   constant ShapeNodeIndexedVertexUniforms & uniforms [[ buffer(ShapeNodeIndexedVertexIndexUniforms) ]]) {
    ShapeNodeIndexedColorInOut out;
    float4 position = float4(verts[vid].position, 0.0, 1.0);
    out.position = uniforms.projectionMatrix * uniforms.modelViewMatrix * position;
    return out;
}

fragment float4 shape_node_indexed_2d_fragment(ShapeNodeIndexedColorInOut in [[stage_in]],
                                                constant ShapeNodeIndexedFragmentUniforms & uniforms [[buffer(ShapeNodeIndexedFragmentIndexUniforms)]]) {
    float4 result = float4(uniforms.r,
                           uniforms.g,
                           uniforms.b,
                           uniforms.a);
    return result;
}


vertex ShapeNodeColoredIndexedColorInOut shape_node_colored_indexed_2d_vertex(constant ShapeNodeColoredIndexedVertex2D *verts [[buffer(ShapeNodeIndexedVertexIndexData)]],
                                                                   ushort vid [[vertex_id]],
                                                                   constant ShapeNodeIndexedVertexUniforms & uniforms [[ buffer(ShapeNodeIndexedVertexIndexUniforms) ]]) {
    ShapeNodeColoredIndexedColorInOut out;
    float4 position = float4(verts[vid].position, 0.0, 1.0);
    out.position = uniforms.projectionMatrix * uniforms.modelViewMatrix * position;
    out.color = verts[vid].color;
    return out;
}

fragment float4 shape_node_colored_indexed_2d_fragment(ShapeNodeColoredIndexedColorInOut in [[stage_in]],
                                                constant ShapeNodeIndexedFragmentUniforms & uniforms [[buffer(ShapeNodeIndexedFragmentIndexUniforms)]]) {
    float4 result = float4(uniforms.r * in.color[0],
                           uniforms.g * in.color[1],
                           uniforms.b * in.color[2],
                           uniforms.a * in.color[3]);
    return result;
}

vertex ShapeNodeIndexedColorInOut shape_node_indexed_3d_vertex(constant ShapeNodeIndexedVertex3D *verts [[buffer(ShapeNodeIndexedVertexIndexData)]],
                                                                   ushort vid [[vertex_id]],
                                                                   constant ShapeNodeIndexedVertexUniforms & uniforms [[ buffer(ShapeNodeIndexedVertexIndexUniforms) ]]) {
    ShapeNodeIndexedColorInOut out;
    float4 position = float4(verts[vid].position, 1.0);
    out.position = uniforms.projectionMatrix * uniforms.modelViewMatrix * position;
    return out;
}

fragment float4 shape_node_indexed_3d_fragment(ShapeNodeIndexedColorInOut in [[stage_in]],
                                                constant ShapeNodeIndexedFragmentUniforms & uniforms [[buffer(ShapeNodeIndexedFragmentIndexUniforms)]]) {
    float4 result = float4(uniforms.r,
                           uniforms.g,
                           uniforms.b,
                           uniforms.a);
    return result;
}

vertex ShapeNodeColoredIndexedColorInOut shape_node_colored_indexed_3d_vertex(constant ShapeNodeColoredIndexedVertex3D *verts [[buffer(ShapeNodeIndexedVertexIndexData)]],
                                                                   ushort vid [[vertex_id]],
                                                                   constant ShapeNodeIndexedVertexUniforms & uniforms [[ buffer(ShapeNodeIndexedVertexIndexUniforms) ]]) {
    ShapeNodeColoredIndexedColorInOut out;
    float4 position = float4(verts[vid].position, 1.0);
    out.position = uniforms.projectionMatrix * uniforms.modelViewMatrix * position;
    out.color = verts[vid].color;
    return out;
}

fragment float4 shape_node_colored_indexed_3d_fragment(ShapeNodeColoredIndexedColorInOut in [[stage_in]],
                                                constant ShapeNodeIndexedFragmentUniforms & uniforms [[buffer(ShapeNodeIndexedFragmentIndexUniforms)]]) {
    float4 result = float4(uniforms.r * in.color[0],
                           uniforms.g * in.color[1],
                           uniforms.b * in.color[2],
                           uniforms.a * in.color[3]);
    return result;
}
