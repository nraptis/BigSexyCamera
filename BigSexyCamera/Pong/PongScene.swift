//
//  PongScene.swift
//  PongCLPA
//
//  Created by Tiger Nixon on 5/4/23.
//

import Foundation
import Metal
import UIKit
import simd

class PongScene: GraphicsDelegate {
    
    var pony2DTexture: MTLTexture?
    var pony2DUniformsVertex = UniformsSpriteVertex()
    var pony2DUniformsVertexBuffer: MTLBuffer!
    var pony2DUniformsFragment = UniformsSpriteFragment()
    var pony2DUniformsFragmentBuffer: MTLBuffer!
    var pony2DPositions: [Float] = [-64.0, -64.0,
                                     64.0, -64.0,
                                    -64.0, 64.0,
                                     64.0, 64.0]
    var pony2DPositionsBuffer: MTLBuffer!
    var pony2DTextureCoords: [Float] = [0.0, 0.0,
                                        1.0, 0.0,
                                        0.0, 1.0,
                                        1.0, 1.0]
    var pony2DTextureCoordsBuffer: MTLBuffer!
    
    
    struct SpriteColored3DNode {
        let x: Float
        let y: Float
        let z: Float
        
        let u: Float
        let v: Float
        
        let r: Float
        let g: Float
        let b: Float
        let a: Float
    }
    
    
    var pony3DTexture: MTLTexture?
    var pony3DUniformsVertex = UniformsSpriteNodeIndexedVertex()
    var pony3DUniformsVertexBuffer: MTLBuffer!
    var pony3DUniformsFragment = UniformsSpriteNodeIndexedFragment()
    var pony3DUniformsFragmentBuffer: MTLBuffer!
    var pony3DData: [SpriteColored3DNode] = [
        SpriteColored3DNode(x: -64.0, y: -64.0, z: 0.0, u: 0.0, v: 0.0, r: 1.0, g: 0.5, b: 1.0, a: 0.75),
        SpriteColored3DNode(x: 64.0, y: -64.0, z: 0.0, u: 1.0, v: 0.0, r: 1.0, g: 1.0, b: 0.5, a: 0.5),
        SpriteColored3DNode(x: -64.0, y: 64.0, z: 0.0, u: 0.0, v: 1.0, r: 1.0, g: 1.0, b: 1.0, a: 0.75),
        SpriteColored3DNode(x: 64.0, y: 64.0, z: 0.0, u: 1.0, v: 1.0, r: 0.75, g: 0.75, b: 0.75, a: 1.0)]
    var pony3DDataBuffer: MTLBuffer!
    
    var pony3DIndices: [UInt16] = [0, 1, 2, 3]
    var pony3DIndexBuffer: MTLBuffer!
    
    var graphics: Graphics!
    
    lazy var paddleEnemy: Paddle = {
        Paddle(graphics: graphics)
    }()
    
    lazy var paddleSelf: Paddle = {
        Paddle(graphics: graphics)
    }()
    
    lazy var ball: Ball = {
       Ball(graphics: graphics)
    }()
    
    var ballX: Float = 0.0
    var ballY: Float = 0.0
    var ballWidth: Float = 32.0
    var ballHeight: Float = 32.0
    
    var ballSpeedX: Float = 0.0
    var ballSpeedY: Float = 0.0
    
    var selfPaddleTouch: UITouch?
    var selfPaddleStartTouchX: Float = 0.0
    var selfPaddleStartTouchY: Float = 0.0
    var selfPaddleStartX: Float = 0.0
    var selfPaddleStartY: Float = 0.0
    
    var selfPaddleX: Float = 0.0
    var selfPaddleY: Float = 0.0
    var enemyPaddleX: Float = 0.0
    var enemyPaddleY: Float = 0.0
    
    func generateSpeed() -> Float {
        
        let spanBig = graphics.width * 0.01
        let spanTiny = graphics.width * 0.002
        
        return spanBig + Float.random(in: 0.0...spanTiny)
    }
    
    func load() {
        
        hardRestart()
        
        /*
    file:///private/var/containers/Bundle/Application/AC91723A-E101-4B2F-ACE0-242A20B275CF/BigSexyCamera.app/icon_pony.png
        ///
        */
        pony2DTexture = graphics.loadTexture(fileName: "icon_pony.png")
        if let pony2DTexture = pony2DTexture {
            print("pony2DTexture size \(pony2DTexture.width) x \(pony2DTexture.height)")
            
            
            let width = Float(pony2DTexture.width)
            let height = Float(pony2DTexture.width)
            
            let width_2 = width * 0.5
            let height_2 = height * 0.5
            let _width_2 = -(width_2)
            let _height_2 = -(height_2)
            
            pony2DPositions[0] = _width_2
            pony2DPositions[1] = _height_2
            pony2DPositions[2] = width_2
            pony2DPositions[3] = _height_2
            pony2DPositions[4] = _width_2
            pony2DPositions[5] = height_2
            pony2DPositions[6] = width_2
            pony2DPositions[7] = height_2
            
            pony2DPositionsBuffer = graphics.buffer(array: pony2DPositions)
            pony2DTextureCoordsBuffer = graphics.buffer(array: pony2DTextureCoords)

            pony2DUniformsVertexBuffer = graphics.buffer(uniform: pony2DUniformsVertex)
            pony2DUniformsFragmentBuffer = graphics.buffer(uniform: pony2DUniformsFragment)
            
        }
        
        
        pony3DTexture = graphics.loadTexture(fileName: "icon_pony.png")
        if let pony3DTexture = pony3DTexture {
            print("pony3DTexture size \(pony3DTexture.width) x \(pony3DTexture.height)")
            
            
            pony3DDataBuffer = graphics.buffer(array: pony3DData)
            
            pony3DIndexBuffer = graphics.buffer(array: pony3DIndices)
            
            pony3DUniformsVertexBuffer = graphics.buffer(uniform: pony3DUniformsVertex)
            pony3DUniformsFragmentBuffer = graphics.buffer(uniform: pony3DUniformsFragment)
        }
    }
    
