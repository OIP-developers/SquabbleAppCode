//
//  CameraController.swift
//  AV Foundation
//
//  Created by Pranjal Satija on 29/5/2017.
//  Copyright © 2017 AppCoda. All rights reserved.
//

import AVFoundation
import UIKit

class CameraController: NSObject, AVCaptureFileOutputRecordingDelegate {
    
    // Capture session
    var captureSession: AVCaptureSession?
    
    var currentCameraPosition: CameraPosition?
    
    var frontCamera: AVCaptureDevice?
    var rearCamera: AVCaptureDevice?
    
    var photoOutput: AVCapturePhotoOutput?
    var movieOutput = AVCaptureMovieFileOutput()
    var videoDataOutput = AVCaptureVideoDataOutput()
    
    var frontCameraInput: AVCaptureDeviceInput?
    var rearCameraInput: AVCaptureDeviceInput?
    var currentCameraInput: AVCaptureDeviceInput?
    var audioInput: AVCaptureDeviceInput?
    
    
    var previewLayer: AVCaptureVideoPreviewLayer?
    var flashMode = AVCaptureDevice.FlashMode.auto
    var hdrMode = false
    
    
    var photoCaptureCompletionBlock: ((UIImage?, Error?) -> Void)?
//    var videoCaptureCompletionBlock: ((URL?, Data?, Error?) -> Void)?
    
    public typealias videoCaptureCompletionBlock = (_ videoURL: URL?, _ data: Data?, _ error: Error?, _ status:Int) -> Void

    var outputURL: URL!
    var timer: Timer?
    
    let cameraEngine = CameraEngine()
    
    public typealias stopVideoCompletionBlock = (_ videoURL: URL?, _ error: Error?) -> Void

    
}

extension CameraController {
    
//    func namehere(complisionHandler:videoCaptureCompletionBlock) -> Void {
//    }
    
    
    
    func prepare(completionHandler: @escaping (Error?) -> Void) {
       
        func createCaptureSession() {
            self.captureSession = AVCaptureSession()
        }
        
        func configureCaptureDevices() throws {
            
            let deviceDisCoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified)
            
            let availableDevices = deviceDisCoverySession.devices.compactMap { $0 }
            
            guard !availableDevices.isEmpty else { throw CameraControllerError.noCamerasAvailable }
            
            for device in availableDevices {
                
                if device.position == .front {
                    self.frontCamera = device
                }
                else if device.position == .back {
                    self.rearCamera = device
                    
                    try device.lockForConfiguration()
                    device.focusMode = .continuousAutoFocus
//                    device.automaticallyAdjustsVideoHDREnabled = true
                    device.unlockForConfiguration()

                }
                
            }
        }
        
        func configureDeviceInputs() throws {
            
            guard let captureSession = self.captureSession else { throw CameraControllerError.captureSessionIsMissing }
            captureSession.beginConfiguration()

             if let frontCamera = self.frontCamera {
                self.frontCameraInput = try AVCaptureDeviceInput(device: frontCamera)
                
                if captureSession.canAddInput(self.frontCameraInput!) { captureSession.addInput(self.frontCameraInput!) }
                else { throw CameraControllerError.inputsAreInvalid }
                
                self.currentCameraPosition = .front
                self.currentCameraInput = self.frontCameraInput
            }
            else if let rearCamera = self.rearCamera {
                self.rearCameraInput = try AVCaptureDeviceInput(device: rearCamera)
                
                if captureSession.canAddInput(self.rearCameraInput!) { captureSession.addInput(self.rearCameraInput!) }
                
                self.currentCameraPosition = .rear
                self.currentCameraInput = self.rearCameraInput
            }

            else { throw CameraControllerError.noCamerasAvailable }
            
            do {
                let audioDevice = AVCaptureDevice.default(for: .audio)
                let audioDeviceInput = try AVCaptureDeviceInput(device: audioDevice!)
                
                if captureSession.canAddInput(audioDeviceInput) {
                    captureSession.addInput(audioDeviceInput)
                    self.audioInput = audioDeviceInput
                } else {
                    print("Could not add audio device input to the session")
                }
            } catch {
                print("Could not create audio device input: \(error)")
            }
            
            captureSession.commitConfiguration()
        }
        
