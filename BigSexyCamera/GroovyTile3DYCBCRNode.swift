//
//  GroovyTile3DYCBCRTile.swift
//  BigSexyCamera
//
//  Created by Tiger Nixon on 5/18/23.
//

import Foundation
import Metal
import simd

class GroovyTile3DYCBCRNode {
    
    struct Sprite3DNode {
        var x: Float
        var y: Float
        var z: Float
        var u: Float
        var v: Float
    }
    
    let graphics: Graphics
    let gridX: Int
    let gridY: Int
    
    private(set) var centerX: Float = 0.0
    private(set) var centerY: Float = 0.0
    
    private(set) var width: Float = 256.0
    private(set) var height: Float = 256.0
    
    private(set) var x1: Float = -128.0
    private(set) var x2: Float = 128.0
    private(set) var y1: Float = -128.0
    private(set) var y2: Float = 128.0
    
    private(set) var topLeftU: Float = 0.0
    private(set) var topLeftV: Float = 0.0
    private(set) var topRightU: Float = 1.0
    private(set) var topRightV: Float = 0.0
    private(set) var bottomLeftU: Float = 0.0
    private(set) var bottomLeftV: Float = 1.0
    private(set) var bottomRightU: Float = 1.0
    private(set) var bottomRightV: Float = 1.0
    
    private(set) var textureWidth = 0
    private(set) var textureHeight = 0
    
    private(set) var textureY: MTLTexture?
    private(set) var textureCBCR: MTLTexture?
    
    var uniformsVertex = UniformsSpriteNodeIndexedVertex()
    private(set) var uniformsVertexBuffer: MTLBuffer!
    var uniformsFragment = UniformsSpriteNodeIndexedFragment()
    private(set) var uniformsFragmentBuffer: MTLBuffer!
    
    var vertexData: [Sprite3DNode] = [
        Sprite3DNode(x: -256.0, y: -256.0, z: 0.0, u: 0.0, v: 0.0),
        Sprite3DNode(x: 256.0, y: -256.0, z: 0.0, u: 1.0, v: 0.0),
        Sprite3DNode(x: -256.0, y: 256.0, z: 0.0, u: 0.0, v: 1.0),
        Sprite3DNode(x: 256.0, y: 256.0, z: 0.0, u: 1.0, v: 1.0)]
    var vertexDataBuffer: MTLBuffer!
    
    var indices: [UInt16] = [0, 1, 2, 3]
    var indexBuffer: MTLBuffer!
    
    required init(graphics: Graphics, gridX: Int, gridY: Int) {
        self.graphics = graphics
        self.gridX = gridX
        self.gridY = gridY
    }
    
    func load() {
        uniformsVertexBuffer = graphics.buffer(uniform: uniformsVertex)
        uniformsFragmentBuffer = graphics.buffer(uniform: uniformsFragment)
        
        vertexDataBuffer = graphics.buffer(array: vertexData)
        indexBuffer = graphics.buffer(array: indices)
    }
    
    func set(centerX: Float, centerY: Float, width: Float, height: Float) {
        
        let width2 = width * 0.5
        let height2 = height * 0.5
        
        self.centerX = centerX
        self.centerY = centerY
        
        self.width = width
        self.height = height
        
        x1 = -width2
        x2 = x1 + width
        y1 = -height2
        y2 = y1 + height

        vertexData[0].x = x1
        vertexData[0].y = y1
        
        vertexData[1].x = x2
        vertexData[1].y = y1
        
        vertexData[2].x = x1
        vertexData[2].y = y2
        
        vertexData[3].x = x2
        vertexData[3].y = y2
    }
    
    func set(topLeftU: Float, topLeftV: Float, topRightU: Float, topRightV: Float,
             bottomLeftU: Float, bottomLeftV: Float, bottomRightU: Float, bottomRightV: Float) {
        self.topLeftU = topLeftU
        self.topLeftV = topLeftV
        
        self.topRightU = topRightU
        self.topRightV = topRightV
        
        self.bottomLeftU = bottomLeftU
        self.bottomLeftV = bottomLeftV
        
        self.bottomRightU = bottomRightU
        self.bottomRightV = bottomRightV

        vertexData[0].u = topLeftU
        vertexData[0].v = topLeftV
        
        vertexData[1].u = topRightU
        vertexData[1].v = topRightV
        
        vertexData[2].u = bottomLeftU
        vertexData[2].v = bottomLeftV
        
        vertexData[3].u = bottomRightU
        vertexData[3].v = bottomRightV
    }
    
    func set(textureY: MTLTexture?, textureCBCR: MTLTexture?) {
        self.textureY = textureY
        self.textureCBCR = textureCBCR
    }
    
    func draw(renderEncoder: MTLRenderCommandEncoder, projection: matrix_float4x4) {
        
        guard let textureY = textureY else { return }
        guard let textureCBCR = textureCBCR else { return }
        
        
        //runiformsFragment.alpha = 0.5
        uniformsVertex.projectionMatrix = projection
        
        
        var modelView = matrix_identity_float4x4
        
        modelView.translate(x: centerX, y: centerY, z: 0.0)
        modelView.scale(0.9)
        
        uniformsVertex.modelViewMatrix = modelView
        
        graphics.write(buffer: uniformsVertexBuffer, uniform: uniformsVertex)
        graphics.write(buffer: uniformsFragmentBuffer, uniform: uniformsFragment)
        
        graphics.write(buffer: vertexDataBuffer, array: vertexData)
        
        graphics.set(pipelineState: .spriteNodeIndexed3DYCBCRAlphaBlending,
                     renderEncoder: renderEncoder)
        
        graphics.set(samplerState: .linearClamp, renderEncoder: renderEncoder)
        
        graphics.setVertexUniformsBuffer(uniformsVertexBuffer,
                                         renderEncoder: renderEncoder)
        graphics.setVertexDataBuffer(vertexDataBuffer,
                                          renderEncoder: renderEncoder)
        
        graphics.setFragmentTextureY(textureY,
                                     renderEncoder: renderEncoder)
        graphics.setFragmentTextureCBCR(textureCBCR,
                                        renderEncoder: renderEncoder)
        
        graphics.setFragmentUniformsBuffer(uniformsFragmentBuffer,
                                           renderEncoder: renderEncoder)
        
        renderEncoder.drawIndexedPrimitives(type: .triangleStrip,
                                            indexCount: indices.count,
                                            indexType: .uint16,
                                            indexBuffer: indexBuffer,
                                            indexBufferOffset: 0,
                                            instanceCount: 1)
        
    }
    
}
