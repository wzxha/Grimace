//
//  ViewController.swift
//  Example
//
//  Created by wzxjiang on 2017/7/19.
//  Copyright © 2017年 wzxjiang. All rights reserved.
//

import UIKit
import GPUImage

class ViewController: UIViewController {

    @IBOutlet var outputView: GPUImageView?
    
    var videoCamera: GPUImageVideoCamera = GPUImageVideoCamera.init(sessionPreset: AVCaptureSessionPreset1280x720, cameraPosition: .front)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupVideoCamera()
    }
    
    func setupVideoCamera() {
        videoCamera.addAudioInputsAndOutputs()
        
        videoCamera.addTarget(outputView)
        
        videoCamera.outputImageOrientation = .portrait
        
        videoCamera.horizontallyMirrorRearFacingCamera = false
        videoCamera.horizontallyMirrorFrontFacingCamera = true
        
        videoCamera.delegate = self
        
        videoCamera.startCapture()
    }
    
}

extension ViewController: GPUImageVideoCameraDelegate {
    func willOutputSampleBuffer(_ sampleBuffer: CMSampleBuffer!) {
        
    }
}

