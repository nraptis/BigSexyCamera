//
//  MetalEngine.swift
//  RebuildEarth
//
//  Created by Nicky Taylor on 2/10/23.
//

import Foundation
import UIKit
import Metal

class MetalEngine {
    
    let delegate: GraphicsDelegate
    let graphics: Graphics
    let layer: CAMetalLayer
    
    var scale: CGFloat
    var device: MTLDevice
    var library: MTLLibrary
    var commandQueue: MTLCommandQueue
    
    var samplerStateLinearClamp: MTLSamplerState!
    var samplerStateLinearRepeat: MTLSamplerState!
    
    var depthStateDisabled: MTLDepthStencilState!
    var depthStateLessThan: MTLDepthStencilState!
    var depthStateLessThanEqual: MTLDepthStencilState!
    
    var storageTexture: MTLTexture!
    var antialiasingTexture: MTLTexture!
    var depthTexture: MTLTexture!
    
    
    
    private var tileSpritePositions: [Float] = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
    private var tileSpriteTextureCoords: [Float] = [0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 1.0, 1.0]
    private var tileUniformVertex = UniformsSpriteVertex()
    private var tileUniformFragment = UniformsSpriteFragment()
    private var tileSpritePositionsBuffer: MTLBuffer!
    private var tileSpriteTextureCoordsBuffer: MTLBuffer!
    private var tileUniformVertexBuffer: MTLBuffer!
    private var tileUniformFragmentBuffer: MTLBuffer!
    private var tileSpriteWidth: Float = 0.0
    private var tileSpriteHeight: Float = 0.0
    
    
    required init(delegate: GraphicsDelegate, graphics: Graphics, layer: CAMetalLayer) {
        self.delegate = delegate
        self.graphics = graphics
        self.layer = layer
        
        scale = UIScreen.main.scale
        device = MTLCreateSystemDefaultDevice()!
        library = device.makeDefaultLibrary()!
        commandQueue = device.makeCommandQueue()!
        
        layer.device = device
        layer.contentsScale = scale
        layer.frame = CGRect(x: 0.0, y: 0.0, width: CGFloat(graphics.width), height: CGFloat(graphics.height))
    }
    
    func load() {
        let width = Int(CGFloat(graphics.width) * scale + 0.5)
        let height = Int(CGFloat(graphics.height) * scale + 0.5)
        
        storageTexture = createStorageTexture(width: width, height: height)
        antialiasingTexture = createAntialiasingTexture(width: width, height: height)
        depthTexture = createDepthTexture(width: width, height: height)
        
        buildSamplerStates()
        buildDepthStates()
        
        tileSpritePositionsBuffer = graphics.buffer(array: tileSpritePositions)
        tileSpriteTextureCoordsBuffer = graphics.buffer(array: tileSpriteTextureCoords)
        tileUniformVertexBuffer = graphics.buffer(uniform: tileUniformVertex)
        tileUniformFragmentBuffer = graphics.buffer(uniform: tileUniformFragment)
    }
    
    let semaphore = DispatchSemaphore(value: 1)
    
    func draw() {
        
        guard let drawable = layer.nextDrawable() else {
            return
        }
        
        guard let commandBuffer = commandQueue.makeCommandBuffer() else {
            return
        }
        
        let renderPassDescriptor3D = MTLRenderPassDescriptor()
        renderPassDescriptor3D.colorAttachments[0].texture = storageTexture
        renderPassDescriptor3D.colorAttachments[0].loadAction = .clear
        renderPassDescriptor3D.colorAttachments[0].storeAction = .store
        renderPassDescriptor3D.colorAttachments[0].clearColor = MTLClearColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        renderPassDescriptor3D.depthAttachment.loadAction = .clear
        renderPassDescriptor3D.depthAttachment.clearDepth = 1.0
        renderPassDescriptor3D.depthAttachment.texture = depthTexture

        if let renderEncoder3D = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor3D) {
            delegate.draw3D(renderEncoder: renderEncoder3D)
            renderEncoder3D.endEncoding()
        }
        
        let renderPassDescriptor2D = MTLRenderPassDescriptor()
        renderPassDescriptor2D.colorAttachments[0].texture = antialiasingTexture
        renderPassDescriptor2D.colorAttachments[0].loadAction = .dontCare
        renderPassDescriptor2D.colorAttachments[0].storeAction = .multisampleResolve
        renderPassDescriptor2D.colorAttachments[0].resolveTexture = drawable.texture

