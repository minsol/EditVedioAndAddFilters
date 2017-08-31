//
//  CoreImageView.swift
//  SimpleFilters
//
//  Created by 极目 on 2017/5/27.
//  Copyright © 2017年 极目. All rights reserved.
//

import Foundation
import GLKit

class CoreImageView: GLKView {
    
    var image: CIImage? {
        didSet {
            display()
        }
    }
    let coreImageContext: CIContext
    
    override convenience init(frame: CGRect) {
        let eaglContext = EAGLContext(api: EAGLRenderingAPI.openGLES2)
        self.init(frame: frame, context: eaglContext!)
    }
    
    override init(frame: CGRect, context eaglContext: EAGLContext) {
        coreImageContext = CIContext(eaglContext: eaglContext)
        super.init(frame: frame, context: eaglContext)
        // We will be calling display() directly, hence this needs to be false
        enableSetNeedsDisplay = false
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        if let img = image {
            let scale = self.window?.screen.scale ?? 1.0
            let destRect = bounds.applying(CGAffineTransform(scaleX: scale, y: scale))
            coreImageContext.draw(img, in: destRect, from: img.extent)
        }
    }
}
