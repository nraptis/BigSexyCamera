//
//  Paddle.swift
//  PongCLPA
//
//  Created by Tiger Nixon on 5/4/23.
//

import Foundation
import Metal

class Paddle {
    
    var x: Float = 0.0
    var y: Float = 0.0
    
    
    let graphics: Graphics
    
    var uniformsVertex = UniformsShapeVertex()
    var uniformsFragment = UniformsShapeFragment()
    
    var positions = [Float](repeating: 0.0, count: 8)
    lazy var positionsBuffer: MTLBuffer = {
        graphics.buffer(array: positions)
    }()
    
    lazy var uniformsVertexBuffer: MTLBuffer = {
        graphics.buffer(uniform: uniformsVertex)
    }()
    
    lazy var uniformsFragmentBuffer: MTLBuffer = {
        graphics.buffer(uniform: uniformsFragment)
    }()
    
    lazy var width: Float = {
        roundf(min(graphics.width * 0.33, 240.0))
    }()
    
    lazy var height: Float = {
        roundf(width * 0.2)
    }()
    
    init(graphics: Graphics) {
        self.graphics = graphics
        
    }
    
    func update(x: Float, y: Float) {
        
        self.x = x
        self.y = y
        
        positions[0] = x
        positions[1] = y
        
        positions[2] = x + width
        positions[3] = y
        
        positions[4] = x
        positions[5] = y + height
        
        positions[6] = x + width
        positions[7] = y + height
    }
    
    func draw(renderEncoder: MTLRenderCommandEncoder) {
        
        uniformsVertex.projectionMatrix.ortho(width: graphics.width,
                                              height: graphics.height)
        
        graphics.write(buffer: positionsBuffer, array: positions)
        graphics.write(buffer: uniformsVertexBuffer, uniform: uniformsVertex)
        graphics.write(buffer: uniformsFragmentBuffer, uniform: uniformsFragment)
        
        graphics.set(pipelineState: .shape2DNoBlending, renderEncoder: renderEncoder)
        
        graphics.setVertexPositionsBuffer(positionsBuffer, renderEncoder: renderEncoder)
        graphics.setVertexUniformsBuffer(uniformsVertexBuffer, renderEncoder: renderEncoder)
        graphics.setFragmentUniformsBuffer(uniformsFragmentBuffer, renderEncoder: renderEncoder)
        
        renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
    }
}
