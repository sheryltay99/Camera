//
//  AVDepthData+Extension.swift
//  AWOMAFrameworkTest
//
//  Copyright © 2020 I2R. All rights reserved.
//

import Foundation
import AVFoundation

extension AVDepthData {
    
    /// Object's center distance from camera in meters
    var distance: Double {
        
        /// Convert Disparity Depth Map to Depth in Float32 format
        let depthDataFloat32 = converting(toDepthDataType: kCVPixelFormatType_DepthFloat32)
        
        /// Pixel buffer containing the depth data's per-pixel depth or disparity data map
        let pixelBufferFloat32 = depthDataFloat32.depthDataMap
        
        // Lock the data buffer for reading
        CVPixelBufferLockBaseAddress(pixelBufferFloat32, CVPixelBufferLockFlags(rawValue: 0))
        
        // Read the data buffer
        let depthPointer = unsafeBitCast(CVPixelBufferGetBaseAddress(pixelBufferFloat32), to: UnsafeMutablePointer<Float32>.self)
        
        // Unlock the data buffer so it can be updated by AVFoundation
        CVPixelBufferUnlockBaseAddress(pixelBufferFloat32, CVPixelBufferLockFlags(rawValue: 0))
                
        let width = CVPixelBufferGetWidth(pixelBufferFloat32)
        let height = CVPixelBufferGetHeight(pixelBufferFloat32)
        let centerPoint = CGPoint(x: width/2, y: height/2)
        
        // Get depth value for image center
        let distance = depthPointer[Int(centerPoint.y * CGFloat(width) + centerPoint.x)]
        return Double(distance)
    }
    
    /// Depth values in Float32 array
    var values: [Float] {
        
        /// Convert Disparity Depth Map to Depth in Float32 format
        let depthDataFloat32 = converting(toDepthDataType: kCVPixelFormatType_DepthFloat32)
        
        /// Pixel buffer containing the depth data's per-pixel depth or disparity data map
        let pixelBufferFloat32 = depthDataFloat32.depthDataMap
        
        // Lock the data buffer for reading
        CVPixelBufferLockBaseAddress(pixelBufferFloat32, CVPixelBufferLockFlags(rawValue: 0))
        
        // Read the data buffer
        let depthPointer = unsafeBitCast(CVPixelBufferGetBaseAddress(pixelBufferFloat32), to: UnsafeMutablePointer<Float32>.self)
        
        // Unlock the data buffer so it can be updated by AVFoundation
        CVPixelBufferUnlockBaseAddress(pixelBufferFloat32, CVPixelBufferLockFlags(rawValue: 0))
                
        let width = CVPixelBufferGetWidth(pixelBufferFloat32)
        let height = CVPixelBufferGetHeight(pixelBufferFloat32)

        return Array(UnsafeBufferPointer(start: depthPointer, count: width * height))
    }
    
    /// Percentage of NaNs
    var percentageOfNaNs: Double {
        let nans = values.filter{ $0.isNaN }
        return (Double(nans.count) / Double(values.count)) * 100.0
    }
    
    /// Displayable distance from camera in cm
    @objc var distanceDisplay: String {
        let measurment = Measurement(value: distance, unit: UnitLength.meters)
        let converted = measurment.converted(to: .centimeters)
        let value = converted.value
        return "\(Int(value)) cm"
    }
    
    /// Size of DepthData
    var size: CGSize {
        let depthDataFloat = converting(toDepthDataType: kCVPixelFormatType_DepthFloat32)
        let pixelBufferFloat32 = depthDataFloat.depthDataMap
        let width = CVPixelBufferGetWidth(pixelBufferFloat32)
        let height = CVPixelBufferGetHeight(pixelBufferFloat32)
        return CGSize(width: width, height: height)
    }
}
