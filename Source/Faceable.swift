//
//  Faceable.swift
//  Example
//
//  Created by wzxjiang on 2017/7/20.
//  Copyright © 2017年 wzxjiang. All rights reserved.
//

import UIKit
import CoreImage

protocol Faceable {
    var bounds: CGRect { set get }
    
    var leftEyePosition: CGPoint { set get }
    
    var rightEyePosition: CGPoint { set get }
    
    var mouthPosition: CGPoint { set get }
}
