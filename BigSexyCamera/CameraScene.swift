//
//  CameraScene.swift
//  BigSexyCamera
//
//  Created by Tiger Nixon on 5/14/23.
//

import Foundation
import Metal
import UIKit
import simd
import ARKit
import CoreVideo

class CameraScene: GraphicsDelegate {
    
    struct SpriteColored3DNode {
        let x: Float
        let y: Float
        let z: Float
        
        let u: Float
        let v: Float
        
        let r: Float
        let g: Float
        let b: Float
        let a: Float
    }
    
    struct SpriteColored2DNode {
        let x: Float
        let y: Float
        
        let u: Float
        let v: Float
        
        let r: Float
        let g: Float
        let b: Float
        let a: Float
    }
    
    struct Sprite3DNode {
        let x: Float
        let y: Float
        let z: Float
        
        let u: Float
        let v: Float
    }
    
    struct Sprite2DNode {
        let x: Float
        let y: Float
        
        let u: Float
        let v: Float
    }
    
    
    lazy var cameraInputProvider: AugmentedRealityCameraInputProvider = {
        let result = AugmentedRealityCameraInputProvider(screenWidth: Int(graphics.width + 0.5),
                                            
                                                         screenHeight: Int(graphics.height + 0.5))
        result.add(observer: self)
        return result
    }()
    
    
    var textureCache: CVMetalTextureCache?
    
    var lidarDepthTexture: MTLTexture?
    var lidarDepth3DUniformsVertex = UniformsSpriteNodeIndexedVertex()
    var lidarDepth3DUniformsVertexBuffer: MTLBuffer!
    var lidarDepth3DUniformsFragment = UniformsSpriteNodeIndexedFragment()
    var lidarDepth3DUniformsFragmentBuffer: MTLBuffer!
    var lidarDepth3DData: [SpriteColored3DNode] = [
        SpriteColored3DNode(x: -256.0, y: -256.0, z: 0.0, u: 0.0, v: 0.0, r: 1.0, g: 1.0, b: 1.0, a: 1.0),
        SpriteColored3DNode(x: 256.0, y: -256.0, z: 0.0, u: 1.0, v: 0.0, r: 1.0, g: 1.0, b: 1.0, a: 1.0),
        SpriteColored3DNode(x: -256.0, y: 256.0, z: 0.0, u: 0.0, v: 1.0, r: 1.0, g: 1.0, b: 1.0, a: 1.0),
        SpriteColored3DNode(x: 256.0, y: 256.0, z: 0.0, u: 1.0, v: 1.0, r: 1.0, g: 1.0, b: 1.0, a: 1.0)]
    var lidarDepth3DDataBuffer: MTLBuffer!
    var lidarDepth3DIndices: [UInt16] = [0, 1, 2, 3]
    var lidarDepth3DIndexBuffer: MTLBuffer!
    
    
    
    var videoTextureDidAttemptCreate = false
    var videoTextureY: MTLTexture?
    var videoTextureCBCR: MTLTexture?
    
    var video3DUniformsVertex = UniformsSpriteVertex()
    var video3DUniformsVertexBuffer: MTLBuffer!
    var video3DUniformsFragment = UniformsSpriteFragment()
    var video3DUniformsFragmentBuffer: MTLBuffer!
    var video3DPositions: [Float] = [-256.0, -256.0, 0.0,
                                     256.0, -256.0, 0.0,
                                    -256.0, 256.0, 0.0,
                                    256.0, 256.0, 0.0]
    var video3DPositionsBuffer: MTLBuffer!
    var video3DTextureCoords: [Float] = [0.0, 0.0,
                                        1.0, 0.0,
                                        0.0, 1.0,
                                        1.0, 1.0]
    var video3DTextureCoordsBuffer: MTLBuffer!
    
    
    
    var video2DUniformsVertex = UniformsSpriteVertex()
    var video2DUniformsVertexBuffer: MTLBuffer!
    var video2DUniformsFragment = UniformsSpriteFragment()
    var video2DUniformsFragmentBuffer: MTLBuffer!
    var video2DPositions: [Float] = [-128.0, -128.0,
                                      128.0, -128.0,
                                    -128.0, 128.0,
                                      128.0, 128.0]
    var video2DPositionsBuffer: MTLBuffer!
    var video2DTextureCoords: [Float] = [0.0, 0.0,
                                        1.0, 0.0,
                                        0.0, 1.0,
                                        1.0, 1.0]
    var video2DTextureCoordsBuffer: MTLBuffer!
    
    
    
