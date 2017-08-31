//
//  ViewController.swift
//  EditVedioAndAddFilters
//
//  Created by 极目 on 2017/5/27.
//  Copyright © 2017年 极目. All rights reserved.
//

import UIKit
import Photos
import Lottie


class ViewController: UIViewController {
    
    let exportURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("TempVideo.mov")
    var currentFilter: CIFilter!//滤镜
    lazy var context: CIContext = {
        let eaglContext = EAGLContext(api: EAGLRenderingAPI.openGLES2)
        let options = [kCIContextWorkingColorSpace : NSNull()]
        return CIContext(eaglContext: eaglContext!, options: options)
    }()
    
    var coreImageView: CoreImageView?//显示帧数据
    
    let audioUrl = URL(fileURLWithPath:Bundle.main.path(forResource: "月半弯", ofType: "mp3")!)

    override func viewDidLoad() {
        super.viewDidLoad()
        let url = Bundle.main.url(forResource: "IMG_2471", withExtension: "mov")!
//        let url = URL(fileURLWithPath:Bundle.main.path(forResource: "IMG_2464", ofType: "MOV")!)
//        let url = Bundle.main.url(forResource: "test", withExtension: "mp4")!
//        getVideoBuffer(videoUrl: url,exportURL:exportURL)
//        
//        coreImageView = CoreImageView(frame: CGRect(x: 26, y: 140, width: self.view.frame.width - 52, height: self.view.frame.width * 9 / 16 - 80))
//        self.view.insertSubview(coreImageView!, at: 0)
//        currentFilter = photoEffectInstant()

        //叠加图片文字
        MediaManager.sharedInstance.exportVideoToJMCollection(videoUrl: url, audioUrl: nil, completionHandler: {
            print("okok:::::::::")
            MediaManager.sharedInstance.exportToPHPhotoLibrary()
        })
//
//        MediaManager.sharedInstance.userAVAssetImageGenerator(vedioURL: url)
    }
    

    @IBAction func changeFilter(){
        let filterArray = [photoEffectInstant(),photoEffectMono(),photoEffectChrome(),photoEffectProcess()]
        currentFilter = filterArray[Int(arc4random()%3)]
        MediaManager.sharedInstance.resetBgmMusic(musicUrl: nil)
    }
    
    @IBAction func changeBGM() {
        let url = URL(fileURLWithPath:Bundle.main.path(forResource: "月半弯", ofType: "mp3")!)
        MediaManager.sharedInstance.resetBgmMusic(musicUrl: nil)
    }
    
    @IBAction func silentFilm(){
        MediaManager.sharedInstance.reseVideoPlayerVolum()
    }
    
    @IBAction func next(){
//        MediaManager.sharedInstance.exportVideoWithAudio(audioUrl: self.audioUrl) {
//            print("exportVideoWithAudio:::::::")
//            MediaManager.sharedInstance.exportToPHPhotoLibrary()
//        }
        let url = Bundle.main.url(forResource: "IMG_2471", withExtension: "mov")!
        MediaManager.sharedInstance.exportVideoToJMCollection(videoUrl: url, audioUrl: nil, completionHandler: {
            print("okok:::::::::")
            MediaManager.sharedInstance.exportToPHPhotoLibrary()
        })
    }

    
    /// 获取视频帧数据
    func getVideoBuffer(videoUrl:URL,exportURL:URL) {
        // MARK: -  AVPlayer获取
        MediaManager.sharedInstance.avplayerGetNewPixelBuffer(url: videoUrl) {[unowned self] (inPutCIImage) -> (CIImage?) in
            let time = CFAbsoluteTimeGetCurrent()
            var inputImage = inPutCIImage
            let filters = inputImage?.autoAdjustmentFilters(options: nil)
            for filter: CIFilter in filters! {
                filter.setValue(inPutCIImage, forKey: kCIInputImageKey)
                inputImage = filter.outputImage!
            }
            print("time2222:::::::::\(CFAbsoluteTimeGetCurrent() - time)")
//            let outputImage = inPutCIImage?.oldFilmEffect()//添加滤镜
//            self.currentFilter.setValue(inPutCIImage, forKey: kCIInputImageKey)
//            let outputImage =  self.currentFilter.outputImage!  //CIImage
            self.coreImageView?.image = inputImage//显示
            return inputImage//返回添加滤镜后的CIImage
        }
    }
    

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

