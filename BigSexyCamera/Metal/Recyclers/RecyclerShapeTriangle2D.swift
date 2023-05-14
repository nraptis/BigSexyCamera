//
//  RecyclerShapeTriangle2D.swift
//  RebuildEarth
//
//  Created by Nicky Taylor on 2/12/23.
//

import Foundation
import Metal
import simd

class RecyclerShapeTriangle2D: Recycler<RecyclerShapeTriangle2D.Slice> {
    
    class Slice: RecyclerNodeConforming {
        
        var uniformsVertex = UniformsShapeVertex()
        var uniformsVertexBuffer: MTLBuffer!
        
        var uniformsFragment = UniformsShapeFragment()
        var uniformsFragmentBuffer: MTLBuffer!
        
        var positions = [Float](repeating: 0.0, count: 6)
        var positionsBuffer: MTLBuffer!
        
        required init(graphics: Graphics) {
            positionsBuffer = graphics.buffer(array: positions)
            uniformsVertexBuffer = graphics.buffer(uniform: uniformsVertex)
            uniformsFragmentBuffer = graphics.buffer(uniform: uniformsFragment)
        }
    }
    
    func drawTriangle(graphics: Graphics, renderEncoder: MTLRenderCommandEncoder,
                      projection: matrix_float4x4, modelView: matrix_float4x4,
                      p1: simd_float2, p2: simd_float2, p3: simd_float2) {
        drawTriangle(graphics: graphics, renderEncoder: renderEncoder, projection: projection, modelView: modelView,
                     x1: p1.x, y1: p1.y, x2: p2.x, y2: p2.y, x3: p3.x, y3: p3.y)
    }
    
    func drawTriangle(graphics: Graphics, renderEncoder: MTLRenderCommandEncoder,
                      projection: matrix_float4x4, modelView: matrix_float4x4,
                      x1: Float, y1: Float, x2: Float, y2: Float, x3: Float, y3: Float) {
        
        let slice = slice(graphics: graphics)
        
        slice.positions[0] = x1; slice.positions[1] = y1
        slice.positions[2] = x2; slice.positions[3] = y2
        slice.positions[4] = x3; slice.positions[5] = y3
        
        
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
        
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3, instanceCount: 1)
    }
}

