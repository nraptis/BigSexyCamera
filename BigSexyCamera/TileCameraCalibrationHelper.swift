//
//  TileCameraCalibrationHelper.swift
//  BigSexyCamera
//
//  Created by Tiger Nixon on 5/17/23.
//

import Foundation
import simd
import UIKit

struct TileCameraCalibrationHelper {
    
    static func distance(camera: TileCamera,
                         graphics: Graphics,
                         frameY: Float,
                         padding: Float) -> Float {
        
        let aspect = graphics.width / graphics.height
        var perspective = matrix_float4x4()
        perspective.perspective(fovy: Float.pi * 0.5, aspect: aspect, nearZ: 1.0, farZ: 4096.0)
        
        var minDist: Float = 2.0
        var minY: Float = estimateY(graphics: graphics,
                                    perspective: perspective,
                                    frameY: frameY,
                                    distance: minDist)
        
        var maxDist: Float = minDist
        var maxY: Float = minY
        
        var fudge = 0
        repeat {
            fudge += 1
            minDist = maxDist
            minY = maxY
            maxDist *= 2.0
            maxY = estimateY(graphics: graphics,
                             perspective: perspective,
                             frameY: frameY,
                             distance: maxDist)
        } while (fudge < 100) && (maxY < padding)
        
        fudge = 0
        repeat {
            fudge += 1
            let midDist = (minDist + maxDist) * 0.5
            let midY = estimateY(graphics: graphics,
                                 perspective: perspective,
                                 frameY: frameY,
                                 distance: midDist)
            if midY > padding {
                maxY = midY
                maxDist = midDist
            } else {
                minY = maxY
                minDist = midDist
            }
        } while (fudge < 100) && (abs(maxY - padding) > Math.epsilon)
        return maxDist
    }
    
    static func distance(camera: TileCamera,
                         graphics: Graphics,
                         frameX: Float,
                         padding: Float) -> Float {
        
        let aspect = graphics.width / graphics.height
        var perspective = matrix_float4x4()
        perspective.perspective(fovy: Float.pi * 0.5, aspect: aspect, nearZ: 1.0, farZ: 4096.0)
        
        var minDist: Float = 2.0
        var minX: Float = estimateX(graphics: graphics,
                                    perspective: perspective,
                                    frameX: frameX,
                                    distance: minDist)
        
        var maxDist: Float = minDist
        var maxX: Float = minX
        
        var fudge = 0
        repeat {
            fudge += 1
            minDist = maxDist
            minX = maxX
            maxDist *= 2.0
            maxX = estimateX(graphics: graphics,
                             perspective: perspective,
                             frameX: frameX,
                             distance: maxDist)
        } while (fudge < 100) && (maxX < padding)
        
        fudge = 0
        repeat {
            fudge += 1
            let midDist = (minDist + maxDist) * 0.5
            let midX = estimateX(graphics: graphics,
                                 perspective: perspective,
                                 frameX: frameX,
                                 distance: midDist)
            if midX > padding {
                maxX = midX
                maxDist = midDist
            } else {
                minX = maxX
                minDist = midDist
            }
        } while (fudge < 100) && (abs(maxX - padding) > Math.epsilon)
        return maxDist
    }
    
    private static func estimateX(graphics: Graphics,
                                  perspective: matrix_float4x4,
                                  frameX: Float,
                                  distance: Float) -> Float {
        
        var lookAt = matrix_float4x4()
        lookAt.lookAt(eyeX: TileCamera.baseUnitEye.x * distance,
                      eyeY: TileCamera.baseUnitEye.y * distance,
                      eyeZ: TileCamera.baseUnitEye.z * distance,
                      centerX: TileCamera.baseCenter.x,
                      centerY: TileCamera.baseCenter.y,
                      centerZ: TileCamera.baseCenter.z,
                      upX: TileCamera.baseUp.x,
                      upY: TileCamera.baseUp.y,
                      upZ: TileCamera.baseUp.z)
        
        let projection = simd_mul(perspective, lookAt)
        
        let point = SIMD3<Float>(x: frameX,
                                 y: 0.0,
                                 z: 0.0)
        let projected = convert(graphics: graphics,
                                projection: projection,
                                point: point)
        return projected.x
    }
    
    private static func estimateY(graphics: Graphics,
                                  perspective: matrix_float4x4,
                                  frameY: Float,
                                  distance: Float) -> Float {
        
        var lookAt = matrix_float4x4()
        lookAt.lookAt(eyeX: TileCamera.baseUnitEye.x * distance,
                      eyeY: TileCamera.baseUnitEye.y * distance,
                      eyeZ: TileCamera.baseUnitEye.z * distance,
                      centerX: TileCamera.baseCenter.x,
                      centerY: TileCamera.baseCenter.y,
                      centerZ: TileCamera.baseCenter.z,
                      upX: TileCamera.baseUp.x,
                      upY: TileCamera.baseUp.y,
                      upZ: TileCamera.baseUp.z)
        
        let projection = simd_mul(perspective, lookAt)
        
        let point = SIMD3<Float>(x: 0.0,
                                 y: frameY,
                                 z: 0.0)
        let projected = convert(graphics: graphics,
                                projection: projection,
                                point: point)
        return projected.y
    }
    
