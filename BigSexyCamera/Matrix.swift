//
//  Matrix.swift
//  RebuildEarth
//
//  Created by Nicky Taylor on 2/10/23.
//

import Foundation
import simd
import SceneKit

extension matrix_float4x4 {
    
    mutating func make(m00: Float, m01: Float, m02: Float, m03: Float,
                       m10: Float, m11: Float, m12: Float, m13: Float,
                       m20: Float, m21: Float, m22: Float, m23: Float,
                       m30: Float, m31: Float, m32: Float, m33: Float) {
        
        columns.0.x = m00 // 0
        columns.1.x = m10 // 1
        columns.2.x = m20 // 2
        columns.3.x = m30 // 3
        
        columns.0.y = m01 // 4
        columns.1.y = m11 // 5
        columns.2.y = m21 // 6
        columns.3.y = m31 // 7
        
        columns.0.z = m02 // 8
        columns.1.z = m12 // 9
        columns.2.z = m22 // 10
        columns.3.z = m32 // 11
        
        columns.0.w = m03 // 12
        columns.1.w = m13 // 13
        columns.2.w = m23 // 14
        columns.3.w = m33 // 15
    }
    
    mutating func make(matrix4: SCNMatrix4) {
        make(m00: matrix4.m11, m01: matrix4.m12, m02: matrix4.m13, m03: matrix4.m14,
             m10: matrix4.m21, m11: matrix4.m22, m12: matrix4.m23, m13: matrix4.m24,
             m20: matrix4.m31, m21: matrix4.m32, m22: matrix4.m33, m23: matrix4.m34,
             m30: matrix4.m41, m31: matrix4.m42, m32: matrix4.m43, m33: matrix4.m44)
    }
    
    func array() -> [Float] {
        return [columns.0.x, columns.0.y, columns.0.z, columns.0.w,
                columns.1.x, columns.1.y, columns.1.z, columns.1.w,
                columns.2.x, columns.2.y, columns.2.z, columns.2.w,
                columns.3.x, columns.3.y, columns.3.z, columns.3.w]
    }
    
    mutating func invert() {
        self = self.inverse
    }
    
    mutating func ortho(left: Float, right: Float, bottom: Float, top: Float,
                        nearZ: Float, farZ: Float) {
        
        let ral = right + left
        let rsl = right - left
        let tab = top + bottom
        let tsb = top - bottom
        let fan = farZ + nearZ
        let fsn = farZ - nearZ
        make(m00: 2.0 / rsl, m01: 0.0, m02: 0.0, m03: 0.0,
             m10: 0.0, m11: 2.0 / tsb, m12: 0.0, m13: 0.0,
             m20: 0.0, m21: 0.0, m22: -2.0 / fsn, m23: 0.0,
             m30: -ral / rsl, m31: -tab / tsb, m32: -fan / fsn, m33: 1.0)
    }
    
    mutating func ortho(width: Float, height: Float) {
        ortho(left: 0.0, right: width,
              bottom: height, top: 0.0,
              nearZ: -2048.0, farZ: 2048.0)
    }
    
    mutating func perspective(fovy: Float, aspect: Float, nearZ: Float, farZ: Float) {
        let cotan = 1.0 / tanf(fovy / 2.0)
        make(m00: cotan / aspect, m01: 0.0, m02: 0.0, m03: 0.0,
             m10: 0.0, m11: cotan, m12: 0.0, m13: 0.0,
             m20: 0.0, m21: 0.0, m22: (farZ + nearZ) / (nearZ - farZ), m23: -1.0,
             m30: 0.0, m31: 0.0, m32: (2.0 * farZ * nearZ) / (nearZ - farZ), m33: 0.0)
    }
    
    mutating func lookAt(eyeX: Float, eyeY: Float, eyeZ: Float,
                         centerX: Float, centerY: Float, centerZ: Float,
                         upX: Float, upY: Float, upZ: Float) {
        var nx = eyeX - centerX
        var ny = eyeY - centerY
        var nz = eyeZ - centerZ
        
        var dist = nx * nx + ny * ny + nz * nz
        if dist > Math.epsilon {
            dist = sqrtf(dist)
            nx /= dist
            ny /= dist
            nz /= dist
        }
        
        var ux = upY * nz - upZ * ny
        var uy = upZ * nx - upX * nz
        var uz = upX * ny - upY * nx
        
        dist = ux * ux + uy * uy + uz * uz
        if dist > Math.epsilon {
            dist = sqrtf(dist)
            ux /= dist
            uy /= dist
            uz /= dist
        }
        
        let vx = ny * uz - nz * uy
        let vy = nz * ux - nx * uz
        let vz = nx * uy - ny * ux
        
        make(m00: ux, m01: vx, m02: nx, m03: 0.0,
             m10: uy, m11: vy, m12: ny, m13: 0.0,
             m20: uz, m21: vz, m22: nz, m23: 0.0,
             m30: -ux * eyeX - uy * eyeY - uz * eyeZ,
             m31: -vx * eyeX - vy * eyeY - vz * eyeZ,
             m32: -nx * eyeX - ny * eyeY - nz * eyeZ,
             m33: 1.0)
    }
    
