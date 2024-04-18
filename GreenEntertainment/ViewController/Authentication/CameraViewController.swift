//
//  CameraViewController.swift
//  GreenEntertainment
//
//  Created by Prateek Keshari on 09/06/20.
//  Copyright © 2020 Quytech. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    
    //for custom camera
    var cameraCompletion : ((Bool,UIImage)->Void)?
    let cameraController = CameraController()
    let cameraEngine = CameraEngine()
    var isCameraForImageMode = false
    //
    
    let imagePicker = UIImagePickerController()
    var screenType: CameraScreenType = .signup
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        self.initialMethod()
    }
    
    
    func initialMethod(){
        heightConstraint.constant = Window_Height - 200
        cameraView.addSubview(createOverlay(frame: cameraView.frame, xOffset: Window_Width / 2 , yOffset: (Window_Height - 200 ) / 2 , radius: 140))
        
        
    }
    
    func createOverlay(frame : CGRect, xOffset: CGFloat, yOffset: CGFloat, radius: CGFloat) -> UIView
    {
        let overlayView = UIView(frame: frame)
        overlayView.alpha = 0.6
        overlayView.backgroundColor = UIColor.black
        
        // Create a path with the rectangle in it.
        let path = CGMutablePath()
        path.addArc(center: CGPoint(x: xOffset, y: yOffset), radius: radius, startAngle: 0.0, endAngle: 2 * 3.14, clockwise: false)
        path.addRect(CGRect(x: 0, y: 0, width: overlayView.frame.width, height: overlayView.frame.height))
        let maskLayer = CAShapeLayer()
        maskLayer.backgroundColor = UIColor.clear.cgColor
        maskLayer.path = path;
        maskLayer.fillRule = CAShapeLayerFillRule.evenOdd
        
        // Release the path since it's not covered by ARC.
        overlayView.layer.mask = maskLayer
        overlayView.clipsToBounds = true
        
        return overlayView
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }
    
    
    //Required Methods for custom camera
    func configureCameraController() {
        cameraController.prepare {(error) in
            if let error = error {
                print(error)
            }
            // Display camera preview..
            try? self.cameraController.displayPreview(on: self.cameraView)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch status {
        case .authorized:
            self.configureCameraController()
        case .denied,.restricted:
            
            AlertController.alert(title: "Required Camera Access", message: "Please allow device camera to record video.", buttons: ["Settings","Cancel"]) { (action, index) in
                if(index == 0){
                    if let url = URL(string:UIApplication.openSettingsURLString) {
                        if UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }
                    }
                }else{
                }
            }
            
        case .notDetermined:
            // Prompting user for the permission to use the camera.
            AVCaptureDevice.requestAccess(for: AVMediaType.video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        self.configureCameraController()
                    } else {
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        @unknown default:
            break
        }
        // audio permission
        let audioStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.audio)
        switch audioStatus {
        case .authorized: break
        case .denied,.restricted:
            AlertController.alert(title: "Required Microphone Access", message: "Please allow device microphone to record audio.", buttons: ["Settings","Cancel"]) { (action, index) in
                if(index == 0){
                    if let url = URL(string:UIApplication.openSettingsURLString) {
                        if UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }
                    }
                }else{
                }
                
            }
        case .notDetermined:
            // Prompting user for the permission to use the camera.
            AVCaptureDevice.requestAccess(for: AVMediaType.audio) { granted in
                DispatchQueue.main.async {
                    if granted {
                    }
                    else {
                    }
                }
            }
        @unknown default:
            break
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.cameraController.stopSession()
        self.cameraController.previewLayer?.removeFromSuperlayer()
    }
    
    
    //
    
    
    
    @IBAction func takePhoto(_ sender: AnyObject) {
        cameraController.captureImage {(image, error) in
            guard let image = image else {
                return
            }
            self.detect(image:image)
        }
    }
    
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        
        if let pickedImage = info[UIImagePickerController.InfoKey(rawValue: UIImagePickerController.InfoKey.originalImage.rawValue)] as? UIImage {
            imageView.contentMode = .scaleAspectFit
            imageView.image = pickedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func detect(image:UIImage) {
        let imageOptions =  NSDictionary(object: NSNumber(value: 5) as NSNumber, forKey: CIDetectorImageOrientation as NSString)
        let personciImage = CIImage(cgImage: image.cgImage!)
        let accuracy = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
        let faceDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: accuracy)
        let faces = faceDetector?.features(in: personciImage, options: imageOptions as? [String : AnyObject])
        
        if let face = faces?.first as? CIFaceFeature {
            if let vc = UIStoryboard.auth.get(CropImageViewController.self) {
                vc.profileImage = image.fixOrientation!
                vc.delegate = self
                self.navigationController?.pushViewController(vc, animated: true)
            }
        } else {
            AlertController.alert(title: "No Face!", message: "No face was detected")
        }
    }
    
}


extension CameraViewController: CropDelegate {
    func croppedImage(image: UIImage) {
        self.navigationController?.popViewController(animated: false)
        self.detectCropped(image: image)
    }
    
    func detectCropped(image:UIImage) {
        let imageOptions =  NSDictionary(object: NSNumber(value: 5) as NSNumber, forKey: CIDetectorImageOrientation as NSString)
        let personciImage = CIImage(cgImage: image.cgImage!)
        let accuracy = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
        let faceDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: accuracy)
        let faces = faceDetector?.features(in: personciImage, options: imageOptions as? [String : AnyObject])
        
        if let face = faces?.first as? CIFaceFeature {
            if screenType == .edit {
                self.cameraCompletion?(true,image)
                self.navigationController?.popViewController(animated: true)
            }else {
                if let vc = UIStoryboard.auth.get(SignupViewController.self) {
                    vc.image = image
                    navigationController?.pushViewController(vc, animated: true)
                }
            }
        } else {
            AlertController.alert(title: "No Face!", message: "No face was detected")
        }
    }
}
