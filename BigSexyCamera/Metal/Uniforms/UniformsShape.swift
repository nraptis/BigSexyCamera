//
//  UniformsShape.swift
//  RebuildEarth
//
//  Created by Nicky Taylor on 2/10/23.
//

import Foundation
import simd

struct UniformsShapeFragment: Uniforms {
    
    var red: Float
    var green: Float
    var blue: Float
    var alpha: Float
    
    init() {
        red = 1.0
        green = 1.0
        blue = 1.0
        alpha = 1.0
    }
    
    mutating func set(red: Float, green: Float, blue: Float) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = 1.0
    }
    
    mutating func set(red: Float, green: Float, blue: Float, alpha: Float) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }
    
    var size: Int {
        var result = 0
        result += (MemoryLayout<Float>.size << 2)
        return result
    }
    
    var data: [Float] {
        var result = [Float]()
        result.reserveCapacity(size)
        result.append(red)
        result.append(green)
        result.append(blue)
        result.append(alpha)
        return result
    }
}

struct UniformsShapeVertex: Uniforms {
    
    var projectionMatrix: matrix_float4x4
    var modelViewMatrix: matrix_float4x4
    
    init() {
        projectionMatrix = matrix_identity_float4x4
        modelViewMatrix = matrix_identity_float4x4
    }
    
    var size: Int {
        var result = 0
        result += (MemoryLayout<matrix_float4x4>.size)
        result += (MemoryLayout<matrix_float4x4>.size)
        return result
    }
    
    var data: [Float] {
        var result = [Float]()
        result.reserveCapacity(size)
        result.append(contentsOf: projectionMatrix.array())
        result.append(contentsOf: modelViewMatrix.array())
        return result
    }
}
