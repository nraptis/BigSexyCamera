//
//  MetalView.swift
//  PongCLPA
//
//  Created by Tiger Nixon on 5/4/23.
//

import UIKit

class MetalView: UIView {
    
    lazy var engine: MetalEngine = {
       MetalEngine(delegate: delegate,
                   graphics: graphics,
                   layer: layer as! CAMetalLayer)
    }()
    
    lazy var pipeline: MetalPipeline = {
        MetalPipeline(engine: engine)
    }()
    
    private var timer: CADisplayLink?
    
    let delegate: GraphicsDelegate
    let graphics: Graphics
    required init(delegate: GraphicsDelegate,
                  graphics: Graphics,
                  width: CGFloat,
                  height: CGFloat) {
        self.delegate = delegate
        self.graphics = graphics
        super.init(frame: CGRect(x: 0.0, y: 0.0, width: width, height: height))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override class var layerClass: AnyClass {
        CAMetalLayer.self
    }
    
    func load() {
        delegate.initialize(graphics: graphics)
        
        engine.load()
        pipeline.load()
        
        delegate.load()
        
        timer?.invalidate()
        timer = CADisplayLink(target: self, selector: #selector(render))
        timer!.add(to: RunLoop.main, forMode: .common)
    }
    
    @objc func render() {
        delegate.update()
        engine.draw()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            delegate.touchBegan(touch: touch,
                                x: Float(location.x),
                                y: Float(location.y))
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            delegate.touchMoved(touch: touch,
                                x: Float(location.x),
                                y: Float(location.y))
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            delegate.touchEnded(touch: touch,
                                x: Float(location.x),
                                y: Float(location.y))
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            delegate.touchEnded(touch: touch,
                                x: Float(location.x),
                                y: Float(location.y))
        }
    }
    
}
