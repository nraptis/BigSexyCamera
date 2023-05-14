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
    
    lazy var cameraInputProvider: AugmentedRealityCameraInputProvider = {
        let result = AugmentedRealityCameraInputProvider(screenWidth: Int(graphics.width + 0.5),
                                            
                                                         screenHeight: Int(graphics.height + 0.5))
        result.add(observer: self)
        return result
    }()
    
    
    var textureCache: CVMetalTextureCache?
    
    
    var videoTextureDidAttemptCreate = false
    var videoTextureY: MTLTexture?
    var videoTextureCBCR: MTLTexture?
    var videoTexture: MTLTexture?
    
    var videoUniformsVertex = UniformsSpriteVertex()
    var videoUniformsVertexBuffer: MTLBuffer!
    var videoUniformsFragment = UniformsSpriteFragment()
    var videoUniformsFragmentBuffer: MTLBuffer!
    var videoPositions: [Float] = [-256.0, -256.0, 0.0,
                                     256.0, -256.0, 0.0,
                                    -256.0, 256.0, 0.0,
                                    256.0, 256.0, 0.0]
    var videoPositionsBuffer: MTLBuffer!
    var videoTextureCoords: [Float] = [0.0, 0.0,
                                        1.0, 0.0,
                                        0.0, 1.0,
                                        1.0, 1.0]
    var videoTextureCoordsBuffer: MTLBuffer!
    
    
    
    
    
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
            
            videoPositions[0] = _width_2
            videoPositions[1] = _height_2
            videoPositions[3] = width_2
            videoPositions[4] = _height_2
            videoPositions[6] = _width_2
            videoPositions[7] = height_2
            videoPositions[9] = width_2
            videoPositions[10] = height_2
            
            videoPositionsBuffer = graphics.buffer(array: videoPositions)
            videoTextureCoordsBuffer = graphics.buffer(array: videoTextureCoords)

            videoUniformsVertexBuffer = graphics.buffer(uniform: videoUniformsVertex)
            videoUniformsFragmentBuffer = graphics.buffer(uniform: videoUniformsFragment)
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
        
        if let videoTextureY = videoTextureY, let videoTextureCBCR = videoTextureCBCR, let videoTexture = videoTexture {
            
            /*
            if let pipelineStateYCBCRToRGBA = graphics.pipeline.pipelineStateYCBCRToRGBA {
                guard let cmdBuffer = graphics.engine.commandQueue.makeCommandBuffer() else { return }
                guard let computeEncoder = cmdBuffer.makeComputeCommandEncoder() else { return }
                
                computeEncoder.setComputePipelineState(graphics.pipeline.pipelineStateYCBCRToRGBA)
                computeEncoder.setTexture(videoTextureY, index: 0)
                computeEncoder.setTexture(videoTextureCBCR, index: 1)
                computeEncoder.setTexture(videoTextureCBCR, index: 2)
                let threadgroupSize = MTLSizeMake(pipelineStateYCBCRToRGBA.threadExecutionWidth,
                                                  pipelineStateYCBCRToRGBA.maxTotalThreadsPerThreadgroup / pipelineStateYCBCRToRGBA.threadExecutionWidth, 1)
                let threadgroupCount = MTLSize(width: Int(ceil(Float(videoTexture.width) / Float(threadgroupSize.width))),
                                               height: Int(ceil(Float(videoTexture.height) / Float(threadgroupSize.height))),
                                               depth: 1)
                computeEncoder.dispatchThreadgroups(threadgroupCount, threadsPerThreadgroup: threadgroupSize)
                computeEncoder.endEncoding()
            }
            */
            
            
            /*
            pony3DUniformsVertex.projectionMatrix.ortho(width: graphics.width,
                                                        height: graphics.height)
            
            var modelView = matrix_identity_float4x4
            modelView.translate(x: graphics.width * 0.5, y: graphics.height * 0.25, z: 0.0)
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
            
            graphics.setFragmentTexture(videoTexture,
                                        renderEncoder: renderEncoder)
            graphics.setFragmentUniformsBuffer(pony3DUniformsFragmentBuffer,
                                               renderEncoder: renderEncoder)
            
            
            renderEncoder.drawIndexedPrimitives(type: .triangleStrip,
                                                indexCount: pony3DIndices.count,
                                                indexType: .uint16,
                                                indexBuffer: pony3DIndexBuffer,
                                                indexBufferOffset: 0,
                                                instanceCount: 1)
            
            */
            
            
            videoUniformsVertex.projectionMatrix.ortho(width: graphics.width,
                                                        height: graphics.height)
            
            var modelView = matrix_identity_float4x4
            modelView.translate(x: graphics.width * 0.5, y: graphics.height * 0.5, z: 0.0)
            videoUniformsVertex.modelViewMatrix = modelView
            
            graphics.write(buffer: videoUniformsVertexBuffer, uniform: videoUniformsVertex)
            graphics.write(buffer: videoUniformsFragmentBuffer, uniform: videoUniformsFragment)
            
            graphics.set(pipelineState: .sprite3DYCBCRNoBlending,
                         renderEncoder: renderEncoder)
            
            graphics.set(samplerState: .linearClamp, renderEncoder: renderEncoder)
            
            graphics.setVertexPositionsBuffer(videoPositionsBuffer,
                                              renderEncoder: renderEncoder)
            graphics.setVertexTextureCoordsBuffer(videoTextureCoordsBuffer,
                                                  renderEncoder: renderEncoder)
            graphics.setFragmentTextureY(videoTextureY,
                                         renderEncoder: renderEncoder)
            graphics.setFragmentTextureCBCR(videoTextureCBCR,
                                            renderEncoder: renderEncoder)
            
            graphics.setVertexUniformsBuffer(videoUniformsVertexBuffer,
                                             renderEncoder: renderEncoder)
            graphics.setFragmentUniformsBuffer(videoUniformsFragmentBuffer,
                                               renderEncoder: renderEncoder)
            
            renderEncoder.drawPrimitives(type: .triangleStrip,
                                         vertexStart: 0,
                                         vertexCount: 4,
                                         instanceCount: 1)
            
            
        }
        
        
    }
    
    func draw2D(renderEncoder: MTLRenderCommandEncoder) {
        
        
        if let pony2DTexture = pony2DTexture {
            
            pony2DUniformsVertex.projectionMatrix.ortho(width: graphics.width,
                                                        height: graphics.height)
            
            var modelView = matrix_identity_float4x4
            modelView.translate(x: graphics.width * 0.5, y: graphics.height * 0.5, z: 0.0)
            modelView.scale(0.25)
            modelView.rotateZ(degrees: 45.0)
            
            pony2DUniformsVertex.modelViewMatrix = modelView
            
            graphics.write(buffer: pony2DUniformsVertexBuffer, uniform: pony2DUniformsVertex)
            
            pony2DUniformsFragment.green = Float.random(in: 0.5...1.0)
            pony2DUniformsFragment.alpha = 0.5
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
        
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
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
    func provider(didReceive frame: ARFrame) {
        
        print("frame:")
        
        if videoTextureDidAttemptCreate == false {
            //videoTextureDidAttemptCreate = true
            
            let planeCount = CVPixelBufferGetPlaneCount(frame.capturedImage)
            
            print("planeCount = \(planeCount)")
            
            let width = CVPixelBufferGetWidth(frame.capturedImage)
            let height = CVPixelBufferGetHeight(frame.capturedImage)
            
            if planeCount >= 2 && width > 0 && height > 0 {
                
                videoTextureY = generateMetalTexture(pixelBuffer: frame.capturedImage,
                                                     pixelFormat: .r8Unorm,
                                                     planeIndex: 0)
                videoTextureCBCR = generateMetalTexture(pixelBuffer: frame.capturedImage,
                                                        pixelFormat: .rg8Unorm,
                                                        planeIndex: 1)
                
                
                
                videoTexture = generateMetalTexture(device: graphics.device,
                                                    width: width,
                                                    height: height,
                                                    usage: [.shaderRead, .shaderWrite],
                                                    pixelFormat: .rgba8Unorm)
                
                //print("videoTextureY = \(videoTextureY)")
                //print("videoTextureCBCR = \(videoTextureCBCR)")
                
            }
        }
    }
    
    func receive(image: UIImage) {
        
    }
    
    
}
