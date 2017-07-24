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
    
    var faceDetect: FaceDetecter<Face>!
    
    var faceDetector: IFlyFaceDetector!

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
        faceDetector = IFlyFaceDetector.sharedInstance()
        
        faceDetect = FaceDetecter <Face> { [weak self] (sampleBuffer) -> [Face] in
            guard let `self` = self else { return [] }
            
            guard let imageInfo = sampleBuffer.imageInfo() else { return [] }
            
            let faceString =
                self.faceDetector.trackFrame(imageInfo.data,
                                             withWidth: Int32(imageInfo.size.width),
                                             height: Int32(imageInfo.size.height),
                                             direction: self.grimace.direction.rawValue)
            
            print(faceString ?? "")
            
            return faceString?.toFaces(imageSize: imageInfo.size, outputViewSize: self.outputView.bounds.size) ?? []
        }
        
        faceDetector.setParameter("1", forKey: "detect")
        faceDetector.setParameter("1", forKey: "align")
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
        faceDetect.detect(sampleBuffer) { [weak self] faces in
            
            guard let `self` = self else { return }
            
            self.grimace.set(faces: faces)
        }
    }
    
    func didOutputSampleBuffer(_ sampleBuffer: CMSampleBuffer!) {}
}

struct Face: Faceable {
    var noseBoundsn: CGRect = .zero

    var mouthBoundsn: CGRect = .zero

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
