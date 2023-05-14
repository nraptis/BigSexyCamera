//
//  CameraReader.swift
//  BigSexyCamera
//
//  Created by Screwy Uncle Louie on 5/13/23.
//

import Foundation
import UIKit
import AVFoundation

protocol CameraReaderDelegate: AnyObject {
    func receive(image: UIImage)
}

class CameraReader_AV: NSObject {
    
    weak var delegate: CameraReaderDelegate?
    
    private var captureSession: AVCaptureSession?
    private var videoOutput: AVCaptureVideoDataOutput?
    private var depthOutput: AVCaptureDepthDataOutput?
    private let videoQueue = DispatchQueue(label: "com.camera.reader.video")
    private let depthQueue = DispatchQueue(label: "com.camera.reader.depth")
    
    
    let screenWidth: CGFloat
    let screenWidthI: Int
    
    let screenHeight: CGFloat
    let screenHeightI: Int
    
    init(screenWidth: Int, screenHeight: Int) {
        self.screenWidthI = screenWidth
        self.screenWidth = CGFloat(screenWidth)
        self.screenHeightI = screenHeight
        self.screenHeight = CGFloat(screenHeight)
        
        print("created camera reader of size \(screenWidth) x \(screenHeight)")
        
        super.init()
        
        setupCaptureSession()
    }
    
    func setupCaptureSession() {
        
        captureSession = AVCaptureSession()
        guard let captureSession = captureSession else {
            print("AVCaptureSession could not be created.")
            return
        }
        
        var hasVideo = false
        if let captureDeviceVideo = AVCaptureDevice.default(for: .video) {
            do {
                let input = try AVCaptureDeviceInput(device: captureDeviceVideo)
                captureSession.addInput(input)
                hasVideo = true
            } catch let error {
                print("error creating capture device input for video: \(error.localizedDescription)")
            }
        } else {
            print("there is no video device available.")
        }
        
        var hasDepth = false
        if let captureDeviceDepth = AVCaptureDevice.default(.builtInTrueDepthCamera, for: .depthData, position: .unspecified) {
            do {
                 let input = try AVCaptureDeviceInput(device: captureDeviceDepth)
                captureSession.addInput(input)
                hasDepth = true
            } catch let error {
                print("error creating capture device input for depth: \(error.localizedDescription)")
            }
        } else {
            print("there is no depth device available.")
        }
        

        // Set up video output
        if hasVideo {
            videoOutput = AVCaptureVideoDataOutput()
            guard let videoOutput = videoOutput else {
                print("AVCaptureVideoDataOutput could not be created.")
                return
            }
            
            videoOutput.setSampleBufferDelegate(self, queue: videoQueue)
            captureSession.addOutput(videoOutput)
        } else {
            print("does not have video.")
        }
        
        
        if hasDepth {
            depthOutput = AVCaptureDepthDataOutput()
            guard let depthOutput = depthOutput else {
                print("AVCaptureDepthDataOutput could not be created.")
                return
            }
            
            //depthOutput.setSampleBufferDelegate(self, queue: DispatchQueue.global(qos: .default))
            depthOutput.setDelegate(self, callbackQueue: depthQueue)
            captureSession.addOutput(depthOutput)
        } else {
            print("does not have depth.")
        }
        
        // Configure capture session
        captureSession.sessionPreset = .high
        
        print("rinnin he")
    }
    
    func startCapturingCameraInput() {
        
        guard let captureSession = captureSession else {
            print("startCapturingCameraInput, no capture session exists!")
            return
        }
        
        captureSession.startRunning()
        print("capture session running!")
    }
    
    static var isColorCameraAvailable: Bool {
        get {
            if let captureDevice = AVCaptureDevice.default(for: .video) {
                return true
            }
            return false
        }
    }
    
    static var isDepthCameraAvailable: Bool {
        get {
            if let captureDevice = AVCaptureDevice.default(for: .depthData) {
                return true
            }
            return false
        }
    }
    
    func stopCapturingCameraInput() {
        
        /*
        if let captureSession = captureSession {
            if let videoOutput = videoOutput {
                captureSession.removeOutput(videoOutput)
            }
            captureSession.stopRunning()
            self.captureSession = nil
        }
        
        if let videoOutput = videoOutput {
            videoOutput.setSampleBufferDelegate(nil, queue: nil)
            self.videoOutput = nil
        }
        */
        captureSession?.stopRunning()
        
        
        
    }
    
}

extension CameraReader_AV: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
        let context = CIContext()
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
            return
        }
        
        // Crop the image to the screen size
        if let croppedImage = cgImage.cropping(to: CGRect(x: 0, y: 0, width: screenWidthI, height: screenHeightI)) {
            
            let imag = UIImage(cgImage: croppedImage)
            
            delegate?.receive(image: imag)
        }
        
        // Process the cropped image (replace with your custom logic)
        //processImage(croppedImage)
    }
}

extension CameraReader_AV: AVCaptureDepthDataOutputDelegate {
    func depthDataOutput(_ output: AVCaptureDepthDataOutput, didOutput depthData: AVDepthData, timestamp: CMTime, connection: AVCaptureConnection) {
     
        print("capped depth data")
    }
    
    
}

/*
class CameraFrameProcessor: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    private var captureSession: AVCaptureSession?
    private var videoOutput: AVCaptureVideoDataOutput?
    
    private var screenFrame: CGRect {
        return UIScreen.main.bounds
    }
    
    override init() {
        super.init()
        
        // Initialize capture session
        captureSession = AVCaptureSession()
        
        // Set up input device (e.g., camera)
        guard let captureDevice = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: captureDevice) else {
            print("Failed to set up camera input")
            return
        }
        captureSession?.addInput(input)
        
        // Set up video output
        videoOutput = AVCaptureVideoDataOutput()
        videoOutput?.setSampleBufferDelegate(self, queue: DispatchQueue.global(qos: .default))
        captureSession?.addOutput(videoOutput!)
        
        // Configure capture session
        captureSession?.sessionPreset = .high
        
        // Start capture session
        captureSession?.startRunning()
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // Convert sample buffer to UIImage
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
        let context = CIContext()
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
            return
        }
        
        // Crop the image to the screen size
        let croppedImage = cgImage.cropping(to: screenFrame)
        
        // Process the cropped image (replace with your custom logic)
        processImage(croppedImage)
    }
    
    func processImage(_ image: CGImage?) {
        // Add your custom image processing logic here
        // This method will be called for every camera frame
        // You can use the `image` parameter, which is the cropped CGImage
        // with the size of the screen
    }
}
*/
