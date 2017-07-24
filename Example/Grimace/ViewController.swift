//
//  ViewController.swift
//  Example
//
//  Created by wzxjiang on 2017/7/19.
//  Copyright © 2017年 wzxjiang. All rights reserved.
//

import UIKit
import Grimace
import GPUImage
import CoreGraphics

class ViewController: UIViewController {
    
    @IBOutlet var outputView: GPUImageView!
    
    var faceDetector: FaceDetector<Face>!

    var grimace: Grimace!
    
    var sticker = Sticker(headImage: #imageLiteral(resourceName: "Crown"),
                          leftEyeImage: nil,
                          rightEyeImage: nil,
                          noseImage: nil,
                          mouthImage: nil,
                          faceImage: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setFaceDetector()
        setupVideoCamera()
    }
    
    func setFaceDetector() {
        
        faceDetector = FaceDetector <Face> { (sampleBuffer) -> [Face] in
            // sampleBuffer -> [face]
            // you can use CIDetector or other
            
            // mock
            return [Face()]
        }
    }
    
    func setupVideoCamera() {
        grimace = Grimace(outputView: outputView, sessionPreset: .preset640x480)
        
        grimace.set(sticker: sticker)
        
        grimace.delegate = self
        
        grimace.startCapture()
    }
}

extension ViewController: GrimaceDelegate {
    func willOutputSampleBuffer(_ sampleBuffer: CMSampleBuffer!) {
        faceDetector.detect(sampleBuffer) { [weak self] faces in
            
            guard let `self` = self else { return }
            
            self.grimace.set(faces: faces)
        }
    }
    
    func didOutputSampleBuffer(_ sampleBuffer: CMSampleBuffer!) {}
}

struct Face: Faceable {
    var noseBounds: CGRect = .zero

    var mouthBounds: CGRect = .zero

    var rightEyeBounds: CGRect = .zero

    var leftEyeBounds: CGRect = .zero

    var bounds: CGRect = CGRect(x: (UIScreen.main.bounds.width - 100)/2.0, y: 100, width: 100, height: 100)
}