        if let renderEncoder2D = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor2D) {
            drawTile(renderEncoder: renderEncoder2D)
            delegate.draw2D(renderEncoder: renderEncoder2D)
            renderEncoder2D.endEncoding()
        }
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    
    func drawTile(renderEncoder: MTLRenderCommandEncoder) {
        if (tileSpriteWidth != graphics.width) || (tileSpriteHeight != graphics.height) {
            tileSpriteWidth = graphics.width
            tileSpriteHeight = graphics.height
            
            tileSpritePositions[0] = 0.0
            tileSpritePositions[1] = 0.0
            tileSpritePositions[2] = graphics.width
            tileSpritePositions[3] = 0.0
            tileSpritePositions[4] = 0.0
            tileSpritePositions[5] = graphics.height
            tileSpritePositions[6] = graphics.width
            tileSpritePositions[7] = graphics.height
            graphics.write(buffer: tileSpritePositionsBuffer, array: tileSpritePositions)
            
            tileUniformVertex.projectionMatrix.ortho(width: graphics.width,
                                                     height: graphics.height)
            graphics.write(buffer: tileUniformVertexBuffer, uniform: tileUniformVertex)
        }
        
        graphics.set(pipelineState: .sprite2DNoBlending, renderEncoder: renderEncoder)
        graphics.set(samplerState: .linearClamp, renderEncoder: renderEncoder)
        
        graphics.setVertexPositionsBuffer(tileSpritePositionsBuffer, renderEncoder: renderEncoder)
        graphics.setVertexTextureCoordsBuffer(tileSpriteTextureCoordsBuffer, renderEncoder: renderEncoder)
        
        graphics.setVertexUniformsBuffer(tileUniformVertexBuffer, renderEncoder: renderEncoder)
        graphics.setFragmentUniformsBuffer(tileUniformFragmentBuffer, renderEncoder: renderEncoder)
        
        graphics.setFragmentTexture(storageTexture, renderEncoder: renderEncoder)
        
        renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
    }
    
    private func buildSamplerStates() {
        let samplerDescriptorLinearClamp = MTLSamplerDescriptor()
        samplerDescriptorLinearClamp.minFilter = .linear
        samplerDescriptorLinearClamp.magFilter = .linear
        samplerDescriptorLinearClamp.sAddressMode = .clampToEdge
        samplerDescriptorLinearClamp.tAddressMode = .clampToEdge
        samplerStateLinearClamp = device.makeSamplerState(descriptor: samplerDescriptorLinearClamp)
        
        let samplerDescriptorLinearRepeat = MTLSamplerDescriptor()
        samplerDescriptorLinearRepeat.minFilter = .linear
        samplerDescriptorLinearRepeat.magFilter = .linear
        samplerDescriptorLinearRepeat.sAddressMode = .repeat
        samplerDescriptorLinearRepeat.tAddressMode = .repeat
        samplerStateLinearRepeat = device.makeSamplerState(descriptor: samplerDescriptorLinearRepeat)
    }
    
    private func buildDepthStates() {
        let depthDescriptorDisabled = MTLDepthStencilDescriptor()
        depthDescriptorDisabled.depthCompareFunction = .always
        depthDescriptorDisabled.isDepthWriteEnabled = false
        depthStateDisabled = device.makeDepthStencilState(descriptor: depthDescriptorDisabled)
        
        let depthDescriptorLessThan = MTLDepthStencilDescriptor()
        depthDescriptorLessThan.depthCompareFunction = .less
        depthDescriptorLessThan.isDepthWriteEnabled = true
        depthStateLessThan = device.makeDepthStencilState(descriptor: depthDescriptorLessThan)
        
        let depthDescriptorLessThanEqual = MTLDepthStencilDescriptor()
        depthDescriptorLessThanEqual.depthCompareFunction = .lessEqual
        depthDescriptorLessThanEqual.isDepthWriteEnabled = true
        depthStateLessThanEqual = device.makeDepthStencilState(descriptor: depthDescriptorLessThanEqual)
    }
    
    func createAntialiasingTexture(width: Int, height: Int) -> MTLTexture {
        let textureDescriptor = MTLTextureDescriptor()
        textureDescriptor.sampleCount = 4
        textureDescriptor.pixelFormat = layer.pixelFormat
        textureDescriptor.width = width
        textureDescriptor.height = height
        textureDescriptor.textureType = .type2DMultisample
        textureDescriptor.usage = .renderTarget
        textureDescriptor.resourceOptions = .storageModePrivate
        return device.makeTexture(descriptor: textureDescriptor)!
    }
    
    func createStorageTexture(width: Int, height: Int) -> MTLTexture {
        let textureDescriptor = MTLTextureDescriptor()
        textureDescriptor.pixelFormat = layer.pixelFormat
        textureDescriptor.width = width
        textureDescriptor.height = height
        textureDescriptor.textureType = .type2D
        textureDescriptor.usage = .renderTarget.union(.shaderRead)
        return device.makeTexture(descriptor: textureDescriptor)!
    }
    
    func createDepthTexture(width: Int, height: Int) -> MTLTexture {
        let textureDescriptor = MTLTextureDescriptor()
        textureDescriptor.pixelFormat = .depth32Float
        textureDescriptor.width = width
        textureDescriptor.height = height
        textureDescriptor.textureType = .type2D
        textureDescriptor.usage = .renderTarget
        textureDescriptor.resourceOptions = .storageModePrivate
        return device.makeTexture(descriptor: textureDescriptor)!
    }
}
