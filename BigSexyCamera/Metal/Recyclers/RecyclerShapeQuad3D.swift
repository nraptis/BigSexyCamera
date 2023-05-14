//
//  RecyclerShapeQuad3D.swift
//  RebuildEarth
//
//  Created by Nicky Taylor on 2/15/23.
//

import Foundation
import Metal
import simd

class RecyclerShapeQuad3D: Recycler<RecyclerShapeQuad3D.Slice> {
    
    class Slice: RecyclerNodeConforming {
        
        var uniformsVertex = UniformsShapeVertex()
        var uniformsVertexBuffer: MTLBuffer!
        
        var uniformsFragment = UniformsShapeFragment()
        var uniformsFragmentBuffer: MTLBuffer!
        
        var positions = [Float](repeating: 0.0, count: 12)
        var positionsBuffer: MTLBuffer!
        
        required init(graphics: Graphics) {
            positionsBuffer = graphics.buffer(array: positions)
            uniformsVertexBuffer = graphics.buffer(uniform: uniformsVertex)
            uniformsFragmentBuffer = graphics.buffer(uniform: uniformsFragment)
        }
    }
    
    func drawQuad(graphics: Graphics, renderEncoder: MTLRenderCommandEncoder,
                  projection: matrix_float4x4, modelView: matrix_float4x4,
                  p1: simd_float3, p2: simd_float3, p3: simd_float3, p4: simd_float3) {
        drawQuad(graphics: graphics, renderEncoder: renderEncoder, projection: projection, modelView: modelView,
                 x1: p1.x, y1: p1.y, z1: p1.z,
                 x2: p2.x, y2: p2.y, z2: p2.z,
                 x3: p3.x, y3: p3.y, z3: p3.z,
                 x4: p4.x, y4: p4.y, z4: p4.z)
    }
    
