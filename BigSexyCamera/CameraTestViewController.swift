//
//  CameraTestViewController.swift
//  BigSexyCamera
//
//  Created by Screwy Uncle Louie on 5/13/23.
//

import UIKit
import ARKit

class CameraTestViewController: UIViewController {
    
    lazy var imageView: UIImageView = {
        let result = UIImageView(frame: CGRect.zero)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.backgroundColor = UIColor.blue
        return result
    }()

    lazy var screenWidth: CGFloat = {
        UIScreen.main.bounds.size.width
    }()
    
    lazy var screenWidthI: Int = {
        Int(screenWidth + 0.5)
    }()
    
    lazy var screenHeight: CGFloat = {
        UIScreen.main.bounds.size.height
    }()
    
    lazy var screenHeightI: Int = {
        Int(screenHeight + 0.5)
    }()
    
    lazy var cameraInputProvider: AugmentedRealityCameraInputProvider = {
        let result = AugmentedRealityCameraInputProvider(screenWidth: screenWidthI,
                                                         screenHeight: screenHeightI)
        return result
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor.orange
        
        
        if let selfView = self.view {
            selfView.addSubview(imageView)
            imageView.addConstraints([
                NSLayoutConstraint(item: imageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: screenWidth),
                NSLayoutConstraint(item: imageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: screenHeight)
            ])
            selfView.addConstraints([
                NSLayoutConstraint(item: imageView, attribute: .centerX, relatedBy: .equal, toItem: selfView, attribute: .centerX, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: imageView, attribute: .centerY, relatedBy: .equal, toItem: selfView, attribute: .centerY, multiplier: 1.0, constant: 0.0)
            ])
        }
        
        cameraInputProvider.add(observer: self)
        cameraInputProvider.setupCaptureSession()
        cameraInputProvider.startCapturingCameraInput()
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension CameraTestViewController: AugmentedRealityCameraInputProviderReceiving {
    func provider(didReceive frame: ARFrame) {
        
    }
    
    
    func receive(image: UIImage) {
        imageView.image = image
    }
}

/*
 extension CameraTestViewController: CameraReaderDelegate {
 
 func receive(image: UIImage) {
 imageView.image = image
 }
 
 
 }
*/
