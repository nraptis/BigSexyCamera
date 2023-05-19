//
//  GroovyTile3DYCBCR.swift
//  BigSexyCamera
//
//  Created by Tiger Nixon on 5/17/23.
//

import Foundation
import Metal
import simd

class GroovyTile3DYCBCR {
    
    struct Sprite3DColorNode {
        var x: Float
        var y: Float
        var z: Float
        var u: Float
        var v: Float
        var r: Float
        var g: Float
        var b: Float
        var a: Float
    }
    
    let graphics: Graphics
    
    var _grid = [[GroovyTile3DYCBCRNode]]()
    
    //var fitFrame = OversizedFrameFixerResult()
    
    private var _cellWidthArray = [Int]()
    private var _cellHeightArray = [Int]()
    private var _cellXArray = [Int]()
    private var _cellYArray = [Int]()
    
    private(set) var frameLeft: Float = -128.0
    private(set) var frameRight: Float = 128.0
    private(set) var frameTop: Float = -128.0
    private(set) var frameBottom: Float = 128.0
    private(set) var frameWidth: Float = 256.0
    private(set) var frameHeight: Float = 256.0
    
    private(set) var textureWidth = 0
    private(set) var textureHeight = 0
    
    private(set) var textureY: MTLTexture?
    private(set) var textureCBCR: MTLTexture?
    
    private var startU: Float = 0.0
    private var startV: Float = 0.0
    
    private var endU: Float = 1.0
    private var endV: Float = 1.0
    
    var uniformsVertex = UniformsSpriteNodeIndexedVertex()
    private(set) var uniformsVertexBuffer: MTLBuffer!
    var uniformsFragment = UniformsSpriteNodeIndexedFragment()
    private(set) var uniformsFragmentBuffer: MTLBuffer!
    
    var vertexData: [Sprite3DColorNode] = [
        Sprite3DColorNode(x: -256.0, y: -256.0, z: 0.0, u: 0.0, v: 0.0, r: 1.0, g: 0.0, b: 0.0, a: 1.0),
        Sprite3DColorNode(x: 256.0, y: -256.0, z: 0.0, u: 1.0, v: 0.0, r: 1.0, g: 0.5, b: 0.0, a: 1.0),
        Sprite3DColorNode(x: -256.0, y: 256.0, z: 0.0, u: 0.0, v: 1.0, r: 1.0, g: 0.0, b: 0.0, a: 1.0),
        Sprite3DColorNode(x: 256.0, y: 256.0, z: 0.0, u: 1.0, v: 1.0, r: 0.0, g: 0.0, b: 1.0, a: 1.0)]
    var vertexDataBuffer: MTLBuffer!
    
    var indices: [UInt16] = [0, 1, 2, 3]
    var indexBuffer: MTLBuffer!
    
    required init(graphics: Graphics) {
        self.graphics = graphics
    }
    
    lazy var gridWidth: Int = {
        34
    }()
    
    lazy var gridHeight: Int = {
        64
    }()
    
    func load() {
        uniformsVertexBuffer = graphics.buffer(uniform: uniformsVertex)
        uniformsFragmentBuffer = graphics.buffer(uniform: uniformsFragment)
        
        vertexDataBuffer = graphics.buffer(array: vertexData)
        indexBuffer = graphics.buffer(array: indices)
    }
    
    func set(x: Float, y: Float, width: Float, height: Float) {
        
        if frameLeft != x || frameWidth != width || frameTop != y || frameHeight != height {
            
            self.frameLeft = Float(Int(x))
            self.frameRight = x + width
            self.frameTop = Float(Int(y))
            self.frameBottom = y + height
            self.frameWidth = width
            self.frameHeight = height
            
            fit()
            buildGrid()
        }
    }
    
