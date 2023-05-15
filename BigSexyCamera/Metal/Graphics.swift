//
//  Graphics.swift
//  RebuildEarth
//
//  Created by Nicky Taylor on 2/9/23.
//

import Foundation
import Metal
import MetalKit

protocol GraphicsDelegate: AnyObject {
    var graphics: Graphics! { set get }
    func initialize(graphics: Graphics)
    func update()
    func load()
    func draw3D(renderEncoder: MTLRenderCommandEncoder)
    func draw2D(renderEncoder: MTLRenderCommandEncoder)
    
    func touchBegan(touch: UITouch, x: Float, y: Float)
    func touchMoved(touch: UITouch, x: Float, y: Float)
    func touchEnded(touch: UITouch, x: Float, y: Float)
}

extension GraphicsDelegate {
    func initialize(graphics: Graphics) {
        self.graphics = graphics
    }
}

class Graphics {
    
    enum PipelineState {
        case invalid
        
        case shape2DNoBlending
        case shape2DAlphaBlending
        case shape2DAdditiveBlending
        case shape2DPremultipliedBlending
        case shape3DNoBlending
        case shape3DAlphaBlending
        case shape3DAdditiveBlending
        case shape3DPremultipliedBlending
        
        case shapeNodeIndexed2DNoBlending
        case shapeNodeIndexed2DAlphaBlending
        case shapeNodeIndexed2DAdditiveBlending
        case shapeNodeIndexed2DPremultipliedBlending
        case shapeNodeIndexed3DNoBlending
        case shapeNodeIndexed3DAlphaBlending
        case shapeNodeIndexed3DAdditiveBlending
        case shapeNodeIndexed3DPremultipliedBlending
        
        case shapeNodeColoredIndexed2DNoBlending
        case shapeNodeColoredIndexed2DAlphaBlending
        case shapeNodeColoredIndexed2DAdditiveBlending
        case shapeNodeColoredIndexed2DPremultipliedBlending
        case shapeNodeColoredIndexed3DNoBlending
        case shapeNodeColoredIndexed3DAlphaBlending
        case shapeNodeColoredIndexed3DAdditiveBlending
        case shapeNodeColoredIndexed3DPremultipliedBlending
        
        case sprite2DNoBlending
        case sprite2DAlphaBlending
        case sprite2DAdditiveBlending
        case sprite2DPremultipliedBlending
        
        case sprite2DYCBCRNoBlending
        case sprite2DYCBCRAlphaBlending
        case sprite2DYCBCRAdditiveBlending
        case sprite2DYCBCRPremultipliedBlending
        
        
        case sprite3DNoBlending
        case sprite3DAlphaBlending
        case sprite3DAdditiveBlending
        case sprite3DPremultipliedBlending
        
        case sprite3DYCBCRNoBlending
        case sprite3DYCBCRAlphaBlending
        case sprite3DYCBCRAdditiveBlending
        case sprite3DYCBCRPremultipliedBlending
        
        case spriteNodeIndexed2DNoBlending
        case spriteNodeIndexed2DAlphaBlending
        case spriteNodeIndexed2DAdditiveBlending
        case spriteNodeIndexed2DPremultipliedBlending
        case spriteNodeIndexed3DNoBlending
        case spriteNodeIndexed3DAlphaBlending
        case spriteNodeIndexed3DAdditiveBlending
        case spriteNodeIndexed3DPremultipliedBlending
        
        case spriteNodeIndexed3DYCBCRNoBlending
        case spriteNodeIndexed3DYCBCRAlphaBlending
        case spriteNodeIndexed3DYCBCRAdditiveBlending
        case spriteNodeIndexed3DYCBCRPremultipliedBlending
        
        case spriteNodeColoredIndexed2DNoBlending
        case spriteNodeColoredIndexed2DAlphaBlending
        case spriteNodeColoredIndexed2DAdditiveBlending
        case spriteNodeColoredIndexed2DPremultipliedBlending
        
        case spriteNodeColoredIndexed2DYCBCRNoBlending
        case spriteNodeColoredIndexed2DYCBCRAlphaBlending
        case spriteNodeColoredIndexed2DYCBCRAdditiveBlending
        case spriteNodeColoredIndexed2DYCBCRPremultipliedBlending
        
        
        case spriteNodeColoredIndexed3DNoBlending
        case spriteNodeColoredIndexed3DAlphaBlending
        case spriteNodeColoredIndexed3DAdditiveBlending
        case spriteNodeColoredIndexed3DPremultipliedBlending
        
        
        case spriteNodeColoredIndexed3DYCBCRNoBlending
        case spriteNodeColoredIndexed3DYCBCRAlphaBlending
        case spriteNodeColoredIndexed3DYCBCRAdditiveBlending
        case spriteNodeColoredIndexed3DYCBCRPremultipliedBlending
        
        
    }
    
    enum SamplerState {
        case invalid
        
        case linearClamp
        case linearRepeat
    }
    
    enum DepthState {
        case invalid

        case disabled
        case lessThan
        case lessThanEqual
    }
    
    let delegate: GraphicsDelegate
    private(set) var width: Float
    private(set) var height: Float
    
    
    init(delegate: GraphicsDelegate, width: Float, height: Float) {
        print("Create Graphics With Size: \(width) x \(height)")
        self.delegate = delegate
        self.width = width
        self.height = height
    }
    
    private(set) var pipelineState = PipelineState.invalid
    private(set) var samplerState = SamplerState.invalid
    private(set) var depthState = DepthState.invalid
    
    lazy var metalViewController: MetalViewController = {
        MetalViewController(graphics: self, metalView: metalView)
    }()
    
    lazy var metalView: MetalView = {
        MetalView(delegate: delegate,
                  graphics: self,
                  width: CGFloat(width),
                  height: CGFloat(height))
    }()
    
    lazy var engine: MetalEngine = {
        metalView.engine
    }()
    
    lazy var pipeline: MetalPipeline = {
        metalView.pipeline
    }()

    lazy var device: MTLDevice = {
        engine.device
    }()
    
