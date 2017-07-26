//
//  FaceView.swift
//  Grimace
//
//  Created by wzxjiang on 2017/7/20.
//  Copyright © 2017年 wzxjiang. All rights reserved.
//

public class FaceView: UIView {

    private var count = 0
    
    var sticker: Sticker? {
        didSet {
            set(sticker: sticker)
        }
    }
    
    private let faceImageView = UIImageView()
    private let headImageView = UIImageView()
    private let leftEyeImageView = UIImageView()
    private let rightEyeImageView = UIImageView()
    private let noseImageView = UIImageView()
    private let mouthImageView = UIImageView()
    
    init(superViewSize size: CGSize) {
        super.init(frame: CGRect.init(origin: .zero, size: size))
        
        self.isHidden = true
        
        self.addSubview(faceImageView)
        self.addSubview(headImageView)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(faces: [Faceable]) {
        
        if faces.count > 0 {
            let face = faces[0]
            
            if face.bounds.width/bounds.width > 0.1, face.bounds.height/bounds.height > 0.1 {
                show(face)
            }
            
        } else {
            
            dismiss()
        }
        
        self.setNeedsDisplay()
    }
    
    private func show(_ face: Faceable) {
        
        faceImageView.frame = face.bounds
        
        leftEyeImageView.frame = face.leftEyeBounds
        
        rightEyeImageView.frame = face.rightEyeBounds
        
        mouthImageView.frame = face.mouthBounds
        
        noseImageView.frame = face.noseBounds
        
        if let headImage = sticker?.headImage {
            headImageView.frame = face.headBounds(withImageSize: headImage.size)
        }
        
        isHidden = false
    }
    
    private func dismiss() {
        
        if count > 5 {
            
            isHidden = true
            
            count = 0
        }
        count += 1
    }
    
    private func set(sticker: Sticker?) {
        faceImageView.image = sticker?.faceImage
        
        headImageView.image = sticker?.headImage
        
        leftEyeImageView.image = sticker?.leftEyeImage
        
        rightEyeImageView.image = sticker?.rightEyeImage
        
        noseImageView.image = sticker?.noseImage
        
        mouthImageView.image = sticker?.mouthImage
    }
}