    mutating func translate(x: Float, y: Float, z: Float) {
        let tx = columns.0.x * x + columns.0.y * y + columns.0.z * z + columns.0.w
        let ty = columns.1.x * x + columns.1.y * y + columns.1.z * z + columns.1.w
        let tz = columns.2.x * x + columns.2.y * y + columns.2.z * z + columns.2.w
        var matrix = simd_float4x4()
        matrix.make(m00: columns.0.x, m01: columns.1.x, m02: columns.2.x, m03: columns.3.x,
                    m10: columns.0.y, m11: columns.1.y, m12: columns.2.y, m13: columns.3.y,
                    m20: columns.0.z, m21: columns.1.z, m22: columns.2.z, m23: columns.3.z,
                    m30: tx, m31: ty, m32: tz, m33: columns.3.w)
        self = matrix
    }

    mutating func translation(x: Float, y: Float, z: Float) {
        make(m00: 1.0, m01: 0.0, m02: 0.0, m03: 0.0,
             m10: 0.0, m11: 1.0, m12: 0.0, m13: 0.0,
             m20: 0.0, m21: 0.0, m22: 1.0, m23: 0.0,
             m30: x, m31: y, m32: z, m33: 1.0)
    }
    
    mutating func rotateX(degrees: Float) {
        rotateX(radians: Math.radians(degrees: degrees))
    }

    mutating func rotateX(radians: Float) {
        var rhs = matrix_float4x4()
        rhs.rotationX(radians: radians)
        self = simd_mul(self, rhs)
    }

    mutating func rotationX(degrees: Float) {
        rotationX(radians: Math.radians(degrees: degrees))
    }

    mutating func rotationX(radians: Float) {
        let _cos = cosf(radians)
        let _sin = sinf(radians)
        make(m00: 1.0, m01: 0.0, m02: 0.0, m03: 0.0,
             m10: 0.0, m11: _cos, m12: _sin, m13: 0.0,
             m20: 0.0, m21: -_sin, m22: _cos, m23: 0.0,
             m30: 0.0, m31: 0.0, m32: 0.0, m33: 1.0)
    }
    
    mutating func rotateY(degrees: Float) {
        rotateY(radians: Math.radians(degrees: degrees))
    }

    mutating func rotateY(radians: Float) {
        var rhs = matrix_float4x4()
        rhs.rotationY(radians: radians)
        self = simd_mul(self, rhs)
    }

    mutating func rotationY(degrees: Float) {
        rotationY(radians: Math.radians(degrees: degrees))
    }

    mutating func rotationY(radians: Float) {
        let _cos = cosf(radians)
        let _sin = sinf(radians)
        make(m00: _cos, m01: 0.0, m02: -_sin, m03: 0.0,
             m10: 0.0, m11: 1.0, m12: 0.0, m13: 0.0,
             m20: _sin, m21: 0.0, m22: _cos, m23: 0.0,
             m30: 0.0, m31: 0.0, m32: 0.0, m33: 1.0)
    }
    
    mutating func rotateZ(degrees: Float) {
        rotateZ(radians: Math.radians(degrees: degrees))
    }

    mutating func rotateZ(radians: Float) {
        var rhs = matrix_float4x4()
        rhs.rotationZ(radians: radians)
        self = simd_mul(self, rhs)
    }

    mutating func rotationZ(degrees: Float) {
        rotationZ(radians: Math.radians(degrees: degrees))
    }

    mutating func rotationZ(radians: Float) {
        let _cos = cosf(radians)
        let _sin = sinf(radians)
        make(m00: _cos, m01: _sin, m02: 0.0, m03: 0.0,
             m10: -_sin, m11: _cos, m12: 0.0, m13: 0.0,
             m20: 0.0, m21: 0.0, m22: 1.0, m23: 0.0,
             m30: 0.0, m31: 0.0, m32: 0.0, m33: 1.0)
    }
    
    mutating func rotate(degrees: Float, axisX: Float, axisY: Float, axisZ: Float) {
        rotate(radians: Math.radians(degrees: degrees), axisX: axisX, axisY: axisY, axisZ: axisZ)
    }

    mutating func rotate(radians: Float, axisX: Float, axisY: Float, axisZ: Float) {
        var rhs = matrix_float4x4()
        rhs.rotation(radians: radians, axisX: axisX, axisY: axisY, axisZ: axisZ)
        self = simd_mul(self, rhs)
    }

