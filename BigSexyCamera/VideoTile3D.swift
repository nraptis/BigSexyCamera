//
//  VideoTile3D.swift
//  BigSexyCamera
//
//  Created by Tiger Nixon on 5/15/23.
//

import Foundation
import Metal
import simd

class VideoTile3D {
    
    struct Sprite3DNode {
        var x: Float
        var y: Float
        var z: Float
        var u: Float
        var v: Float
    }
    
    let graphics: Graphics
    
    private(set) var frameLeft: Float = -128.0
    private(set) var frameRight: Float = 128.0
    private(set) var frameTop: Float = -128.0
    private(set) var frameBottom: Float = 128.0
    private(set) var frameWidth: Float = 256.0
    private(set) var frameHeight: Float = 256.0
    
    private(set) var textureWidth = 0
    private(set) var textureHeight = 0
    
    private(set) var texture: MTLTexture?
    
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
    
    required init(graphics: Graphics) {
        self.graphics = graphics
    }
    
    func load() {
        uniformsVertexBuffer = graphics.buffer(uniform: uniformsVertex)
        uniformsFragmentBuffer = graphics.buffer(uniform: uniformsFragment)
        
        vertexDataBuffer = graphics.buffer(array: vertexData)
        indexBuffer = graphics.buffer(array: indices)
    }
    
    func set(x: Float, y: Float, width: Float, height: Float) {
        
        if frameLeft != x || frameWidth != width || frameTop != y || frameHeight != height {
            
            self.frameLeft = x
            self.frameRight = x + width
            self.frameTop = y
            self.frameBottom = y + height
            self.frameWidth = width
            self.frameHeight = height
            
            fit()
        }
    }
    
    func set(texture: MTLTexture?) {
        self.texture = texture
        if let texture = texture {
            if textureWidth != texture.width || textureHeight != texture.height {
                textureWidth = texture.width
                textureHeight = texture.height
                fit()
            }
        } else {
            if 0 != self.textureWidth || 0 != self.textureHeight {
                textureWidth = 0
                textureHeight = 0
                fit()
            }
        }
    }
    
    private func fit() {
        
        let fitResult = OversizedFrameFixer.fitLandscape(frameX: frameLeft,
                                                        frameY: frameTop,
                                                        frameWidth: frameWidth,
                                                        frameHeight: frameHeight,
                                                        textureWidth: textureWidth,
                                                        textureHeight: textureHeight)
        
        vertexData[0].x = fitResult.topLeft.x
        vertexData[0].y = fitResult.topLeft.y
        vertexData[0].u = fitResult.topLeft.u
        vertexData[0].v = fitResult.topLeft.v
        
        vertexData[1].x = fitResult.topRight.x
        vertexData[1].y = fitResult.topRight.y
        vertexData[1].u = fitResult.topRight.u
        vertexData[1].v = fitResult.topRight.v
        
        vertexData[2].x = fitResult.bottomLeft.x
        vertexData[2].y = fitResult.bottomLeft.y
        vertexData[2].u = fitResult.bottomLeft.u
        vertexData[2].v = fitResult.bottomLeft.v
        
        vertexData[3].x = fitResult.bottomRight.x
        vertexData[3].y = fitResult.bottomRight.y
        vertexData[3].u = fitResult.bottomRight.u
        vertexData[3].v = fitResult.bottomRight.v
    }
    
    func draw(renderEncoder: MTLRenderCommandEncoder) {
        
        guard let texture = texture else { return }
        
        uniformsVertex.projectionMatrix.ortho(width: graphics.width,
                                              height: graphics.height)
        uniformsVertex.modelViewMatrix = matrix_identity_float4x4
        
        graphics.write(buffer: uniformsVertexBuffer, uniform: uniformsVertex)
        graphics.write(buffer: uniformsFragmentBuffer, uniform: uniformsFragment)
        
        graphics.write(buffer: vertexDataBuffer, array: vertexData)
        
        graphics.set(pipelineState: .spriteNodeIndexed3DAlphaBlending,
                     renderEncoder: renderEncoder)
        
        graphics.set(samplerState: .linearClamp, renderEncoder: renderEncoder)
        
        graphics.setVertexUniformsBuffer(uniformsVertexBuffer,
                                         renderEncoder: renderEncoder)
        graphics.setVertexDataBuffer(vertexDataBuffer,
                                          renderEncoder: renderEncoder)
        
        graphics.setFragmentTexture(texture,
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
