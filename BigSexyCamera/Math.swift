//
//  Math.swift
//  RebuildEarth
//
//  Created by Nicky Taylor on 2/12/23.
//

import Foundation
import simd

struct Math {
    
    static let epsilon: Float = 0.0001
    
    static func radians(degrees: Float) -> Float {
        return degrees * Float.pi / 180.0
    }

    static func degrees(radians: Float) -> Float {
        return radians * 180.0 / Float.pi
    }
    
    static func vector2D(radians: Float) -> simd_float2 {
        let x = sinf(radians)
        let y = -cos(radians)
        return simd_float2(x, y)
    }

    static func vector2D(degrees: Float) -> simd_float2 {
        vector2D(radians: radians(degrees: degrees))
    }
    
    static func rotate(float3: simd_float3, radians: Float, axisX: Float, axisY: Float, axisZ: Float) -> simd_float3 {
        var rotationMatrix = matrix_float4x4()
        rotationMatrix.rotation(radians: radians, axisX: axisX, axisY: axisY, axisZ: axisZ)
        return rotationMatrix.processRotationOnly(point3: float3)
    }

    static func rotate(float3: simd_float3, degrees: Float, axisX: Float, axisY: Float, axisZ: Float) -> simd_float3 {
        var rotationMatrix = matrix_float4x4()
        rotationMatrix.rotation(degrees: degrees, axisX: axisX, axisY: axisY, axisZ: axisZ)
        return rotationMatrix.processRotationOnly(point3: float3)
    }

    static func rotateNormalized(float3: simd_float3, radians: Float, axisX: Float, axisY: Float, axisZ: Float) -> simd_float3 {
        var rotationMatrix = matrix_float4x4()
        rotationMatrix.rotationNormalized(radians: radians, axisX: axisX, axisY: axisY, axisZ: axisZ)
        return rotationMatrix.processRotationOnly(point3: float3)
    }

    static func rotateNormalized(float3: simd_float3, degrees: Float, axisX: Float, axisY: Float, axisZ: Float) -> simd_float3 {
        var rotationMatrix = matrix_float4x4()
        rotationMatrix.rotationNormalized(degrees: degrees, axisX: axisX, axisY: axisY, axisZ: axisZ)
        return rotationMatrix.processRotationOnly(point3: float3)
    }
    
    static func rotateX(float3: simd_float3, radians: Float) -> simd_float3 {
        var rotationMatrix = matrix_float4x4()
        rotationMatrix.rotationX(radians: radians)
        return rotationMatrix.processRotationOnly(point3: float3)
    }

    static func rotateX(float3: simd_float3, degrees: Float) -> simd_float3 {
        var rotationMatrix = matrix_float4x4()
        rotationMatrix.rotationX(degrees: degrees)
        return rotationMatrix.processRotationOnly(point3: float3)
    }
    
    static func rotateY(float3: simd_float3, radians: Float) -> simd_float3 {
        var rotationMatrix = matrix_float4x4()
        rotationMatrix.rotationY(radians: radians)
        return rotationMatrix.processRotationOnly(point3: float3)
    }

    static func rotateY(float3: simd_float3, degrees: Float) -> simd_float3 {
        var rotationMatrix = matrix_float4x4()
        rotationMatrix.rotationY(degrees: degrees)
        return rotationMatrix.processRotationOnly(point3: float3)
    }
    
    static func rotateZ(float3: simd_float3, radians: Float) -> simd_float3 {
        var rotationMatrix = matrix_float4x4()
        rotationMatrix.rotationZ(radians: radians)
        return rotationMatrix.processRotationOnly(point3: float3)
    }

