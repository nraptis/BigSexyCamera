//
//  AugmentedRealityCameraInputProvider.swift
//  BigSexyCamera
//
//  Created by Screwy Uncle Louie on 5/13/23.
//

import Foundation
import ARKit
import CoreGraphics

protocol AugmentedRealityCameraInputProviderReceiving: AnyObject {
    func receive(image: UIImage)
    func provider(didReceive data: AugmentedRealityCameraInputProviderData)
}

struct AugmentedRealityCameraInputProviderData {
    let capturedImagePixelBuffer: CVPixelBuffer?
    
    let smoothedSceneDepthPixelBuffer: CVPixelBuffer?
    let smoothedSceneDepthConfidencePixelBuffer: CVPixelBuffer?
    
    let sceneDepthPixelBuffer: CVPixelBuffer?
    let sceneDepthConfidencePixelBuffer: CVPixelBuffer?
}

class AugmentedRealityCameraInputProvider: NSObject {
    
    let screenWidth: CGFloat
    let screenWidthI: Int
    
    let screenHeight: CGFloat
    let screenHeightI: Int
    
    var arSession: ARSession?
    
    private var observers = [WeakObserver]()
    
    init(screenWidth: Int, screenHeight: Int) {
        self.screenWidthI = screenWidth
        self.screenWidth = CGFloat(screenWidth)
        self.screenHeightI = screenHeight
        self.screenHeight = CGFloat(screenHeight)
        
        print("created camera reader of size \(screenWidth) x \(screenHeight)")
        print("cam supported: \(ARWorldTrackingConfiguration.isSupported)")
        
        if ARWorldTrackingConfiguration.supportsFrameSemantics([.sceneDepth, .smoothedSceneDepth]) {
            print("supports depth...")
        } else {
            print("doesnt support depth")
        }
    }
    
    func setupCaptureSession() {
        
        guard arSession === nil else {
            print("calling setupCaptureSession twice, this should not happen")
            return
        }
        
        arSession = ARSession()
        guard let arSession = arSession else {
            print("ARSession could not be created.")
            return
        }
        
        arSession.delegate = self
        
        if ARWorldTrackingConfiguration.supportsFrameSemantics([.sceneDepth]) {
            if ARWorldTrackingConfiguration.supportsFrameSemantics([.smoothedSceneDepth]) {
                let worldTrackingConfiguration = ARWorldTrackingConfiguration()
                worldTrackingConfiguration.frameSemantics = [.sceneDepth, .smoothedSceneDepth]
                arSession.run(worldTrackingConfiguration)
            } else {
                let worldTrackingConfiguration = ARWorldTrackingConfiguration()
                worldTrackingConfiguration.frameSemantics = [.sceneDepth]
                arSession.run(worldTrackingConfiguration)
            }
        } else if ARWorldTrackingConfiguration.supportsFrameSemantics([.smoothedSceneDepth]) {
            let worldTrackingConfiguration = ARWorldTrackingConfiguration()
            worldTrackingConfiguration.frameSemantics = [.smoothedSceneDepth]
            arSession.run(worldTrackingConfiguration)
        } else {
            let worldTrackingConfiguration = ARWorldTrackingConfiguration()
            arSession.run(worldTrackingConfiguration)
        }
        
        /*
        let worldTrackingConfiguration = ARWorldTrackingConfiguration()
        arSession.run(worldTrackingConfiguration)
        */
    }
    
    func startCapturingCameraInput() {
        
    }
    
    func stopCapturingCameraInput() {
        
    }
    
    private final class WeakObserver {
        weak var observer: (any AugmentedRealityCameraInputProviderReceiving)?
        init(observer: any AugmentedRealityCameraInputProviderReceiving) {
            self.observer = observer
        }
    }
    
    func add(observer: AugmentedRealityCameraInputProviderReceiving?) {
        cleanupObservers()
        if let observer = observer {
            observers.append(WeakObserver(observer: observer))
        }
    }
    
    private var _observerPurgeList = [WeakObserver]()
    private func cleanupObservers() {
        _observerPurgeList.removeAll(keepingCapacity: true)
        for observer in observers {
            if observer.observer == nil {
                _observerPurgeList.append(observer)
            }
        }
        for observer in _observerPurgeList {
            var removeIndex: Int?
            for index in 0..<observers.count {
                if observers[index] === observer {
                    removeIndex = index
                }
            }
            if let removeIndex = removeIndex {
                observers.remove(at: removeIndex)
            }
        }
    }
}

extension AugmentedRealityCameraInputProvider: ARSessionDelegate {
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        
        let data = AugmentedRealityCameraInputProviderData(capturedImagePixelBuffer: frame.capturedImage,
                                                           smoothedSceneDepthPixelBuffer: frame.smoothedSceneDepth?.depthMap,
                                                           smoothedSceneDepthConfidencePixelBuffer: frame.smoothedSceneDepth?.confidenceMap,
                                                           sceneDepthPixelBuffer: frame.sceneDepth?.depthMap,
                                                           sceneDepthConfidencePixelBuffer: frame.sceneDepth?.confidenceMap)
        
        for observer in observers {
            if let observer = observer.observer {
                observer.provider(didReceive: data)
            }
        }
    }
}
