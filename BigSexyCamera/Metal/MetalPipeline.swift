//
//  MetalPipeline.swift
//  RebuildEarth
//
//  Created by Nicky Taylor on 2/10/23.
//

import Foundation
import UIKit
import Metal

class MetalPipeline {
    
    static let shapeVertexIndexPosition = 0
    static let shapeVertexIndexUniforms = 1
    static let shapeFragmentIndexUniforms = 0
    
    static let shapeNodeIndexedVertexIndexData = 0
    static let shapeNodeIndexedVertexIndexUniforms = 1
    static let shapeNodeIndexedFragmentIndexUniforms = 0
    
    static let spriteVertexIndexPosition = 0
    static let spriteVertexIndexTextureCoord = 1
    static let spriteVertexIndexUniforms = 2
    static let spriteFragmentIndexTexture = 0
    static let spriteFragmentIndexSampler = 1
    static let spriteFragmentIndexUniforms = 2
    
    static let spriteNodeIndexedVertexIndexData = 0
    static let spriteNodeIndexedVertexIndexUniforms = 1
    static let spriteNodeIndexedFragmentIndexTexture = 0
    static let spriteNodeIndexedFragmentIndexSampler = 1
    static let spriteNodeIndexedFragmentIndexUniforms = 2
    
    private let engine: MetalEngine
    private let library: MTLLibrary
    private let layer: CAMetalLayer
    private let device: MTLDevice
    init(engine: MetalEngine) {
        self.engine = engine
        library = engine.library
        layer = engine.layer
        device = engine.device
    }
    
    private var shape2DVertexProgram: MTLFunction!
    private var shape2DFragmentProgram: MTLFunction!
    private var shape3DVertexProgram: MTLFunction!
    private var shape3DFragmentProgram: MTLFunction!
    
    private var shapeNodeIndexed2DVertexProgram: MTLFunction!
    private var shapeNodeIndexed2DFragmentProgram: MTLFunction!
    private var shapeNodeIndexed3DVertexProgram: MTLFunction!
    private var shapeNodeIndexed3DFragmentProgram: MTLFunction!
    
    private var shapeNodeColoredIndexed2DVertexProgram: MTLFunction!
    private var shapeNodeColoredIndexed2DFragmentProgram: MTLFunction!
    private var shapeNodeColoredIndexed3DVertexProgram: MTLFunction!
    private var shapeNodeColoredIndexed3DFragmentProgram: MTLFunction!
    
    private var sprite2DVertexProgram: MTLFunction!
    private var sprite2DFragmentProgram: MTLFunction!
    private var sprite3DVertexProgram: MTLFunction!
    private var sprite3DFragmentProgram: MTLFunction!
    
    private var spriteNodeIndexed2DVertexProgram: MTLFunction!
    private var spriteNodeIndexed2DFragmentProgram: MTLFunction!
    private var spriteNodeIndexed3DVertexProgram: MTLFunction!
    private var spriteNodeIndexed3DFragmentProgram: MTLFunction!
    
    private var spriteNodeColoredIndexed2DVertexProgram: MTLFunction!
    private var spriteNodeColoredIndexed2DFragmentProgram: MTLFunction!
    private var spriteNodeColoredIndexed3DVertexProgram: MTLFunction!
    private var spriteNodeColoredIndexed3DFragmentProgram: MTLFunction!
    
    private(set) var pipelineStateShape2DNoBlending: MTLRenderPipelineState!
    private(set) var pipelineStateShape2DAlphaBlending: MTLRenderPipelineState!
    private(set) var pipelineStateShape2DAdditiveBlending: MTLRenderPipelineState!
    private(set) var pipelineStateShape2DPremultipliedBlending: MTLRenderPipelineState!
    private(set) var pipelineStateShape3DNoBlending: MTLRenderPipelineState!
    private(set) var pipelineStateShape3DAlphaBlending: MTLRenderPipelineState!
    private(set) var pipelineStateShape3DAdditiveBlending: MTLRenderPipelineState!
    private(set) var pipelineStateShape3DPremultipliedBlending: MTLRenderPipelineState!
    
