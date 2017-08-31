//
//  JMCIImageExtensions.swift
//  SimpleFilters
//
//  Created by 极目 on 2017/5/27.
//  Copyright © 2017年 极目. All rights reserved.
//

import UIKit

extension CIImage{
    //自动调整
    public func autoAdjust() -> CIImage{
        var inputImage : CIImage = self
        let filters = self.autoAdjustmentFilters(options: nil)
        for filter: CIFilter in filters {
            filter.setValue(inputImage, forKey: kCIInputImageKey)
            inputImage = filter.outputImage!
        }
        return inputImage
    }
    
    
    //模糊
    public func blur(radius: Double) -> CIImage {
        let parameters = [kCIInputRadiusKey: radius,
                          kCIInputImageKey: self] as [String : Any]
        let filter = CIFilter(name: "CIGaussianBlur",withInputParameters: parameters)
        return filter!.outputImage!
    }
    
    
    
    //怀旧
    public func photoEffectInstant() -> CIImage {
        let parameters = [kCIInputImageKey: self] as [String : Any]
        let filter = CIFilter(name: "CIPhotoEffectInstant",withInputParameters: parameters)
        return filter!.outputImage!
    }
    
    //黑白
    public func photoEffectNoir() -> CIImage {
        let parameters = [kCIInputImageKey: self] as [String : Any]
        let filter = CIFilter(name: "CIPhotoEffectNoir",withInputParameters: parameters)
        return filter!.outputImage!
    }
    
    //色调
    public func photoEffectTonal() -> CIImage {
        let parameters = [kCIInputImageKey: self] as [String : Any]
        let filter = CIFilter(name: "CIPhotoEffectTonal",withInputParameters: parameters)
        return filter!.outputImage!
    }
    
    //岁月
    public func photoEffectTransfer() -> CIImage {
        let parameters = [kCIInputImageKey: self] as [String : Any]
        let filter = CIFilter(name: "CIPhotoEffectTransfer",withInputParameters: parameters)
        return filter!.outputImage!
    }
    
    
    //单色
    public func photoEffectMono() -> CIImage {
        let parameters = [kCIInputImageKey: self] as [String : Any]
        let filter = CIFilter(name: "CIPhotoEffectMono",withInputParameters: parameters)
        return filter!.outputImage!
    }
    
    
    //褪色
    public func photoEffectFade() -> CIImage {
        let parameters = [kCIInputImageKey: self] as [String : Any]
        let filter = CIFilter(name: "CIPhotoEffectFade",withInputParameters: parameters)
        return filter!.outputImage!
    }
    
    
    //冲印
    public func photoEffectProcess() -> CIImage {
        let parameters = [kCIInputImageKey: self] as [String : Any]
        let filter = CIFilter(name: "CIPhotoEffectProcess",withInputParameters: parameters)
        return filter!.outputImage!
    }
    
    
    //铬黄
    public func photoEffectChrome() -> CIImage {
        let parameters = [kCIInputImageKey: self] as [String : Any]
        let filter = CIFilter(name: "CIPhotoEffectChrome",withInputParameters: parameters)
        return filter!.outputImage!
    }
    
    //渐变
    public func radialGradient(_ center: CGPoint, radius: CGFloat) -> CIImage {
        let params: [String: Any] = [
            "inputColor0": CIColor(red: 1, green: 1, blue: 1),
            "inputColor1": CIColor(red: 0, green: 0, blue: 0),
            "inputCenter": CIVector(cgPoint: center),
            "inputRadius0": radius,
            "inputRadius1": radius + 1
        ]
        return CIFilter(name: "CIRadialGradient", withInputParameters: params)!.outputImage!
    }
    
    //合成滤镜
    public func compositeSourceOver(overlay: CIImage) -> CIImage {
        let parameters = [
            kCIInputBackgroundImageKey: self,
            kCIInputImageKey: overlay
        ]
        let filter = CIFilter(name: "CISourceOverCompositing",withInputParameters: parameters)
        let cropRect = self.extent
        return filter!.outputImage!.cropping(to: cropRect)
    }
    
