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
    
    let ciContext = CIContext()
    
}

extension AugmentedRealityCameraInputProvider: ARSessionDelegate {
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        
        
        let pixelBuffer = frame.capturedImage
        //guard let pixelBuffer = frame.sceneDepth?.depthMap else { return }
                
                
        
        /*
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        
        print("size: \(width) x \(height)")
        
        
        
        var ciImage = CIImage(cvPixelBuffer: frame.capturedImage)
        ciImage = ciImage.oriented(.right)
        
        let imageWidth = ciImage.extent.width
        let imageHeight = ciImage.extent.height
        
        let imageSize = CGSize(width: imageWidth, height: imageHeight)
        let screenSize = CGSize(width: screenWidth, height: screenHeight)
        
        let aspect = screenSize.getAspectFill(imageSize)
        
        var transform = CGAffineTransform.identity
        transform = transform.scaledBy(x: aspect.scale, y: aspect.scale)
        ciImage = ciImage.transformed(by: transform)
        
        var diff1 = abs(ciImage.extent.width - screenWidth)
        var diff2 = abs(ciImage.extent.height - screenHeight)
        if diff1 > diff2 && diff1 > 0 {
            ciImage = ciImage.cropped(to: CGRect(x: (ciImage.extent.width - screenWidth) * 0.5, y: 0.0, width: screenWidth, height: screenHeight))
        }
        if diff2 > diff1 && diff2 > 0 {
            ciImage = ciImage.cropped(to: CGRect(x: 0.0, y: (ciImage.extent.height - screenHeight) * 0.5, width: screenWidth, height: screenHeight))
        }
        
        guard let cgImage = ciContext.createCGImage(ciImage, from: ciImage.extent) else {
            return
        }
        */
        
        if let image = fix(pixelBuffer: pixelBuffer) {
        //if let image = fix2(pixelBuffer: pixelBuffer, frame: frame) {
            for observer in observers {
                observer.observer?.receive(image: image)
            }
        }
        
