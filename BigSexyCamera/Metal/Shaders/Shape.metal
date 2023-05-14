//
//  Shape.metal
//  RebuildEarth
//
//  Created by Nicky Taylor on 2/10/23.
//

#include <metal_stdlib>
#include <simd/simd.h>

using namespace metal;

#define ShapeVertexIndexPosition 0
#define ShapeVertexIndexUniforms 1
#define ShapeFragmentIndexUniforms 0

typedef struct {
    matrix_float4x4 projectionMatrix;
    matrix_float4x4 modelViewMatrix;
} ShapeVertexUniforms;

typedef struct {
    float r;
    float g;
    float b;
    float a;
} ShapeFragmentUniforms;

typedef struct {
    float2 position [[attribute(ShapeVertexIndexPosition)]];
} ShapeVertex2D;

typedef struct {
    float3 position [[attribute(ShapeVertexIndexPosition)]];
} ShapeVertex3D;

typedef struct {
    float4 position [[position]];
} ShapeColorInOut;

vertex ShapeColorInOut shape_2d_vertex(ShapeVertex2D verts [[stage_in]],
                                         constant ShapeVertexUniforms & uniforms [[ buffer(ShapeVertexIndexUniforms) ]]) {
    ShapeColorInOut out;
    float4 position = float4(verts.position, 0.0, 1.0);
    out.position = uniforms.projectionMatrix * uniforms.modelViewMatrix * position;
    return out;
}

fragment float4 shape_2d_fragment(ShapeColorInOut in [[stage_in]],
                               constant ShapeFragmentUniforms & uniforms [[ buffer(ShapeFragmentIndexUniforms) ]]) {
    float4 result = float4(uniforms.r, uniforms.g, uniforms.b, uniforms.a);
    return result;
}

vertex ShapeColorInOut shape_3d_vertex(ShapeVertex3D verts [[stage_in]],
                                       constant ShapeVertexUniforms & uniforms [[ buffer(ShapeVertexIndexUniforms) ]]) {
    ShapeColorInOut out;
    float4 position = float4(verts.position, 1.0);
    out.position = uniforms.projectionMatrix * uniforms.modelViewMatrix * position;
    return out;
}

fragment float4 shape_3d_fragment(ShapeColorInOut in [[stage_in]],
                                  constant ShapeFragmentUniforms & uniforms [[ buffer(ShapeFragmentIndexUniforms) ]]) {
    float4 result = float4(uniforms.r, uniforms.g, uniforms.b, uniforms.a);
    return result;
}
