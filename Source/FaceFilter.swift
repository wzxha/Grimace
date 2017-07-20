//
//  FaceFilter.swift
//  Example
//
//  Created by wzxjiang on 2017/7/20.
//  Copyright © 2017年 wzxjiang. All rights reserved.
//

import Foundation
import GPUImage

class FaceFilter {
    
    func filter(_ sampleBuffer: CMSampleBuffer!, completion: @escaping ([Faceable]) -> Void) {
        guard let sampleBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        GPUImageContext.sharedContextQueue().async {
            let detector =
                CIDetector(
                    ofType: CIDetectorTypeFace,
                    context: nil,
                    options:
                        [CIDetectorAccuracy: CIDetectorAccuracyLow]
                )
            
            let ciImage = CIImage(cvPixelBuffer: sampleBuffer)
            
            guard let features = detector?.features(in: ciImage, options: nil) else {
                return
            }
            
            let faces = features.flatMap { $0 as? CIFaceFeature }

            completion(faces)
//
            print(faces.count)
        }
    }
}

// mock
class Face: Faceable {
    var bounds: CGRect { return CGRect.init(origin: CGPoint.init(x: 100, y: 200), size: CGSize.init(width: 150, height: 150)) }
    
    var leftEyePosition: CGPoint { return .zero }
    
    var rightEyePosition: CGPoint { return .zero }
    
    var mouthPosition: CGPoint { return .zero }
}
