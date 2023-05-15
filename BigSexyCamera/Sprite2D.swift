//
//  Sprite2D.swift
//  RebuildEarth
//
//  Created by Nicky Taylor on 2/12/23.
//

import Foundation
import Metal

class Sprite2D {
    
    private(set) var texture: MTLTexture?
    var width: Float = 0.0
    var height: Float = 0.0
    
    var positions: [Float] = [-64.0, -64.0,
                               64.0, -64.0,
                              -64.0, 64.0,
                               64.0, 64.0]
    
    var textureCoords: [Float] = [0.0, 0.0,
                                  1.0, 0.0,
                                  0.0, 1.0,
                                  1.0, 1.0]
    
    init() {
        
    }
    
    func load(graphics: Graphics, texture: MTLTexture?) {
        
        if let texture = texture {
            self.texture = texture
            width = Float(texture.width)
            height = Float(texture.width)
            
            let width_2 = width * 0.5
            let height_2 = height * 0.5
            let _width_2 = -(width_2)
            let _height_2 = -(height_2)
            
            positions[0] = _width_2
            positions[1] = _height_2
            positions[2] = width_2
            positions[3] = _height_2
            positions[4] = _width_2
            positions[5] = height_2
            positions[6] = width_2
            positions[7] = height_2
        } else {
            self.texture = nil
            width = 0.0
            height = 0.0
        }
    }
    
    func load(graphics: Graphics, fileName: String) {
        let texture = graphics.loadTexture(fileName: fileName)
        load(graphics: graphics, texture: texture)
    }
}