    private(set) var pipelineStateShapeNodeIndexed2DNoBlending: MTLRenderPipelineState!
    private(set) var pipelineStateShapeNodeIndexed2DAlphaBlending: MTLRenderPipelineState!
    private(set) var pipelineStateShapeNodeIndexed2DAdditiveBlending: MTLRenderPipelineState!
    private(set) var pipelineStateShapeNodeIndexed2DPremultipliedBlending: MTLRenderPipelineState!
    private(set) var pipelineStateShapeNodeIndexed3DNoBlending: MTLRenderPipelineState!
    private(set) var pipelineStateShapeNodeIndexed3DAlphaBlending: MTLRenderPipelineState!
    private(set) var pipelineStateShapeNodeIndexed3DAdditiveBlending: MTLRenderPipelineState!
    private(set) var pipelineStateShapeNodeIndexed3DPremultipliedBlending: MTLRenderPipelineState!
    
    private(set) var pipelineStateShapeNodeColoredIndexed2DNoBlending: MTLRenderPipelineState!
    private(set) var pipelineStateShapeNodeColoredIndexed2DAlphaBlending: MTLRenderPipelineState!
    private(set) var pipelineStateShapeNodeColoredIndexed2DAdditiveBlending: MTLRenderPipelineState!
    private(set) var pipelineStateShapeNodeColoredIndexed2DPremultipliedBlending: MTLRenderPipelineState!
    private(set) var pipelineStateShapeNodeColoredIndexed3DNoBlending: MTLRenderPipelineState!
    private(set) var pipelineStateShapeNodeColoredIndexed3DAlphaBlending: MTLRenderPipelineState!
    private(set) var pipelineStateShapeNodeColoredIndexed3DAdditiveBlending: MTLRenderPipelineState!
    private(set) var pipelineStateShapeNodeColoredIndexed3DPremultipliedBlending: MTLRenderPipelineState!
    
    private(set) var pipelineStateSprite2DNoBlending: MTLRenderPipelineState!
    private(set) var pipelineStateSprite2DAlphaBlending: MTLRenderPipelineState!
    private(set) var pipelineStateSprite2DAdditiveBlending: MTLRenderPipelineState!
    private(set) var pipelineStateSprite2DPremultipliedBlending: MTLRenderPipelineState!
    private(set) var pipelineStateSprite3DNoBlending: MTLRenderPipelineState!
    private(set) var pipelineStateSprite3DAlphaBlending: MTLRenderPipelineState!
    private(set) var pipelineStateSprite3DAdditiveBlending: MTLRenderPipelineState!
    private(set) var pipelineStateSprite3DPremultipliedBlending: MTLRenderPipelineState!
    
    private(set) var pipelineStateSpriteNodeIndexed2DNoBlending: MTLRenderPipelineState!
    private(set) var pipelineStateSpriteNodeIndexed2DAlphaBlending: MTLRenderPipelineState!
    private(set) var pipelineStateSpriteNodeIndexed2DAdditiveBlending: MTLRenderPipelineState!
    private(set) var pipelineStateSpriteNodeIndexed2DPremultipliedBlending: MTLRenderPipelineState!
    private(set) var pipelineStateSpriteNodeIndexed3DNoBlending: MTLRenderPipelineState!
    private(set) var pipelineStateSpriteNodeIndexed3DAlphaBlending: MTLRenderPipelineState!
    private(set) var pipelineStateSpriteNodeIndexed3DAdditiveBlending: MTLRenderPipelineState!
    private(set) var pipelineStateSpriteNodeIndexed3DPremultipliedBlending: MTLRenderPipelineState!
    
    private(set) var pipelineStateSpriteNodeColoredIndexed2DNoBlending: MTLRenderPipelineState!
    private(set) var pipelineStateSpriteNodeColoredIndexed2DAlphaBlending: MTLRenderPipelineState!
    private(set) var pipelineStateSpriteNodeColoredIndexed2DAdditiveBlending: MTLRenderPipelineState!
    private(set) var pipelineStateSpriteNodeColoredIndexed2DPremultipliedBlending: MTLRenderPipelineState!
    private(set) var pipelineStateSpriteNodeColoredIndexed3DNoBlending: MTLRenderPipelineState!
    private(set) var pipelineStateSpriteNodeColoredIndexed3DAlphaBlending: MTLRenderPipelineState!
    private(set) var pipelineStateSpriteNodeColoredIndexed3DAdditiveBlending: MTLRenderPipelineState!
    private(set) var pipelineStateSpriteNodeColoredIndexed3DPremultipliedBlending: MTLRenderPipelineState!
    
