//
//  Faceable.swift
//  Example
//
//  Created by wzxjiang on 2017/7/20.
//  Copyright © 2017年 wzxjiang. All rights reserved.
//

import Foundation
import CoreImage

protocol Faceable {
    var bounds: CGRect { get }
    
    var leftEyePosition: CGPoint { get }
    
    var rightEyePosition: CGPoint { get }
    
    var mouthPosition: CGPoint { get }
}

extension CIFaceFeature: Faceable {}