    var videoNodeColored3DUniformsVertex = UniformsSpriteNodeIndexedVertex()
    var videoNodeColored3DUniformsVertexBuffer: MTLBuffer!
    var videoNodeColored3DUniformsFragment = UniformsSpriteNodeIndexedFragment()
    var videoNodeColored3DUniformsFragmentBuffer: MTLBuffer!
    var videoNodeColored3DData: [SpriteColored3DNode] = [
        SpriteColored3DNode(x: -64.0, y: -64.0, z: 0.0, u: 0.0, v: 0.0, r: 0.5, g: 1.0, b: 0.25, a: 0.5),
        SpriteColored3DNode(x: 64.0, y: -64.0, z: 0.0, u: 1.0, v: 0.0, r: 1.0, g: 1.0, b: 1.0, a: 1.0),
        SpriteColored3DNode(x: -64.0, y: 64.0, z: 0.0, u: 0.0, v: 1.0, r: 1.0, g: 0.75, b: 1.0, a: 0.75),
        SpriteColored3DNode(x: 64.0, y: 64.0, z: 0.0, u: 1.0, v: 1.0, r: 0.0, g: 1.0, b: 1.0, a: 0.25)]
    var videoNodeColored3DDataBuffer: MTLBuffer!
    var videoNodeColored3DIndices: [UInt16] = [0, 1, 2, 3]
    var videoNodeColored3DIndexBuffer: MTLBuffer!
    
    
    
    
    
    var videoNodeColored2DUniformsVertex = UniformsSpriteNodeIndexedVertex()
    var videoNodeColored2DUniformsVertexBuffer: MTLBuffer!
    var videoNodeColored2DUniformsFragment = UniformsSpriteNodeIndexedFragment()
    var videoNodeColored2DUniformsFragmentBuffer: MTLBuffer!
    var videoNodeColored2DData: [SpriteColored2DNode] = [
        SpriteColored2DNode(x: -128.0, y: -128.0, u: 0.0, v: 0.0, r: 0.0, g: 1.0, b: 0.0, a: 0.5),
        SpriteColored2DNode(x: 128.0, y: -128.0, u: 1.0, v: 0.0, r: 0.0, g: 1.0, b: 1.0, a: 1.0),
        SpriteColored2DNode(x: -128.0, y: 128.0, u: 0.0, v: 1.0, r: 0.0, g: 0.0, b: 1.0, a: 0.25),
        SpriteColored2DNode(x: 128, y: 128.0, u: 1.0, v: 1.0, r: 1.0, g: 0.0, b: 0.25, a: 1.0)]
    var videoNodeColored2DDataBuffer: MTLBuffer!
    var videoNodeColored2DIndices: [UInt16] = [0, 1, 2, 3]
    var videoNodeColored2DIndexBuffer: MTLBuffer!
    
    
    var videoNode2DUniformsVertex = UniformsSpriteNodeIndexedVertex()
    var videoNode2DUniformsVertexBuffer: MTLBuffer!
    var videoNode2DUniformsFragment = UniformsSpriteNodeIndexedFragment()
    var videoNode2DUniformsFragmentBuffer: MTLBuffer!
    var videoNode2DData: [Sprite2DNode] = [
        Sprite2DNode(x: -128.0, y: -128.0, u: 0.0, v: 0.0),
        Sprite2DNode(x: 128.0, y: -128.0, u: 1.0, v: 0.0),
        Sprite2DNode(x: -128.0, y: 128.0, u: 0.0, v: 1.0),
        Sprite2DNode(x: 128, y: 128.0, u: 1.0, v: 1.0)]
    var videoNode2DDataBuffer: MTLBuffer!
    var videoNode2DIndices: [UInt16] = [0, 1, 2, 3]
    var videoNode2DIndexBuffer: MTLBuffer!
    
    
    
    var videoNode3DUniformsVertex = UniformsSpriteNodeIndexedVertex()
    var videoNode3DUniformsVertexBuffer: MTLBuffer!
    var videoNode3DUniformsFragment = UniformsSpriteNodeIndexedFragment()
    var videoNode3DUniformsFragmentBuffer: MTLBuffer!
    var videoNode3DData: [Sprite3DNode] = [
        Sprite3DNode(x: -64.0, y: -64.0, z: 0.0, u: 0.0, v: 0.0),
        Sprite3DNode(x: 64.0, y: -64.0, z: 0.0, u: 1.0, v: 0.0),
        Sprite3DNode(x: -64.0, y: 64.0, z: 0.0, u: 0.0, v: 1.0),
        Sprite3DNode(x: 64.0, y: 64.0, z: 0.0, u: 1.0, v: 1.0)]
    var videoNode3DDataBuffer: MTLBuffer!
    var videoNode3DIndices: [UInt16] = [0, 1, 2, 3]
    var videoNode3DIndexBuffer: MTLBuffer!
    
    
    //Sprite3DNode
    
    var pony2DTexture: MTLTexture?
    var pony2DUniformsVertex = UniformsSpriteVertex()
    var pony2DUniformsVertexBuffer: MTLBuffer!
    var pony2DUniformsFragment = UniformsSpriteFragment()
    var pony2DUniformsFragmentBuffer: MTLBuffer!
    var pony2DPositions: [Float] = [-64.0, -64.0,
                                     64.0, -64.0,
                                    -64.0, 64.0,
                                     64.0, 64.0]
    var pony2DPositionsBuffer: MTLBuffer!
    var pony2DTextureCoords: [Float] = [0.0, 0.0,
                                        1.0, 0.0,
                                        0.0, 1.0,
                                        1.0, 1.0]
    var pony2DTextureCoordsBuffer: MTLBuffer!
    
    
    
    
    