    func load() {
        buildFunctions()
        
        buildPipelineStatesShape2D()
        buildPipelineStatesShape3D()
        
        buildPipelineStatesShapeNodeIndexed2D()
        buildPipelineStatesShapeNodeIndexed3D()
        
        buildPipelineStatesShapeNodeColoredIndexed2D()
        buildPipelineStatesShapeNodeColoredIndexed3D()
        
        buildPipelineStatesSprite2D()
        buildPipelineStatesSprite3D()
        
        buildPipelineStatesSpriteNodeIndexed2D()
        buildPipelineStatesSpriteNodeIndexed3D()
        
        buildPipelineStatesSpriteNodeColoredIndexed2D()
        buildPipelineStatesSpriteNodeColoredIndexed3D()
    }
    
    private func buildFunctions() {
        shape2DVertexProgram = library.makeFunction(name: "shape_2d_vertex")
        shape2DFragmentProgram = library.makeFunction(name: "shape_2d_fragment")
        shape3DVertexProgram = library.makeFunction(name: "shape_3d_vertex")
        shape3DFragmentProgram = library.makeFunction(name: "shape_3d_fragment")
        
        shapeNodeIndexed2DVertexProgram = library.makeFunction(name: "shape_node_indexed_2d_vertex")
        shapeNodeIndexed2DFragmentProgram = library.makeFunction(name: "shape_node_indexed_2d_fragment")
        shapeNodeIndexed3DVertexProgram = library.makeFunction(name: "shape_node_indexed_3d_vertex")
        shapeNodeIndexed3DFragmentProgram = library.makeFunction(name: "shape_node_indexed_3d_fragment")
        
        shapeNodeColoredIndexed2DVertexProgram = library.makeFunction(name: "shape_node_colored_indexed_2d_vertex")
        shapeNodeColoredIndexed2DFragmentProgram = library.makeFunction(name: "shape_node_colored_indexed_2d_fragment")
        shapeNodeColoredIndexed3DVertexProgram = library.makeFunction(name: "shape_node_colored_indexed_3d_vertex")
        shapeNodeColoredIndexed3DFragmentProgram = library.makeFunction(name: "shape_node_colored_indexed_3d_fragment")
        
        sprite2DVertexProgram = library.makeFunction(name: "sprite_2d_vertex")
        sprite2DFragmentProgram = library.makeFunction(name: "sprite_2d_fragment")
        sprite3DVertexProgram = library.makeFunction(name: "sprite_3d_vertex")
        sprite3DFragmentProgram = library.makeFunction(name: "sprite_3d_fragment")
        
        spriteNodeIndexed2DVertexProgram = library.makeFunction(name: "sprite_node_indexed_2d_vertex")
        spriteNodeIndexed2DFragmentProgram = library.makeFunction(name: "sprite_node_indexed_2d_fragment")
        spriteNodeIndexed3DVertexProgram = library.makeFunction(name: "sprite_node_indexed_3d_vertex")!
        spriteNodeIndexed3DFragmentProgram = library.makeFunction(name: "sprite_node_indexed_3d_fragment")!
        
        spriteNodeColoredIndexed2DVertexProgram = library.makeFunction(name: "sprite_node_colored_indexed_2d_vertex")
        spriteNodeColoredIndexed2DFragmentProgram = library.makeFunction(name: "sprite_node_colored_indexed_2d_fragment")
        spriteNodeColoredIndexed3DVertexProgram = library.makeFunction(name: "sprite_node_colored_indexed_3d_vertex")
        spriteNodeColoredIndexed3DFragmentProgram = library.makeFunction(name: "sprite_node_colored_indexed_3d_fragment")
    }
    
