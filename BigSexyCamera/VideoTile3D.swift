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
        
        print("fitting with tex: \(textureWidth), frame: \(frameLeft)")
        
        vertexData[0].x = self.frameLeft
        vertexData[0].y = self.frameTop
        vertexData[1].x = self.frameRight
        vertexData[1].y = self.frameTop
        vertexData[2].x = self.frameLeft
        vertexData[2].y = self.frameBottom
        vertexData[3].x = self.frameRight
        vertexData[3].y = self.frameBottom
        
        guard frameWidth > 8.0 else { return }
        guard frameHeight > 8.0 else { return }
        
        var _textureWidth = Float(textureWidth)
        var _textureHeight = Float(textureHeight)
        
        guard _textureWidth > 8.0 else { return }
        guard _textureHeight > 8.0 else { return }
        
        swap(&_textureWidth, &_textureHeight)
        
        let fitScale: Float
        let fitWidth: Float
        let fitHeight: Float
        let fitMode: Bool
        if (_textureWidth / _textureHeight) < (frameWidth / frameHeight) {
            fitScale = frameWidth / _textureWidth
            fitWidth = frameWidth
            fitHeight = fitScale * _textureHeight
            fitMode = true
        } else {
            fitScale = frameHeight / _textureHeight
            fitWidth = fitScale * _textureWidth
            fitHeight = frameHeight
            fitMode = false
        }
        
        var centerX = frameLeft + frameWidth * 0.5
        var centerY = frameTop + frameHeight * 0.5
        
        let left = centerX - fitWidth * 0.5
        let right = centerX + fitWidth * 0.5
        
        let top = centerY - fitHeight * 0.5
        let bottom = centerY + fitHeight * 0.5
        
        /*
        vertexData[0].x = left
        vertexData[0].y = top
        vertexData[1].x = right
        vertexData[1].y = top
        vertexData[2].x = left
        vertexData[2].y = bottom
        vertexData[3].x = right
        vertexData[3].y = bottom
        */
        
        var startU = Float(0.0)
        var startV = Float(0.0)
        var endU = Float(1.0)
        var endV = Float(1.0)
        
        if fitMode {
            print("height \(fitHeight) vs \(frameHeight)")
            if fitHeight > frameHeight {
                
                var center = fitHeight / 2.0
                var top = center - (frameHeight * 0.5)
                var bottom = center + (frameHeight * 0.5)
                
                startV = top / fitHeight
                endV = bottom / fitHeight
                
            }
        } else {
            print("width \(fitWidth) vs \(frameWidth)")
            
            var center = fitWidth / 2.0
            var left = center - (frameWidth * 0.5)
            var right = center + (frameWidth * 0.5)
            
            startU = left / fitWidth
            endU = right / fitWidth
        }
        
        print("su: \(startU) eu: \(endU) sv: \(startV) ev: \(endV)")
        
        if false {
            vertexData[0].u = startU
            vertexData[0].v = startV
            vertexData[1].u = endU
            vertexData[1].v = startV
            vertexData[2].u = startU
            vertexData[2].v = endV
            vertexData[3].u = endU
            vertexData[3].v = endV
        } else {
            vertexData[0].u = startU
            vertexData[0].v = endV
            vertexData[1].u = startU
            vertexData[1].v = startV
            vertexData[2].u = endU
            vertexData[2].v = endV
            vertexData[3].u = endU
            vertexData[3].v = startV
        }
        //vertexData[0].
        
        // [0, 0]  [1, 0]
        // [0, 1]  [1, 1]
        
        // [0, 1], [0, 0]
        // [1, 1], [1, 0]
        /*
        
        */
        
        //swap(&textureWidth, &textureHeight)
        
        
        
        
        //var uvTopLeft = SIMD2<Float>(
        
        
        
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
