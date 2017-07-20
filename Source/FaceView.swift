//
//  FaceView.swift
//  Example
//
//  Created by wzxjiang on 2017/7/20.
//  Copyright © 2017年 wzxjiang. All rights reserved.
//

import UIKit

class FaceView: UIView {

    var headImage: UIImage?
    var leftEyeImage: UIImage?
    var rightEyeImage: UIImage?
    var noseImage: UIImage?
    var mouthImage: UIImage?
    var faceImage: UIImage?
    
    private let faceImageView = UIImageView.init(image: #imageLiteral(resourceName: "Baby"))
    
    internal(set) var faces: [Faceable] {
        set {
            set(faces: newValue)
        }
        
        get { return [] }
    }
    
    init(withSticker sticker: Sticker, superView: UIView) {
        super.init(frame: superView.bounds)
        
        self.isHidden = true
        
        headImage = sticker.headImage
        leftEyeImage = sticker.leftEyeImage
        rightEyeImage = sticker.rightEyeImage
        noseImage = sticker.noseImage
        mouthImage = sticker.mouthImage
        faceImage = sticker.faceImage
        
        self.addSubview(faceImageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func set(faces: [Faceable]) {
        if faces.count > 0 {
            faceImageView.image = faceImage
            faceImageView.frame = faces[0].bounds
            
            self.isHidden = false
        } else {
            self.isHidden = true
        }
        
        self.setNeedsDisplay()
    }
}