    private func buildPipelineStatesShape2D() {
        let vertexDescriptor = MTLVertexDescriptor()
        
        vertexDescriptor.attributes[Self.shapeVertexIndexPosition].format = MTLVertexFormat.float2
        vertexDescriptor.attributes[Self.shapeVertexIndexPosition].bufferIndex = Self.shapeVertexIndexPosition
        vertexDescriptor.layouts[Self.shapeVertexIndexPosition].stride = MemoryLayout<Float>.size * 2
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexDescriptor = vertexDescriptor
        pipelineDescriptor.vertexFunction = shape2DVertexProgram
        pipelineDescriptor.fragmentFunction = shape2DFragmentProgram
        pipelineDescriptor.colorAttachments[0].pixelFormat = layer.pixelFormat
        pipelineDescriptor.rasterSampleCount = 4
        pipelineStateShape2DNoBlending = try? device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        
        configAlphaBlending(pipelineDescriptor: pipelineDescriptor)
        pipelineStateShape2DAlphaBlending = try? device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        
        configAdditiveBlending(pipelineDescriptor: pipelineDescriptor)
        pipelineStateShape2DAdditiveBlending = try? device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        
        configPremultipliedBlending(pipelineDescriptor: pipelineDescriptor)
        pipelineStateShape2DPremultipliedBlending = try? device.makeRenderPipelineState(descriptor: pipelineDescriptor)
    }
    
    private func buildPipelineStatesShape3D() {
        let vertexDescriptor = MTLVertexDescriptor()
        vertexDescriptor.attributes[Self.shapeVertexIndexPosition].format = MTLVertexFormat.float3
        vertexDescriptor.attributes[Self.shapeVertexIndexPosition].bufferIndex = Self.shapeVertexIndexPosition
        vertexDescriptor.layouts[Self.shapeVertexIndexPosition].stride = MemoryLayout<Float>.size * 3
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexDescriptor = vertexDescriptor
        pipelineDescriptor.vertexFunction = shape3DVertexProgram
        pipelineDescriptor.fragmentFunction = shape3DFragmentProgram
        pipelineDescriptor.colorAttachments[0].pixelFormat = layer.pixelFormat
        pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
        
        pipelineStateShape3DNoBlending = try? device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        
        configAlphaBlending(pipelineDescriptor: pipelineDescriptor)
        pipelineStateShape3DAlphaBlending = try? device.makeRenderPipelineState(descriptor: pipelineDescriptor)

        configAdditiveBlending(pipelineDescriptor: pipelineDescriptor)
        pipelineStateShape3DAdditiveBlending = try? device.makeRenderPipelineState(descriptor: pipelineDescriptor)

        configPremultipliedBlending(pipelineDescriptor: pipelineDescriptor)
        pipelineStateShape3DPremultipliedBlending = try? device.makeRenderPipelineState(descriptor: pipelineDescriptor)
    }
    
    private func buildPipelineStatesShapeNodeIndexed2D() {
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = shapeNodeIndexed2DVertexProgram
        pipelineDescriptor.fragmentFunction = shapeNodeIndexed2DFragmentProgram
        pipelineDescriptor.colorAttachments[0].pixelFormat = layer.pixelFormat
        pipelineDescriptor.rasterSampleCount = 4
        pipelineStateShapeNodeIndexed2DNoBlending = try? device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        
        configAlphaBlending(pipelineDescriptor: pipelineDescriptor)
        pipelineStateShapeNodeIndexed2DAlphaBlending = try? device.makeRenderPipelineState(descriptor: pipelineDescriptor)

        configAdditiveBlending(pipelineDescriptor: pipelineDescriptor)
        pipelineStateShapeNodeIndexed2DAdditiveBlending = try? device.makeRenderPipelineState(descriptor: pipelineDescriptor)

        configPremultipliedBlending(pipelineDescriptor: pipelineDescriptor)
        pipelineStateShapeNodeIndexed2DPremultipliedBlending = try? device.makeRenderPipelineState(descriptor: pipelineDescriptor)
    }
    