    var pony3DTexture: MTLTexture?
    var pony3DUniformsVertex = UniformsSpriteNodeIndexedVertex()
    var pony3DUniformsVertexBuffer: MTLBuffer!
    var pony3DUniformsFragment = UniformsSpriteNodeIndexedFragment()
    var pony3DUniformsFragmentBuffer: MTLBuffer!
    var pony3DData: [SpriteColored3DNode] = [
        SpriteColored3DNode(x: -64.0, y: -64.0, z: 0.0, u: 0.0, v: 0.0, r: 1.0, g: 0.5, b: 1.0, a: 0.75),
        SpriteColored3DNode(x: 64.0, y: -64.0, z: 0.0, u: 1.0, v: 0.0, r: 1.0, g: 1.0, b: 0.5, a: 0.5),
        SpriteColored3DNode(x: -64.0, y: 64.0, z: 0.0, u: 0.0, v: 1.0, r: 1.0, g: 1.0, b: 1.0, a: 0.75),
        SpriteColored3DNode(x: 64.0, y: 64.0, z: 0.0, u: 1.0, v: 1.0, r: 0.75, g: 0.75, b: 0.75, a: 1.0)]
    var pony3DDataBuffer: MTLBuffer!
    var pony3DIndices: [UInt16] = [0, 1, 2, 3]
    var pony3DIndexBuffer: MTLBuffer!
    
    var graphics: Graphics!
    
    
    func load() {
        
        CVMetalTextureCacheCreate(nil, nil, graphics.device, nil, &textureCache)
        
        if true {
            
            let width = Float(graphics.width)
            let height = Float(graphics.height)
            
            let width_2 = width * 0.5
            let height_2 = height * 0.5
            let _width_2 = -(width_2)
            let _height_2 = -(height_2)
            
            video3DPositions[0] = _width_2
            video3DPositions[1] = _height_2
            video3DPositions[3] = width_2
            video3DPositions[4] = _height_2
            video3DPositions[6] = _width_2
            video3DPositions[7] = height_2
            video3DPositions[9] = width_2
            video3DPositions[10] = height_2
            
            video3DPositionsBuffer = graphics.buffer(array: video3DPositions)
            video3DTextureCoordsBuffer = graphics.buffer(array: video3DTextureCoords)

            video3DUniformsVertexBuffer = graphics.buffer(uniform: video3DUniformsVertex)
            video3DUniformsFragmentBuffer = graphics.buffer(uniform: video3DUniformsFragment)
        }
        
        if true {
            
            let width = Float(graphics.width)
            let height = Float(graphics.height)
            
            let width_2 = width * 0.5
            let height_2 = height * 0.5
            let _width_2 = -(width_2)
            let _height_2 = -(height_2)
            
            video2DPositions[0] = _width_2
            video2DPositions[1] = _height_2
            video2DPositions[2] = width_2
            video2DPositions[3] = _height_2
            video2DPositions[4] = _width_2
            video2DPositions[5] = height_2
            video2DPositions[6] = width_2
            video2DPositions[7] = height_2
            
            video2DPositionsBuffer = graphics.buffer(array: video2DPositions)
            video2DTextureCoordsBuffer = graphics.buffer(array: video2DTextureCoords)

            video2DUniformsVertexBuffer = graphics.buffer(uniform: video2DUniformsVertex)
            video2DUniformsFragmentBuffer = graphics.buffer(uniform: video2DUniformsFragment)
        }
        
        if true {
            videoNodeColored3DUniformsVertexBuffer = graphics.buffer(uniform: videoNodeColored3DUniformsVertex)
            videoNodeColored3DUniformsFragmentBuffer = graphics.buffer(uniform: videoNodeColored3DUniformsFragment)
            
            videoNodeColored3DDataBuffer = graphics.buffer(array: videoNodeColored3DData)
            videoNodeColored3DIndexBuffer = graphics.buffer(array: videoNodeColored3DIndices)
        }
        
        if true {
            videoNode2DUniformsVertexBuffer = graphics.buffer(uniform: videoNode2DUniformsVertex)
            videoNode2DUniformsFragmentBuffer = graphics.buffer(uniform: videoNode2DUniformsFragment)
            
            videoNode2DDataBuffer = graphics.buffer(array: videoNode2DData)
            videoNode2DIndexBuffer = graphics.buffer(array: videoNode2DIndices)
        }
        
        if true {
            videoNode3DUniformsVertexBuffer = graphics.buffer(uniform: videoNode3DUniformsVertex)
            videoNode3DUniformsFragmentBuffer = graphics.buffer(uniform: videoNode3DUniformsFragment)
            
            videoNode3DDataBuffer = graphics.buffer(array: videoNode3DData)
            videoNode3DIndexBuffer = graphics.buffer(array: videoNode3DIndices)
        }
        
        
        if true {
            videoNodeColored2DUniformsVertexBuffer = graphics.buffer(uniform: videoNodeColored2DUniformsVertex)
            videoNodeColored2DUniformsFragmentBuffer = graphics.buffer(uniform: videoNodeColored2DUniformsFragment)
            
            videoNodeColored2DDataBuffer = graphics.buffer(array: videoNodeColored2DData)
            videoNodeColored2DIndexBuffer = graphics.buffer(array: videoNodeColored2DIndices)
        }
        
        if true {
            lidarDepth3DUniformsVertexBuffer = graphics.buffer(uniform: lidarDepth3DUniformsVertex)
            lidarDepth3DUniformsFragmentBuffer = graphics.buffer(uniform: lidarDepth3DUniformsFragment)
            
            lidarDepth3DDataBuffer = graphics.buffer(array: lidarDepth3DData)
            lidarDepth3DIndexBuffer = graphics.buffer(array: lidarDepth3DIndices)
        }
        
 
        
        pony2DTexture = graphics.loadTexture(fileName: "icon_pony.png")
        if let pony2DTexture = pony2DTexture {
            print("pony2DTexture size \(pony2DTexture.width) x \(pony2DTexture.height)")
            
            
            let width = Float(pony2DTexture.width)
            let height = Float(pony2DTexture.width)
            
            let width_2 = width * 0.5
            let height_2 = height * 0.5
            let _width_2 = -(width_2)
            let _height_2 = -(height_2)
            
            pony2DPositions[0] = _width_2
            pony2DPositions[1] = _height_2
            pony2DPositions[2] = width_2
            pony2DPositions[3] = _height_2
            pony2DPositions[4] = _width_2
            pony2DPositions[5] = height_2
            pony2DPositions[6] = width_2
            pony2DPositions[7] = height_2
            
            pony2DPositionsBuffer = graphics.buffer(array: pony2DPositions)
            pony2DTextureCoordsBuffer = graphics.buffer(array: pony2DTextureCoords)

            pony2DUniformsVertexBuffer = graphics.buffer(uniform: pony2DUniformsVertex)
            pony2DUniformsFragmentBuffer = graphics.buffer(uniform: pony2DUniformsFragment)
            
        }
        
        
        pony3DTexture = graphics.loadTexture(fileName: "icon_pony.png")
        if let pony3DTexture = pony3DTexture {
            print("pony3DTexture size \(pony3DTexture.width) x \(pony3DTexture.height)")
            
            
            pony3DDataBuffer = graphics.buffer(array: pony3DData)
            
            pony3DIndexBuffer = graphics.buffer(array: pony3DIndices)
            
            pony3DUniformsVertexBuffer = graphics.buffer(uniform: pony3DUniformsVertex)
            pony3DUniformsFragmentBuffer = graphics.buffer(uniform: pony3DUniformsFragment)
        }
        
        cameraInputProvider.setupCaptureSession()
        cameraInputProvider.startCapturingCameraInput()
    }
    