    func hardRestart() {
        
        selfPaddleTouch = nil
        
        ballWidth = paddleSelf.height
        ballHeight = paddleSelf.height
        
        ballSpeedX = generateSpeed() * (Bool.random() ? -1.0 : 1.0)
        ballSpeedY = generateSpeed() * (Bool.random() ? -1.0 : 1.0)
        
        ballX = graphics.width * 0.5 - ballWidth * 0.5
        ballY = graphics.height * 0.5 - ballHeight * 0.5
        
        selfPaddleX = graphics.width * 0.5 - paddleSelf.width * 0.5
        selfPaddleY = graphics.height - graphics.safeAreaBottom - paddleSelf.height - 32.0
        
        enemyPaddleX = graphics.width * 0.5 - paddleEnemy.width * 0.5
        enemyPaddleY = graphics.safeAreaTop + 32.0
    }
    
    func update() {
        
        ballX += ballSpeedX
        if ballX <= 0 {
            ballX = 0.0
            ballSpeedX = generateSpeed()
        }
        if ballX >= (graphics.width - ball.width) {
            ballX = (graphics.width - ball.width)
            ballSpeedX = -generateSpeed()
        }

        ballY += ballSpeedY
        if ballY <= (enemyPaddleY + paddleEnemy.height) {
            ballY = (enemyPaddleY + paddleEnemy.height)
            ballSpeedY = generateSpeed()
        }
        
        if ballY >= (selfPaddleY - ballHeight) && ballSpeedY > 0.0 {
            
            if ballY <= (selfPaddleY - ballHeight * 0.5) {
                
                if (ballX + ball.width * 0.5 >= selfPaddleX) &&
                    (ballX <= selfPaddleX + paddleSelf.width - ballWidth * 0.5) {
                    
                    ballY = (selfPaddleY - ballHeight)
                    ballSpeedY = -generateSpeed()
                }
            }
        }
        
        if ballY >= graphics.height + graphics.height * 0.125 {
            // Hard Restart
            hardRestart()
        }
        
        
        
        enemyPaddleX = (ballX + ballWidth * 0.5) - paddleEnemy.width * 0.5
        if enemyPaddleX <= 0.0 {
            enemyPaddleX = 0.0
        }
        if enemyPaddleX >= (graphics.width - paddleEnemy.width) {
            enemyPaddleX = (graphics.width - paddleEnemy.width)
        }
        
        
        paddleEnemy.update(x: enemyPaddleX, y: enemyPaddleY)
        
        paddleSelf.update(x: selfPaddleX, y: selfPaddleY)
        
        ball.update(x: ballX, y: ballY, width: ballWidth, height: ballHeight)

    }
    
    func draw3D(renderEncoder: MTLRenderCommandEncoder) {
        
        
        if let pony3DTexture = pony3DTexture {
            
            pony3DUniformsVertex.projectionMatrix.ortho(width: graphics.width,
                                                        height: graphics.height)
            
            var modelView = matrix_identity_float4x4
            modelView.translate(x: graphics.width * 0.5, y: graphics.height * 0.75, z: 0.0)
            modelView.scale(2.0)
            modelView.rotateZ(degrees: -25.0)
            
            pony3DUniformsVertex.modelViewMatrix = modelView
            
            graphics.write(buffer: pony3DUniformsVertexBuffer, uniform: pony3DUniformsVertex)
            
            pony3DUniformsFragment.green = Float.random(in: 0.5...1.0)
            pony3DUniformsFragment.alpha = 0.5
            graphics.write(buffer: pony3DUniformsFragmentBuffer, uniform: pony3DUniformsFragment)
            
            graphics.set(pipelineState: .spriteNodeColoredIndexed3DAlphaBlending,
                         renderEncoder: renderEncoder)
            
            graphics.set(samplerState: .linearClamp, renderEncoder: renderEncoder)
            
            graphics.setFragmentTexture(pony3DTexture,
                                        renderEncoder: renderEncoder)
            graphics.setVertexDataBuffer(pony3DDataBuffer,
                                         renderEncoder: renderEncoder)
            
            graphics.setFragmentUniformsBuffer(pony3DUniformsFragmentBuffer,
                                               renderEncoder: renderEncoder)
            graphics.setVertexUniformsBuffer(pony3DUniformsVertexBuffer,
                                             renderEncoder: renderEncoder)
            
            renderEncoder.drawIndexedPrimitives(type: .triangleStrip,
                                                indexCount: pony3DIndices.count,
                                                indexType: .uint16,
                                                indexBuffer: pony3DIndexBuffer,
                                                indexBufferOffset: 0,
                                                instanceCount: 1)
            
        }
        
    }
    