    static func rotateZ(float3: simd_float3, degrees: Float) -> simd_float3 {
        var rotationMatrix = matrix_float4x4()
        rotationMatrix.rotationZ(degrees: degrees)
        return rotationMatrix.processRotationOnly(point3: float3)
    }
    
    
    static func quadBoundingBoxContainsPoint2D(x: Float, y: Float,
                                        quadX1: Float, quadY1: Float,
                                        quadX2: Float, quadY2: Float,
                                        quadX3: Float, quadY3: Float,
                                        quadX4: Float, quadY4: Float) -> Bool {
        
        var minX = min(quadX1, min(quadX2, min(quadX3, quadX4)))
        var minY = min(quadY1, min(quadY2, min(quadY3, quadY4)))
        var maxX = max(quadX1, max(quadX2, max(quadX3, quadX4)))
        var maxY = max(quadY1, max(quadY2, max(quadY3, quadY4)))
        
        minX -= Self.epsilon
        minY -= Self.epsilon
        maxX += Self.epsilon
        maxY += Self.epsilon
        
        return (x >= minX) && (x <= maxX) && (y >= minY) && (y <= maxY)
    }
    
    private static var quadListX = [Float](repeating: 0.0, count: 4)
    private static var quadListY = [Float](repeating: 0.0, count: 4)
    static func quadContainsPoint2D(x: Float, y: Float,
                             quadX1: Float, quadY1: Float,
                             quadX2: Float, quadY2: Float,
                             quadX3: Float, quadY3: Float,
                             quadX4: Float, quadY4: Float) -> Bool {
        
        quadListX[0] = quadX1
        quadListX[1] = quadX2
        quadListX[2] = quadX3
        quadListX[3] = quadX4
        
        quadListY[0] = quadY1
        quadListY[1] = quadY2
        quadListY[2] = quadY3
        quadListY[3] = quadY4
        
        var end = 3
        var start = 0
        var result = false
        while start < 4 {
            if (((quadListY[start] <= y ) && (y < quadListY[end]))
                || ((quadListY[end] <= y) && (y < quadListY[start])))
                && (x < (quadListX[end] - quadListX[start]) * (y - quadListY[start])
                    / (quadListY[end] - quadListY[start]) + quadListX[start]) {
                result = !result
            }
            end = start
            start += 1
        }
        return result
    }
    
    static func segmentClosestPoint(point: simd_float2,
                                    lineStart: simd_float2,
                                    lineEnd: simd_float2) -> simd_float2 {
        var result = simd_float2(lineStart.x, lineStart.y)
        let factor1X = point.x - lineStart.x
        let factor1Y = point.y - lineStart.y
        let lineDiffX = lineEnd.x - lineStart.x
        let lineDiffY = lineEnd.y - lineStart.y
        var factor2X = lineDiffX
        var factor2Y = lineDiffY
        var lineLength = lineDiffX * lineDiffX + lineDiffY * lineDiffY
        if lineLength > Math.epsilon {
            lineLength = sqrtf(lineLength)
            factor2X /= lineLength
            factor2Y /= lineLength
            let scalar = factor2X * factor1X + factor2Y * factor1Y
            if scalar < 0.0 {
                result.x = lineStart.x
                result.y = lineStart.y
            } else if scalar > lineLength {
                result.x = lineEnd.x
                result.y = lineEnd.y
            } else {
                result.x = lineStart.x + factor2X * scalar
                result.y = lineStart.y + factor2Y * scalar
            }
        }
        return result
    }
    
    static func distance(point1: simd_float2, point2: simd_float2) -> Float {
        let distanceSquared = distanceSquared(point1: point1, point2: point2)
        if distanceSquared > Self.epsilon {
            return sqrtf(distanceSquared)
        }
        return 0.0
    }

    static func distanceSquared(point1: simd_float2, point2: simd_float2) -> Float {
        let diffX = point2.x - point1.x
        let diffY = point2.y - point1.y
        return diffX * diffX + diffY * diffY
    }
    
