//
//  Extension.swift
//  Pods
//
//  Created by wzxjiang on 2017/7/24.
//
//

import CoreMedia

extension CMSampleBuffer {
    public func imageInfo() -> (data: Data, size: CGSize)? {
        guard let buffer = CMSampleBufferGetImageBuffer(self) else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(buffer, CVPixelBufferLockFlags(rawValue: 0))
        
        let lumaBuffer = CVPixelBufferGetBaseAddressOfPlane(buffer, 0)
        let bytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(buffer, 0)
        let width = CVPixelBufferGetWidth(buffer)
        let height = CVPixelBufferGetHeight(buffer)
        
        let grayColorSpace = CGColorSpaceCreateDeviceGray()
        
        let context = CGContext(data: lumaBuffer, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: grayColorSpace, bitmapInfo: 0)
        
        var cgImage = context?.makeImage()
        
        CVPixelBufferUnlockBaseAddress(buffer,  CVPixelBufferLockFlags(rawValue: 0))
        
        guard let data = cgImage?.dataProvider?.data else { return nil }
        
        cgImage = nil
        
        return (data as Data, CGSize(width: width, height: height))
    }
}
