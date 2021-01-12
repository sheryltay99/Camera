//
//  ViewController.swift
//  Camera
//
//  Created by Sheryl Tay on 6/1/21.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate, AVCapturePhotoCaptureDelegate {
//class ViewController: UIViewController, AVCapturePhotoCaptureDelegate, AVCaptureDepthDataOutputDelegate {
    
    @IBOutlet weak var cameraView: UIView!
    
    let session = AVCaptureSession()
    var previewLayer: CALayer!
    var captureDevice: AVCaptureDevice!
    
    var takePhoto = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        prepareCamera()
    }


    func prepareCamera() {
        session.sessionPreset = AVCaptureSession.Preset.photo
        if let availableDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            captureDevice = availableDevice
            beginCapture()
        }
    }
    
    func beginCapture() {
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: captureDevice)
            session.addInput(captureDeviceInput)
        } catch {
            print(error.localizedDescription)
        }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.previewLayer = previewLayer
        self.previewLayer.frame = cameraView.bounds
       
        cameraView.layer.addSublayer(self.previewLayer)
        
        session.startRunning()
        
        let dataOutput = AVCaptureVideoDataOutput()
        
        dataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as String): NSNumber(value:kCVPixelFormatType_32BGRA)]
        
        dataOutput.alwaysDiscardsLateVideoFrames = true
        
        if session.canAddOutput(dataOutput) {
            session.addOutput(dataOutput)
        }
        
        session.commitConfiguration()
        
        let queue = DispatchQueue(label: "com.sheryltay.sessionQueue")
        dataOutput.setSampleBufferDelegate(self, queue: queue)
    }
    
    @IBAction func takePhoto(_ sender: Any) {
        takePhoto = true
    }
    
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if takePhoto {
            takePhoto = false
            
            let photoOutput = AVCapturePhotoOutput()
            self.session.addOutput(photoOutput)
            print(photoOutput.isDepthDataDeliverySupported)
            
            if let image = self.getImageFromSampleBuffer(buffer: sampleBuffer) {
                
//                let photoOutput = output as! AVCapturePhotoOutput
//                self.session.addOutput(photoOutput)
                
//                if photoOutput.isDepthDataDeliverySupported {
//                    photoOutput.isDepthDataDeliveryEnabled = true
//                }
                
                DispatchQueue.main.async {
                    
                    let photoVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "PhotoVC") as! PhotoViewController
                    photoVC.takenPhoto = image
                    
                    self.present(photoVC, animated: true, completion: nil)
                }
            }
        }
    }
    
    func getImageFromSampleBuffer(buffer: CMSampleBuffer) -> UIImage? {
        if let pixelBuffer = CMSampleBufferGetImageBuffer(buffer) {
            let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
            let context = CIContext()
            
            let imageRect = CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(pixelBuffer), height: CVPixelBufferGetHeight(pixelBuffer))
            
            if let image = context.createCGImage(ciImage, from: imageRect) {
                return UIImage(cgImage: image, scale: UIScreen.main.scale, orientation: .right)
            }
        }
        return nil
    }
    
//    func stopCaptureSession() {
//        self.session.stopRunning()
//
//        if let inputs = session.inputs as? [AVCaptureDeviceInput] {
//            for input in inputs {
//                self.session.removeInput(input)
//            }
//        }
//    }
    
}
