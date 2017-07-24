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

    @IBOutlet var outputView: GPUImageView!
    
    var faceFilter = FaceFilter()
    
    var element: GPUImageUIElement!
    
    var sticker = Sticker(headImage: nil,
                         leftEyeImage: nil,
                         rightEyeImage: nil,
                         noseImage: nil,
                         mouthImage: nil,
                         faceImage: #imageLiteral(resourceName: "Baby"))
    
    var faceView: FaceView!
    
    var videoCamera: GPUImageVideoCamera = GPUImageVideoCamera(sessionPreset: AVCaptureSessionPreset1280x720, cameraPosition: .front)
    
    var count = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupVideoCamera()
    }
    
    func setupVideoCamera() {
        self.faceView = FaceView(withSticker: sticker, superView: outputView)

        videoCamera.addAudioInputsAndOutputs()
        
        let filter = GPUImageFilter()
        videoCamera.addTarget(filter)
        
        filter.frameProcessingCompletionBlock = { [weak self] output, time in
            guard let `self` = self else { return }
            
            GPUImageContext.sharedContextQueue().async {
                self.element.update(withTimestamp: time)
            }
        }
        
        let blendFilter = GPUImageAlphaBlendFilter()
        blendFilter.mix = 1.0
        blendFilter.frameProcessingCompletionBlock = { [weak self] output, time in
//            guard let `self` = self else { return }
        }
        
        element = GPUImageUIElement(view: faceView)
        
        filter.addTarget(blendFilter)
        element.addTarget(blendFilter)
        
        blendFilter.addTarget(outputView)
        
        videoCamera.outputImageOrientation = .portrait
        
        videoCamera.horizontallyMirrorRearFacingCamera = false
        videoCamera.horizontallyMirrorFrontFacingCamera = true
        
        videoCamera.delegate = self
        
        videoCamera.startCapture()
    }
    
}

extension ViewController: GPUImageVideoCameraDelegate {
    func willOutputSampleBuffer(_ sampleBuffer: CMSampleBuffer!) {
        count += 1
        
        guard count >= 3 else { return }
        
        count = 0
        
        faceFilter.filter(sampleBuffer) { [weak self] faces in
            guard let `self` = self else { return }
            
            self.faceView.faces = faces
        }
    }
}

