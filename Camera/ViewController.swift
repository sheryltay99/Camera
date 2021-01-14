//
//  ViewController.swift
//  Camera
//
//  Created by Sheryl Tay on 6/1/21.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVCapturePhotoCaptureDelegate, AVCaptureDepthDataOutputDelegate, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    @IBOutlet weak var cameraView: UIView!
    
    let session = AVCaptureSession()
    var previewLayer: CALayer!
    var captureDevice: AVCaptureDevice!
    var photoOutput: AVCapturePhotoOutput?
    var outputSynchronizer: AVCaptureDataOutputSynchronizer?
    var depthOutput: AVCaptureDepthDataOutput?
    var dataOutput: AVCaptureVideoDataOutput?
    
    var takePhoto = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        prepareCamera()
    }

    ///finding capture device
    func prepareCamera() {
        session.sessionPreset = AVCaptureSession.Preset.photo
        if let availableDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            captureDevice = availableDevice
            beginCapture()
        }
    }
    
    ///adding input and outputs to session
    func beginCapture() {
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: captureDevice)
            session.addInput(captureDeviceInput)
        } catch {
            print(error.localizedDescription)
        }
        
        session.startRunning()
        
        //setting preview layer
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.previewLayer = previewLayer
        self.previewLayer.frame = cameraView.bounds
        cameraView.layer.addSublayer(self.previewLayer)
        
        let dataOutputQueue = DispatchQueue(label: "dataOutputQueue", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)
        
        //adding video data output to session
        dataOutput = AVCaptureVideoDataOutput()
        if let dataOutput = self.dataOutput {
            if session.canAddOutput(dataOutput) {
                session.addOutput(dataOutput)
            }
            dataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as String): NSNumber(value:kCVPixelFormatType_32BGRA)]
            dataOutput.alwaysDiscardsLateVideoFrames = true
            dataOutput.setSampleBufferDelegate(self, queue: dataOutputQueue)
        }
        
        //adding depth data output to session
        depthOutput = AVCaptureDepthDataOutput()
        if let depthOutput = self.depthOutput {
            if session.canAddOutput(depthOutput) {
                session.addOutput(depthOutput)
            }
            depthOutput.setDelegate(self, callbackQueue: dataOutputQueue)
            depthOutput.connection(with: .depthData)?.isEnabled = true
            depthOutput.isFilteringEnabled = true
        }
//        let depthOutputQueue = DispatchQueue(label: "depthOutputQueue", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)
        
        //adding photo output to session
        photoOutput = AVCapturePhotoOutput()
        if let photoOutput = self.photoOutput {
            if session.canAddOutput(photoOutput) {
                session.addOutput(photoOutput)
            }
            if photoOutput.isDepthDataDeliverySupported {
                photoOutput.isDepthDataDeliveryEnabled = true
                
                //synchronizing outputs of video output and depth output
                if let depthOutput = self.depthOutput {
        //                    let synchronizedQueue = DispatchQueue(label: "synchronizedQueue", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)
                    if let dataOutput = self.dataOutput {
                        outputSynchronizer = AVCaptureDataOutputSynchronizer(dataOutputs: [dataOutput, depthOutput])
                        outputSynchronizer!.setDelegate(self, queue: dataOutputQueue)
                    }
                }
            }
        }
        
        session.commitConfiguration()
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
            
            if let depthDataMap = photo.depthData?.depthDataMap {
                let height = CVPixelBufferGetHeight(depthDataMap)
                print(height)
            }
            
            if let depthData = photo.depthData {
                print(depthData.size)
                print(depthData.percentageOfNaNs)
                print(depthData.distanceDisplay)
            }
            
            DispatchQueue.main.async {
                
                let photoVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "PhotoVC") as! PhotoViewController
                photoVC.takenPhoto = image
                
                self.present(photoVC, animated: true, completion: nil)
            }
        }
    }
    
    func depthDataOutput(_ output: AVCaptureDepthDataOutput, didOutput depthData: AVDepthData, timestamp: CMTime, connection: AVCaptureConnection) {
        //not getting called
        print("depth data output")
    }
    
    
    func depthDataOutput(_ output: AVCaptureDepthDataOutput, didDrop depthData: AVDepthData, timestamp: CMTime, connection: AVCaptureConnection, reason: AVCaptureOutput.DataDroppedReason) {
        //not getting called
        print("depth data dropped")
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
    
//    func getImageFromSampleBuffer(buffer: CMSampleBuffer) -> UIImage? {
//        if let pixelBuffer = CMSampleBufferGetImageBuffer(buffer) {
//            let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
//            let context = CIContext()
//
//            let imageRect = CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(pixelBuffer), height: CVPixelBufferGetHeight(pixelBuffer))
//
//            if let image = context.createCGImage(ciImage, from: imageRect) {
//                return UIImage(cgImage: image, scale: UIScreen.main.scale, orientation: .right)
//            }
//        }
//        return nil
//    }
    
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


extension ViewController: AVCaptureDataOutputSynchronizerDelegate {

    func dataOutputSynchronizer(_ synchronizer: AVCaptureDataOutputSynchronizer, didOutput synchronizedDataCollection: AVCaptureSynchronizedDataCollection) {
        print(synchronizedDataCollection.count) //always returns 1
        
        guard let depthOutput = self.depthOutput else { return }
        guard let dataOutput = self.dataOutput else { return }
        
        if let syncedDepthData: AVCaptureSynchronizedDepthData = synchronizedDataCollection.synchronizedData(for: depthOutput) as? AVCaptureSynchronizedDepthData {
            print(syncedDepthData.depthData.distanceDisplay) //this doesnt get called
        }
        
        if let syncedVideoData: AVCaptureSynchronizedSampleBufferData = synchronizedDataCollection.synchronizedData(for: dataOutput) as? AVCaptureSynchronizedSampleBufferData {
            print("its a video!")
        }
        
    }
}