    func drawQuad(graphics: Graphics, renderEncoder: MTLRenderCommandEncoder,
                  projection: matrix_float4x4, modelView: matrix_float4x4,
                  x1: Float, y1: Float, z1: Float,
                  x2: Float, y2: Float, z2: Float,
                  x3: Float, y3: Float, z3: Float,
                  x4: Float, y4: Float, z4: Float) {
        
        let slice = slice(graphics: graphics)
        
        slice.positions[0] = x1
        slice.positions[1] = y1
        slice.positions[2] = z1
        slice.positions[3] = x2
        slice.positions[4] = y2
        slice.positions[5] = z2
        slice.positions[6] = x3
        slice.positions[7] = y3
        slice.positions[8] = z3
        slice.positions[9] = x4
        slice.positions[10] = y4
        slice.positions[11] = z4
        
        slice.uniformsVertex.projectionMatrix = projection
        slice.uniformsVertex.modelViewMatrix = modelView
        graphics.write(buffer: slice.uniformsVertexBuffer, uniform: slice.uniformsVertex)
        
        slice.uniformsFragment.red = red
        slice.uniformsFragment.green = green
        slice.uniformsFragment.blue = blue
        slice.uniformsFragment.alpha = alpha
        graphics.write(buffer: slice.uniformsFragmentBuffer, uniform: slice.uniformsFragment)
        
        graphics.write(buffer: slice.positionsBuffer, array: slice.positions)
        
        graphics.setVertexPositionsBuffer(slice.positionsBuffer, renderEncoder: renderEncoder)
        graphics.setVertexUniformsBuffer(slice.uniformsVertexBuffer, renderEncoder: renderEncoder)
        graphics.setFragmentUniformsBuffer(slice.uniformsFragmentBuffer, renderEncoder: renderEncoder)
        
        renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4, instanceCount: 1)
    }
    
    
    func drawCube(graphics: Graphics, renderEncoder: MTLRenderCommandEncoder,
                  projection: matrix_float4x4, modelView: matrix_float4x4,
                  point: simd_float3, size: Float) {
        drawCube(graphics: graphics, renderEncoder: renderEncoder,
                 projection: projection, modelView: modelView,
                 x: point.x, y: point.y, z: point.z, size: size)
    }
    
    func drawCube(graphics: Graphics, renderEncoder: MTLRenderCommandEncoder,
                  projection: matrix_float4x4, modelView: matrix_float4x4,
                  x: Float, y: Float, z: Float,
                  size: Float) {
        
        let size_2 = size * 0.5
        
        let lX = x - size_2
        let rX = x + size_2
        
        let uY = y - size_2
        let dY = y + size_2
        
        let fz = z - size_2
        let bz = z + size_2
        
        //back
        drawQuad(graphics: graphics, renderEncoder: renderEncoder,
                 projection: projection, modelView: modelView,
                 x1: lX, y1: dY, z1: bz,
                 x2: rX, y2: dY, z2: bz,
                 x3: lX, y3: uY, z3: bz,
                 x4: rX, y4: uY, z4: bz)
        
        //left
        drawQuad(graphics: graphics, renderEncoder: renderEncoder,
                 projection: projection, modelView: modelView,
                 x1: lX, y1: uY, z1: fz,
                 x2: lX, y2: dY, z2: fz,
                 x3: lX, y3: uY, z3: bz,
                 x4: lX, y4: dY, z4: bz)
        
        //right
        drawQuad(graphics: graphics, renderEncoder: renderEncoder,
                 projection: projection, modelView: modelView,
                 x1: rX, y1: uY, z1: bz,
                 x2: rX, y2: dY, z2: bz,
                 x3: rX, y3: uY, z3: fz,
                 x4: rX, y4: dY, z4: fz)
        
        //top
        drawQuad(graphics: graphics, renderEncoder: renderEncoder,
                 projection: projection, modelView: modelView,
                 x1: lX, y1: uY, z1: bz,
                 x2: rX, y2: uY, z2: bz,
                 x3: lX, y3: uY, z3: fz,
                 x4: rX, y4: uY, z4: fz)
        
        //bottom
        drawQuad(graphics: graphics, renderEncoder: renderEncoder,
                 projection: projection, modelView: modelView,
                 x1: lX, y1: dY, z1: fz,
                 x2: rX, y2: dY, z2: fz,
                 x3: lX, y3: dY, z3: bz,
                 x4: rX, y4: dY, z4: bz)
        
        //front
        drawQuad(graphics: graphics, renderEncoder: renderEncoder,
                 projection: projection, modelView: modelView,
                 x1: lX, y1: uY, z1: fz,
                 x2: rX, y2: uY, z2: fz,
                 x3: lX, y3: dY, z3: fz,
                 x4: rX, y4: dY, z4: fz)
    }
    
    func drawLineCuboid(graphics: Graphics, renderEncoder: MTLRenderCommandEncoder,
                        projection: matrix_float4x4, modelView: matrix_float4x4,
                        x1: Float, y1: Float, z1: Float,
                        x2: Float, y2: Float, z2: Float,
                        size: Float) {
        
        var dirX = x2 - x1
        var dirY = y2 - y1
        var dirZ = z2 - z1
        
        var length = dirX * dirX + dirY * dirY + dirZ * dirZ
        
        if length < Math.epsilon { return }
        
        length = sqrtf(length)
        dirX /= length
        dirY /= length
        dirZ /= length
        
        let axis = simd_float3(dirX, dirY, dirZ)
        let reference = Math.perpendicularNormal(float3: axis)
        
        var perp1 = Math.rotateNormalized(float3: reference, radians: 0.0, axisX: axis.x, axisY: axis.y, axisZ: axis.z)
        var perp2 = Math.rotateNormalized(float3: reference, radians: Float.pi / 2.0, axisX: axis.x, axisY: axis.y, axisZ: axis.z)
        var perp3 = Math.rotateNormalized(float3: reference, radians: Float.pi, axisX: axis.x, axisY: axis.y, axisZ: axis.z)
        var perp4 = Math.rotateNormalized(float3: reference, radians: (3.0 * Float.pi) / 2.0, axisX: axis.x, axisY: axis.y, axisZ: axis.z)
        
        perp1 = simd_float3(perp1.x * size, perp1.y * size, perp1.z * size)
        perp2 = simd_float3(perp2.x * size, perp2.y * size, perp2.z * size)
        perp3 = simd_float3(perp3.x * size, perp3.y * size, perp3.z * size)
        perp4 = simd_float3(perp4.x * size, perp4.y * size, perp4.z * size)
        
        var corner_1_0 = simd_float3(0.0, 0.0, 0.0)
        var corner_1_1 = simd_float3(0.0, 0.0, 0.0)
        var corner_1_2 = simd_float3(0.0, 0.0, 0.0)
        var corner_1_3 = simd_float3(0.0, 0.0, 0.0)

        var corner_2_0 = simd_float3(0.0, 0.0, 0.0)
        var corner_2_1 = simd_float3(0.0, 0.0, 0.0)
        var corner_2_2 = simd_float3(0.0, 0.0, 0.0)
        var corner_2_3 = simd_float3(0.0, 0.0, 0.0)
        
        // // // // //
        //          //
        corner_1_0.x = x1 + perp1.x; corner_1_0.y = y1 + perp1.y; corner_1_0.z = z1 + perp1.z;
        corner_1_1.x = x1 + perp2.x; corner_1_1.y = y1 + perp2.y; corner_1_1.z = z1 + perp2.z;
        corner_1_2.x = x1 + perp3.x; corner_1_2.y = y1 + perp3.y; corner_1_2.z = z1 + perp3.z;
        corner_1_3.x = x1 + perp4.x; corner_1_3.y = y1 + perp4.y; corner_1_3.z = z1 + perp4.z;
        //          //
        // // // // //
        //          //
        corner_2_0.x = x2 + perp1.x; corner_2_0.y = y2 + perp1.y; corner_2_0.z = z2 + perp1.z;
        corner_2_1.x = x2 + perp2.x; corner_2_1.y = y2 + perp2.y; corner_2_1.z = z2 + perp2.z;
        corner_2_2.x = x2 + perp3.x; corner_2_2.y = y2 + perp3.y; corner_2_2.z = z2 + perp3.z;
        corner_2_3.x = x2 + perp4.x; corner_2_3.y = y2 + perp4.y; corner_2_3.z = z2 + perp4.z;
        //          //
        // // // // //
        
        drawQuad(graphics: graphics, renderEncoder: renderEncoder,
                 projection: projection, modelView: modelView,
                 x1: corner_1_0.x, y1: corner_1_0.y, z1: corner_1_0.z,
                 x2: corner_2_0.x, y2: corner_2_0.y, z2: corner_2_0.z,
                 x3: corner_1_1.x, y3: corner_1_1.y, z3: corner_1_1.z,
                 x4: corner_2_1.x, y4: corner_2_1.y, z4: corner_2_1.z)
        
        drawQuad(graphics: graphics, renderEncoder: renderEncoder,
                 projection: projection, modelView: modelView,
                 x1: corner_1_1.x, y1: corner_1_1.y, z1: corner_1_1.z,
                 x2: corner_2_1.x, y2: corner_2_1.y, z2: corner_2_1.z,
                 x3: corner_1_2.x, y3: corner_1_2.y, z3: corner_1_2.z,
                 x4: corner_2_2.x, y4: corner_2_2.y, z4: corner_2_2.z)
        
        drawQuad(graphics: graphics, renderEncoder: renderEncoder,
                 projection: projection, modelView: modelView,
                 x1: corner_1_2.x, y1: corner_1_2.y, z1: corner_1_2.z,
                 x2: corner_2_2.x, y2: corner_2_2.y, z2: corner_2_2.z,
                 x3: corner_1_3.x, y3: corner_1_3.y, z3: corner_1_3.z,
                 x4: corner_2_3.x, y4: corner_2_3.y, z4: corner_2_3.z)
        
         drawQuad(graphics: graphics, renderEncoder: renderEncoder,
                  projection: projection, modelView: modelView,
                  x1: corner_1_3.x, y1: corner_1_3.y, z1: corner_1_3.z,
                  x2: corner_2_3.x, y2: corner_2_3.y, z2: corner_2_3.z,
                  x3: corner_1_0.x, y3: corner_1_0.y, z3: corner_1_0.z,
                  x4: corner_2_0.x, y4: corner_2_0.y, z4: corner_2_0.z)
        
        drawQuad(graphics: graphics, renderEncoder: renderEncoder,
                 projection: projection, modelView: modelView,
                 x1: corner_1_0.x, y1: corner_1_0.y, z1: corner_1_0.z,
                 x2: corner_1_3.x, y2: corner_1_3.y, z2: corner_1_3.z,
                 x3: corner_1_1.x, y3: corner_1_1.y, z3: corner_1_1.z,
                 x4: corner_1_2.x, y4: corner_1_2.y, z4: corner_1_2.z)
        
        drawQuad(graphics: graphics, renderEncoder: renderEncoder,
                 projection: projection, modelView: modelView,
                 x1: corner_2_0.x, y1: corner_2_0.y, z1: corner_2_0.z,
                 x2: corner_2_1.x, y2: corner_2_1.y, z2: corner_2_1.z,
                 x3: corner_2_3.x, y3: corner_2_3.y, z3: corner_2_3.z,
                 x4: corner_2_2.x, y4: corner_2_2.y, z4: corner_2_2.z)
    }
    
}