    func update() {
        
    }
    
    func draw3D(renderEncoder: MTLRenderCommandEncoder) {
        
        /*
        if let pony3DTexture = pony3DTexture {
            
            pony3DUniformsVertex.projectionMatrix.ortho(width: graphics.width,
                                                        height: graphics.height)
            
            var modelView = matrix_identity_float4x4
            modelView.translate(x: graphics.width * 0.5, y: graphics.height * 0.75, z: 0.0)
            modelView.scale(2.0)
            modelView.rotateZ(degrees: -25.0)
            
            pony3DUniformsVertex.modelViewMatrix = modelView
            
            graphics.write(buffer: pony3DUniformsVertexBuffer, uniform: pony3DUniformsVertex)
            
            pony3DUniformsFragment.green = Float.random(in: 0.5...1.0)
            pony3DUniformsFragment.alpha = 0.5
            graphics.write(buffer: pony3DUniformsFragmentBuffer, uniform: pony3DUniformsFragment)
            
            graphics.set(pipelineState: .spriteNodeColoredIndexed3DAlphaBlending,
                         renderEncoder: renderEncoder)
            
            graphics.set(samplerState: .linearClamp, renderEncoder: renderEncoder)
            
            
            graphics.setVertexDataBuffer(pony3DDataBuffer,
                                         renderEncoder: renderEncoder)
            graphics.setVertexUniformsBuffer(pony3DUniformsVertexBuffer,
                                             renderEncoder: renderEncoder)
            
            graphics.setFragmentTexture(pony3DTexture,
                                        renderEncoder: renderEncoder)
            graphics.setFragmentUniformsBuffer(pony3DUniformsFragmentBuffer,
                                               renderEncoder: renderEncoder)
            
            
            renderEncoder.drawIndexedPrimitives(type: .triangleStrip,
                                                indexCount: pony3DIndices.count,
                                                indexType: .uint16,
                                                indexBuffer: pony3DIndexBuffer,
                                                indexBufferOffset: 0,
                                                instanceCount: 1)
        }
        */
        
        /*
        if let videoTextureY = videoTextureY, let videoTextureCBCR = videoTextureCBCR {

            video3DUniformsVertex.projectionMatrix.ortho(width: graphics.width,
                                                        height: graphics.height)
            
            var modelView = matrix_identity_float4x4
            modelView.translate(x: graphics.width * 0.5, y: graphics.height * 0.5, z: 0.0)
            video3DUniformsVertex.modelViewMatrix = modelView
            
            graphics.write(buffer: video3DUniformsVertexBuffer, uniform: video3DUniformsVertex)
            graphics.write(buffer: video3DUniformsFragmentBuffer, uniform: video3DUniformsFragment)
            
            graphics.set(pipelineState: .sprite3DYCBCRNoBlending,
                         renderEncoder: renderEncoder)
            
            graphics.set(samplerState: .linearClamp, renderEncoder: renderEncoder)
            
            graphics.setVertexPositionsBuffer(video3DPositionsBuffer,
                                              renderEncoder: renderEncoder)
            graphics.setVertexTextureCoordsBuffer(video3DTextureCoordsBuffer,
                                                  renderEncoder: renderEncoder)
            graphics.setFragmentTextureY(videoTextureY,
                                         renderEncoder: renderEncoder)
            graphics.setFragmentTextureCBCR(videoTextureCBCR,
                                            renderEncoder: renderEncoder)
            
            graphics.setVertexUniformsBuffer(video3DUniformsVertexBuffer,
                                             renderEncoder: renderEncoder)
            graphics.setFragmentUniformsBuffer(video3DUniformsFragmentBuffer,
                                               renderEncoder: renderEncoder)
            
            renderEncoder.drawPrimitives(type: .triangleStrip,
                                         vertexStart: 0,
                                         vertexCount: 4,
                                         instanceCount: 1)
            
            
        }
        
        if let videoTextureY = videoTextureY, let videoTextureCBCR = videoTextureCBCR {
            
            videoNodeColored3DUniformsVertex.projectionMatrix.ortho(width: graphics.width,
                                                        height: graphics.height)
            
            var modelView = matrix_identity_float4x4
            modelView.translate(x: graphics.width * 0.25, y: graphics.height * 0.75, z: 0.0)
            videoNodeColored3DUniformsVertex.modelViewMatrix = modelView
            
            graphics.write(buffer: videoNodeColored3DUniformsVertexBuffer, uniform: videoNodeColored3DUniformsVertex)
            graphics.write(buffer: videoNodeColored3DUniformsFragmentBuffer, uniform: videoNodeColored3DUniformsFragment)
            
            graphics.set(pipelineState: .spriteNodeColoredIndexed3DYCBCRAlphaBlending,
                         renderEncoder: renderEncoder)
            
            graphics.set(samplerState: .linearClamp, renderEncoder: renderEncoder)
            
            graphics.setVertexDataBuffer(videoNodeColored3DDataBuffer,
                                              renderEncoder: renderEncoder)
            
            graphics.setFragmentTextureY(videoTextureY,
                                         renderEncoder: renderEncoder)
            graphics.setFragmentTextureCBCR(videoTextureCBCR,
                                            renderEncoder: renderEncoder)
            
            graphics.setVertexUniformsBuffer(videoNodeColored3DUniformsVertexBuffer,
                                             renderEncoder: renderEncoder)
            graphics.setFragmentUniformsBuffer(videoNodeColored3DUniformsFragmentBuffer,
                                               renderEncoder: renderEncoder)
            
            renderEncoder.drawIndexedPrimitives(type: .triangleStrip,
                                                indexCount: videoNodeColored3DIndices.count,
                                                indexType: .uint16,
                                                indexBuffer: videoNodeColored3DIndexBuffer,
                                                indexBufferOffset: 0,
                                                instanceCount: 1)
            
            
        }
        
        
        
        if let videoTextureY = videoTextureY, let videoTextureCBCR = videoTextureCBCR {
            
            videoNode3DUniformsVertex.projectionMatrix.ortho(width: graphics.width,
                                                        height: graphics.height)
            
            var modelView = matrix_identity_float4x4
            modelView.translate(x: graphics.width * 0.75, y: graphics.height * 0.25, z: 0.0)
            videoNode3DUniformsVertex.modelViewMatrix = modelView
            
            graphics.write(buffer: videoNode3DUniformsVertexBuffer, uniform: videoNode3DUniformsVertex)
            graphics.write(buffer: videoNode3DUniformsFragmentBuffer, uniform: videoNode3DUniformsFragment)
            
            graphics.set(pipelineState: .spriteNodeIndexed3DYCBCRAlphaBlending,
                         renderEncoder: renderEncoder)
            
            graphics.set(samplerState: .linearClamp, renderEncoder: renderEncoder)
            
            graphics.setVertexDataBuffer(videoNode3DDataBuffer,
                                              renderEncoder: renderEncoder)
            
            graphics.setFragmentTextureY(videoTextureY,
                                         renderEncoder: renderEncoder)
            graphics.setFragmentTextureCBCR(videoTextureCBCR,
                                            renderEncoder: renderEncoder)
            
            graphics.setVertexUniformsBuffer(videoNode3DUniformsVertexBuffer,
                                             renderEncoder: renderEncoder)
            graphics.setFragmentUniformsBuffer(videoNode3DUniformsFragmentBuffer,
                                               renderEncoder: renderEncoder)
            
            renderEncoder.drawIndexedPrimitives(type: .triangleStrip,
                                                indexCount: videoNode3DIndices.count,
                                                indexType: .uint16,
                                                indexBuffer: videoNode3DIndexBuffer,
                                                indexBufferOffset: 0,
                                                instanceCount: 1)
        }
        
        
        */

        
        if let lidarDepthTexture = lidarDepthTexture {
            
            lidarDepth3DUniformsVertex.projectionMatrix.ortho(width: graphics.width,
                                                        height: graphics.height)
            
            var modelView = matrix_identity_float4x4
            modelView.translate(x: graphics.width * 0.5, y: graphics.height * 0.5, z: 0.0)
            lidarDepth3DUniformsVertex.modelViewMatrix = modelView
            
            graphics.write(buffer: lidarDepth3DUniformsVertexBuffer, uniform: lidarDepth3DUniformsVertex)
            graphics.write(buffer: lidarDepth3DUniformsFragmentBuffer, uniform: lidarDepth3DUniformsFragment)
            
            graphics.set(pipelineState: .spriteNodeColoredIndexed3DAlphaBlending,
                         renderEncoder: renderEncoder)
            
            graphics.set(samplerState: .linearClamp, renderEncoder: renderEncoder)
            
            
            graphics.setVertexUniformsBuffer(lidarDepth3DUniformsVertexBuffer,
                                             renderEncoder: renderEncoder)
            graphics.setVertexDataBuffer(lidarDepth3DDataBuffer,
                                              renderEncoder: renderEncoder)
            
            graphics.setFragmentTexture(lidarDepthTexture,
                                         renderEncoder: renderEncoder)
            graphics.setFragmentUniformsBuffer(lidarDepth3DUniformsFragmentBuffer,
                                               renderEncoder: renderEncoder)
            
            renderEncoder.drawIndexedPrimitives(type: .triangleStrip,
                                                indexCount: lidarDepth3DIndices.count,
                                                indexType: .uint16,
                                                indexBuffer: lidarDepth3DIndexBuffer,
                                                indexBufferOffset: 0,
                                                instanceCount: 1)
        }
        
    }
    