    private func buildPipelineStatesShapeNodeIndexed3D() {
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = shapeNodeIndexed3DVertexProgram
        pipelineDescriptor.fragmentFunction = shapeNodeIndexed3DFragmentProgram
        pipelineDescriptor.colorAttachments[0].pixelFormat = layer.pixelFormat
        pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
        pipelineStateShapeNodeIndexed3DNoBlending = try? device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        
        configAlphaBlending(pipelineDescriptor: pipelineDescriptor)
        pipelineStateShapeNodeIndexed3DAlphaBlending = try? device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        
        configAdditiveBlending(pipelineDescriptor: pipelineDescriptor)
        pipelineStateShapeNodeIndexed3DAdditiveBlending = try? device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        
        configPremultipliedBlending(pipelineDescriptor: pipelineDescriptor)
        pipelineStateShapeNodeIndexed3DPremultipliedBlending = try? device.makeRenderPipelineState(descriptor: pipelineDescriptor)
    }
    
    private func buildPipelineStatesShapeNodeColoredIndexed2D() {
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = shapeNodeColoredIndexed2DVertexProgram
        pipelineDescriptor.fragmentFunction = shapeNodeColoredIndexed2DFragmentProgram
        pipelineDescriptor.colorAttachments[0].pixelFormat = layer.pixelFormat
        pipelineDescriptor.rasterSampleCount = 4
        pipelineStateShapeNodeColoredIndexed2DNoBlending = try? device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        
        configAlphaBlending(pipelineDescriptor: pipelineDescriptor)
        pipelineStateShapeNodeColoredIndexed2DAlphaBlending = try? device.makeRenderPipelineState(descriptor: pipelineDescriptor)

        configAdditiveBlending(pipelineDescriptor: pipelineDescriptor)
        pipelineStateShapeNodeColoredIndexed2DAdditiveBlending = try? device.makeRenderPipelineState(descriptor: pipelineDescriptor)

        configPremultipliedBlending(pipelineDescriptor: pipelineDescriptor)
        pipelineStateShapeNodeColoredIndexed2DPremultipliedBlending = try? device.makeRenderPipelineState(descriptor: pipelineDescriptor)
    }
    
    private func buildPipelineStatesShapeNodeColoredIndexed3D() {
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = shapeNodeColoredIndexed3DVertexProgram
        pipelineDescriptor.fragmentFunction = shapeNodeColoredIndexed3DFragmentProgram
        pipelineDescriptor.colorAttachments[0].pixelFormat = layer.pixelFormat
        pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
        pipelineStateShapeNodeColoredIndexed3DNoBlending = try? device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        
        configAlphaBlending(pipelineDescriptor: pipelineDescriptor)
        pipelineStateShapeNodeColoredIndexed3DAlphaBlending = try? device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        
        configAdditiveBlending(pipelineDescriptor: pipelineDescriptor)
        pipelineStateShapeNodeColoredIndexed3DAdditiveBlending = try? device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        
        configPremultipliedBlending(pipelineDescriptor: pipelineDescriptor)
        pipelineStateShapeNodeColoredIndexed3DPremultipliedBlending = try? device.makeRenderPipelineState(descriptor: pipelineDescriptor)
    }
    
    private func buildPipelineStatesSprite2D() {
        let vertexDescriptor = MTLVertexDescriptor()
        
        vertexDescriptor.attributes[Self.spriteVertexIndexPosition].format = MTLVertexFormat.float2
        vertexDescriptor.attributes[Self.spriteVertexIndexPosition].bufferIndex = Self.spriteVertexIndexPosition
        vertexDescriptor.layouts[Self.spriteVertexIndexPosition].stride = MemoryLayout<Float>.size * 2
        vertexDescriptor.attributes[Self.spriteVertexIndexTextureCoord].format = MTLVertexFormat.float2
        vertexDescriptor.attributes[Self.spriteVertexIndexTextureCoord].offset = 0
        vertexDescriptor.attributes[Self.spriteVertexIndexTextureCoord].bufferIndex = Self.spriteVertexIndexTextureCoord
        vertexDescriptor.layouts[Self.spriteVertexIndexTextureCoord].stride = MemoryLayout<Float>.size * 2
        vertexDescriptor.layouts[Self.spriteVertexIndexTextureCoord].stepRate = 1
        vertexDescriptor.layouts[Self.spriteVertexIndexTextureCoord].stepFunction = MTLVertexStepFunction.perVertex
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = sprite2DVertexProgram;
        pipelineDescriptor.fragmentFunction = sprite2DFragmentProgram
        pipelineDescriptor.vertexDescriptor = vertexDescriptor
        pipelineDescriptor.colorAttachments[0].pixelFormat = layer.pixelFormat
        pipelineDescriptor.rasterSampleCount = 4
        pipelineStateSprite2DNoBlending = try? device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        
        configAlphaBlending(pipelineDescriptor: pipelineDescriptor)
        pipelineStateSprite2DAlphaBlending = try? device.makeRenderPipelineState(descriptor: pipelineDescriptor)

        configAdditiveBlending(pipelineDescriptor: pipelineDescriptor)
        pipelineStateSprite2DAdditiveBlending = try? device.makeRenderPipelineState(descriptor: pipelineDescriptor)

        configPremultipliedBlending(pipelineDescriptor: pipelineDescriptor)
        pipelineStateSprite2DPremultipliedBlending = try? device.makeRenderPipelineState(descriptor: pipelineDescriptor)
    }
    