    func set(textureY: MTLTexture?, textureCBCR: MTLTexture?) {
        self.textureY = textureY
        self.textureCBCR = textureCBCR
        
        if let textureY = textureY {
            if textureWidth != textureY.width || textureHeight != textureY.height {
                textureWidth = textureY.width
                textureHeight = textureY.height
                fit()
                buildGrid()
            }
        } else {
            if 0 != self.textureWidth || 0 != self.textureHeight {
                textureWidth = 0
                textureHeight = 0
                fit()
                buildGrid()
            }
        }
    }
    
    private func fit() {
        
        let fitFrame = OversizedFrameFixer.fitPortrait(frameX: frameLeft,
                                                       frameY: frameTop,
                                                       frameWidth: frameWidth,
                                                       frameHeight: frameHeight,
                                                       textureWidth: textureWidth,
                                                       textureHeight: textureHeight)
        

        vertexData[0].x = fitFrame.topLeft.x
        vertexData[0].y = fitFrame.topLeft.y
        vertexData[0].u = fitFrame.topLeft.u
        vertexData[0].v = fitFrame.topLeft.v
        
        vertexData[1].x = fitFrame.topRight.x
        vertexData[1].y = fitFrame.topRight.y
        vertexData[1].u = fitFrame.topRight.u
        vertexData[1].v = fitFrame.topRight.v
        
        vertexData[2].x = fitFrame.bottomLeft.x
        vertexData[2].y = fitFrame.bottomLeft.y
        vertexData[2].u = fitFrame.bottomLeft.u
        vertexData[2].v = fitFrame.bottomLeft.v
        
        vertexData[3].x = fitFrame.bottomRight.x
        vertexData[3].y = fitFrame.bottomRight.y
        vertexData[3].u = fitFrame.bottomRight.u
        vertexData[3].v = fitFrame.bottomRight.v
        
        print("vd[0] = { \(vertexData[0].u), \(vertexData[0].v) }")
        print("vd[1] = { \(vertexData[1].u), \(vertexData[1].v) }")
        print("vd[2] = { \(vertexData[2].u), \(vertexData[2].v) }")
        print("vd[3] = { \(vertexData[3].u), \(vertexData[3].v) }")
        
        startU = vertexData[1].v
        startV = vertexData[0].u
        
        endU = vertexData[0].v
        endV = vertexData[2].u
        
        
    }
    
