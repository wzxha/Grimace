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

    var iflyFaceDetector: IFlyFaceDetector!
    
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
        
        iflyFaceDetector = IFlyFaceDetector.sharedInstance()
        
        iflyFaceDetector.setParameter("1", forKey: "align")
        iflyFaceDetector.setParameter("1", forKey: "detect")
        
        faceDetector = FaceDetector <Face> { [weak self] (sampleBuffer) -> [Face] in
            guard let `self` = self else { return [] }
            
            guard let imageInfo = sampleBuffer.imageInfo() else { return [] }
            
            let faceString =
                self.iflyFaceDetector.trackFrame(imageInfo.data,
                                                 withWidth: Int32(imageInfo.size.width),
                                                 height: Int32(imageInfo.size.height),
                                                 direction: self.grimace.direction.rawValue)
            
            print(faceString ?? "")
            
            return faceString?.toFaces(imageSize: imageInfo.size, outputViewSize: self.outputView.bounds.size) ?? []
        }
    }
    
    func setupVideoCamera() {
        grimace = Grimace(outputView: outputView, sessionPreset: .preset640x480, delegate: self)
        
        grimace.set(sticker: sticker)
        
        grimace.startCapture()
    }
}

extension ViewController: GrimaceDelegate {
    func willOutput(sampleBuffer: CMSampleBuffer) {
        faceDetector.detect(sampleBuffer) { [weak self] faces in
            
            guard let `self` = self else { return }
            
            self.grimace.set(faces: faces)
        }
    }
    
    func mixedOutput(imageFramebuffer: CVPixelBuffer, timestamp: CFTimeInterval) {}
}

struct Face: Faceable {
    var noseBounds: CGRect = .zero
    
    var mouthBounds: CGRect = .zero
    
    var rightEyeBounds: CGRect = .zero
    
    var leftEyeBounds: CGRect = .zero
    
    var bounds: CGRect
    
    init?(withPosition position: Position?, imageSize: CGSize, outputViewSize: CGSize) {
        guard let position = position else { return nil }
        
        var widthScale = outputViewSize.width/imageSize.width
        var heightScale = outputViewSize.height/imageSize.height
        
        if widthScale > 1 { widthScale = 1 }
        
        if heightScale > 1 { heightScale = 1 }
        
        // rotate
        bounds = CGRect(x: position.top * widthScale,
                        y: position.left * heightScale,
                        width: position.bottom - position.top,
                        height: position.right - position.left)
    }
}

struct Position {
    let left: CGFloat
    let right: CGFloat
    let bottom: CGFloat
    let top: CGFloat
    
    init?(withDictionary dictionary: [String: Any]) {
        
        guard let left   = dictionary["left"] as? CGFloat,
            let right  = dictionary["right"] as? CGFloat,
            let bottom = dictionary["bottom"] as? CGFloat,
            let top    = dictionary["top"] as? CGFloat else {
                return nil
        }
        
        self.left = left
        self.right = right
        self.bottom = bottom
        self.top = top
    }
}

extension String {
    func toFaces(imageSize: CGSize, outputViewSize: CGSize) -> [Face] {
        guard let data = self.data(using: .utf8) else {
            return []
        }
        
        do {
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                return []
            }
            
            guard let faces = json["face"] as? [[String: Any]]else { return [] }
            
            return faces.flatMap {
                guard let dictionary = $0["position"] as? [String: Any] else { return nil }
                
                return Face(withPosition: Position(withDictionary: dictionary),
                            imageSize: imageSize,
                            outputViewSize: outputViewSize)
            }
            
        } catch _  {
            return []
        }
    }
}

