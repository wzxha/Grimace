//
//  FaceDetect.swift
//  Grimace
//
//  Created by wzxjiang on 2017/7/20.
//  Copyright © 2017年 wzxjiang. All rights reserved.
//

import CoreMedia

public class FaceDetecter<T: Faceable> {
    
    public typealias Recognition = (CMSampleBuffer) -> [T]
    
    public typealias Handle = ([T]) -> Void
    
    private let recognition: Recognition
    
    public init(_ recognition: @escaping Recognition) {
        self.recognition = recognition
    }
    
    public func detect(_ sampleBuffer: CMSampleBuffer!, handle: Handle) {
        handle(recognition(sampleBuffer))
    }
}