    static func perpendicularNormal(float3: simd_float3) -> simd_float3 {
        
        let factorX = fabsf(float3.x)
        let factorY = fabsf(float3.y)
        let factorZ = fabsf(float3.z)

        var result = simd_float3(0.0, 0.0, 0.0)
        if factorX < Math.epsilon {
            if factorY < Math.epsilon {
                result.y = 1.0
            } else {
                result.y = -float3.z
                result.z = float3.y
            }
        } else if factorY < Math.epsilon {
            if factorZ < Math.epsilon {
                result.y = -1
            } else {
                result.x = -float3.z
                result.z = float3.x
            }
        } else if factorZ < Math.epsilon {
            result.x = -float3.y
            result.y = float3.x
        } else {
            result.x = 1.0
            result.y = 1.0
            result.z = -((float3.x + float3.y) / float3.z)
        }
        
        return simd_normalize(result)
    }
    
    static func equalsApproximately(number1: Float, number2: Float) -> Bool {
        let diff = abs(number1 - number2)
        return diff <= epsilon
    }
    
    static func clamp(number: Float, lower: Float, upper: Float) -> Float {
        var result = number
        if result < lower { result = lower }
        if result > upper { result = upper }
        return result
    }
    
    static func radiansFacing(vector2D: simd_float2) -> Float {
        -atan2f(vector2D.x, vector2D.y)
    }
    
    static func radiansFacing(origin: simd_float2, target: simd_float2) -> Float {
        radiansFacing(vector2D: simd_float2(origin.x - target.x, origin.y - target.y))
    }
    
    static func degreesFacing(vector2D: simd_float2) -> Float {
        let radians = radiansFacing(vector2D: vector2D)
        return degrees(radians: radians)
    }
    
    static func degreesFacing(origin: simd_float2, target: simd_float2) -> Float {
        degreesFacing(vector2D: simd_float2(origin.x - target.x, origin.y - target.y))
    }
    
    
    static func angleDistance(radians1: Float, radians2: Float) -> Float {
        var distance = radians1 - radians2
        distance = fmodf(distance, (Float.pi * 2.0))
        if distance < 0.0 { distance += (Float.pi * 2.0) }
        if distance > Float.pi {
            return (Float.pi * 2.0) - distance
        } else {
            return -distance
        }
    }
    
    static func angleDistance(degrees1: Float, degrees2: Float) -> Float {
        let radians1 = radians(degrees: degrees1)
        let radians2 = radians(degrees: degrees2)
        return angleDistance(radians1: radians1, radians2: radians2)
    }
    
    static func fallOffOvershoot(input: Float, falloffStart: Float, resultMax: Float, inputMax: Float) -> Float {
        var result = input
        if result > falloffStart {
            result = resultMax
            if input < inputMax {
                //We are constrained between [falloffStart ... inputMax]
                let span = (inputMax - falloffStart)
                if span > Math.epsilon {
                    var percent = (input - falloffStart) / span
                    if percent < 0.0 { percent = 0.0 }
                    if percent > 1.0 { percent = 1.0 }
                    //sin [0..1] => [0..pi/2]
                    let factor = sinf(Float(percent * (Float.pi * 0.5)))
                    result = falloffStart + factor * (resultMax - falloffStart)
                }
            }
        }
        return result
    }
    
    static func fallOffUndershoot(input: Float, falloffStart: Float, resultMin: Float, inputMin: Float) -> Float {
        var result = input
        if result < falloffStart {
            result = resultMin
            if input > inputMin {
                //We are constrained between [inputMin ... falloffStart]
                let span = (falloffStart - inputMin)
                if span > Math.epsilon {
                    var percent = (falloffStart - input) / span
                    if percent < 0.0 { percent = 0.0 }
                    if percent > 1.0 { percent = 1.0 }
                    //sin [0..1] => [0..pi/2]
                    let factor = sinf(Float(percent * (Float.pi * 0.5)))
                    result = falloffStart - factor * (falloffStart - resultMin)
                }
            }
        }
        return result
    }
    
}
