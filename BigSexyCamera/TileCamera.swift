//
//  TileCamera.swift
//  BigSexyCamera
//
//  Created by Tiger Nixon on 5/17/23.
//

import Foundation
import simd

struct TileCamera {

    static let baseUnitEye = SIMD3<Float>(x: 0.0, y: 0.0, z: -1.0)
    static let baseUp = SIMD3<Float>(x: 0.0, y: -1.0, z: 0.0)
    static let baseCenter = SIMD3<Float>(x: 0.0, y: 0.0, z: 0.0)
    
    lazy var perspective: matrix_float4x4 = {
        let aspect = graphics.width / graphics.height
        var perspective = matrix_float4x4()
        perspective.perspective(fovy: Float.pi * 0.5, aspect: aspect, nearZ: 0.01, farZ: 4096.0)
        return perspective
    }()
    
    let graphics: Graphics
    init(graphics: Graphics) {
        self.graphics = graphics
    }
    
    
    
}