    func buildGrid() {

        _grid = [[GroovyTile3DYCBCRNode]](repeating: [GroovyTile3DYCBCRNode](), count: gridWidth)
        for x in 0..<gridWidth {
            _grid[x].reserveCapacity(gridHeight)
            for y in 0..<gridHeight {
                _grid[x].append(GroovyTile3DYCBCRNode(graphics: graphics, gridX: x, gridY: y))
            }
        }
        
        for x in 0..<gridWidth {
            for y in 0..<gridHeight {
                _grid[x][y].load()
            }
        }
        
        _cellWidthArray = cellWidthArray()
        _cellHeightArray = cellHeightArray()
        _cellXArray = cellXArray()
        _cellYArray = cellYArray()
        
        print("_cellWidthArray = \(_cellWidthArray)")
        print("_cellXArray = \(_cellXArray)")
        print("_cellHeightArray = \(_cellHeightArray)")
        print("_cellYArray = \(_cellYArray)")
        
        for x in 0..<gridWidth {
            
            let left = Float(_cellXArray[x])
            let width = Float(_cellWidthArray[x])
            let right = left + width
            let centerX = left + width * 0.5
            
            
            
            for y in 0..<gridHeight {
                let top = Float(_cellYArray[y])
                let height = Float(_cellHeightArray[y])
                let bottom = top + height
                let centerY = top + height * 0.5
                
                _grid[x][y].set(centerX: centerX,
                                centerY: centerY,
                                width: width,
                                height: height)
                
                var xp1 = (right - frameLeft) / frameWidth
                var xp2 = (left - frameLeft) / frameWidth
                
                xp1 = (1.0 - xp1)
                xp2 = (1.0 - xp2)
                
                var yp1 = (top - frameTop) / frameHeight
                var yp2 = (bottom - frameTop) / frameHeight

                
                //vd[0] = { 0.0, 0.8078818 }  { 0.0, 0.19211823 }
                //vd[1] =
                //vd[2] = { 1.0, 0.8078818 }  { 1.0, 0.19211823 }
                
                //startU = 0.0, endU = 1.0
                //startV = 0.19211823, endV = 0.8078818
                
                /*
                var _startU = endV + (startV - endV) * xp1
                var _endU = endV + (startV - endV) * xp2
                
                var _startV = startU + (endU - startU) * yp1
                var _endV = startU + (endU - startU) * yp2
                */
                
                /*
                result.topLeft.u = startV
                result.topLeft.v = endU
                result.topRight.u = startV
                result.topRight.v = startU
                result.bottomLeft.u = endV
                result.bottomLeft.v = endU
                result.bottomRight.u = endV
                result.bottomRight.v = startU
                */
                
                /*
                _grid[0][0].set(topLeftU: 0.0,
                                topLeftV: 1.0,
                                topRightU: 0.0,
                                topRightV: 0.5,
                                bottomLeftU: 1.0,
                                bottomLeftV: 1.0,
                                bottomRightU: 1.0,
                                bottomRightV: 0.5)
                _grid[1][0].set(topLeftU: 0.0,
                                topLeftV: 0.5,
                                topRightU: 0.0,
                                topRightV: 0.0,
                                bottomLeftU: 1.0,
                                bottomLeftV: 0.5,
                                bottomRightU: 1.0,
                                bottomRightV: 0.0)
                */
                
                var u1 = startU + (endU - startU) * xp1
                var u2 = startU + (endU - startU) * xp2
                
                var v1 = startV + (endV - startV) * yp1
                var v2 = startV + (endV - startV) * yp2
                
                _grid[x][y].set(topLeftU: v1,
                                topLeftV: u2,
                                topRightU: v1,
                                topRightV: u1,
                                bottomLeftU: v2,
                                bottomLeftV: u2,
                                bottomRightU: v2,
                                bottomRightV: u1)
                
                /*
                _grid[x][y].set(topLeftU: yp1,
                                topLeftV: xp2,
                                topRightU: yp1,
                                topRightV: xp1,
                                bottomLeftU: yp2,
                                bottomLeftV: xp2,
                                bottomRightU: yp2,
                                bottomRightV: xp1)
                */
            }
        }
        
        /*
        _grid[0][0].set(topLeftU: 0.0,
                        topLeftV: 1.0,
                        topRightU: 0.0,
                        topRightV: 0.5,
                        bottomLeftU: 1.0,
                        bottomLeftV: 1.0,
                        bottomRightU: 1.0,
                        bottomRightV: 0.5)
        _grid[1][0].set(topLeftU: 0.0,
                        topLeftV: 0.5,
                        topRightU: 0.0,
                        topRightV: 0.0,
                        bottomLeftU: 1.0,
                        bottomLeftV: 0.5,
                        bottomRightU: 1.0,
                        bottomRightV: 0.0)
        */
        
        
        
    }
    
