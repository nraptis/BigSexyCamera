//
//  RecyclerSprite2D.swift
//  RebuildEarth
//
//  Created by Nicky Taylor on 2/12/23.
//

import Foundation
import Metal
import simd

class RecyclerSprite2D: Recycler<RecyclerSprite2D.Slice> {
    
    class Slice: RecyclerNodeConforming {
        
        var uniformsVertex = UniformsSpriteVertex()
        var uniformsVertexBuffer: MTLBuffer!
        
        var uniformsFragment = UniformsSpriteFragment()
        var uniformsFragmentBuffer: MTLBuffer!
        
        var positions = [Float](repeating: 0.0, count: 8)
        var positionsBuffer: MTLBuffer!
        
        var textureCoords = [Float](repeating: 0.0, count: 8)
        var textureCoordsBuffer: MTLBuffer!
        
        required init(graphics: Graphics) {
            positionsBuffer = graphics.buffer(array: positions)
            textureCoordsBuffer = graphics.buffer(array: textureCoords)
            uniformsVertexBuffer = graphics.buffer(uniform: uniformsVertex)
            uniformsFragmentBuffer = graphics.buffer(uniform: uniformsFragment)
        }
    }
    
    func draw(graphics: Graphics, renderEncoder: MTLRenderCommandEncoder,
              projection: matrix_float4x4, modelView: matrix_float4x4,
              sprite: Sprite2D, position: simd_float2) {
        draw(graphics: graphics, renderEncoder: renderEncoder,
             projection: projection, modelView: modelView,
             sprite: sprite, x: position.x, y: position.y)
    }

    func draw(graphics: Graphics, renderEncoder: MTLRenderCommandEncoder,
              projection: matrix_float4x4, modelView: matrix_float4x4,
              sprite: Sprite2D, x: Float, y: Float) {
        
        var modelView = modelView
        modelView.translate(x: x + sprite.width * 0.5,
                            y: y + sprite.height * 0.5,
                            z: 0.0)
        
        draw(graphics: graphics, renderEncoder: renderEncoder,
             projection: projection, modelView: modelView, sprite: sprite)
    }
    
    func center(graphics: Graphics, renderEncoder: MTLRenderCommandEncoder,
                projection: matrix_float4x4, modelView: matrix_float4x4,
                sprite: Sprite2D, position: simd_float2) {
        center(graphics: graphics, renderEncoder: renderEncoder,
               projection: projection, modelView: modelView,
               sprite: sprite, x: position.x, y: position.y)
    }

    func center(graphics: Graphics, renderEncoder: MTLRenderCommandEncoder,
                projection: matrix_float4x4, modelView: matrix_float4x4,
                sprite: Sprite2D, x: Float, y: Float) {
        
        var modelView = modelView
        modelView.translate(x: x, y: y, z: 0.0)
        
        draw(graphics: graphics, renderEncoder: renderEncoder,
             projection: projection, modelView: modelView, sprite: sprite)
    }
    
    func draw(graphics: Graphics, renderEncoder: MTLRenderCommandEncoder,
                      projection: matrix_float4x4, modelView: matrix_float4x4,
                      sprite: Sprite2D) {
        
        let slice = slice(graphics: graphics)
        
        for index in 0..<8 {
            slice.positions[index] = sprite.positions[index]
            slice.textureCoords[index] = sprite.textureCoords[index]
        }
        graphics.write(buffer: slice.positionsBuffer, array: slice.positions)
        graphics.write(buffer: slice.textureCoordsBuffer, array: slice.textureCoords)
        
        slice.uniformsVertex.projectionMatrix = projection
        slice.uniformsVertex.modelViewMatrix = modelView
        graphics.write(buffer: slice.uniformsVertexBuffer, uniform: slice.uniformsVertex)
        
        slice.uniformsFragment.red = red
        slice.uniformsFragment.green = green
        slice.uniformsFragment.blue = blue
        slice.uniformsFragment.alpha = alpha
        graphics.write(buffer: slice.uniformsFragmentBuffer, uniform: slice.uniformsFragment)
        
        graphics.setVertexPositionsBuffer(slice.positionsBuffer, renderEncoder: renderEncoder)
        graphics.setVertexTextureCoordsBuffer(slice.textureCoordsBuffer, renderEncoder: renderEncoder)
        graphics.setVertexUniformsBuffer(slice.uniformsVertexBuffer, renderEncoder: renderEncoder)
        
        graphics.setFragmentUniformsBuffer(slice.uniformsFragmentBuffer, renderEncoder: renderEncoder)
        graphics.setFragmentTexture(sprite.texture, renderEncoder: renderEncoder)
        
        renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4, instanceCount: 1)
    }
}
