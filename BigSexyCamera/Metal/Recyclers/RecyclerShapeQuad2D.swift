//
//  RecyclerShapeQuad2D.swift
//  RebuildEarth
//
//  Created by Nicky Taylor on 2/12/23.
//

import Foundation
import Metal
import simd

class RecyclerShapeQuad2D: Recycler<RecyclerShapeQuad2D.Slice> {
    
    class Slice: RecyclerNodeConforming {
        
        var uniformsVertex = UniformsShapeVertex()
        var uniformsVertexBuffer: MTLBuffer!
        
        var uniformsFragment = UniformsShapeFragment()
        var uniformsFragmentBuffer: MTLBuffer!
        
        var positions = [Float](repeating: 0.0, count: 8)
        var positionsBuffer: MTLBuffer!
        
        required init(graphics: Graphics) {
            positionsBuffer = graphics.buffer(array: positions)
            uniformsVertexBuffer = graphics.buffer(uniform: uniformsVertex)
            uniformsFragmentBuffer = graphics.buffer(uniform: uniformsFragment)
        }
    }
    
    func drawQuad(graphics: Graphics, renderEncoder: MTLRenderCommandEncoder,
                  projection: matrix_float4x4, modelView: matrix_float4x4,
                  p1: simd_float2, p2: simd_float2, p3: simd_float2, p4: simd_float2) {
        drawQuad(graphics: graphics, renderEncoder: renderEncoder, projection: projection, modelView: modelView,
                 x1: p1.x, y1: p1.y, x2: p2.x, y2: p2.y, x3: p3.x, y3: p3.y, x4: p4.x, y4: p4.y)
    }
    
    func drawQuad(graphics: Graphics, renderEncoder: MTLRenderCommandEncoder,
                  projection: matrix_float4x4, modelView: matrix_float4x4,
                  x1: Float, y1: Float, x2: Float, y2: Float, x3: Float, y3: Float, x4: Float, y4: Float) {
        
        let slice = slice(graphics: graphics)
        
        slice.positions[0] = x1; slice.positions[1] = y1
        slice.positions[2] = x2; slice.positions[3] = y2
        slice.positions[4] = x3; slice.positions[5] = y3
        slice.positions[6] = x4; slice.positions[7] = y4
        
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
    
    func drawLine(graphics: Graphics, renderEncoder: MTLRenderCommandEncoder,
                  projection: matrix_float4x4, modelView: matrix_float4x4,
                  x1: Float, y1: Float, x2: Float, y2: Float, thickness: Float = 1.0) {
        var dirX = x2 - x1; var dirY = y2 - y1
        var length = dirX * dirX + dirY * dirY
        if length <= Math.epsilon { return }
        let thickness = thickness * 0.5
        length = sqrtf(length)
        dirX /= length; dirY /= length
        let hold = dirX
        dirX = dirY * (-thickness)
        dirY = hold * thickness
        drawQuad(graphics: graphics, renderEncoder: renderEncoder,
                 projection: projection, modelView: modelView,
                 x1: x2 - dirX, y1: y2 - dirY,
                 x2: x2 + dirX, y2: y2 + dirY,
                 x3: x1 - dirX, y3: y1 - dirY,
                 x4: x1 + dirX, y4: y1 + dirY)
    }
    
    func drawLine(graphics: Graphics, renderEncoder: MTLRenderCommandEncoder,
                  projection: matrix_float4x4, modelView: matrix_float4x4,
                  p1: simd_float2, p2: simd_float2, thickness: Float = 1.0) {
        drawLine(graphics: graphics, renderEncoder: renderEncoder,
                 projection: projection, modelView: modelView,
                 x1: p1.x, y1: p1.y, x2: p2.x, y2: p2.y, thickness: thickness)
    }
    
    func drawRect(graphics: Graphics, renderEncoder: MTLRenderCommandEncoder,
                  projection: matrix_float4x4, modelView: matrix_float4x4,
                  x: Float, y: Float, width: Float, height: Float) {
        drawQuad(graphics: graphics, renderEncoder: renderEncoder,
                 projection: projection, modelView: modelView,
                 x1: x, y1: y, x2: x + width, y2: y, x3: x, y3: y + height, x4: x + width, y4: y + height)
    }

    func drawRect(graphics: Graphics, renderEncoder: MTLRenderCommandEncoder,
                  projection: matrix_float4x4, modelView: matrix_float4x4,
                  origin: simd_float2, size: simd_float2) {
        drawRect(graphics: graphics, renderEncoder: renderEncoder,
                 projection: projection, modelView: modelView,
                 x: origin.x, y: origin.y, width: size.x, height: size.y)
    }
    
    func drawPoint(graphics: Graphics, renderEncoder: MTLRenderCommandEncoder,
                   projection: matrix_float4x4, modelView: matrix_float4x4,
                   x: Float, y: Float, size: Float = 6.0) {
        let size_2 = (size * 0.5)
        drawRect(graphics: graphics, renderEncoder: renderEncoder,
                 projection: projection, modelView: modelView,
                 x: x - size_2, y: y - size_2, width: size, height: size)
    }

    func drawPoint(graphics: Graphics, renderEncoder: MTLRenderCommandEncoder,
                   projection: matrix_float4x4, modelView: matrix_float4x4,
                   point: simd_float2, size: Float = 6.0) {
        drawPoint(graphics: graphics, renderEncoder: renderEncoder,
                  projection: projection, modelView: modelView,
                  x: point.x, y: point.y, size: size)
    }
    
}
