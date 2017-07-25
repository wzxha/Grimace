//
//  Grimace.swift
//  Grimace
//
//  Created by wzxjiang on 2017/7/21.
//  Copyright © 2017年 wzxjiang. All rights reserved.
//
//

import AVFoundation
import GPUImage
import CoreMotion

public enum FaceDirection: Int32 {
    case up    = 0  /* normal */
    case left       /* rotate -90 */
    case down       /* rotate 180 */
    case right      /* rotate 90 */
}

public enum SessionPreset {
    case preset640x480
    
    case preset1280x720
    
    case preset1920x1080
    
    var string: String {
        switch self {
        case .preset640x480:
            return AVCaptureSessionPreset640x480
        case .preset1280x720:
            return AVCaptureSessionPreset1280x720
        case .preset1920x1080:
            return AVCaptureSessionPreset1920x1080
        }
    }
}

public protocol GrimaceDelegate: class {
    func willOutput(sampleBuffer: CMSampleBuffer!)
    
    func mixedOutput(imageFramebuffer: GPUImageFramebuffer!, timestamp: CFTimeInterval)
}

public class Grimace: NSObject {
    public typealias Camera = AVCaptureDevicePosition
    
    public weak var delegate: GrimaceDelegate?
    
    public var renderCycleFrame = 2
    
    public var direction: FaceDirection = .up
    
    fileprivate let faceView: FaceView
    
    fileprivate var currentRenderFrame = 0
    
    private let videoCapture: GPUImageVideoCamera
    
    private let element: GPUImageUIElement
    
    private let outputView: GPUImageView
    
    private let motionManager: CMMotionManager
    
    private var currentCamera: Camera
    
    public init(outputView: GPUImageView, sessionPreset: SessionPreset = .preset640x480, camera: Camera = .front) {
        self.outputView = outputView
        
        faceView = FaceView(withSuperView: outputView)

        element = GPUImageUIElement(view: faceView)
        
        videoCapture = GPUImageVideoCamera(sessionPreset: sessionPreset.string, cameraPosition: camera)
     
        motionManager = CMMotionManager()
        
        currentCamera = camera
        
        super.init()
        
        setupMotion()
        
        setupVideoCapture()
        
        setupFilter()
    }
    
    deinit {
        motionManager.stopAccelerometerUpdates()
        
        stopCapture()
    }
    
    func setupVideoCapture() {
        videoCapture.addAudioInputsAndOutputs()
        
        videoCapture.horizontallyMirrorRearFacingCamera = false
        
        videoCapture.horizontallyMirrorFrontFacingCamera = true
        
        videoCapture.outputImageOrientation = .portrait
        
        videoCapture.delegate = self
    }
    
    func setupMotion() {
        motionManager.accelerometerUpdateInterval = 0.2
        motionManager.gyroUpdateInterval = 0.2
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!) { [weak self] accelerometerData, error in
            guard error == nil,
                let accelerometerData = accelerometerData,
                let `self` = self  else { return }
            
            switch (accelerometerData.acceleration.x, accelerometerData.acceleration.y) {
            case (_, 0.75 ... 1):
                self.direction = .right
            case (_, -1 ... -0.75):
                self.direction = .left
            case (0.75 ... 1, _):
                self.direction = self.currentCamera == .front ? .down : .up
            case (-1 ... -0.75, _):
                self.direction = self.currentCamera == .front ? .up : .down
            default: break
            }
        }
    }
    
    func setupFilter() {
        
        let filter = GPUImageFilter()
        filter.frameProcessingCompletionBlock = { [weak self] output, time in
            guard let `self` = self else { return }
            
            GPUImageContext.sharedContextQueue().async {
                self.element.update(withTimestamp: time)
            }
        }
        videoCapture.addTarget(filter)
        
        let blendFilter = GPUImageAlphaBlendFilter()
        blendFilter.mix = 1.0
        blendFilter.frameProcessingCompletionBlock = { [weak self] output, time in
            guard let `self` = self else { return }
            
            guard let output = output else { return }
            
            guard let delegate = self.delegate else { return }
            
            // TODO: - try set GPUImageFramebuffer to samplebuffer
            delegate.mixedOutput(imageFramebuffer: output.framebufferForOutput(), timestamp: CACurrentMediaTime())
        }
        
        filter.addTarget(blendFilter)
        element.addTarget(blendFilter)
        
        blendFilter.addTarget(outputView)
    }
    
    public func startCapture(_ camera: Camera = .front) {
        currentCamera = camera
        
        videoCapture.startCapture()
    }
    
    public func stopCapture() {
        videoCapture.stopCapture()
        
        videoCapture.removeAllTargets()
    }
    
    public func set(sticker: Sticker) {
        faceView.sticker = sticker
    }
    
    public func set(faces: [Faceable]) {
        faceView.set(faces: faces)
    }
}

extension Grimace: GPUImageVideoCameraDelegate {

    public func willOutputSampleBuffer(_ sampleBuffer: CMSampleBuffer!) {
        currentRenderFrame += 1
        
        guard currentRenderFrame >= renderCycleFrame else { return }
        
        currentRenderFrame = 0
        
        guard let delegate = delegate else { return }
        
        delegate.willOutput(sampleBuffer: sampleBuffer)
    }
}
