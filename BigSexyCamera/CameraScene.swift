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
import Accelerate

class CameraScene: GraphicsDelegate {
    
    var graphics: Graphics!
    var textureCache: CVMetalTextureCache?
    
    
    var inputProviderDataCurrentInUse = false
    var inputProviderDataNext: AugmentedRealityCameraInputProviderData?
    
    
    lazy var cameraInputProvider: AugmentedRealityCameraInputProvider = {
        let result = AugmentedRealityCameraInputProvider(screenWidth: Int(graphics.width + 0.5),
                                            
                                                         screenHeight: Int(graphics.height + 0.5))
        result.add(observer: self)
        return result
    }()
    
    
    
    lazy var tileVideo: VideoTile3DYCBCR = {
        VideoTile3DYCBCR(graphics: graphics)
    }()
    
    lazy var tileGroovy: GroovyTile3DYCBCR = {
        GroovyTile3DYCBCR(graphics: graphics)
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
    //var lidarDepthBuffer: MTLBuffer?
    
    var lidarConfidenceTexture: MTLTexture?
    //var lidarConfidenceBuffer: MTLBuffer?
    
    var videoTextureY: MTLTexture?
    //var videoBufferY: MTLBuffer?
    
    var videoTextureCBCR: MTLTexture?
    //var videoBufferCBCR: MTLBuffer?
    
    func load() {
        
        CVMetalTextureCacheCreate(nil, nil, graphics.device, nil, &textureCache)
        
        let widthLeft = Float(Int(graphics.width * 0.5 + 0.5))
        let widthRight = Float(Int(graphics.width - Float(widthLeft) + 0.5))
        
        let heightTop = Float(Int(graphics.height * 0.5 + 0.5))
        let heightBottom = Float(Int(graphics.height - Float(heightTop) + 0.5))
        
        tileVideo.load()
        tileGroovy.load()
        tileVideoY.load()
        tileVideoCBCR.load()
        tileVideoLidarDepth.load()
        tileVideoLidarConfidence.load()
        
        
        tileVideoLidarConfidence.uniformsFragment.red = 128.0
        
        tileVideoY.set(x: 0.0, y: 0.0, width: widthLeft, height: heightTop)
        tileVideoCBCR.set(x: widthLeft, y: 0.0, width: widthRight, height: heightTop)
        tileVideoLidarDepth.set(x: 0.0, y: heightTop, width: widthLeft, height: heightBottom)
        tileVideoLidarConfidence.set(x: widthLeft, y: heightTop, width: widthRight, height: heightBottom)
        
        tileVideo.set(x: 0.0, y: 0.0, width: graphics.width, height: graphics.height)
        tileGroovy.set(x: -(graphics.width * 0.5),
                       y: -(graphics.height * 0.5),
                       width: graphics.width,
                       height: graphics.height)
        
        cameraInputProvider.setupCaptureSession()
        cameraInputProvider.startCapturingCameraInput()
    }
    
    func update() {
        
    }
    
    func draw3D(renderEncoder: MTLRenderCommandEncoder) {
        
        //heavy()
        
        //tileVideoY.draw(renderEncoder: renderEncoder)
        //tileVideoCBCR.draw(renderEncoder: renderEncoder)
        //tileVideoLidarDepth.draw(renderEncoder: renderEncoder)
        //tileVideoLidarConfidence.draw(renderEncoder: renderEncoder)
        
        //tileVideo.draw(renderEncoder: renderEncoder)
        tileGroovy.draw(renderEncoder: renderEncoder)
        
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
    
    /*
    func convertPixelBufferToUInt8Array(pixelBuffer: CVPixelBuffer) -> [[UInt8]]? {
        CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)

        guard let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer) else {
            return nil
        }

        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
        let channels = 4 // Assuming RGBA pixel format

        let buffer = baseAddress.bindMemory(to: UInt8.self, capacity: width * height * channels)
        defer { buffer.deallocate() }

        var pixelBufferArray = [[UInt8]](repeating: [UInt8](repeating: 0, count: channels), count: height)

        for y in 0..<height {
            for x in 0..<width {
                let offset = (y * bytesPerRow) + (x * channels)
                let pixelData = buffer[offset..<offset+channels]
                pixelBufferArray[y][x] = Array(pixelData)
            }
        }

        CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly)

        return pixelBufferArray
    }
    */
    
    /*
    func convertPixelBufferToUInt8Array(pixelBuffer: CVPixelBuffer) -> [[UInt8]]? {
        CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)

        guard let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer) else {
            return nil
        }

        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
        let channels = 4 // Assuming RGBA pixel format

        var pixelBufferArray = [[UInt8]](repeating: [UInt8](repeating: 0, count: channels), count: height)

        for y in 0..<height {
            let rowData = baseAddress + y * bytesPerRow
            for x in 0..<width {
                let offset = x * channels
                let r = rowData[offset]
                let g = rowData[offset + 1]
                let b = rowData[offset + 2]
                let a = rowData[offset + 3]
                pixelBufferArray[y][x] = [r, g, b, a]
            }
        }

        CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly)

        return pixelBufferArray
    }
    */
    
    /*
    var _isSpool = false
    func spool() {
        
        if _isSpool {
            print("already spool...")
            return
        }
        
        _isSpool = true
        DispatchQueue.global(qos: .default).async {
            
            self.graphics.engine.semaphore.wait()
            
            self.heavy()

            self.graphics.engine.semaphore.signal()
            
            DispatchQueue.main.sync {
                self._isSpool = false
            }
        }
        
    }
    */
    
    func heavy() {
        
        guard let data = inputProviderDataNext else { return }
        
        /*
        if Int.random(in: 0...10) == 5 {
            Thread.sleep(forTimeInterval: 0.1)
        }
        */
        
        if let pixelBuffer = data.sceneDepthPixelBuffer {
            lidarDepthTexture = generateMetalTexture(pixelBuffer: pixelBuffer,
                                                      pixelFormat: .r32Float,
                                                     planeIndex: 0)
            tileVideoLidarDepth.set(texture: lidarDepthTexture)
        }
        
        if let pixelBuffer = data.sceneDepthConfidencePixelBuffer {
            
            lidarConfidenceTexture = generateMetalTexture(pixelBuffer: pixelBuffer,
                                                          pixelFormat: .r8Unorm,
                                                          planeIndex: 0)
            
            tileVideoLidarConfidence.set(texture: lidarConfidenceTexture)
        }
        
        if let pixelBuffer = data.capturedImagePixelBuffer {
            let planeCount = CVPixelBufferGetPlaneCount(pixelBuffer)
            let width = CVPixelBufferGetWidth(pixelBuffer)
            let height = CVPixelBufferGetHeight(pixelBuffer)
            if planeCount >= 2 && width > 0 && height > 0 {

                videoTextureY = generateMetalTexture(pixelBuffer: pixelBuffer,
                                                          pixelFormat: .r8Unorm,
                                                          planeIndex: 0)
                videoTextureCBCR = generateMetalTexture(pixelBuffer: pixelBuffer,
                                                        pixelFormat: .rg8Unorm,
                                                        planeIndex: 1)
                
                tileVideoY.set(texture: videoTextureY)
                tileVideoCBCR.set(texture: videoTextureCBCR)
                
                tileVideo.set(textureY: videoTextureY,
                              textureCBCR: videoTextureCBCR)
                
                tileGroovy.set(textureY: videoTextureY,
                               textureCBCR: videoTextureCBCR)
                
            }
        }
    }
}

extension CameraScene: AugmentedRealityCameraInputProviderReceiving {
    
    func provider(didReceive data: AugmentedRealityCameraInputProviderData) {
        self.graphics.engine.semaphore.wait()
        inputProviderDataNext = data
        heavy()
        self.graphics.engine.semaphore.signal()
    }
}