             /*
        if let chauntex = copyPixelBufferToCGImage(pixelBuffer: pixelBuffer) {
            
            if let croppe = rotateAndCrop(cgImage: chauntex) {
                
                //let chappy = UIImage(cgImage: chauntex)
                //let image = UIImage(cgImage: chauntex)
                
                // Crop the image to the screen size
                //if let croppedImage = cgImage.cropping(to: CGRect(x: 0, y: 0, width: screenWidthI, height: screenHeightI)) {
                //    let imag = UIImage(cgImage: croppedImage)
                for observer in observers {
                    observer.observer?.receive(image: croppe)
                }
                //}
            }
            
        }
            */
        
    }
    
    func fix2(pixelBuffer: CVPixelBuffer, frame: ARFrame) -> UIImage? {
        
        let transform = frame.displayTransform(for: .portrait,
                                               viewportSize: CGSize(width: screenWidth,
                                                                    height: screenHeight))
        
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        
        print("size: \(width) x \(height)")
        
        
        
        var ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        
        print("original ci-image: \(ciImage.extent.width) x \(ciImage.extent.height)")
        ciImage = ciImage.transformed(by: transform)
        
        print("transformed ci-image: \(ciImage.extent.width) x \(ciImage.extent.height)")
        
        /*
        var diff1 = abs(ciImage.extent.width - screenWidth)
        var diff2 = abs(ciImage.extent.height - screenHeight)
        if diff1 > diff2 && diff1 > 0 {
            ciImage = ciImage.cropped(to: CGRect(x: (ciImage.extent.width - screenWidth) * 0.5, y: 0.0, width: screenWidth, height: screenHeight))
        }
        if diff2 > diff1 && diff2 > 0 {
            ciImage = ciImage.cropped(to: CGRect(x: 0.0, y: (ciImage.extent.height - screenHeight) * 0.5, width: screenWidth, height: screenHeight))
        }
        */
        
        guard let cgImage = ciContext.createCGImage(ciImage, from: ciImage.extent) else {
            return nil
        }
        let image = UIImage(cgImage: cgImage)
        return image
    }
    
    func fix(pixelBuffer: CVPixelBuffer) -> UIImage? {
        
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        
        print("size: \(width) x \(height)")
        
        
        
        var ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        ciImage = ciImage.oriented(.right)
        
        let imageWidth = ciImage.extent.width
        let imageHeight = ciImage.extent.height
        
        let imageSize = CGSize(width: imageWidth, height: imageHeight)
        let screenSize = CGSize(width: screenWidth, height: screenHeight)
        
        let aspect = screenSize.getAspectFill(imageSize)
        
        var transform = CGAffineTransform.identity
        transform = transform.scaledBy(x: aspect.scale, y: aspect.scale)
        ciImage = ciImage.transformed(by: transform)
        
        var diff1 = abs(ciImage.extent.width - screenWidth)
        var diff2 = abs(ciImage.extent.height - screenHeight)
        if diff1 > diff2 && diff1 > 0 {
            ciImage = ciImage.cropped(to: CGRect(x: (ciImage.extent.width - screenWidth) * 0.5, y: 0.0, width: screenWidth, height: screenHeight))
        }
        if diff2 > diff1 && diff2 > 0 {
            ciImage = ciImage.cropped(to: CGRect(x: 0.0, y: (ciImage.extent.height - screenHeight) * 0.5, width: screenWidth, height: screenHeight))
        }
        
        guard let cgImage = ciContext.createCGImage(ciImage, from: ciImage.extent) else {
            return nil
        }
        let image = UIImage(cgImage: cgImage)
        return image
    }
    
    func pixelBufferToCGImage(pixelBuffer: CVPixelBuffer) -> CGImage? {
        var ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        return ciContext.createCGImage(ciImage, from: ciImage.extent)
    }
    
    func rotateAndCrop(cgImage: CGImage?) -> UIImage? {
        guard let cgImage = cgImage else { return nil }
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: screenWidth, height: screenHeight), true, UIScreen.main.scale)
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        
        context.draw(cgImage, in: CGRect(x: 10, y: 30, width: 200, height: 400))
        
        let result = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return result
    }
    
    /*
    func rotateAndScaleImage(_ image: CGImage, toSize newSize: CGSize, SCALE: CGFloat, withRotationAngle rotationAngle: CGFloat) -> UIImage? {
        // Calculate the scale ratio
        // Create the context
        UIGraphicsBeginImageContextWithOptions(scaledSize, false, 0.0)
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        
        // Apply rotation and scaling transformations
        context.translateBy(x: scaledSize.width / 2, y: scaledSize.height / 2)
        context.rotate(by: rotationAngle)
        context.scaleBy(x: SCALE, y: -SCALE) // Flip the y-axis
        
        // Draw the image onto the context
        let drawRect = CGRect(
            x: -CGFloat(image.width) / 2,
            y: -CGFloat(image.height) / 2,
            width: CGFloat(image.width),
            height: CGFloat(image.height)
        )
        context.draw(image, in: drawRect)
        
        // Get the rotated and scaled image from the context
        let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // End the context
        UIGraphicsEndImageContext()
        
        return rotatedImage
    }
    */
    
    
    func copyPixelBufferToCGImage(pixelBuffer: CVPixelBuffer) -> CGImage? {
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        
        // Create a context to render the pixel buffer
        var cgImage: CGImage?
        var context: CGContext?
        CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
        if let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer) {
            let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            
            context = CGContext(
                data: baseAddress,
                width: width,
                height: height,
                bitsPerComponent: 8,
                bytesPerRow: bytesPerRow,
                space: colorSpace,
                bitmapInfo: CGBitmapInfo.byteOrder32Little.rawValue
            )
            
            if let context = context {
                cgImage = context.makeImage()
            }
        }
        CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly)
        
        return cgImage
    }
    
    
}
