//
//  ViewController.swift
//  Camera
//
//  Created by Sheryl Tay on 6/1/21.
//

import UIKit
import AVFoundation

//class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate, AVCapturePhotoCaptureDelegate {
class ViewController: UIViewController, AVCapturePhotoCaptureDelegate, AVCaptureDepthDataOutputDelegate {
    
    @IBOutlet weak var cameraView: UIView!
    
    let session = AVCaptureSession()
    var previewLayer: CALayer!
    var captureDevice: AVCaptureDevice!
    var photoOutput: AVCapturePhotoOutput?
    var outputSynchronizer: AVCaptureDataOutputSynchronizer?
    var depthOutput: AVCaptureDepthDataOutput?
    
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
        
        depthOutput = AVCaptureDepthDataOutput()
        let dataOutputQueue = DispatchQueue(label: "com.sheryltay.dataOutputQueue")
        depthOutput?.setDelegate(self, callbackQueue: dataOutputQueue)
        
        photoOutput = AVCapturePhotoOutput()
        
//        let dataOutput = AVCaptureVideoDataOutput()
//
//        dataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as String): NSNumber(value:kCVPixelFormatType_32BGRA)]
//
//        dataOutput.alwaysDiscardsLateVideoFrames = true
        
        if let photoOutput = self.photoOutput {
            if session.canAddOutput(photoOutput) {
                session.addOutput(photoOutput)
                
                if let depthOutput = self.depthOutput {
                    if session.canAddOutput(depthOutput) {
                        session.addOutput(depthOutput)
                    }
                    if photoOutput.isDepthDataDeliverySupported {
                        photoOutput.isDepthDataDeliveryEnabled = true
                        
                        depthOutput.connection(with: .depthData)?.isEnabled = true
//                        outputSynchronizer = AVCaptureDataOutputSynchronizer(dataOutputs: [photoOutput, depthOutput])
//                        outputSynchronizer!.setDelegate(self, queue: dataOutputQueue)
                    }
                }
            }
            
        }
        
        session.startRunning()
        
        session.commitConfiguration()
        //        dataOutput.setSampleBufferDelegate(self, queue: queue)
    }
    
    @IBAction func takePhoto(_ sender: Any) {
        guard let capturePhotoOutput = self.photoOutput else { return }
        
        let photoSettings = AVCapturePhotoSettings()
        
        if capturePhotoOutput.isDepthDataDeliverySupported {
            photoSettings.isDepthDataDeliveryEnabled = true

            capturePhotoOutput.capturePhoto(with: photoSettings, delegate: self)
        }
        
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let dataImage = photo.fileDataRepresentation() {
            let image = UIImage(data: dataImage)
            
            if output.isDepthDataDeliverySupported {
                
            }
            if let depthDataMap = photo.depthData?.depthDataMap {
                let width = CVPixelBufferGetWidth(depthDataMap)
                print("hi")
                print(width)
            }
            
            DispatchQueue.main.async {
                
                let photoVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "PhotoVC") as! PhotoViewController
                photoVC.takenPhoto = image
                
                self.present(photoVC, animated: true, completion: nil)
            }
        }
    }
    
    //    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
//        if takePhoto {
//            takePhoto = false
//
//            let photoOutput = AVCapturePhotoOutput()
//            self.session.addOutput(photoOutput)
//            print(photoOutput.isDepthDataDeliverySupported)
//
//            if let image = self.getImageFromSampleBuffer(buffer: sampleBuffer) {
//
////                let photoOutput = output as! AVCapturePhotoOutput
////                self.session.addOutput(photoOutput)
//
////                if photoOutput.isDepthDataDeliverySupported {
////                    photoOutput.isDepthDataDeliveryEnabled = true
////                }
//
//                DispatchQueue.main.async {
//
//                    let photoVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "PhotoVC") as! PhotoViewController
//                    photoVC.takenPhoto = image
//
//                    self.present(photoVC, animated: true, completion: nil)
//                }
//            }
//        }
//    }
    
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


//extension ViewController: AVCaptureDataOutputSynchronizerDelegate {
//
//    func dataOutputSynchronizer(_ synchronizer: AVCaptureDataOutputSynchronizer, didOutput synchronizedDataCollection: AVCaptureSynchronizedDataCollection) {
//        return
//    }
//}