        func configurePhotoOutput() throws {
            
            guard let captureSession = self.captureSession else { throw CameraControllerError.captureSessionIsMissing }
            captureSession.beginConfiguration()
            
            // set up photo output
            self.photoOutput = AVCapturePhotoOutput()
            
            // provide settings for photos...
            self.photoOutput!.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecType.jpeg])], completionHandler: nil)
            
            self.photoOutput?.isHighResolutionCaptureEnabled = true
            
            if captureSession.canAddOutput(self.photoOutput!) { captureSession.addOutput(self.photoOutput!) }
            
            CameraEngine.shared().setUpVideoOutputFor(self.captureSession)
            
            captureSession.commitConfiguration()
            
            captureSession.startRunning()

        }
        
        
        
        DispatchQueue(label: "prepare").async {
            do {
                createCaptureSession()
                try configureCaptureDevices()
                try configureDeviceInputs()
                try configurePhotoOutput()
            }
                
            catch {
                DispatchQueue.main.async {
                    completionHandler(error)
                }
                
                return
            }
            
            DispatchQueue.main.async {
                completionHandler(nil)
            }
        }
    }
    
    
    // 4. Video PreView Layer
    func displayPreview(on view: UIView) throws {
        
        guard let captureSession = self.captureSession, captureSession.isRunning else { throw CameraControllerError.captureSessionIsMissing }
        
        self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.previewLayer?.connection?.videoOrientation = .portrait
        
        view.layer.insertSublayer(self.previewLayer!, at: 0)
        self.previewLayer?.frame = view.frame
    }
    
    
    
    // Switch camera....
    func switchCameras() throws {
        guard let currentCameraPosition = currentCameraPosition, let captureSession = self.captureSession, captureSession.isRunning else { throw CameraControllerError.captureSessionIsMissing }
        
        captureSession.beginConfiguration()
        
        
        func switchToFrontCamera() throws {
            
            guard let rearCameraInput = self.rearCameraInput, captureSession.inputs.contains(rearCameraInput),
                let frontCamera = self.frontCamera else { throw CameraControllerError.invalidOperation }
            
            self.frontCameraInput = try AVCaptureDeviceInput(device: frontCamera)
            
            captureSession.removeInput(rearCameraInput)
            
            if captureSession.canAddInput(self.frontCameraInput!) {
                captureSession.addInput(self.frontCameraInput!)
                
                self.currentCameraPosition = .front
                self.currentCameraInput = self.frontCameraInput
                
                CameraEngine.shared().update(captureSession)
            }
                
            else {
                throw CameraControllerError.invalidOperation
            }
        }
        
        func switchToRearCamera() throws {
            
            guard let frontCameraInput = self.frontCameraInput, captureSession.inputs.contains(frontCameraInput),
                let rearCamera = self.rearCamera else { throw CameraControllerError.invalidOperation }
            
            self.rearCameraInput = try AVCaptureDeviceInput(device: rearCamera)
            
            captureSession.removeInput(frontCameraInput)
            
            if captureSession.canAddInput(self.rearCameraInput!) {
                captureSession.addInput(self.rearCameraInput!)
                
                self.currentCameraPosition = .rear
                self.currentCameraInput = self.rearCameraInput
                
                CameraEngine.shared().update(captureSession)
            }
                
                
            else { throw CameraControllerError.invalidOperation }
        }
        
        switch currentCameraPosition {
        case .front:
            try switchToRearCamera()
            
        case .rear:
            try switchToFrontCamera()
        }
        
        captureSession.commitConfiguration()
    }
    
    // MARK: - Capture Image
    func captureImage(completion: @escaping (UIImage?, Error?) -> Void) {
        guard let captureSession = captureSession, captureSession.isRunning else { completion(nil, CameraControllerError.captureSessionIsMissing); return }
        
        let settings = AVCapturePhotoSettings()
        
        do {
            try self.currentCameraInput?.device.lockForConfiguration()
            self.currentCameraInput?.device.automaticallyAdjustsVideoHDREnabled = false
            if (self.currentCameraInput?.device.activeFormat.isVideoHDRSupported)! {
                self.currentCameraInput?.device.isVideoHDREnabled = hdrMode
            }
            self.currentCameraInput?.device.unlockForConfiguration()
        } catch {
            print("Cant change HDR mode...")
        }
        
        let position = self.currentCameraInput?.device.position
        settings.flashMode = position == .front || position == .unspecified ? .off : self.flashMode
        
        settings.isAutoStillImageStabilizationEnabled = true
        
        self.photoOutput?.capturePhoto(with: settings, delegate: self)
        self.photoCaptureCompletionBlock = completion
    }
    
//    func startRecording(completionHandler : videoCaptureCompletionBlock) -> Void {

    // MARK: - Video Capture Methods
    func startRecording() {
        CameraEngine.shared().startCapture()
    }
    
    func stopSession() {
        CameraEngine.shared().shutdown()
        self.captureSession?.stopRunning()
    }
    
    func pauseRecording() {
        CameraEngine.shared().pauseCapture()
    }
    
    func resumeRecording() {
        CameraEngine.shared().resumeCapture()
    }
    
    func stopRecording(complisionHandler:@escaping stopVideoCompletionBlock) {
        CameraEngine.shared().stopCapture { (videoURL, error) in
            complisionHandler(videoURL,error)
        }
    }
    
    
    func tempURL() -> URL? {
//        let directory = DocumentDirectoryPath.documentsPath.appending("/10SECVideos")
        let directory = NSTemporaryDirectory() as NSString

        if directory != "" {
            let path = directory.appendingPathComponent(NSUUID().uuidString + ".mp4")
            return URL(fileURLWithPath: path)
        }
        return nil
    }
    
    // Recording Starts
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        print("recording starts...")
    }

    // Recording ends
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if (error != nil) {
            print("Error recording movie: \(error!.localizedDescription)")
        } else {
            let videoURL = outputURL as URL
            print(videoURL.absoluteString)
        }
        
        outputURL = nil
    }
    
    
}

// MARK: - AVCapturePhotoCaptureDelegate Methods

extension CameraController: AVCapturePhotoCaptureDelegate {
    
    public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        if let error = error {
            self.photoCaptureCompletionBlock?(nil, error)
        }
        else {
            let data = photo.fileDataRepresentation()
            let image = UIImage(data: data!)
            self.photoCaptureCompletionBlock!(image,nil)
        }
    }
}

// MARK: - EXTENSION
extension CameraController {
    enum CameraControllerError: Swift.Error {
        case captureSessionAlreadyRunning
        case captureSessionIsMissing
        case inputsAreInvalid
        case invalidOperation
        case noCamerasAvailable
        case unknown
    }
    
    public enum CameraPosition {
        case front
        case rear
    }
}