    func draw2D(renderEncoder: MTLRenderCommandEncoder) {
        
        return
        
        if let pony2DTexture = pony2DTexture {
            
            pony2DUniformsVertex.projectionMatrix.ortho(width: graphics.width,
                                                        height: graphics.height)
            
            var modelView = matrix_identity_float4x4
            modelView.translate(x: graphics.width * 0.5, y: graphics.height * 0.5, z: 0.0)
            modelView.scale(0.25)
            modelView.rotateZ(degrees: 45.0)
            
            pony2DUniformsVertex.modelViewMatrix = modelView
            
            graphics.write(buffer: pony2DUniformsVertexBuffer, uniform: pony2DUniformsVertex)

            graphics.write(buffer: pony2DUniformsFragmentBuffer, uniform: pony2DUniformsFragment)
            
            graphics.set(pipelineState: .sprite2DAlphaBlending,
                         renderEncoder: renderEncoder)
            
            graphics.set(samplerState: .linearClamp, renderEncoder: renderEncoder)
            
            graphics.setFragmentTexture(pony2DTexture,
                                        renderEncoder: renderEncoder)
            graphics.setVertexPositionsBuffer(pony2DPositionsBuffer,
                                              renderEncoder: renderEncoder)
            graphics.setVertexTextureCoordsBuffer(pony2DTextureCoordsBuffer,
                                                  renderEncoder: renderEncoder)
            
            graphics.setFragmentUniformsBuffer(pony2DUniformsFragmentBuffer,
                                               renderEncoder: renderEncoder)
            graphics.setVertexUniformsBuffer(pony2DUniformsVertexBuffer,
                                             renderEncoder: renderEncoder)
            
            renderEncoder.drawPrimitives(type: .triangleStrip,
                                         vertexStart: 0,
                                         vertexCount: 4,
                                         instanceCount: 1)
            
        }
        
        
        if let videoTextureY = videoTextureY, let videoTextureCBCR = videoTextureCBCR {

            video2DUniformsVertex.projectionMatrix.ortho(width: graphics.width,
                                                        height: graphics.height)
            
            var modelView = matrix_identity_float4x4
            modelView.translate(x: graphics.width * 0.5, y: graphics.height * 0.25, z: 0.0)
            modelView.scale(0.25)
            video2DUniformsVertex.modelViewMatrix = modelView
            
            video2DUniformsFragment.red = 1.0
            video2DUniformsFragment.green = 0.0
            video2DUniformsFragment.blue = 0.5
            video2DUniformsFragment.alpha = 0.5
            
            graphics.write(buffer: video2DUniformsVertexBuffer, uniform: video2DUniformsVertex)
            graphics.write(buffer: video2DUniformsFragmentBuffer, uniform: video2DUniformsFragment)
            
            graphics.set(pipelineState: .sprite2DYCBCRAlphaBlending,
                         renderEncoder: renderEncoder)
            
            graphics.set(samplerState: .linearClamp, renderEncoder: renderEncoder)
            
            graphics.setVertexPositionsBuffer(video2DPositionsBuffer,
                                              renderEncoder: renderEncoder)
            graphics.setVertexTextureCoordsBuffer(video2DTextureCoordsBuffer,
                                                  renderEncoder: renderEncoder)
            graphics.setFragmentTextureY(videoTextureY,
                                         renderEncoder: renderEncoder)
            graphics.setFragmentTextureCBCR(videoTextureCBCR,
                                            renderEncoder: renderEncoder)
            
            graphics.setVertexUniformsBuffer(video2DUniformsVertexBuffer,
                                             renderEncoder: renderEncoder)
            graphics.setFragmentUniformsBuffer(video2DUniformsFragmentBuffer,
                                               renderEncoder: renderEncoder)
            
            renderEncoder.drawPrimitives(type: .triangleStrip,
                                         vertexStart: 0,
                                         vertexCount: 4,
                                         instanceCount: 1)
            
            
        }
        
        
        if let videoTextureY = videoTextureY, let videoTextureCBCR = videoTextureCBCR {
            
            videoNodeColored2DUniformsVertex.projectionMatrix.ortho(width: graphics.width,
                                                        height: graphics.height)
            
            var modelView = matrix_identity_float4x4
            modelView.translate(x: graphics.width * 0.75, y: graphics.height * 0.75, z: 0.0)
            videoNodeColored2DUniformsVertex.modelViewMatrix = modelView
            
            videoNodeColored2DUniformsFragment.red = 1.0
            videoNodeColored2DUniformsFragment.green = 1.0
            videoNodeColored2DUniformsFragment.blue = 1.0
            videoNodeColored2DUniformsFragment.alpha = 1.0
            
            
            graphics.write(buffer: videoNodeColored2DUniformsVertexBuffer, uniform: videoNodeColored2DUniformsVertex)
            graphics.write(buffer: videoNodeColored2DUniformsFragmentBuffer, uniform: videoNodeColored2DUniformsFragment)
            
            graphics.set(pipelineState: .spriteNodeColoredIndexed2DYCBCRAlphaBlending,
                         renderEncoder: renderEncoder)
            
            graphics.set(samplerState: .linearClamp, renderEncoder: renderEncoder)
            
            graphics.setVertexDataBuffer(videoNodeColored2DDataBuffer,
                                              renderEncoder: renderEncoder)
            
            graphics.setFragmentTextureY(videoTextureY,
                                         renderEncoder: renderEncoder)
            graphics.setFragmentTextureCBCR(videoTextureCBCR,
                                            renderEncoder: renderEncoder)
            
            graphics.setVertexUniformsBuffer(videoNodeColored2DUniformsVertexBuffer,
                                             renderEncoder: renderEncoder)
            graphics.setFragmentUniformsBuffer(videoNodeColored2DUniformsFragmentBuffer,
                                               renderEncoder: renderEncoder)
            
            renderEncoder.drawIndexedPrimitives(type: .triangleStrip,
                                                indexCount: videoNodeColored2DIndices.count,
                                                indexType: .uint16,
                                                indexBuffer: videoNodeColored2DIndexBuffer,
                                                indexBufferOffset: 0,
                                                instanceCount: 1)
            
            
        }
        
    
        
        if let videoTextureY = videoTextureY, let videoTextureCBCR = videoTextureCBCR {
            
            videoNode2DUniformsVertex.projectionMatrix.ortho(width: graphics.width,
                                                        height: graphics.height)
            
            var modelView = matrix_identity_float4x4
            modelView.translate(x: graphics.width * 0.25, y: graphics.height * 0.25, z: 0.0)
            videoNode2DUniformsVertex.modelViewMatrix = modelView
            
            videoNode2DUniformsFragment.red = 1.0
            videoNode2DUniformsFragment.green = 0.0
            videoNode2DUniformsFragment.blue = 1.0
            videoNode2DUniformsFragment.alpha = 1.0
            
            
            graphics.write(buffer: videoNode2DUniformsVertexBuffer, uniform: videoNode2DUniformsVertex)
            graphics.write(buffer: videoNode2DUniformsFragmentBuffer, uniform: videoNode2DUniformsFragment)
            
            graphics.set(pipelineState: .spriteNodeIndexed2DYCBCRAlphaBlending,
                         renderEncoder: renderEncoder)
            
            graphics.set(samplerState: .linearClamp, renderEncoder: renderEncoder)
            
            graphics.setVertexDataBuffer(videoNode2DDataBuffer,
                                              renderEncoder: renderEncoder)
            
            graphics.setFragmentTextureY(videoTextureY,
                                         renderEncoder: renderEncoder)
            graphics.setFragmentTextureCBCR(videoTextureCBCR,
                                            renderEncoder: renderEncoder)
            
            graphics.setVertexUniformsBuffer(videoNode2DUniformsVertexBuffer,
                                             renderEncoder: renderEncoder)
            graphics.setFragmentUniformsBuffer(videoNode2DUniformsFragmentBuffer,
                                               renderEncoder: renderEncoder)
            
            renderEncoder.drawIndexedPrimitives(type: .triangleStrip,
                                                indexCount: videoNode2DIndices.count,
                                                indexType: .uint16,
                                                indexBuffer: videoNode2DIndexBuffer,
                                                indexBufferOffset: 0,
                                                instanceCount: 1)
            
            
        }
        
        
    }
    