    mutating func rotation(degrees: Float, axisX: Float, axisY: Float, axisZ: Float) {
        rotation(radians: Math.radians(degrees: degrees), axisX: axisX, axisY: axisY, axisZ: axisZ)
    }

    mutating func rotation(radians: Float, axisX: Float, axisY: Float, axisZ: Float) {
        var axisLength = axisX * axisX + axisY * axisY + axisZ * axisZ
        if axisLength > Math.epsilon {
            axisLength = sqrtf(axisLength)
            let axisX = axisX / axisLength
            let axisY = axisY / axisLength
            let axisZ = axisZ / axisLength
            rotationNormalized(radians: radians,
                               axisX: axisX,
                               axisY: axisY,
                               axisZ: axisZ)
        }
    }

    mutating func rotateNormalized(degrees: Float, axisX: Float, axisY: Float, axisZ: Float) {
        rotateNormalized(radians: Math.radians(degrees: degrees), axisX: axisX, axisY: axisY, axisZ: axisZ)
    }

    mutating func rotateNormalized(radians: Float, axisX: Float, axisY: Float, axisZ: Float) {
        var rhs = matrix_float4x4()
        rhs.rotationNormalized(radians: radians, axisX: axisX, axisY: axisY, axisZ: axisZ)
        self = simd_mul(self, rhs)
    }

    mutating func rotationNormalized(degrees: Float, axisX: Float, axisY: Float, axisZ: Float) {
        rotationNormalized(radians: Math.radians(degrees: degrees), axisX: axisX, axisY: axisY, axisZ: axisZ)
    }

    mutating func rotationNormalized(radians: Float, axisX: Float, axisY: Float, axisZ: Float) {
        let sinAngle = sinf(radians)
        let cosAngle = cosf(radians)
        let cosAngleInv = 1.0 - cosAngle
        let cosAngleInvX = cosAngleInv * axisX
        let cosAngleInvY = cosAngleInv * axisY
        let cosAngleInvXY = cosAngleInvX * axisY
        let cosAngleInvXZ = cosAngleInvX * axisZ
        let cosAngleInvYZ = cosAngleInvY * axisZ
        let sinAngleX = axisX * sinAngle
        let sinAngleY = axisY * sinAngle
        let sinAngleZ = axisZ * sinAngle
        make(m00: cosAngle + cosAngleInvX * axisX,
             m01: cosAngleInvXY + sinAngleZ,
             m02: cosAngleInvXZ - sinAngleY,
             m03: 0.0,
             m10: cosAngleInvXY - sinAngleZ,
             m11: cosAngle + cosAngleInvY * axisY,
             m12: cosAngleInvYZ + sinAngleX,
             m13: 0.0,
             m20: cosAngleInvXZ + sinAngleY,
             m21: cosAngleInvYZ - sinAngleX,
             m22: cosAngle + cosAngleInv * axisZ * axisZ,
             m23: 0.0,
             m30: 0.0,
             m31: 0.0,
             m32: 0.0,
             m33: 1.0)
    }
    
    func process(point3: simd_float3) -> simd_float3 {
        let x = columns.0.x * point3.x + columns.1.x * point3.y + columns.2.x * point3.z + columns.3.x
        let y = columns.0.y * point3.x + columns.1.y * point3.y + columns.2.y * point3.z + columns.3.y
        let z = columns.0.z * point3.x + columns.1.z * point3.y + columns.2.z * point3.z + columns.3.z
        let w = columns.0.w * point3.x + columns.1.w * point3.y + columns.2.w * point3.z + columns.3.w
        if fabsf(w) > Math.epsilon {
            let scale = 1.0 / w
            return simd_float3(x * scale, y * scale, z * scale)
        } else {
            return simd_float3(x, y, z)
        }
    }
    
    func processRotationOnly(point3: simd_float3) -> simd_float3 {
        let x = columns.0.x * point3.x + columns.1.x * point3.y + columns.2.x * point3.z
        let y = columns.0.y * point3.x + columns.1.y * point3.y + columns.2.y * point3.z
        let z = columns.0.z * point3.x + columns.1.z * point3.y + columns.2.z * point3.z
        return simd_float3(x, y, z)
    }
    
    mutating func scale(_ factor: Float) {
        columns.0.x = columns.0.x * factor
        columns.1.x = columns.1.x * factor
        columns.2.x = columns.2.x * factor
        columns.0.y = columns.0.y * factor
        columns.1.y = columns.1.y * factor
        columns.2.y = columns.2.y * factor
        columns.0.z = columns.0.z * factor
        columns.1.z = columns.1.z * factor
        columns.2.z = columns.2.z * factor
        columns.0.w = columns.0.w * factor
        columns.1.w = columns.1.w * factor
        columns.2.w = columns.2.w * factor
    }
}