    func draw2D(renderEncoder: MTLRenderCommandEncoder) {
        
        /*
        let positions: [Float] = [20.0, 20.0,
                                  graphics.width - 20.0, 20.0,
                                  20.0, graphics.height - 20.0,
                                  graphics.width - 20.0, graphics.height - 20.0]
        
        let positionsBuffer = graphics.buffer(array: positions)
        
        var uniformsVertex = UniformsShapeVertex()
        uniformsVertex.projectionMatrix.ortho(width: graphics.width, height: graphics.height)
        let uniformsVertexBuffer = graphics.buffer(uniform: uniformsVertex)
        
        var uniformsFragment = UniformsShapeFragment()
        uniformsFragment.set(red: 1.0, green: 0.5, blue: 0.0)
        let uniformsFragmentBuffer = graphics.buffer(uniform: uniformsFragment)
        
        graphics.set(pipelineState: .shape2DNoBlending, renderEncoder: renderEncoder)
        
        graphics.setVertexPositionsBuffer(positionsBuffer, renderEncoder: renderEncoder)
        graphics.setVertexUniformsBuffer(uniformsVertexBuffer, renderEncoder: renderEncoder)
        graphics.setFragmentUniformsBuffer(uniformsFragmentBuffer, renderEncoder: renderEncoder)
        
        renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
        */
        
        paddleEnemy.draw(renderEncoder: renderEncoder)
        paddleSelf.draw(renderEncoder: renderEncoder)
        ball.draw(renderEncoder: renderEncoder)
        
        //ponySprite.
        
        if let pony2DTexture = pony2DTexture {
            
            pony2DUniformsVertex.projectionMatrix.ortho(width: graphics.width,
                                                        height: graphics.height)
            
            var modelView = matrix_identity_float4x4
            modelView.translate(x: graphics.width * 0.5, y: graphics.height * 0.5, z: 0.0)
            modelView.scale(0.25)
            modelView.rotateZ(degrees: 45.0)
            
            pony2DUniformsVertex.modelViewMatrix = modelView
            
            graphics.write(buffer: pony2DUniformsVertexBuffer, uniform: pony2DUniformsVertex)
            
            pony2DUniformsFragment.green = Float.random(in: 0.5...1.0)
            pony2DUniformsFragment.alpha = 0.5
            graphics.write(buffer: pony2DUniformsFragmentBuffer, uniform: pony2DUniformsFragment)
            
            graphics.set(pipelineState: .sprite2DAlphaBlending,
                         renderEncoder: renderEncoder)
            graphics.setFragmentTexture(pony2DTexture,
                                        renderEncoder: renderEncoder)
            graphics.setVertexPositionsBuffer(pony2DPositionsBuffer,
                                              renderEncoder: renderEncoder)
            graphics.setVertexTextureCoordsBuffer(pony2DTextureCoordsBuffer,
                                                  renderEncoder: renderEncoder)
            
            graphics.setFragmentUniformsBuffer(pony2DUniformsFragmentBuffer,
                                               renderEncoder: renderEncoder)
            graphics.setVertexUniformsBuffer(pony2DUniformsVertexBuffer,
                                             renderEncoder: renderEncoder)
            
            renderEncoder.drawPrimitives(type: .triangleStrip,
                                         vertexStart: 0,
                                         vertexCount: 4,
                                         instanceCount: 1)
            
        }
        
    }
    
    func touchBegan(touch: UITouch, x: Float, y: Float) {
        
        if selfPaddleTouch === nil {
            selfPaddleTouch = touch
            selfPaddleStartTouchX = x
            selfPaddleStartTouchY = y
            selfPaddleStartX = selfPaddleX
            selfPaddleStartY = selfPaddleY
        }
        
    }
    
    func touchMoved(touch: UITouch, x: Float, y: Float) {
        
        //paddleSelf.update(x: x, y: 300)
        if touch === selfPaddleTouch {
            
            selfPaddleX = selfPaddleStartX + (x - selfPaddleStartTouchX)
            if selfPaddleX <= 0.0 {
                selfPaddleX = 0.0
            }
            if selfPaddleX >= (graphics.width - paddleSelf.width) {
                selfPaddleX = (graphics.width - paddleSelf.width)
            }
            
        }
        
        
    }
    
    func touchEnded(touch: UITouch, x: Float, y: Float) {
        
        if touch === selfPaddleTouch {
            selfPaddleTouch = nil
        }
        
    }
}
