//
//  FaceDetect.swift
//  Grimace
//
//  Created by wzxjiang on 2017/7/20.
//  Copyright © 2017年 wzxjiang. All rights reserved.
//

import CoreMedia

public class FaceDetecter<T: Faceable> {
    
    public typealias Recognize = (CMSampleBuffer) -> [T]
    
    public typealias Handle = ([T]) -> Void
    
    private let recognize: Recognize
    
    public init(_ recognition: @escaping Recognize) {
        self.recognize = recognition
    }
    
    public func detect(_ sampleBuffer: CMSampleBuffer!, handle: Handle) {
        handle(recognize(sampleBuffer))
    }
}
