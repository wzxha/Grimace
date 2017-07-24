//
//  Faceable.swift
//  Grimace
//
//  Created by wzxjiang on 2017/7/20.
//  Copyright © 2017年 wzxjiang. All rights reserved.
//

public protocol Faceable {
    var bounds: CGRect { set get }
    
    var leftEyeBounds: CGRect { set get }
    
    var rightEyeBounds: CGRect { set get }
    
    var mouthBoundsn: CGRect { set get }
    
    var noseBoundsn: CGRect { set get }
}

extension Faceable {
    func headBounds(withImageSize imageSize: CGSize) -> CGRect {
        var headBounds = bounds
        headBounds.size.height = imageSize.height * (headBounds.size.width/imageSize.width)
        headBounds.origin.y -= headBounds.size.height
        return headBounds
    }
}
