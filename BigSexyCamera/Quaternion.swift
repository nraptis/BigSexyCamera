//
//  Quaternion.swift
//  MetalEarth
//
//  Created by Nicky Taylor on 2/3/23.
//

import simd

extension simd_quatf {
    
    mutating func reset() {
        vector.x = 0.0
        vector.y = 0.0
        vector.z = 0.0
        vector.w = 1.0
    }
    
    func eulersRadians() -> simd_float3 {
        let xSquared = vector.x * vector.x
        let ySquared = vector.y * vector.y
        let zSquared = vector.z * vector.z
        let wSquared = vector.w * vector.w
        let test = 2.0 * (vector.y * vector.w - vector.x * vector.z)
        var euler = simd_float3(0.0, 0.0, 0.0)
        /*
        if Math.equalsApproximately(number1: 1.0, number2: test) {
            euler.x = 0.0
            euler.y = Float.pi * 0.5
            euler.z = -2.0 * atan2f(vector.x, vector.w)
        } else if Math.equalsApproximately(number1: -1.0, number2: test) {
            euler.x = 0.0
            euler.y = Float.pi * -0.5
            euler.z = -2.0 * atan2f(vector.x, vector.w)
        } else {
            euler.x = atan2f(2.0 * (vector.y * vector.z + vector.x * vector.w),
                             -xSquared - ySquared + zSquared + wSquared)
            euler.y = asinf(Math.clamp(number: test, lower: -1.0, upper: 1.0))
            euler.z = atan2f(2.0 * (vector.x * vector.y + vector.z * vector.w),
                             xSquared - ySquared - zSquared + wSquared)
        }
        */
        
        euler.x = atan2f(2.0 * (vector.y * vector.z + vector.x * vector.w),
                         -xSquared - ySquared + zSquared + wSquared)
        euler.y = asinf(Math.clamp(number: test, lower: -1.0, upper: 1.0))
        euler.z = atan2f(2.0 * (vector.x * vector.y + vector.z * vector.w),
                         xSquared - ySquared - zSquared + wSquared)
        
        return euler
    }
    
    func eulersDegrees() -> simd_float3 {
        let eulersRadians = eulersRadians()
        let x = Math.degrees(radians: eulersRadians.x)
        let y = Math.degrees(radians: eulersRadians.y)
        let z = Math.degrees(radians: eulersRadians.z)
        return simd_float3(x, y, z)
    }
    
    mutating func makeEulerDegrees(yaw: Float, pitch: Float, roll: Float) {
        let yaw = Math.radians(degrees: yaw)
        let pitch = Math.radians(degrees: pitch)
        let roll = Math.radians(degrees: roll)
        makeEulerRadians(yaw: yaw, pitch: pitch, roll: roll)
    }
    
    mutating func makeEulerRadians(yaw: Float, pitch: Float, roll: Float) {
        let yaw = yaw * 0.5
        let sinYaw = sinf(yaw)
        let cosYaw = cosf(yaw)
        
        let pitch = pitch * 0.5
        let sinPitch = sinf(pitch)
        let cosPitch = cosf(pitch)
        
        let roll = roll * 0.5
        let sinRoll = sinf(roll)
        let cosRoll = cosf(roll)
        
        let cosPitchCosRoll = cosPitch * cosRoll
        let sinPitchCosRoll = sinPitch * cosRoll
        let cosPitchSinRoll = cosPitch * sinRoll
        let sinPitchSinRoll = sinPitch * sinRoll
        
        vector.x = sinYaw * cosPitchCosRoll - cosYaw * sinPitchSinRoll
        vector.y = cosYaw * sinPitchCosRoll + sinYaw * cosPitchSinRoll
        vector.z = cosYaw * cosPitchSinRoll - sinYaw * sinPitchCosRoll
        vector.w = cosYaw * cosPitchCosRoll + sinYaw * sinPitchSinRoll
        
        normalize()
    }
    
    mutating func normalize() {
        self = simd_normalize(self)
    }
    
}

