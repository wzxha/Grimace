//
//  Sticker.swift
//  Grimace
//
//  Created by wzxjiang on 2017/7/20.
//  Copyright © 2017年 wzxjiang. All rights reserved.
//

public struct Sticker {
    public let headImage: UIImage?
    
    public let leftEyeImage: UIImage?
    
    public let rightEyeImage: UIImage?
    
    public let noseImage: UIImage?
    
    public let mouthImage: UIImage?
    
    public let faceImage: UIImage?
    
    public init(headImage: UIImage?, leftEyeImage: UIImage?, rightEyeImage: UIImage?, noseImage: UIImage?, mouthImage: UIImage?, faceImage: UIImage?) {
        
        self.headImage = headImage
        
        self.leftEyeImage = leftEyeImage
        
        self.rightEyeImage = rightEyeImage
        
        self.noseImage = noseImage
        
        self.mouthImage = mouthImage
        
        self.faceImage = faceImage
    }
}