    static func convert(graphics: Graphics,
                        projection: matrix_float4x4,
                        point: SIMD3<Float>) -> SIMD2<Float> {
        let point = projection.process(point3: point)
        let x = graphics.width * (point.x + 1.0) * 0.5
        let y = graphics.height * (1.0 - (point.y + 1.0) * 0.5)
        return SIMD2<Float>(x, y)
    }
    
    /*
    func convert(float3: SIMD3<Float>) -> SIMD2<Float> {
        let point = projection.process(point3: float3)
        let x = graphics.width * (point.x + 1.0) * 0.5
        let y = graphics.height * (1.0 - (point.y + 1.0) * 0.5)
        return SIMD2<Float>(x, y)
    }
    */
                        
    
}

/*
import Foundation
import simd
import UIKit

struct CameraCalibrationTool {
    
    private static let epsilon = Float(0.01)
    
    private static let tileCountV = 24
    private static let tileCountH = 24
    
    static func earthRestingRadius(graphics: Graphics) -> Float {
        let dimension = min(graphics.width, graphics.height)
        let ratio: Float = (dimension < 340.0) ? 0.95 : 0.78
        let maxRadius: Float = 425.0
        var result = dimension * 0.5 * ratio
        if result > maxRadius {
            result = maxRadius
        }
        return result
    }
    
    static func starsRestingRadius(graphics: Graphics) -> Float {
        let diffX = graphics.width * 0.6
        let diffY = graphics.height * 0.6
        var length = diffX * diffX + diffY * diffY
        if length > Math.epsilon {
            length = sqrtf(length)
        }
        return length
    }
    
    static let screenMinDimensionRatio: Float = (min(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height) < 340.0) ? 0.95 : 0.78
    static let screenMinDimensionMaxSize: Float = 425.0
    
    let sphere = UnitPointSphere()
    
    init() {
        sphere.load(tileCountH: Self.tileCountH, tileCountV: Self.tileCountV)
    }
    
    func calibrate(graphics: Graphics, camera: Camera, radius: Float) -> Float {
        
        let center = SIMD2<Float>(graphics.width * 0.5, graphics.height * 0.5)
        let perspective = camera.perspectiveMatrix()
        let unitEye = camera.unitEye()
        
        var minDist: Float = 1.25
        var minRadius: Float = self.estimateRadius(graphics: graphics,
                                                   camera: camera,
                                                   sphere: sphere,
                                                   center: center,
                                                   perspective: perspective,
                                                   unitEye: unitEye,
                                                   distance: minDist)
        
        var maxDist: Float = minDist
        var maxRadius: Float = minRadius
        
        // Keep doubling until the radius produced from the maxDist
        // exceeds the targetRadius
        var fudge = 0
        repeat {
            fudge += 1
            minDist = maxDist
            minRadius = maxRadius
            maxDist *= 2.0
            maxRadius = estimateRadius(graphics: graphics,
                                       camera: camera,
                                       sphere: sphere,
                                       center: center,
                                       perspective: perspective,
                                       unitEye: unitEye,
                                       distance: maxDist)
        } while (fudge < 100) && (maxRadius > radius)
        
        // Use binary search to pinch min and max dist towards
        // such that their radius is close enough to targetRadius
        fudge = 0
        repeat {
            fudge += 1
            let midDist = (minDist + maxDist) * 0.5
            let midRadius = estimateRadius(graphics: graphics,
                                           camera: camera,
                                           sphere: sphere,
                                           center: center,
                                           perspective: perspective,
                                           unitEye: unitEye,
                                           distance: midDist)
            if midRadius < radius {
                maxRadius = midRadius
                maxDist = midDist
            } else {
                minRadius = midRadius
                minDist = midDist
            }
        } while (fudge < 100) && (abs(maxRadius - radius) > Self.epsilon)
        
        return maxDist
    }
    
    func estimateRadius(graphics: Graphics, camera: Camera) -> Float {
        let center = SIMD2<Float>(graphics.width * 0.5, graphics.height * 0.5)
        let perspective = camera.perspectiveMatrix()
        let unitEye = camera.unitEye()
        let radius = estimateRadius(graphics: graphics,
                                    camera: camera,
                                    sphere: sphere,
                                    center: center,
                                    perspective: perspective,
                                    unitEye: unitEye,
                                    distance: camera.distance)
        return radius
    }
    
    private func estimateRadius(graphics: Graphics,
                                camera: Camera,
                                sphere: UnitPointSphere,
                                center: SIMD2<Float>,
                                perspective: matrix_float4x4,
                                unitEye: SIMD3<Float>,
                                distance: Float) -> Float {
        
        let holdDistance = camera.distance
        
        camera.distance = distance
        camera.compute(perspective: perspective, unitEye: unitEye)
        
        var result: Float = 0.0
        var indexV = 0
        while indexV < Self.tileCountV {
            var indexH = 0
            while indexH < Self.tileCountH {
                let point3D = sphere.points[indexH][indexV]
                let point2D = camera.convert(float3: point3D)
                let diffX = point2D.x - center.x
                let diffY = point2D.y - center.y
                let length = diffX * diffX + diffY * diffY
                if length > result {
                    result = length
                }
                indexH += 1
            }
            indexV += 1
        }
        if result > Math.epsilon {
            result = sqrtf(result)
        }
        
        camera.distance = holdDistance
        
        return result
    }
}

*/

