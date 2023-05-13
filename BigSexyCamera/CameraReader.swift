//
//  CameraReader.swift
//  BigSexyCamera
//
//  Created by Screwy Uncle Louie on 5/13/23.
//

import Foundation
import UIKit
import AVFoundation

actor CameraReader: NSObject {
    

    
    private var captureSession: AVCaptureSession?
    
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
    }
    
    func startCapturingCameraInput() {
        
        stopCapturingCameraInput()
        
        
    }
    
    func stopCapturingCameraInput() {
        
    }
    
}

extension CameraReader: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    
    
    
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
