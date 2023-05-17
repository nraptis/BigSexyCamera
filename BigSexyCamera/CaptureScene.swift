//
//  CaptureScene.swift
//  BigSexyCamera
//
//  Created by Tiger Nixon on 5/16/23.
//

import Foundation
import Metal
import UIKit
import simd
import ARKit
import CoreVideo

class CaptureScene: GraphicsDelegate {
    
    var graphics: Graphics!
    var textureCache: CVMetalTextureCache?
    
    
    lazy var cameraInputProvider: CameraInputProvider = {
        let result = CameraInputProvider(screenWidth: Int(graphics.width + 0.5),
                                         screenHeight: Int(graphics.height + 0.5))
        return result
    }()
    
    lazy var tileVideoY: VideoTile3D = {
        VideoTile3D(graphics: graphics)
    }()
    
    lazy var tileVideoCBCR: VideoTile3D = {
        VideoTile3D(graphics: graphics)
    }()
    
    lazy var tileVideoLidarDepth: VideoTile3D = {
        VideoTile3D(graphics: graphics)
    }()
    
    lazy var tileVideoLidarConfidence: VideoTile3D = {
        VideoTile3D(graphics: graphics)
    }()
    
    var lidarDepthTexture: MTLTexture?
    var lidarDepthBuffer: MTLBuffer?
    
    var lidarConfidenceTexture: MTLTexture?
    var lidarConfidenceBuffer: MTLBuffer?
    
    var videoTextureY: MTLTexture?
    var videoBufferY: MTLBuffer?
    
    var videoTextureCBCR: MTLTexture?
    var videoBufferCBCR: MTLBuffer?
    
    func load() {
        
        CVMetalTextureCacheCreate(nil, nil, graphics.device, nil, &textureCache)
        
        let widthLeft = Float(Int(graphics.width * 0.5 + 0.5))
        let widthRight = Float(Int(graphics.width - Float(widthLeft) + 0.5))
        
        let heightTop = Float(Int(graphics.height * 0.5 + 0.5))
        let heightBottom = Float(Int(graphics.height - Float(heightTop) + 0.5))
        
        tileVideoY.load()
        tileVideoCBCR.load()
        tileVideoLidarDepth.load()
        tileVideoLidarConfidence.load()
        
        tileVideoLidarConfidence.uniformsFragment.red = 128.0
        
        tileVideoY.set(x: 0.0, y: 0.0, width: widthLeft, height: heightTop)
        tileVideoCBCR.set(x: widthLeft, y: 0.0, width: widthRight, height: heightTop)
        tileVideoLidarDepth.set(x: 0.0, y: heightTop, width: widthLeft, height: heightBottom)
        tileVideoLidarConfidence.set(x: widthLeft, y: heightTop, width: widthRight, height: heightBottom)
        
        cameraInputProvider.delegate = self
        cameraInputProvider.setupCaptureSession()
        cameraInputProvider.startCapturingCameraInput()
    }
    
    func update() {
        
    }
    
    func draw3D(renderEncoder: MTLRenderCommandEncoder) {
        
        tileVideoY.draw(renderEncoder: renderEncoder)
        tileVideoCBCR.draw(renderEncoder: renderEncoder)
        tileVideoLidarDepth.draw(renderEncoder: renderEncoder)
        tileVideoLidarConfidence.draw(renderEncoder: renderEncoder)
    }
    
    func draw2D(renderEncoder: MTLRenderCommandEncoder) {
        return
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
    
    func generateMetalBuffer(pixelBuffer: CVPixelBuffer?, planeIndex: Int) -> MTLBuffer? {
        guard let pixelBuffer = pixelBuffer else { return nil }
        let width = CVPixelBufferGetWidthOfPlane(pixelBuffer, planeIndex)
        let height = CVPixelBufferGetHeightOfPlane(pixelBuffer, planeIndex)
        let bytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, planeIndex)
        let size = height * bytesPerRow
        return graphics.device.makeBuffer(length: size, options: .storageModeShared)
    }
    
    func generateMetalTexture(pixelBuffer: CVPixelBuffer?, pixelFormat: MTLPixelFormat, planeIndex: Int) -> MTLTexture? {
        guard let pixelBuffer = pixelBuffer else { return nil }
        guard let textureCache = textureCache else { return nil }
        
        let width = CVPixelBufferGetWidthOfPlane(pixelBuffer, planeIndex)
        let height = CVPixelBufferGetHeightOfPlane(pixelBuffer, planeIndex)
        
        guard width > 0 else { return nil }
        guard height > 0 else { return nil }

        var cvMetalTexture: CVMetalTexture?
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
    
    func stamp(pixelBuffer: CVPixelBuffer?, dataBuffer: MTLBuffer?, texture: MTLTexture?, planeIndex: Int) {
        
        guard let pixelBuffer = pixelBuffer else { return }
        guard let dataBuffer = dataBuffer else { return }
        guard let texture = texture else { return }
        
        CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
        
        let width = CVPixelBufferGetWidthOfPlane(pixelBuffer, planeIndex)
        let height = CVPixelBufferGetHeightOfPlane(pixelBuffer, planeIndex)
        let bytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, planeIndex)

        // Get the base address of the pixel buffer
        guard let baseAddress = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, planeIndex) else {
            CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly)
            return
        }

        // Calculate the size of the pixel data
        let size = height * bytesPerRow

        // Copy the pixel data from the CVPixelBuffer to the temporary buffer
        dataBuffer.contents().copyMemory(from: baseAddress, byteCount: size)

        // Copy the pixel data from the temporary buffer to the MTLTexture
        let bufferBytes = dataBuffer.contents()
        let region = MTLRegionMake2D(0, 0, width, height)
        texture.replace(region: region, mipmapLevel: 0, withBytes: bufferBytes, bytesPerRow: bytesPerRow)
        
        // Unlock the CVPixelBuffer
        CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly)
        
        
        /*
        guard let pixelBuffer = pixelBuffer else { return }
        guard let texture = texture else { return }
        
        CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)

        // Get the base address of the CVPixelBuffer's data.
        if let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer) {
            
            texture.getBytes(pixelData,
                             bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer),
                             bytesPerImage: <#Int#>,
                             from: MTLRegionMake2D(0, 0, texture.width, texture.height),
                             mipmapLevel: 0,
                             slice: 0)
        }
        
        CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly)
        */
    }
    
}

extension CaptureScene: CameraInputProviderDelegate {
    func receive(image: UIImage) {
        
    }
    
    
}