    func touchBegan(touch: UITouch, x: Float, y: Float) {

    }
    
    func touchMoved(touch: UITouch, x: Float, y: Float) {
        
        
        
    }
    
    func touchEnded(touch: UITouch, x: Float, y: Float) {

    }
    
    func generateMetalTexture(device: MTLDevice, width: Int, height: Int, usage: MTLTextureUsage, pixelFormat: MTLPixelFormat) -> MTLTexture? {
        let textureDescriptor = MTLTextureDescriptor()
        textureDescriptor.pixelFormat = pixelFormat
        textureDescriptor.width = width
        textureDescriptor.height = height
        textureDescriptor.usage = usage
        return device.makeTexture(descriptor: textureDescriptor)
    }
    
    func generateMetalTexture(pixelBuffer: CVPixelBuffer?, pixelFormat: MTLPixelFormat, planeIndex: Int) -> MTLTexture? {
        guard let pixelBuffer = pixelBuffer else { return nil }
        guard let textureCache = textureCache else { return nil }
        
        let device = graphics.device
        
        //let width = CVPixelBufferGetWidth(pixelBuffer)
        //let height = CVPixelBufferGetHeight(pixelBuffer)
        
        let width = CVPixelBufferGetWidthOfPlane(pixelBuffer, planeIndex)
        let height = CVPixelBufferGetHeightOfPlane(pixelBuffer, planeIndex)
        
        print("plane \(planeIndex) width: \(width), height: \(height)")
        
        //let pixelFormat = CVPixelBufferGetPixelFormatType(pixelBuffer)
        
        guard width > 0 else { return nil }
        guard height > 0 else { return nil }

        var cvMetalTexture: CVMetalTexture?
        
        /*
        public func CVMetalTextureCacheCreateTextureFromImage(_ allocator: CFAllocator?, _ textureCache: CVMetalTextureCache, _ sourceImage: CVImageBuffer, _ textureAttributes: CFDictionary?, _ pixelFormat: MTLPixelFormat, _ width: Int, _ height: Int, _ planeIndex: Int, _ textureOut: UnsafeMutablePointer<CVMetalTexture?>) -> CVReturn
        */
        
        _ = CVMetalTextureCacheCreateTextureFromImage(nil,
                                                      textureCache,
                                                      pixelBuffer,
                                                      nil,
                                                      pixelFormat,
                                                      width,
                                                      height,
                                                      planeIndex,
                                                      &cvMetalTexture)
        if let cvMetalTexture = cvMetalTexture {
            let result = CVMetalTextureGetTexture(cvMetalTexture)
            return result
        }
        
        return nil
    }
    