    private func buildPipelineStatesSprite3D() {
        let vertexDescriptor = MTLVertexDescriptor()
        vertexDescriptor.attributes[Self.spriteVertexIndexPosition].format = MTLVertexFormat.float3
        vertexDescriptor.attributes[Self.spriteVertexIndexPosition].bufferIndex = Self.spriteVertexIndexPosition
        vertexDescriptor.layouts[Self.spriteVertexIndexPosition].stride = MemoryLayout<Float>.size * 3
        vertexDescriptor.attributes[Self.spriteVertexIndexTextureCoord].format = MTLVertexFormat.float2
        vertexDescriptor.attributes[Self.spriteVertexIndexTextureCoord].bufferIndex = Self.spriteVertexIndexTextureCoord
        vertexDescriptor.layouts[Self.spriteVertexIndexTextureCoord].stride = MemoryLayout<Float>.size * 2
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = sprite3DVertexProgram;
        pipelineDescriptor.fragmentFunction = sprite3DFragmentProgram
        pipelineDescriptor.vertexDescriptor = vertexDescriptor
        pipelineDescriptor.colorAttachments[0].pixelFormat = layer.pixelFormat
        pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
        pipelineStateSprite3DNoBlending = try? device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        
        configAlphaBlending(pipelineDescriptor: pipelineDescriptor)
        pipelineStateSprite3DAlphaBlending = try? device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        
        configAdditiveBlending(pipelineDescriptor: pipelineDescriptor)
        pipelineStateSprite3DAdditiveBlending = try? device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        
        configPremultipliedBlending(pipelineDescriptor: pipelineDescriptor)
        pipelineStateSprite3DPremultipliedBlending = try? device.makeRenderPipelineState(descriptor: pipelineDescriptor)
    }
    
    private func buildPipelineStatesSpriteNodeIndexed2D() {
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = spriteNodeIndexed2DVertexProgram;
        pipelineDescriptor.fragmentFunction = spriteNodeIndexed2DFragmentProgram
        pipelineDescriptor.colorAttachments[0].pixelFormat = layer.pixelFormat
        pipelineDescriptor.rasterSampleCount = 4
        pipelineStateSpriteNodeIndexed2DNoBlending = try? device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        
        configAlphaBlending(pipelineDescriptor: pipelineDescriptor)
        pipelineStateSpriteNodeIndexed2DAlphaBlending = try? device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        
        configAdditiveBlending(pipelineDescriptor: pipelineDescriptor)
        pipelineStateSpriteNodeIndexed2DAdditiveBlending = try? device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        
        configPremultipliedBlending(pipelineDescriptor: pipelineDescriptor)
        pipelineStateSpriteNodeIndexed2DPremultipliedBlending = try? device.makeRenderPipelineState(descriptor: pipelineDescriptor)
    }
    
