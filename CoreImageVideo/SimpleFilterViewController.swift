//
//  ViewController.swift
//  CoreImageVideo
//
//  Created by Chris Eidhof on 03/04/15.
//  Copyright (c) 2015 objc.io. All rights reserved.
//

import UIKit
import AVFoundation

class SimpleFilterViewController: UIViewController {
    var source: CaptureBufferSource?
    var coreImageView: CoreImageView?

    var angleForCurrentTime: Float {
        return Float(NSDate.timeIntervalSinceReferenceDate() % M_PI*2)
    }

    override func loadView() {
        coreImageView = CoreImageView(frame: CGRect())
        self.view = coreImageView
    }
    
    override func viewDidAppear(animated: Bool) {
        setupCameraSource()

    }

    override func viewDidDisappear(animated: Bool) {
        source?.running = false
    }
    
    func setupCameraSource() {
        source = CaptureBufferSource(position: AVCaptureDevicePosition.Front) { [unowned self] (buffer, transform) in
            guard let input = CIImage(buffer: buffer)?.imageByApplyingTransform(transform) else {
                return
            }
            let filterImage = UIImage(named: "monkey")
            let filterCIImage = CIImage(CGImage: (filterImage!.CGImage)!).imageByCompositingOverImage(input)

            let filter = CIFilter(name: "CIHueAdjust", withInputParameters: [
                kCIInputAngleKey: self.angleForCurrentTime,
                kCIInputImageKey: filterCIImage
                ])
            
            dispatch_sync(dispatch_get_main_queue()) {
                self.coreImageView?.image = filter?.outputImage
            }
        }
        source?.running = true
    }
    
    func imageWithImage(image: UIImage, newSize: CGSize) -> UIImage {
        //UIGraphicsBeginImageContext(newSize);
        // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
        // Pass 1.0 to force exact pixel size.
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage;
    }
}
