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
    private(set) var frameHeight: Float = -256.0
    
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
        self.frameLeft = x
        self.frameRight = x + width
        self.frameTop = y
        self.frameBottom = y + height
        self.frameWidth = width
        self.frameHeight = height
        
        vertexData[0].x = self.frameLeft
        vertexData[0].y = self.frameTop
        
        vertexData[1].x = self.frameRight
        vertexData[1].y = self.frameTop
        
        vertexData[2].x = self.frameLeft
        vertexData[2].y = self.frameBottom
        
        vertexData[3].x = self.frameRight
        vertexData[3].y = self.frameBottom
    }
    
    func set(texture: MTLTexture?) {
        self.texture = texture
        if let texture = texture {
            self.textureWidth = texture.width
            self.textureHeight = texture.height
        } else {
            self.textureWidth = 0
            self.textureHeight = 0
        }
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

/*
var textureCache: CVMetalTextureCache?

var lidarDepthTexture: MTLTexture?

var lidarDepth3DData: [SpriteColored3DNode] = [
    SpriteColored3DNode(x: -256.0, y: -256.0, z: 0.0, u: 0.0, v: 0.0, r: 1.0, g: 1.0, b: 1.0, a: 1.0),
    SpriteColored3DNode(x: 256.0, y: -256.0, z: 0.0, u: 1.0, v: 0.0, r: 1.0, g: 1.0, b: 1.0, a: 1.0),
    SpriteColored3DNode(x: -256.0, y: 256.0, z: 0.0, u: 0.0, v: 1.0, r: 1.0, g: 1.0, b: 1.0, a: 1.0),
    SpriteColored3DNode(x: 256.0, y: 256.0, z: 0.0, u: 1.0, v: 1.0, r: 1.0, g: 1.0, b: 1.0, a: 1.0)]
var lidarDepth3DDataBuffer: MTLBuffer!
var lidarDepth3DIndices: [UInt16] = [0, 1, 2, 3]
var lidarDepth3DIndexBuffer: MTLBuffer!
*/