    private func buildPipelineStatesSpriteNodeIndexed3D() {
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = spriteNodeIndexed3DVertexProgram;
        pipelineDescriptor.fragmentFunction = spriteNodeIndexed3DFragmentProgram
        pipelineDescriptor.colorAttachments[0].pixelFormat = layer.pixelFormat
        pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
        pipelineStateSpriteNodeIndexed3DNoBlending = try? device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        
        configAlphaBlending(pipelineDescriptor: pipelineDescriptor)
        pipelineStateSpriteNodeIndexed3DAlphaBlending = try? device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        
        configAdditiveBlending(pipelineDescriptor: pipelineDescriptor)
        pipelineStateSpriteNodeIndexed3DAdditiveBlending = try? device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        
        configPremultipliedBlending(pipelineDescriptor: pipelineDescriptor)
        pipelineStateSpriteNodeIndexed3DPremultipliedBlending = try? device.makeRenderPipelineState(descriptor: pipelineDescriptor)
    }
    
    private func buildPipelineStatesSpriteNodeColoredIndexed2D() {
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = spriteNodeColoredIndexed2DVertexProgram;
        pipelineDescriptor.fragmentFunction = spriteNodeColoredIndexed2DFragmentProgram
        pipelineDescriptor.colorAttachments[0].pixelFormat = layer.pixelFormat
        pipelineDescriptor.rasterSampleCount = 4
        pipelineStateSpriteNodeColoredIndexed2DNoBlending = try? device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        
        configAlphaBlending(pipelineDescriptor: pipelineDescriptor)
        pipelineStateSpriteNodeColoredIndexed2DAlphaBlending = try? device.makeRenderPipelineState(descriptor: pipelineDescriptor)

        configAdditiveBlending(pipelineDescriptor: pipelineDescriptor)
        pipelineStateSpriteNodeColoredIndexed2DAdditiveBlending = try? device.makeRenderPipelineState(descriptor: pipelineDescriptor)

        configPremultipliedBlending(pipelineDescriptor: pipelineDescriptor)
        pipelineStateSpriteNodeColoredIndexed2DPremultipliedBlending = try? device.makeRenderPipelineState(descriptor: pipelineDescriptor)
    }
    
    private func buildPipelineStatesSpriteNodeColoredIndexed3D() {
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = spriteNodeColoredIndexed3DVertexProgram;
        pipelineDescriptor.fragmentFunction = spriteNodeColoredIndexed3DFragmentProgram
        pipelineDescriptor.colorAttachments[0].pixelFormat = layer.pixelFormat
        pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
        pipelineStateSpriteNodeColoredIndexed3DNoBlending = try? device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        
        configAlphaBlending(pipelineDescriptor: pipelineDescriptor)
        pipelineStateSpriteNodeColoredIndexed3DAlphaBlending = try? device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        
        configAdditiveBlending(pipelineDescriptor: pipelineDescriptor)
        pipelineStateSpriteNodeColoredIndexed3DAdditiveBlending = try? device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        
        configPremultipliedBlending(pipelineDescriptor: pipelineDescriptor)
        pipelineStateSpriteNodeColoredIndexed3DPremultipliedBlending = try? device.makeRenderPipelineState(descriptor: pipelineDescriptor)
    }
    
    private func configAlphaBlending(pipelineDescriptor: MTLRenderPipelineDescriptor) {
        pipelineDescriptor.colorAttachments[0].isBlendingEnabled = true
        pipelineDescriptor.colorAttachments[0].rgbBlendOperation = .add
        pipelineDescriptor.colorAttachments[0].alphaBlendOperation = .add
        pipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
        pipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .sourceAlpha
        pipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
        pipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha
    }
    
    private func configAdditiveBlending(pipelineDescriptor: MTLRenderPipelineDescriptor) {
        pipelineDescriptor.colorAttachments[0].isBlendingEnabled = true
        pipelineDescriptor.colorAttachments[0].rgbBlendOperation = .add
        pipelineDescriptor.colorAttachments[0].alphaBlendOperation = .add
        pipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
        pipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .one
        pipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = .one
        pipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .one
    }
    
    private func configPremultipliedBlending(pipelineDescriptor: MTLRenderPipelineDescriptor) {
        pipelineDescriptor.colorAttachments[0].isBlendingEnabled = true
        pipelineDescriptor.colorAttachments[0].rgbBlendOperation = .add
        pipelineDescriptor.colorAttachments[0].alphaBlendOperation = .add
        pipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = .one
        pipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .one
        pipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
        pipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha
    }
}