    func stamp(pixelBuffer: CVPixelBuffer?, texture: MTLTexture?) {
        
    }
    
}

extension CameraScene: AugmentedRealityCameraInputProviderReceiving {
    
    func provider(didReceive data: AugmentedRealityCameraInputProviderData) {
        
        if let pixelBuffer = data.sceneDepthPixelBuffer {
            lidarDepthTexture = generateMetalTexture(pixelBuffer: pixelBuffer,
                                                      pixelFormat: .r32Float,
                                                      planeIndex: 0)
        }
        
        if videoTextureDidAttemptCreate == false, let pixelBuffer = data.capturedImagePixelBuffer {
            //videoTextureDidAttemptCreate = true
            
            let planeCount = CVPixelBufferGetPlaneCount(pixelBuffer)
            
            //print("planeCount = \(planeCount)")
            
            let width = CVPixelBufferGetWidth(pixelBuffer)
            let height = CVPixelBufferGetHeight(pixelBuffer)
            
            if planeCount >= 2 && width > 0 && height > 0 {
                
                /*
                capturedImageTextureY = createTexture(fromPixelBuffer: pixelBuffer, pixelFormat:.r8Unorm, planeIndex:0)
                        capturedImageTextureCbCr = createTexture(fromPixelBuffer: pixelBuffer, pixelFormat:.rg8Unorm, planeIndex:1)
                */
                 
                videoTextureY = generateMetalTexture(pixelBuffer: pixelBuffer,
                                                     pixelFormat: .r8Unorm,
                                                     planeIndex: 0)
                videoTextureCBCR = generateMetalTexture(pixelBuffer: pixelBuffer,
                                                        pixelFormat: .rg8Unorm,
                                                        planeIndex: 1)
                
                //print("videoTextureY = \(videoTextureY)")
                //print("videoTextureCBCR = \(videoTextureCBCR)")
                
            }
        }
        
    }
    
    func provider(didReceive frame: ARFrame) {
        
        print("frame:")
        
        
    }
    
    func receive(image: UIImage) {
        
    }
    
    
}