    func draw(renderEncoder: MTLRenderCommandEncoder) {
        
        guard let textureY = textureY else { return }
        guard let textureCBCR = textureCBCR else { return }
        
        guard _grid.count == gridWidth else { return }
        guard _grid[0].count == gridHeight else { return }
        
        /*
        uniformsVertex.projectionMatrix.ortho(width: graphics.width,
                                              height: graphics.height)
        */
        
        let cam = TileCamera(graphics: graphics)
        
        let ddd = TileCameraCalibrationHelper.distance(camera: cam,
                                             graphics: graphics,
                                             frameY: vertexData[0].y,
                                             padding: 4.0)
        
        let aspect = graphics.width / graphics.height
        var perspective = matrix_float4x4()
        perspective.perspective(fovy: Float.pi * 0.5, aspect: aspect, nearZ: 1.0, farZ: 2048.0)
        
        var eye = SIMD3<Float>(x: 0.0, y: 0.0, z: -ddd)
        var up = SIMD3<Float>(x: 0.0, y: -1.0, z: 0.0)
        var center = SIMD3<Float>(x: 0.0, y: 0.0, z: 0.0)
        
        var lookAt = matrix_float4x4()
        lookAt.lookAt(eyeX: eye.x, eyeY: eye.y, eyeZ: eye.z,
                      centerX: 0.0, centerY: 0.0, centerZ: 0.0,
                      upX: up.x, upY: up.y, upZ: up.z)
        var projection = simd_mul(perspective, lookAt)
        
        
        
        
        
        
        
        if true {
            uniformsVertex.projectionMatrix = projection
            uniformsVertex.modelViewMatrix = matrix_identity_float4x4
            
            graphics.write(buffer: uniformsVertexBuffer, uniform: uniformsVertex)
            graphics.write(buffer: uniformsFragmentBuffer, uniform: uniformsFragment)
            graphics.write(buffer: vertexDataBuffer, array: vertexData)
            
            graphics.set(pipelineState: .spriteNodeColoredIndexed3DYCBCRAlphaBlending,
                         renderEncoder: renderEncoder)
            
            graphics.set(samplerState: .linearClamp, renderEncoder: renderEncoder)
            
            graphics.setVertexUniformsBuffer(uniformsVertexBuffer,
                                             renderEncoder: renderEncoder)
            graphics.setVertexDataBuffer(vertexDataBuffer,
                                         renderEncoder: renderEncoder)
            
            graphics.setFragmentTextureY(textureY,
                                         renderEncoder: renderEncoder)
            graphics.setFragmentTextureCBCR(textureCBCR,
                                            renderEncoder: renderEncoder)
            
            graphics.setFragmentUniformsBuffer(uniformsFragmentBuffer,
                                               renderEncoder: renderEncoder)
            
            renderEncoder.drawIndexedPrimitives(type: .triangleStrip,
                                                indexCount: indices.count,
                                                indexType: .uint16,
                                                indexBuffer: indexBuffer,
                                                indexBufferOffset: 0,
                                                instanceCount: 1)
        }
        
        
        
        for x in 0..<gridWidth {
            for y in 0..<gridHeight {
                _grid[x][y].set(textureY: textureY,
                                textureCBCR: textureCBCR)
                _grid[x][y].draw(renderEncoder: renderEncoder,
                                 projection: projection)
            }
        }
        
        
        
        
        
        
    }
    
    func cellWidthArray() -> [Int] {
        var result = [Int]()
        result.reserveCapacity(gridWidth)
        var totalSpace = Int(frameWidth)
        let baseWidth = totalSpace / gridWidth
        for _ in 0..<gridWidth {
            result.append(baseWidth)
            totalSpace -= baseWidth
        }
        while totalSpace > 0 {
            for colIndex in 0..<gridWidth {
                result[colIndex] += 1
                totalSpace -= 1
                if totalSpace <= 0 { break }
            }
        }
        return result
    }
    
    func cellXArray() -> [Int] {
        var result = [Int]()
        var cellX = Int(frameLeft)
        for index in 0..<gridWidth {
            result.append(cellX)
            cellX += _cellWidthArray[index]
        }
        return result
    }
    
    func cellHeightArray() -> [Int] {
        var result = [Int]()
        result.reserveCapacity(gridHeight)
        var totalSpace = Int(frameHeight)
        let baseHeight = totalSpace / gridHeight
        for _ in 0..<gridHeight {
            result.append(baseHeight)
            totalSpace -= baseHeight
        }
        
        //there might be a little space left over,
        //evenly distribute that remaining space...
        while totalSpace > 0 {
            for colIndex in 0..<gridHeight {
                result[colIndex] += 1
                totalSpace -= 1
                if totalSpace <= 0 { break }
            }
        }
        return result
    }
    
    func cellYArray() -> [Int] {
        var result = [Int]()
        var cellY = Int(frameTop)
        for index in 0..<gridHeight {
            result.append(cellY)
            cellY += _cellHeightArray[index]
        }
        return result
    }
    
}