    //老照片
    func oldFilmEffect() -> CIImage {
        // 1.创建CISepiaTone滤镜
        let sepiaToneFilter = CIFilter(name: "CISepiaTone")!
        sepiaToneFilter.setValue(self, forKey: kCIInputImageKey)
        sepiaToneFilter.setValue(1, forKey: kCIInputIntensityKey)
        // 2.创建白班图滤镜
        let whiteSpecksFilter = CIFilter(name: "CIColorMatrix")!
        whiteSpecksFilter.setValue(CIFilter(name: "CIRandomGenerator")!.outputImage!.cropping(to: self.extent), forKey: kCIInputImageKey)
        whiteSpecksFilter.setValue(CIVector(x: 0, y: 1, z: 0, w: 0), forKey: "inputRVector")
        whiteSpecksFilter.setValue(CIVector(x: 0, y: 1, z: 0, w: 0), forKey: "inputGVector")
        whiteSpecksFilter.setValue(CIVector(x: 0, y: 1, z: 0, w: 0), forKey: "inputBVector")
        whiteSpecksFilter.setValue(CIVector(x: 0, y: 0, z: 0, w: 0), forKey: "inputBiasVector")
        // 3.把CISepiaTone滤镜和白班图滤镜以源覆盖(source over)的方式先组合起来
        let sourceOverCompositingFilter = CIFilter(name: "CISourceOverCompositing")!
        sourceOverCompositingFilter.setValue(whiteSpecksFilter.outputImage, forKey: kCIInputBackgroundImageKey)
        sourceOverCompositingFilter.setValue(sepiaToneFilter.outputImage, forKey: kCIInputImageKey)
        // ---------上面算是完成了一半
        // 4.用CIAffineTransform滤镜先对随机噪点图进行处理
        let affineTransformFilter = CIFilter(name: "CIAffineTransform")!
        affineTransformFilter.setValue(CIFilter(name: "CIRandomGenerator")!.outputImage!.cropping(to: self.extent), forKey: kCIInputImageKey)
        affineTransformFilter.setValue(NSValue(cgAffineTransform: CGAffineTransform(scaleX: 1.5, y: 25)), forKey: kCIInputTransformKey)
        // 5.创建蓝绿色磨砂图滤镜
        let darkScratchesFilter = CIFilter(name: "CIColorMatrix")!
        darkScratchesFilter.setValue(affineTransformFilter.outputImage, forKey: kCIInputImageKey)
        darkScratchesFilter.setValue(CIVector(x: 4, y: 0, z: 0, w: 0), forKey: "inputRVector")
        darkScratchesFilter.setValue(CIVector(x: 0, y: 0, z: 0, w: 0), forKey: "inputGVector")
        darkScratchesFilter.setValue(CIVector(x: 0, y: 0, z: 0, w: 0), forKey: "inputBVector")
        darkScratchesFilter.setValue(CIVector(x: 0, y: 0, z: 0, w: 0), forKey: "inputAVector")
        darkScratchesFilter.setValue(CIVector(x: 0, y: 1, z: 1, w: 1), forKey: "inputBiasVector")
        // 6.用CIMinimumComponent滤镜把蓝绿色磨砂图滤镜处理成黑色磨砂图滤镜
        let minimumComponentFilter = CIFilter(name: "CIMinimumComponent")!
        minimumComponentFilter.setValue(darkScratchesFilter.outputImage, forKey: kCIInputImageKey)
        // ---------上面算是基本完成了
        // 7.最终组合在一起
        let multiplyCompositingFilter = CIFilter(name: "CIMultiplyCompositing")!
        multiplyCompositingFilter.setValue(minimumComponentFilter.outputImage, forKey: kCIInputBackgroundImageKey)
        multiplyCompositingFilter.setValue(sourceOverCompositingFilter.outputImage, forKey: kCIInputImageKey)
        return multiplyCompositingFilter.outputImage!
    }
    
}

extension UIViewController{

    //模糊
    public func blur(radius: Double) -> CIFilter {
        let parameters = [kCIInputRadiusKey: radius] as [String : Any]
        let filter = CIFilter(name: "CIGaussianBlur",withInputParameters: parameters)
        return filter!
    }
    
    
    
    //怀旧
    public func photoEffectInstant() -> CIFilter {
        let filter = CIFilter(name: "CIPhotoEffectInstant")
        return filter!
    }
    
    //黑白
    public func photoEffectNoir() -> CIFilter {
        let filter = CIFilter(name: "CIPhotoEffectNoir")
        return filter!
    }
    
    //色调
    public func photoEffectTonal() -> CIFilter {
        let filter = CIFilter(name: "CIPhotoEffectTonal")
        return filter!
    }
    
    //岁月
    public func photoEffectTransfer() -> CIFilter {
        let filter = CIFilter(name: "CIPhotoEffectTransfer")
        return filter!
    }
    
    
    //单色
    public func photoEffectMono() -> CIFilter {
        let filter = CIFilter(name: "CIPhotoEffectMono")
        return filter!
    }
    
    
    //褪色
    public func photoEffectFade() -> CIFilter {
        let filter = CIFilter(name: "CIPhotoEffectFade")
        return filter!
    }
    
    
    //冲印
    public func photoEffectProcess() -> CIFilter {
        let filter = CIFilter(name: "CIPhotoEffectProcess")
        return filter!
    }
    
    
    //铬黄
    public func photoEffectChrome() -> CIFilter {
        let filter = CIFilter(name: "CIPhotoEffectChrome")
        return filter!
    }
    


}

