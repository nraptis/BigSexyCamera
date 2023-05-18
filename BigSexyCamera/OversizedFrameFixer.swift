//
//  OversizedFrameFixer.swift
//  BigSexyCamera
//
//  Created by Tiger Nixon on 5/17/23.
//

import Foundation

struct OversizedFrameFixerResult {
    struct OversizedFrameFixerResultNode {
        var x: Float
        var y: Float
        var u: Float
        var v: Float
    }
    var topLeft = OversizedFrameFixerResultNode(x: -64.0, y: -64.0, u: 0.0, v: 0.0)
    var topRight = OversizedFrameFixerResultNode(x: 64.0, y: -64.0, u: 1.0, v: 0.0)
    var bottomLeft = OversizedFrameFixerResultNode(x: -64.0, y: 64.0, u: 0.0, v: 1.0)
    var bottomRight = OversizedFrameFixerResultNode(x: 64.0, y: 64.0, u: 1.0, v: 1.0)
}

struct OversizedFrameFixer {
    
    static func fitPortrait(frameX: Float, frameY: Float,
                            frameWidth: Float, frameHeight: Float,
                            textureWidth: Int, textureHeight: Int) -> OversizedFrameFixerResult {
        fit(frameX: frameX,
            frameY: frameY,
            frameWidth: frameWidth,
            frameHeight: frameHeight,
            textureWidth: textureWidth,
            textureHeight: textureHeight,
            portrait: true)
    }
    
    static func fitLandscape(frameX: Float, frameY: Float,
                            frameWidth: Float, frameHeight: Float,
                            textureWidth: Int, textureHeight: Int) -> OversizedFrameFixerResult {
        fit(frameX: frameX,
            frameY: frameY,
            frameWidth: frameWidth,
            frameHeight: frameHeight,
            textureWidth: textureWidth,
            textureHeight: textureHeight,
            portrait: false)
    }
    
    private static func fit(frameX: Float, frameY: Float,
                            frameWidth: Float, frameHeight: Float,
                            textureWidth: Int, textureHeight: Int, portrait: Bool) -> OversizedFrameFixerResult {
        let frameRight = frameX + frameWidth
        let frameBottom = frameY + frameHeight
        
        var result = OversizedFrameFixerResult()
        
        result.topLeft.x = frameX
        result.topLeft.y = frameY
        result.topLeft.u = 0.0
        result.topLeft.v = 0.0
        
        result.topRight.x = frameRight
        result.topRight.y = frameY
        result.topRight.u = 1.0
        result.topRight.v = 0.0
        
        result.bottomLeft.x = frameX
        result.bottomLeft.y = frameBottom
        result.bottomLeft.u = 0.0
        result.bottomLeft.v = 1.0
        
        result.bottomRight.x = frameRight
        result.bottomRight.y = frameBottom
        result.bottomRight.u = 1.0
        result.bottomRight.v = 1.0
        
        guard frameWidth > 8.0 else { return result }
        guard frameHeight > 8.0 else { return result }
        
        var _textureWidth = Float(textureWidth)
        var _textureHeight = Float(textureHeight)
        
        guard _textureWidth > 8.0 else { return result }
        guard _textureHeight > 8.0 else { return result }
        
        if portrait {
            swap(&_textureWidth, &_textureHeight)
        }
        
        let fitScale: Float
        let fitWidth: Float
        let fitHeight: Float
        let fitMode: Bool
        if (_textureWidth / _textureHeight) < (frameWidth / frameHeight) {
            fitScale = frameWidth / _textureWidth
            fitWidth = frameWidth
            fitHeight = fitScale * _textureHeight
            fitMode = true
        } else {
            fitScale = frameHeight / _textureHeight
            fitWidth = fitScale * _textureWidth
            fitHeight = frameHeight
            fitMode = false
        }
        
        var startU = Float(0.0)
        var startV = Float(0.0)
        var endU = Float(1.0)
        var endV = Float(1.0)
        
        if fitMode {
            if fitHeight > frameHeight {
                let center = fitHeight / 2.0
                let top = center - (frameHeight * 0.5)
                let bottom = center + (frameHeight * 0.5)
                startV = top / fitHeight
                endV = bottom / fitHeight
            }
        } else {
            if fitWidth > frameWidth {
                let center = fitWidth / 2.0
                let left = center - (frameWidth * 0.5)
                let right = center + (frameWidth * 0.5)
                startU = left / fitWidth
                endU = right / fitWidth
            }
        }
        
        if portrait {
            result.topLeft.u = startV
            result.topLeft.v = endU
            result.topRight.u = startV
            result.topRight.v = startU
            result.bottomLeft.u = endV
            result.bottomLeft.v = endU
            result.bottomRight.u = endV
            result.bottomRight.v = startU
        } else {
            result.topLeft.u = startU
            result.topLeft.v = startV
            result.topRight.u = endU
            result.topRight.v = startV
            result.bottomLeft.u = startU
            result.bottomLeft.v = endV
            result.bottomRight.u = endU
            result.bottomRight.v = endV
        }
        return result
    }
    
}