    lazy var window: UIWindow = {
        guard let scene = UIApplication.shared.connectedScenes.first else {
            return UIWindow()
        }
        guard let windowScene = scene as? UIWindowScene else {
            return UIWindow()
        }
        guard let window = windowScene.windows.first else {
            return UIWindow()
        }
        return window
    }()
    
    lazy var safeAreaTop: Float = {
        Float(window.safeAreaInsets.top)
    }()
    
    lazy var safeAreaBottom: Float = {
        Float(window.safeAreaInsets.bottom)
    }()
    
    lazy var safeAreaLeft: Float = {
        Float(window.safeAreaInsets.left)
    }()
    
    lazy var safeAreaRight: Float = {
        Float(window.safeAreaInsets.right)
    }()
    
    func update(width: Float, height: Float) {
        if (width != self.width) || (height != self.height) {
            self.width = width
            self.height = height
        }
    }
    
    func loadTexture(url: URL) -> MTLTexture? {
        let loader = MTKTextureLoader(device: engine.device)
        return try? loader.newTexture(URL: url, options: nil)
    }
    
    func loadTexture(fileName: String) -> MTLTexture? {
        if let bundleResourcePath = Bundle.main.resourcePath {
            let filePath = bundleResourcePath + "/" + fileName
            if #available(iOS 16.0, *) {
                let fileURL = URL(filePath: filePath)
                return loadTexture(url: fileURL)
            } else {
                // Fallback on earlier versions
                let fileURL = URL(fileURLWithPath: filePath)
                return loadTexture(url: fileURL)
            }
        }
        return nil
    }
    
    func buffer<Element>(array: Array<Element>) -> MTLBuffer! {
        let length = MemoryLayout<Element>.size * array.count
        return device.makeBuffer(bytes: array,
                                 length: length)
    }

    func write<Element>(buffer: MTLBuffer, array: Array<Element>) {
        let length = MemoryLayout<Element>.size * array.count
        buffer.contents().copyMemory(from: array,
                                     byteCount: length)
    }

    func buffer(uniform: Uniforms) -> MTLBuffer! {
        return device.makeBuffer(bytes: uniform.data,
                                 length: uniform.size,
                                 options: [])
    }

    func write(buffer: MTLBuffer, uniform: Uniforms) {
        buffer.contents().copyMemory(from: uniform.data, byteCount: uniform.size)
    }
    
    func set(pipelineState: PipelineState, renderEncoder: MTLRenderCommandEncoder) {
        self.pipelineState = pipelineState
        switch pipelineState {
        case .invalid:
            break
        case .shape2DNoBlending:
            renderEncoder.setRenderPipelineState(pipeline.pipelineStateShape2DNoBlending)
        case .shape2DAlphaBlending:
            renderEncoder.setRenderPipelineState(pipeline.pipelineStateShape2DAlphaBlending)
        case .shape2DAdditiveBlending:
            renderEncoder.setRenderPipelineState(pipeline.pipelineStateShape2DAdditiveBlending)
        case .shape2DPremultipliedBlending:
            renderEncoder.setRenderPipelineState(pipeline.pipelineStateShape2DPremultipliedBlending)
            
        case .shape3DNoBlending:
            renderEncoder.setRenderPipelineState(pipeline.pipelineStateShape3DNoBlending)
        case .shape3DAlphaBlending:
            renderEncoder.setRenderPipelineState(pipeline.pipelineStateShape3DAlphaBlending)
        case .shape3DAdditiveBlending:
            renderEncoder.setRenderPipelineState(pipeline.pipelineStateShape3DAdditiveBlending)
        case .shape3DPremultipliedBlending:
            renderEncoder.setRenderPipelineState(pipeline.pipelineStateShape3DPremultipliedBlending)
            
        case .shapeNodeIndexed2DNoBlending:
            renderEncoder.setRenderPipelineState(pipeline.pipelineStateShapeNodeIndexed2DNoBlending)
        case .shapeNodeIndexed2DAlphaBlending:
            renderEncoder.setRenderPipelineState(pipeline.pipelineStateShapeNodeIndexed2DAlphaBlending)
        case .shapeNodeIndexed2DAdditiveBlending:
            renderEncoder.setRenderPipelineState(pipeline.pipelineStateShapeNodeIndexed2DAdditiveBlending)
        case .shapeNodeIndexed2DPremultipliedBlending:
            renderEncoder.setRenderPipelineState(pipeline.pipelineStateShapeNodeIndexed2DPremultipliedBlending)
            
        case .shapeNodeIndexed3DNoBlending:
            renderEncoder.setRenderPipelineState(pipeline.pipelineStateShapeNodeIndexed3DNoBlending)
        case .shapeNodeIndexed3DAlphaBlending:
            renderEncoder.setRenderPipelineState(pipeline.pipelineStateShapeNodeIndexed3DAlphaBlending)
        case .shapeNodeIndexed3DAdditiveBlending:
            renderEncoder.setRenderPipelineState(pipeline.pipelineStateShapeNodeIndexed3DAdditiveBlending)
        case .shapeNodeIndexed3DPremultipliedBlending:
            renderEncoder.setRenderPipelineState(pipeline.pipelineStateShapeNodeIndexed3DPremultipliedBlending)
            
        case .shapeNodeColoredIndexed2DNoBlending:
            renderEncoder.setRenderPipelineState(pipeline.pipelineStateShapeNodeColoredIndexed2DNoBlending)
        case .shapeNodeColoredIndexed2DAlphaBlending:
            renderEncoder.setRenderPipelineState(pipeline.pipelineStateShapeNodeColoredIndexed2DAlphaBlending)
        case .shapeNodeColoredIndexed2DAdditiveBlending:
            renderEncoder.setRenderPipelineState(pipeline.pipelineStateShapeNodeColoredIndexed2DAdditiveBlending)
        case .shapeNodeColoredIndexed2DPremultipliedBlending:
            renderEncoder.setRenderPipelineState(pipeline.pipelineStateShapeNodeColoredIndexed2DPremultipliedBlending)
            
        case .shapeNodeColoredIndexed3DNoBlending:
            renderEncoder.setRenderPipelineState(pipeline.pipelineStateShapeNodeColoredIndexed3DNoBlending)
        case .shapeNodeColoredIndexed3DAlphaBlending:
            renderEncoder.setRenderPipelineState(pipeline.pipelineStateShapeNodeColoredIndexed3DAlphaBlending)
        case .shapeNodeColoredIndexed3DAdditiveBlending:
            renderEncoder.setRenderPipelineState(pipeline.pipelineStateShapeNodeColoredIndexed3DAdditiveBlending)
        case .shapeNodeColoredIndexed3DPremultipliedBlending:
            renderEncoder.setRenderPipelineState(pipeline.pipelineStateShapeNodeColoredIndexed3DPremultipliedBlending)
            
        case .sprite2DNoBlending:
            renderEncoder.setRenderPipelineState(pipeline.pipelineStateSprite2DNoBlending)
        case .sprite2DAlphaBlending:
            renderEncoder.setRenderPipelineState(pipeline.pipelineStateSprite2DAlphaBlending)
        case .sprite2DAdditiveBlending:
            renderEncoder.setRenderPipelineState(pipeline.pipelineStateSprite2DAdditiveBlending)
        case .sprite2DPremultipliedBlending:
            renderEncoder.setRenderPipelineState(pipeline.pipelineStateSprite2DPremultipliedBlending)
            
        case .sprite2DYCBCRNoBlending:
            renderEncoder.setRenderPipelineState(pipeline.pipelineStateSprite2DYCBCRNoBlending)
        case .sprite2DYCBCRAlphaBlending:
            renderEncoder.setRenderPipelineState(pipeline.pipelineStateSprite2DYCBCRAlphaBlending)
        case .sprite2DYCBCRAdditiveBlending:
            renderEncoder.setRenderPipelineState(pipeline.pipelineStateSprite2DYCBCRAdditiveBlending)
        case .sprite2DYCBCRPremultipliedBlending:
            renderEncoder.setRenderPipelineState(pipeline.pipelineStateSprite2DYCBCRPremultipliedBlending)
            
        case .sprite3DNoBlending:
            renderEncoder.setRenderPipelineState(pipeline.pipelineStateSprite3DNoBlending)
        case .sprite3DAlphaBlending:
            renderEncoder.setRenderPipelineState(pipeline.pipelineStateSprite3DAlphaBlending)
        case .sprite3DAdditiveBlending:
            renderEncoder.setRenderPipelineState(pipeline.pipelineStateSprite3DAdditiveBlending)
        case .sprite3DPremultipliedBlending:
            renderEncoder.setRenderPipelineState(pipeline.pipelineStateSprite3DPremultipliedBlending)
            
            
            
        case .sprite3DYCBCRNoBlending:
            renderEncoder.setRenderPipelineState(pipeline.pipelineStateSprite3DYCBCRNoBlending)
        case .sprite3DYCBCRAlphaBlending:
            renderEncoder.setRenderPipelineState(pipeline.pipelineStateSprite3DYCBCRAlphaBlending)
        case .sprite3DYCBCRAdditiveBlending:
            renderEncoder.setRenderPipelineState(pipeline.pipelineStateSprite3DYCBCRAdditiveBlending)
        case .sprite3DYCBCRPremultipliedBlending:
            renderEncoder.setRenderPipelineState(pipeline.pipelineStateSprite3DYCBCRPremultipliedBlending)
            
        case .spriteNodeIndexed2DNoBlending:
            renderEncoder.setRenderPipelineState(pipeline.pipelineStateSpriteNodeIndexed2DNoBlending)
        case .spriteNodeIndexed2DAlphaBlending:
            renderEncoder.setRenderPipelineState(pipeline.pipelineStateSpriteNodeIndexed2DAlphaBlending)
        case .spriteNodeIndexed2DAdditiveBlending:
            renderEncoder.setRenderPipelineState(pipeline.pipelineStateSpriteNodeIndexed2DAdditiveBlending)
        case .spriteNodeIndexed2DPremultipliedBlending:
            renderEncoder.setRenderPipelineState(pipeline.pipelineStateSpriteNodeIndexed2DPremultipliedBlending)
        case .spriteNodeIndexed3DNoBlending:
            renderEncoder.setRenderPipelineState(pipeline.pipelineStateSpriteNodeIndexed3DNoBlending)
        case .spriteNodeIndexed3DAlphaBlending:
            renderEncoder.setRenderPipelineState(pipeline.pipelineStateSpriteNodeIndexed3DAlphaBlending)
        case .spriteNodeIndexed3DAdditiveBlending:
            renderEncoder.setRenderPipelineState(pipeline.pipelineStateSpriteNodeIndexed3DAdditiveBlending)
        case .spriteNodeIndexed3DPremultipliedBlending:
            renderEncoder.setRenderPipelineState(pipeline.pipelineStateSpriteNodeIndexed3DPremultipliedBlending)
            
        case .spriteNodeIndexed3DYCBCRNoBlending:
            renderEncoder.setRenderPipelineState(pipeline.pipelineStateSpriteNodeIndexed3DYCBCRNoBlending)
        case .spriteNodeIndexed3DYCBCRAlphaBlending:
            renderEncoder.setRenderPipelineState(pipeline.pipelineStateSpriteNodeIndexed3DYCBCRAlphaBlending)
        case .spriteNodeIndexed3DYCBCRAdditiveBlending:
            renderEncoder.setRenderPipelineState(pipeline.pipelineStateSpriteNodeIndexed3DYCBCRAdditiveBlending)
        case .spriteNodeIndexed3DYCBCRPremultipliedBlending:
            renderEncoder.setRenderPipelineState(pipeline.pipelineStateSpriteNodeIndexed3DYCBCRPremultipliedBlending)
            
        case .spriteNodeColoredIndexed2DNoBlending:
            renderEncoder.setRenderPipelineState(pipeline.pipelineStateSpriteNodeColoredIndexed2DNoBlending)
        case .spriteNodeColoredIndexed2DAlphaBlending:
            renderEncoder.setRenderPipelineState(pipeline.pipelineStateSpriteNodeColoredIndexed2DAlphaBlending)
        case .spriteNodeColoredIndexed2DAdditiveBlending:
            renderEncoder.setRenderPipelineState(pipeline.pipelineStateSpriteNodeColoredIndexed2DAdditiveBlending)
        case .spriteNodeColoredIndexed2DPremultipliedBlending:
            renderEncoder.setRenderPipelineState(pipeline.pipelineStateSpriteNodeColoredIndexed2DPremultipliedBlending)
            
        case .spriteNodeColoredIndexed2DYCBCRNoBlending:
            renderEncoder.setRenderPipelineState(pipeline.pipelineStateSpriteNodeColoredIndexed2DNoBlending)
        case .spriteNodeColoredIndexed2DYCBCRAlphaBlending:
            renderEncoder.setRenderPipelineState(pipeline.pipelineStateSpriteNodeColoredIndexed2DAlphaBlending)
        case .spriteNodeColoredIndexed2DYCBCRAdditiveBlending:
            renderEncoder.setRenderPipelineState(pipeline.pipelineStateSpriteNodeColoredIndexed2DAdditiveBlending)
        case .spriteNodeColoredIndexed2DYCBCRPremultipliedBlending:
            renderEncoder.setRenderPipelineState(pipeline.pipelineStateSpriteNodeColoredIndexed2DPremultipliedBlending)
            
        case .spriteNodeColoredIndexed3DNoBlending:
            renderEncoder.setRenderPipelineState(pipeline.pipelineStateSpriteNodeColoredIndexed3DNoBlending)
        case .spriteNodeColoredIndexed3DAlphaBlending:
            renderEncoder.setRenderPipelineState(pipeline.pipelineStateSpriteNodeColoredIndexed3DAlphaBlending)
        case .spriteNodeColoredIndexed3DAdditiveBlending:
            renderEncoder.setRenderPipelineState(pipeline.pipelineStateSpriteNodeColoredIndexed3DAdditiveBlending)
        case .spriteNodeColoredIndexed3DPremultipliedBlending:
            renderEncoder.setRenderPipelineState(pipeline.pipelineStateSpriteNodeColoredIndexed3DPremultipliedBlending)
            
        case .spriteNodeColoredIndexed3DYCBCRNoBlending:
            renderEncoder.setRenderPipelineState(pipeline.pipelineStateSpriteNodeColoredIndexed3DYCBCRNoBlending)
        case .spriteNodeColoredIndexed3DYCBCRAlphaBlending:
            renderEncoder.setRenderPipelineState(pipeline.pipelineStateSpriteNodeColoredIndexed3DYCBCRAlphaBlending)
        case .spriteNodeColoredIndexed3DYCBCRAdditiveBlending:
            renderEncoder.setRenderPipelineState(pipeline.pipelineStateSpriteNodeColoredIndexed3DYCBCRAdditiveBlending)
        case .spriteNodeColoredIndexed3DYCBCRPremultipliedBlending:
            renderEncoder.setRenderPipelineState(pipeline.pipelineStateSpriteNodeColoredIndexed3DYCBCRPremultipliedBlending)
        }
    }
    
    func set(depthState: DepthState, renderEncoder: MTLRenderCommandEncoder) {
        self.depthState = depthState
        switch depthState {
        case .invalid:
            break
        case .disabled:
            renderEncoder.setDepthStencilState(engine.depthStateDisabled)
        case .lessThan:
            renderEncoder.setDepthStencilState(engine.depthStateLessThan)
        case .lessThanEqual:
            renderEncoder.setDepthStencilState(engine.depthStateLessThanEqual)
        }
    }
    
    func set(samplerState: SamplerState, renderEncoder: MTLRenderCommandEncoder) {
        
        self.samplerState = samplerState
        
        var metalSamplerState: MTLSamplerState!
        switch samplerState {
        case .linearClamp:
            metalSamplerState = engine.samplerStateLinearClamp
        case .linearRepeat:
            metalSamplerState = engine.samplerStateLinearRepeat
        default:
            break
        }
        
        switch pipelineState {
        case .sprite2DNoBlending,
                .sprite2DAlphaBlending,
                .sprite2DAdditiveBlending,
                .sprite2DPremultipliedBlending,
                .sprite3DNoBlending,
                .sprite3DAlphaBlending,
                .sprite3DAdditiveBlending,
                .sprite3DPremultipliedBlending:
            renderEncoder.setFragmentSamplerState(metalSamplerState, index: MetalPipeline.spriteFragmentIndexSampler)
        case .sprite2DYCBCRNoBlending,
                .sprite2DYCBCRAlphaBlending,
                .sprite2DYCBCRAdditiveBlending,
                .sprite2DYCBCRPremultipliedBlending,
            
                .sprite3DYCBCRNoBlending,
                .sprite3DYCBCRAlphaBlending,
                .sprite3DYCBCRAdditiveBlending,
                .sprite3DYCBCRPremultipliedBlending:
            renderEncoder.setFragmentSamplerState(metalSamplerState, index: MetalPipeline.spriteYCBCRFragmentIndexSampler)
        case .spriteNodeIndexed2DNoBlending,
                .spriteNodeIndexed2DAlphaBlending,
                .spriteNodeIndexed2DAdditiveBlending,
                .spriteNodeIndexed2DPremultipliedBlending,
                .spriteNodeColoredIndexed2DNoBlending,
                .spriteNodeColoredIndexed2DAlphaBlending,
                .spriteNodeColoredIndexed2DAdditiveBlending,
                .spriteNodeColoredIndexed2DPremultipliedBlending,
                .spriteNodeIndexed3DNoBlending,
                .spriteNodeIndexed3DAlphaBlending,
                .spriteNodeIndexed3DAdditiveBlending,
                .spriteNodeIndexed3DPremultipliedBlending,
                .spriteNodeColoredIndexed3DNoBlending,
                .spriteNodeColoredIndexed3DAlphaBlending,
                .spriteNodeColoredIndexed3DAdditiveBlending,
                .spriteNodeColoredIndexed3DPremultipliedBlending:
            renderEncoder.setFragmentSamplerState(metalSamplerState, index: MetalPipeline.spriteNodeIndexedFragmentIndexSampler)
            
        case .spriteNodeIndexed3DYCBCRNoBlending,
                .spriteNodeIndexed3DYCBCRAlphaBlending,
                .spriteNodeIndexed3DYCBCRAdditiveBlending,
                .spriteNodeIndexed3DYCBCRPremultipliedBlending,
            
                .spriteNodeColoredIndexed2DYCBCRNoBlending,
                .spriteNodeColoredIndexed2DYCBCRAlphaBlending,
                .spriteNodeColoredIndexed2DYCBCRAdditiveBlending,
                .spriteNodeColoredIndexed2DYCBCRPremultipliedBlending,
            
                .spriteNodeColoredIndexed3DYCBCRNoBlending,
                .spriteNodeColoredIndexed3DYCBCRAlphaBlending,
                .spriteNodeColoredIndexed3DYCBCRAdditiveBlending,
                .spriteNodeColoredIndexed3DYCBCRPremultipliedBlending:
            renderEncoder.setFragmentSamplerState(metalSamplerState, index: MetalPipeline.spriteNodeYCBCRIndexedFragmentIndexSampler)
            
        default:
            break
        }
    }
    
    func setVertexUniformsBuffer(_ uniformsBuffer: MTLBuffer?, renderEncoder: MTLRenderCommandEncoder) {
        if let uniformsBuffer = uniformsBuffer {
            switch pipelineState {
            case .shape2DNoBlending,
                    .shape2DAlphaBlending,
                    .shape2DAdditiveBlending,
                    .shape2DPremultipliedBlending,
                    .shape3DNoBlending,
                    .shape3DAlphaBlending,
                    .shape3DAdditiveBlending,
                    .shape3DPremultipliedBlending:
                renderEncoder.setVertexBuffer(uniformsBuffer, offset: 0, index: MetalPipeline.shapeVertexIndexUniforms)
                
            case .shapeNodeIndexed2DNoBlending,
                    .shapeNodeIndexed2DAlphaBlending,
                    .shapeNodeIndexed2DAdditiveBlending,
                    .shapeNodeIndexed2DPremultipliedBlending,
                    .shapeNodeColoredIndexed2DNoBlending,
                    .shapeNodeColoredIndexed2DAlphaBlending,
                    .shapeNodeColoredIndexed2DAdditiveBlending,
                    .shapeNodeColoredIndexed2DPremultipliedBlending,
                    .spriteNodeColoredIndexed2DYCBCRNoBlending,
                    .spriteNodeColoredIndexed2DYCBCRAlphaBlending,
                    .spriteNodeColoredIndexed2DYCBCRAdditiveBlending,
                    .spriteNodeColoredIndexed2DYCBCRPremultipliedBlending,
                    .shapeNodeIndexed3DNoBlending,
                    .shapeNodeIndexed3DAlphaBlending,
                    .shapeNodeIndexed3DAdditiveBlending,
                    .shapeNodeIndexed3DPremultipliedBlending,
                    .shapeNodeColoredIndexed3DNoBlending,
                    .shapeNodeColoredIndexed3DAlphaBlending,
                    .shapeNodeColoredIndexed3DAdditiveBlending,
                    .shapeNodeColoredIndexed3DPremultipliedBlending:
                
                renderEncoder.setVertexBuffer(uniformsBuffer, offset: 0, index: MetalPipeline.shapeNodeIndexedVertexIndexUniforms)
                
            case .sprite2DNoBlending,
                    .sprite2DAlphaBlending,
                    .sprite2DAdditiveBlending,
                    .sprite2DPremultipliedBlending,
                
                    .sprite2DYCBCRNoBlending,
                    .sprite2DYCBCRAlphaBlending,
                    .sprite2DYCBCRAdditiveBlending,
                    .sprite2DYCBCRPremultipliedBlending,
                
                    .sprite3DNoBlending,
                    .sprite3DAlphaBlending,
                    .sprite3DAdditiveBlending,
                    .sprite3DPremultipliedBlending,
                
                    .sprite3DYCBCRNoBlending,
                    .sprite3DYCBCRAlphaBlending,
                    .sprite3DYCBCRAdditiveBlending,
                    .sprite3DYCBCRPremultipliedBlending:
                renderEncoder.setVertexBuffer(uniformsBuffer, offset: 0, index: MetalPipeline.spriteVertexIndexUniforms)
                
            case .spriteNodeIndexed2DNoBlending,
                    .spriteNodeIndexed2DAlphaBlending,
                    .spriteNodeIndexed2DAdditiveBlending,
                    .spriteNodeIndexed2DPremultipliedBlending,
                    .spriteNodeColoredIndexed2DNoBlending,
                    .spriteNodeColoredIndexed2DAlphaBlending,
                    .spriteNodeColoredIndexed2DAdditiveBlending,
                    .spriteNodeColoredIndexed2DPremultipliedBlending,
                    .spriteNodeIndexed3DNoBlending,
                    .spriteNodeIndexed3DAlphaBlending,
                    .spriteNodeIndexed3DAdditiveBlending,
                    .spriteNodeIndexed3DPremultipliedBlending,
                    .spriteNodeIndexed3DYCBCRNoBlending,
                    .spriteNodeIndexed3DYCBCRAlphaBlending,
                    .spriteNodeIndexed3DYCBCRAdditiveBlending,
                    .spriteNodeIndexed3DYCBCRPremultipliedBlending,
                    .spriteNodeColoredIndexed3DNoBlending,
                    .spriteNodeColoredIndexed3DAlphaBlending,
                    .spriteNodeColoredIndexed3DAdditiveBlending,
                    .spriteNodeColoredIndexed3DPremultipliedBlending,
                    .spriteNodeColoredIndexed3DYCBCRNoBlending,
                    .spriteNodeColoredIndexed3DYCBCRAlphaBlending,
                    .spriteNodeColoredIndexed3DYCBCRAdditiveBlending,
                    .spriteNodeColoredIndexed3DYCBCRPremultipliedBlending:
                renderEncoder.setVertexBuffer(uniformsBuffer, offset: 0, index: MetalPipeline.spriteNodeIndexedVertexIndexUniforms)
                
            default:
                break
            }
        }
    }

    func setFragmentUniformsBuffer(_ uniformsBuffer: MTLBuffer?, renderEncoder: MTLRenderCommandEncoder) {
        if let uniformsBuffer = uniformsBuffer {
            switch pipelineState {
            case .shape2DNoBlending,
                    .shape2DAlphaBlending,
                    .shape2DAdditiveBlending,
                    .shape2DPremultipliedBlending,
                    .shape3DNoBlending,
                    .shape3DAlphaBlending,
                    .shape3DAdditiveBlending,
                    .shape3DPremultipliedBlending:
                renderEncoder.setFragmentBuffer(uniformsBuffer, offset: 0, index: MetalPipeline.shapeFragmentIndexUniforms)
                
            case .shapeNodeIndexed2DNoBlending,
                    .shapeNodeIndexed2DAlphaBlending,
                    .shapeNodeIndexed2DAdditiveBlending,
                    .shapeNodeIndexed2DPremultipliedBlending,
                    .shapeNodeColoredIndexed2DNoBlending,
                    .shapeNodeColoredIndexed2DAlphaBlending,
                    .shapeNodeColoredIndexed2DAdditiveBlending,
                    .shapeNodeColoredIndexed2DPremultipliedBlending,
                    .shapeNodeIndexed3DNoBlending,
                    .shapeNodeIndexed3DAlphaBlending,
                    .shapeNodeIndexed3DAdditiveBlending,
                    .shapeNodeIndexed3DPremultipliedBlending,
                    .shapeNodeColoredIndexed3DNoBlending,
                    .shapeNodeColoredIndexed3DAlphaBlending,
                    .shapeNodeColoredIndexed3DAdditiveBlending,
                    .shapeNodeColoredIndexed3DPremultipliedBlending:
                renderEncoder.setFragmentBuffer(uniformsBuffer, offset: 0, index: MetalPipeline.shapeNodeIndexedFragmentIndexUniforms)
                
            case .sprite2DNoBlending,
                    .sprite2DAlphaBlending,
                    .sprite2DAdditiveBlending,
                    .sprite2DPremultipliedBlending,
                
                    .sprite3DNoBlending,
                    .sprite3DAlphaBlending,
                    .sprite3DAdditiveBlending,
                    .sprite3DPremultipliedBlending:
                renderEncoder.setFragmentBuffer(uniformsBuffer, offset: 0, index: MetalPipeline.spriteFragmentIndexUniforms)
                
            case .sprite2DYCBCRNoBlending,
                    .sprite2DYCBCRAlphaBlending,
                    .sprite2DYCBCRAdditiveBlending,
                    .sprite2DYCBCRPremultipliedBlending,
                
                    .sprite3DYCBCRNoBlending,
                    .sprite3DYCBCRAlphaBlending,
                    .sprite3DYCBCRAdditiveBlending,
                    .sprite3DYCBCRPremultipliedBlending:
                renderEncoder.setFragmentBuffer(uniformsBuffer, offset: 0, index: MetalPipeline.spriteYCBCRFragmentIndexUniforms)
            
            case .spriteNodeIndexed2DNoBlending,
                    .spriteNodeIndexed2DAlphaBlending,
                    .spriteNodeIndexed2DAdditiveBlending,
                    .spriteNodeIndexed2DPremultipliedBlending,
                    .spriteNodeColoredIndexed2DNoBlending,
                    .spriteNodeColoredIndexed2DAlphaBlending,
                    .spriteNodeColoredIndexed2DAdditiveBlending,
                    .spriteNodeColoredIndexed2DPremultipliedBlending,
                    .spriteNodeIndexed3DNoBlending,
                    .spriteNodeIndexed3DAlphaBlending,
                    .spriteNodeIndexed3DAdditiveBlending,
                    .spriteNodeIndexed3DPremultipliedBlending,
                    .spriteNodeColoredIndexed3DNoBlending,
                    .spriteNodeColoredIndexed3DAlphaBlending,
                    .spriteNodeColoredIndexed3DAdditiveBlending,
                    .spriteNodeColoredIndexed3DPremultipliedBlending:
                renderEncoder.setFragmentBuffer(uniformsBuffer, offset: 0, index: MetalPipeline.spriteNodeIndexedFragmentIndexUniforms)
                    
            case .spriteNodeIndexed3DYCBCRNoBlending,
                    .spriteNodeIndexed3DYCBCRAlphaBlending,
                    .spriteNodeIndexed3DYCBCRAdditiveBlending,
                    .spriteNodeIndexed3DYCBCRPremultipliedBlending,
                    .spriteNodeColoredIndexed2DYCBCRNoBlending,
                    .spriteNodeColoredIndexed2DYCBCRAlphaBlending,
                    .spriteNodeColoredIndexed2DYCBCRAdditiveBlending,
                    .spriteNodeColoredIndexed2DYCBCRPremultipliedBlending,
                    .spriteNodeColoredIndexed3DYCBCRNoBlending,
                    .spriteNodeColoredIndexed3DYCBCRAlphaBlending,
                    .spriteNodeColoredIndexed3DYCBCRAdditiveBlending,
                    .spriteNodeColoredIndexed3DYCBCRPremultipliedBlending:
                renderEncoder.setFragmentBuffer(uniformsBuffer, offset: 0, index: MetalPipeline.spriteNodeYCBCRIndexedFragmentIndexUniforms)
            default:
                break
            }
        }
    }
    
    func setVertexDataBuffer(_ dataBuffer: MTLBuffer?, renderEncoder: MTLRenderCommandEncoder) {
        if let dataBuffer = dataBuffer {
            switch pipelineState {
            case .shapeNodeIndexed2DNoBlending,
                    .shapeNodeIndexed2DAlphaBlending,
                    .shapeNodeIndexed2DAdditiveBlending,
                    .shapeNodeIndexed2DPremultipliedBlending,
                    .shapeNodeColoredIndexed2DNoBlending,
                    .shapeNodeColoredIndexed2DAlphaBlending,
                    .shapeNodeColoredIndexed2DAdditiveBlending,
                    .shapeNodeColoredIndexed2DPremultipliedBlending,
                    .shapeNodeIndexed3DNoBlending,
                    .shapeNodeIndexed3DAlphaBlending,
                    .shapeNodeIndexed3DAdditiveBlending,
                    .shapeNodeIndexed3DPremultipliedBlending,
                    .shapeNodeColoredIndexed3DNoBlending,
                    .shapeNodeColoredIndexed3DAlphaBlending,
                    .shapeNodeColoredIndexed3DAdditiveBlending,
                    .shapeNodeColoredIndexed3DPremultipliedBlending:
                renderEncoder.setVertexBuffer(dataBuffer, offset: 0, index: MetalPipeline.shapeNodeIndexedVertexIndexData)
                
            
            case .spriteNodeIndexed2DNoBlending,
                    .spriteNodeIndexed2DAlphaBlending,
                    .spriteNodeIndexed2DAdditiveBlending,
                    .spriteNodeIndexed2DPremultipliedBlending,
                    .spriteNodeColoredIndexed2DNoBlending,
                    .spriteNodeColoredIndexed2DAlphaBlending,
                    .spriteNodeColoredIndexed2DAdditiveBlending,
                    .spriteNodeColoredIndexed2DPremultipliedBlending,
                    .spriteNodeColoredIndexed2DYCBCRNoBlending,
                    .spriteNodeColoredIndexed2DYCBCRAlphaBlending,
                    .spriteNodeColoredIndexed2DYCBCRAdditiveBlending,
                    .spriteNodeColoredIndexed2DYCBCRPremultipliedBlending,
                    .spriteNodeIndexed3DNoBlending,
                    .spriteNodeIndexed3DAlphaBlending,
                    .spriteNodeIndexed3DAdditiveBlending,
                    .spriteNodeIndexed3DPremultipliedBlending,
                    .spriteNodeIndexed3DYCBCRNoBlending,
                    .spriteNodeIndexed3DYCBCRAlphaBlending,
                    .spriteNodeIndexed3DYCBCRAdditiveBlending,
                    .spriteNodeIndexed3DYCBCRPremultipliedBlending,
                    .spriteNodeColoredIndexed3DNoBlending,
                    .spriteNodeColoredIndexed3DAlphaBlending,
                    .spriteNodeColoredIndexed3DAdditiveBlending,
                    .spriteNodeColoredIndexed3DPremultipliedBlending,
                    .spriteNodeColoredIndexed3DYCBCRNoBlending,
                    .spriteNodeColoredIndexed3DYCBCRAlphaBlending,
                    .spriteNodeColoredIndexed3DYCBCRAdditiveBlending,
                    .spriteNodeColoredIndexed3DYCBCRPremultipliedBlending:
                renderEncoder.setVertexBuffer(dataBuffer, offset: 0, index: MetalPipeline.spriteNodeIndexedVertexIndexData)
                
            default:
                break
            }
        }
    }
    
    func setVertexPositionsBuffer(_ positionsBuffer: MTLBuffer?, renderEncoder: MTLRenderCommandEncoder) {
        if let positionsBuffer = positionsBuffer {
            switch pipelineState {
            case .shape2DNoBlending,
                    .shape2DAlphaBlending,
                    .shape2DAdditiveBlending,
                    .shape2DPremultipliedBlending,
                    .shape3DNoBlending,
                    .shape3DAlphaBlending,
                    .shape3DAdditiveBlending,
                    .shape3DPremultipliedBlending:
                renderEncoder.setVertexBuffer(positionsBuffer, offset: 0, index: MetalPipeline.shapeVertexIndexPosition)
            case .sprite2DNoBlending,
                    .sprite2DAlphaBlending,
                    .sprite2DAdditiveBlending,
                    .sprite2DPremultipliedBlending,
                
                    .sprite2DYCBCRNoBlending,
                    .sprite2DYCBCRAlphaBlending,
                    .sprite2DYCBCRAdditiveBlending,
                    .sprite2DYCBCRPremultipliedBlending,
                
                    .sprite3DNoBlending,
                    .sprite3DAlphaBlending,
                    .sprite3DAdditiveBlending,
                    .sprite3DPremultipliedBlending,
                
                    .sprite3DYCBCRNoBlending,
                    .sprite3DYCBCRAlphaBlending,
                    .sprite3DYCBCRAdditiveBlending,
                    .sprite3DYCBCRPremultipliedBlending:
                renderEncoder.setVertexBuffer(positionsBuffer, offset: 0, index: MetalPipeline.spriteVertexIndexPosition)
            default:
                break
            }
        }
    }
    
    func setVertexTextureCoordsBuffer(_ textureCoordsBuffer: MTLBuffer?, renderEncoder: MTLRenderCommandEncoder) {
        if let textureCoordsBuffer = textureCoordsBuffer {
            switch pipelineState {
            case .sprite2DNoBlending,
                    .sprite2DAlphaBlending,
                    .sprite2DAdditiveBlending,
                    .sprite2DPremultipliedBlending,
                
                    .sprite2DYCBCRNoBlending,
                    .sprite2DYCBCRAlphaBlending,
                    .sprite2DYCBCRAdditiveBlending,
                    .sprite2DYCBCRPremultipliedBlending,
                
                    .sprite3DNoBlending,
                    .sprite3DAlphaBlending,
                    .sprite3DAdditiveBlending,
                    .sprite3DPremultipliedBlending,
                
                    .sprite3DYCBCRNoBlending,
                    .sprite3DYCBCRAlphaBlending,
                    .sprite3DYCBCRAdditiveBlending,
                    .sprite3DYCBCRPremultipliedBlending:
                renderEncoder.setVertexBuffer(textureCoordsBuffer, offset: 0, index: MetalPipeline.spriteVertexIndexTextureCoord)
            default:
                break
            }
        }
    }

    func setFragmentTexture(_ texture: MTLTexture?, renderEncoder: MTLRenderCommandEncoder) {
        if let texture = texture {
            switch pipelineState {
            case .sprite2DNoBlending,
                    .sprite2DAlphaBlending,
                    .sprite2DAdditiveBlending,
                    .sprite2DPremultipliedBlending,
                    .sprite3DNoBlending,
                    .sprite3DAlphaBlending,
                    .sprite3DAdditiveBlending,
                    .sprite3DPremultipliedBlending:
                renderEncoder.setFragmentTexture(texture, index: MetalPipeline.spriteFragmentIndexTexture)
            case .spriteNodeIndexed2DNoBlending,
                    .spriteNodeIndexed2DAlphaBlending,
                    .spriteNodeIndexed2DAdditiveBlending,
                    .spriteNodeIndexed2DPremultipliedBlending,
                    .spriteNodeColoredIndexed2DNoBlending,
                    .spriteNodeColoredIndexed2DAlphaBlending,
                    .spriteNodeColoredIndexed2DAdditiveBlending,
                    .spriteNodeColoredIndexed2DPremultipliedBlending,
                    .spriteNodeIndexed3DNoBlending,
                    .spriteNodeIndexed3DAlphaBlending,
                    .spriteNodeIndexed3DAdditiveBlending,
                    .spriteNodeIndexed3DPremultipliedBlending,
                    .spriteNodeColoredIndexed3DNoBlending,
                    .spriteNodeColoredIndexed3DAlphaBlending,
                    .spriteNodeColoredIndexed3DAdditiveBlending,
                    .spriteNodeColoredIndexed3DPremultipliedBlending:
                renderEncoder.setFragmentTexture(texture, index: MetalPipeline.spriteNodeIndexedFragmentIndexTexture)
            default:
                break
            }
        }
    }
    
    func setFragmentTextureY(_ texture: MTLTexture?, renderEncoder: MTLRenderCommandEncoder) {
        if let texture = texture {
            switch pipelineState {
            case .sprite2DYCBCRNoBlending,
                    .sprite2DYCBCRAlphaBlending,
                    .sprite2DYCBCRAdditiveBlending,
                    .sprite2DYCBCRPremultipliedBlending,
                    .sprite3DYCBCRNoBlending,
                    .sprite3DYCBCRAlphaBlending,
                    .sprite3DYCBCRAdditiveBlending,
                    .sprite3DYCBCRPremultipliedBlending:
                renderEncoder.setFragmentTexture(texture, index: MetalPipeline.spriteYCBCRFragmentIndexTextureY)
                
            case
                    .spriteNodeColoredIndexed2DYCBCRNoBlending,
                    .spriteNodeColoredIndexed2DYCBCRAlphaBlending,
                    .spriteNodeColoredIndexed2DYCBCRAdditiveBlending,
                    .spriteNodeColoredIndexed2DYCBCRPremultipliedBlending,
                    .spriteNodeIndexed3DYCBCRNoBlending,
                    .spriteNodeIndexed3DYCBCRAlphaBlending,
                    .spriteNodeIndexed3DYCBCRAdditiveBlending,
                    .spriteNodeIndexed3DYCBCRPremultipliedBlending,
                    .spriteNodeColoredIndexed3DYCBCRNoBlending,
                    .spriteNodeColoredIndexed3DYCBCRAlphaBlending,
                    .spriteNodeColoredIndexed3DYCBCRAdditiveBlending,
                    .spriteNodeColoredIndexed3DYCBCRPremultipliedBlending:
                renderEncoder.setFragmentTexture(texture, index: MetalPipeline.spriteNodeYCBCRIndexedFragmentIndexTextureY)
                
            default:
                break
            }
        }
    }
    
    func setFragmentTextureCBCR(_ texture: MTLTexture?, renderEncoder: MTLRenderCommandEncoder) {
        if let texture = texture {
            switch pipelineState {
            case .sprite2DYCBCRNoBlending,
                    .sprite2DYCBCRAlphaBlending,
                    .sprite2DYCBCRAdditiveBlending,
                    .sprite2DYCBCRPremultipliedBlending,
                
                    .sprite3DYCBCRNoBlending,
                    .sprite3DYCBCRAlphaBlending,
                    .sprite3DYCBCRAdditiveBlending,
                    .sprite3DYCBCRPremultipliedBlending:
                renderEncoder.setFragmentTexture(texture, index: MetalPipeline.spriteYCBCRFragmentIndexTextureCBCR)
                
            case .spriteNodeColoredIndexed2DYCBCRNoBlending,
                    .spriteNodeColoredIndexed2DYCBCRAlphaBlending,
                    .spriteNodeColoredIndexed2DYCBCRAdditiveBlending,
                    .spriteNodeColoredIndexed2DYCBCRPremultipliedBlending,
                
                    .spriteNodeIndexed3DYCBCRNoBlending,
                    .spriteNodeIndexed3DYCBCRAlphaBlending,
                    .spriteNodeIndexed3DYCBCRAdditiveBlending,
                    .spriteNodeIndexed3DYCBCRPremultipliedBlending,
                
                    .spriteNodeColoredIndexed3DYCBCRNoBlending,
                    .spriteNodeColoredIndexed3DYCBCRAlphaBlending,
                    .spriteNodeColoredIndexed3DYCBCRAdditiveBlending,
                    .spriteNodeColoredIndexed3DYCBCRPremultipliedBlending:
                renderEncoder.setFragmentTexture(texture, index: MetalPipeline.spriteNodeYCBCRIndexedFragmentIndexTextureCBCR)
                
            default:
                break
            }
        }
    }
    
}
