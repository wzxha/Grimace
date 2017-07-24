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
    
    init(withSuperView superView: UIView) {
        super.init(frame: superView.bounds)
        
        self.isHidden = true
        
        self.addSubview(faceImageView)
        self.addSubview(headImageView)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(faces: [Faceable]) {
        guard let sticker = sticker else { return }
        
        if faces.count > 0 {
            faceImageView.frame = faces[0].bounds

            if let headImage = sticker.headImage {
                headImageView.frame = faces[0].headBounds(withImageSize: headImage.size)
            }
            
            isHidden = false
        } else {
            if count > 5 {
                isHidden = true
                count = 0
            }
            count += 1
        }
        
        self.setNeedsDisplay()
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
