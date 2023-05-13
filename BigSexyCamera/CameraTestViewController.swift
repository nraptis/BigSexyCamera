//
//  CameraTestViewController.swift
//  BigSexyCamera
//
//  Created by Screwy Uncle Louie on 5/13/23.
//

import UIKit

class CameraTestViewController: UIViewController {

    lazy var cameraReader: CameraReader = {
        let screenWidthI = Int(UIScreen.main.bounds.size.width + 0.5)
        let screenHeightI = Int(UIScreen.main.bounds.size.height + 0.5)
        return CameraReader(screenWidth: screenWidthI,
                            screenHeight: screenHeightI)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor.orange
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
