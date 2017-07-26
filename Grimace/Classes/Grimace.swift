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
    
    var size: CGSize {
        switch self {
        case .preset640x480:
            return CGSize(width: 640, height: 480)
        case .preset1280x720:
            return CGSize(width: 1280, height: 720)
        case .preset1920x1080:
            return CGSize(width: 1920, height: 1080)
        }
    }
}

public protocol GrimaceDelegate: class {
    func willOutput(sampleBuffer: CMSampleBuffer)
    
    func mixedOutput(imageFramebuffer: CVPixelBuffer, timestamp: CFTimeInterval)
}

public class Grimace: NSObject {
    public typealias Camera = AVCaptureDevicePosition
    
    public var pixelFormatType: OSType = kCVPixelFormatType_32BGRA
        
    public var direction: FaceDirection = .up
    
    fileprivate let faceView: FaceView
    
    private var videoCapture: GPUImageVideoCamera?
    
    private var outputView: GPUImageView?
    
    private var motionManager: CMMotionManager?
    
    private var sessionPreset: SessionPreset
    
    private var currentCamera: Camera = .front
    
    private var dataOutput: GPUImageRawDataOutput?
    
    fileprivate weak var delegate: GrimaceDelegate?
    
    // filter
    private let element: GPUImageUIElement
    
    private let filter = GPUImageFilter()
    
    private let blendFilter = GPUImageAlphaBlendFilter()
    
    public init(input: GPUImageRawDataInput, outputViewSize: CGSize, sessionPreset: SessionPreset = .preset640x480, delegate: GrimaceDelegate?) {
        self.sessionPreset = sessionPreset
        
        faceView = FaceView(superViewSize: outputViewSize)
        
        element = GPUImageUIElement(view: faceView)
        
        self.delegate = delegate
        
        super.init()
        
        setupFilter()
        
        // pipeline
        
        input.addTarget(filter)
        
        filter.addTarget(blendFilter)
        
        element.addTarget(blendFilter)
        
        blendFilter.addTarget(outputView)
        
        guard delegate != nil else { return }
        
        setupDataOutput()
        
        blendFilter.addTarget(dataOutput)
    }
    
    public init(outputView: GPUImageView, sessionPreset: SessionPreset = .preset640x480, delegate: GrimaceDelegate?) {
        self.sessionPreset = sessionPreset
        
        self.outputView = outputView
        
        faceView = FaceView(superViewSize: outputView.bounds.size)
        
        element = GPUImageUIElement(view: faceView)
    
        self.delegate = delegate
        
        super.init()
        
        setupMotion()
        
        setupVideoCapture()
        
        setupFilter()
        
        // pipeline
        videoCapture!.addTarget(filter)
        
        filter.addTarget(blendFilter)
        
        element.addTarget(blendFilter)
        
        blendFilter.addTarget(outputView)
        
        guard delegate != nil else { return }
        
        setupDataOutput()
        
        blendFilter.addTarget(dataOutput)
    }
    
    deinit {
        motionManager?.stopAccelerometerUpdates()
        
        stopCapture()
    }
    
    func setupVideoCapture() {
        
        videoCapture = GPUImageVideoCamera(sessionPreset: sessionPreset.string, cameraPosition: currentCamera)
        
        guard let videoCapture = videoCapture else { return }
        
        videoCapture.addAudioInputsAndOutputs()
        
        videoCapture.horizontallyMirrorRearFacingCamera = false
        
        videoCapture.horizontallyMirrorFrontFacingCamera = true
        
        videoCapture.outputImageOrientation = .portrait
        
        videoCapture.delegate = self
    }
    
    func setupMotion() {
        
        motionManager = CMMotionManager()
        
        guard let motionManager = motionManager else { return }

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
        
        filter.frameProcessingCompletionBlock = { [weak self] output, time in
            guard let `self` = self else { return }
            
            GPUImageContext.sharedContextQueue().async {
                self.element.update(withTimestamp: time)
            }
        }
        
        blendFilter.mix = 1.0
    }
    
    func setupDataOutput() {
        let dataOutput = GPUImageRawDataOutput(imageSize: sessionPreset.size, resultsInBGRAFormat: true)

        dataOutput?.newFrameAvailableBlock = { [weak self] in
            guard let `self` = self else { return }

            guard let delegate = self.delegate else { return }

            guard let dataOutput = self.dataOutput else { return }

            dataOutput.lockFramebufferForReading()

            var outBytes = dataOutput.rawBytesForImage
            let bytesPerRow = dataOutput.bytesPerRowInOutput()
            var pixelBuffer: CVPixelBuffer? = nil
            let ret =
                CVPixelBufferCreateWithBytes(
                    kCFAllocatorDefault,
                    Int(self.sessionPreset.size.width),
                    Int(self.sessionPreset.size.height),
                    self.pixelFormatType,
                    &outBytes,
                    Int(bytesPerRow),
                    nil,
                    nil,
                    nil,
                    &pixelBuffer
                )
            
            dataOutput.unlockFramebufferAfterReading()

            guard ret == kCVReturnSuccess else { return }
            
            guard let buffer = pixelBuffer else { return }
            
            delegate.mixedOutput(imageFramebuffer: buffer, timestamp: CACurrentMediaTime())
        }
    }
    
    public func startCapture(_ camera: Camera = .front) {
        guard let videoCapture = videoCapture else { return }
        
        currentCamera = camera
        
        videoCapture.startCapture()
    }
    
    public func stopCapture() {
        guard let videoCapture = videoCapture else { return }
        
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
        guard let delegate = delegate else { return }
        
        delegate.willOutput(sampleBuffer: sampleBuffer)
    }
}
