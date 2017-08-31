//
//  MediaManager.swift
//  EditVideo
//
//  Created by 极目 on 2017/5/23.
//  Copyright © 2017年 极目. All rights reserved.
//

import UIKit
import Photos
import Lottie


class MediaManager: NSObject {
    
    static let sharedInstance = MediaManager()
    
    // MARK: -  音视频叠加、导出本地
    fileprivate var assetExport:AVAssetExportSession!//视频导出功能

    
    // MARK: -  视频帧读取
    fileprivate var videoPlayer:AVPlayer!//视频播放器
    fileprivate var videoPlayerVolum:Float?//视频播放器
    
    fileprivate var audioPlayer:AVPlayer!//背景音乐播放器

    fileprivate var videoOutput:AVPlayerItemVideoOutput!//视频输出流
    fileprivate var displayLink:CADisplayLink?//定时器
    fileprivate var newPixelBufferCallBack: ((CIImage?) -> (CIImage?))?//刷新时候的回调
    fileprivate var finishWritingHandler: (() -> Swift.Void)?//写入本地完成以后的回调

    // MARK: -  添加滤镜后视频导出功能
    fileprivate var assetWriter: AVAssetWriter?
    fileprivate var assetWriterPixelBufferInput: AVAssetWriterInputPixelBufferAdaptor?

    fileprivate var audioInput: AVAssetWriterInput?
    
    var isWriting = false
    var currentVideoSize = CGRect()
    let exportURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("TempVideo.mov")
    lazy var context: CIContext = {
        let eaglContext = EAGLContext(api: EAGLRenderingAPI.openGLES2)
        let options = [kCIContextWorkingColorSpace : NSNull()]
        return CIContext(eaglContext: eaglContext!, options: options)
    }()
    
    
    // MARK: -  #########################################################################
    private override init() {
        super.init()
    }
    
    
    // MARK: -  音视频叠加、导出本地
    func exportVideoToJMCollection(videoUrl:URL, audioUrl :URL?,completionHandler: @escaping () -> Swift.Void) {

        let videoAsset = AVURLAsset(url: videoUrl)
        let mixComposition = AVMutableComposition()
        
        let compositionVideoTrack = mixComposition.addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID: kCMPersistentTrackID_Invalid)
        
        guard let clipVideoTrack = videoAsset.tracks(withMediaType: AVMediaTypeVideo).first else {
            return
        }
        print("clipVideoTrack:::::::::\(clipVideoTrack.nominalFrameRate)")

        do {
            try compositionVideoTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, videoAsset.duration), of: clipVideoTrack, at: kCMTimeZero)
        } catch {
            print("error")
        }
        compositionVideoTrack.preferredTransform = clipVideoTrack.preferredTransform
        
        //音频
        if let audioURL = audioUrl {
            let audioAsset = AVURLAsset(url: audioURL)
            if let clipAudioTrack = audioAsset.tracks(withMediaType: AVMediaTypeAudio).first {
                let compositionAudioTrack = mixComposition.addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID: kCMPersistentTrackID_Invalid)
                do {
                    try compositionAudioTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, videoAsset.duration), of: clipAudioTrack, at: kCMTimeZero)
                } catch {
                    print("error")
                }
                compositionAudioTrack.preferredTransform = clipAudioTrack.preferredTransform
            }
        }
        
        //添加文本、边框
        let avMComI = AVMutableVideoCompositionInstruction()
        avMComI.timeRange = CMTimeRangeMake(kCMTimeZero, videoAsset.duration)
        
        //AVMutableVideoCompositionLayerInstruction 视频追踪和定位
        let avMVComLayerI = AVMutableVideoCompositionLayerInstruction(assetTrack: compositionVideoTrack)
        avMVComLayerI.setTransform(clipVideoTrack.preferredTransform, at: kCMTimeZero)
        avMVComLayerI.setOpacity(0.0, at: videoAsset.duration)
        avMComI.layerInstructions = [avMVComLayerI]
        
        
        print("clipVideoTrack:::::::::\(clipVideoTrack.preferredTransform)")

        let mainCompositionInst = AVMutableVideoComposition()
        mainCompositionInst.renderSize = CGSize(width: clipVideoTrack.naturalSize.width, height: clipVideoTrack.naturalSize.height)
        mainCompositionInst.instructions = [avMComI]
        mainCompositionInst.frameDuration = CMTime(value: 1, timescale: 30)
        

        let parentLayer = CALayer()
        parentLayer.backgroundColor = UIColor.white.cgColor
        parentLayer.frame = CGRect(x: 0, y: 0, width: clipVideoTrack.naturalSize.width, height: clipVideoTrack.naturalSize.height)

        //视频
        let videoLayer = CALayer()
        videoLayer.frame = CGRect(x: 10, y:20, width: clipVideoTrack.naturalSize.width - 20, height: clipVideoTrack.naturalSize.height - 40)
        parentLayer.addSublayer(videoLayer)
        
        
        //边框
        let backgroundLayer = CALayer()
        backgroundLayer.frame = CGRect(x: 0, y: 0, width: clipVideoTrack.naturalSize.width, height: clipVideoTrack.naturalSize.height)
        let backgroundimage = UIImage.init(named: "border_17")
        backgroundLayer.contents = backgroundimage?.cgImage
//        parentLayer.addSublayer(backgroundLayer)
        

        //添加文字
        let titleLayer = CATextLayer()
        titleLayer.font = "Helvetica-Bold" as CFTypeRef?
        titleLayer.fontSize = 36
        titleLayer.frame = CGRect(x: 10, y: 10, width: 100, height: 100)
        titleLayer.string = "hello"
        titleLayer.foregroundColor = UIColor.red.cgColor
//        parentLayer.addSublayer(titleLayer)
        
        
        
        let showImage = PendantImageView(frame: CGRect(x: clipVideoTrack.naturalSize.width - 100, y: 160, width: 100, height: 100), imageName: "sticker_16")
        
        //添加图片
        let showImageLayer = CALayer()
//        let showimage = UIImage(named: "sticker_1")
        showImageLayer.contents = showImage.makeImageWithView()
        showImageLayer.frame =  CGRect(x: clipVideoTrack.naturalSize.width - 100, y: 160, width: 100, height: 100)
        parentLayer.addSublayer(showImageLayer)
        
        
        
        let animationView = LOTAnimationView(name: "test")
        animationView.frame = CGRect(x: 0, y: 0, width: 400, height: 400)
        animationView.loopAnimation = false
        animationView.contentMode = .scaleAspectFill
        animationView.animationSpeed = 1.0
        print("animationDuration:::::::::\(animationView.animationDuration)")
        let start = CFAbsoluteTimeGetCurrent()
        animationView.layer.beginTime = AVCoreAnimationBeginTimeAtZero
        animationView.layer.animationKeys()
        parentLayer.addSublayer(animationView.layer)
//        animationView.play { (bool) in
//            print("use time:::::::::\(CFAbsoluteTimeGetCurrent() - start)")
//        }
        
        
        //gif
//        let imageLayer = CALayer()
//        imageLayer.frame = CGRect(x: 0, y: 0, width: clipVideoTrack.naturalSize.width, height: clipVideoTrack.naturalSize.height)
//        
//        let source = CGImageSourceCreateWithURL(Bundle.main.url(forResource: "timg", withExtension: "gif")! as CFURL, nil)
//        let count = CGImageSourceGetCount(source!)
//        print("count:::::::::\(count)")
//        
//        var imageArray = [CGImage]()
//        for i in 0..<count {
////            let image = UIImage(named: "border_" + String(i))?.cgImage
//            let image = CGImageSourceCreateImageAtIndex(source!, i, nil)
//            imageArray.append(image!)
//            print("CGImageSourceCopyPropertiesAtIndex(source, i, NULL):::::::::\(String(describing: CGImageSourceCopyPropertiesAtIndex(source!, i, nil)))")
//        }
//        
//        let animation = CAKeyframeAnimation(keyPath: "contents")
//        animation.values = imageArray
//        animation.timingFunctions = [CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)]
//        var currentTime: Double = 0
//        var times = [NSNumber]()
//        for _ in 0..<imageArray.count {
//            times.append(NSNumber(value: currentTime/0.9))
//            currentTime += 0.1
//        }
//        animation.keyTimes = times
//        animation.repeatCount = MAXFLOAT
//        animation.duration = 10
//        animation.beginTime = 0.001
//        imageLayer.add(animation, forKey: "gifAnimation")
//        parentLayer.addSublayer(imageLayer)

        
        //合并
        mainCompositionInst.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, in: parentLayer)
        
        self.assetExport = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetMediumQuality)
        if FileManager.default.fileExists(atPath: exportURL.path) {
            do { try FileManager.default.removeItem(atPath: exportURL.path)} catch{}
        }
        
        self.assetExport.outputFileType = AVFileTypeQuickTimeMovie
        self.assetExport.outputURL = exportURL
        self.assetExport.shouldOptimizeForNetworkUse = true
        self.assetExport.videoComposition = mainCompositionInst
        self.assetExport.exportAsynchronously(completionHandler: completionHandler)
    }
    
    
    
    
    func exportVideoWithAudio(audioUrl :URL?,completionHandler: @escaping () -> Swift.Void) {
        exportVideoToJMCollection(videoUrl: exportURL, audioUrl: audioUrl, completionHandler: completionHandler)
    }
    
    
    // MARK: -  AVPlayer视频帧读取,通过AVPlayer获取
    func avplayerGetNewPixelBuffer(url: URL,finishWritingHandler: (() -> Swift.Void)? = nil,newPixelBufferCallBack:@escaping (CIImage?) -> (CIImage?)) {
        self.newPixelBufferCallBack = newPixelBufferCallBack
        self.finishWritingHandler = finishWritingHandler
        
        audioPlayer = AVPlayer()

        videoPlayer = AVPlayer(url: url)
        videoPlayerVolum = videoPlayer.volume
        videoOutput = AVPlayerItemVideoOutput(pixelBufferAttributes: [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange])
        videoPlayer.currentItem?.add(videoOutput)
        startDisplayLink()
        videoPlayer.play()
    }
    
    @objc private func displayLinkDidRefresh(_ link: CADisplayLink) {
        //转成视频播放当前时间
        let itemTime = videoOutput.itemTime(forHostTime: CACurrentMediaTime())
//        CMTimeShow(itemTime)
        
        //判断播放是否完成
        let timescale  = Double((videoPlayer.currentItem?.duration.timescale)!)
        let value = Double((videoPlayer.currentItem?.duration.value)!)
        let totleTime = value/timescale
        
        let currentTime = Double(CMTimeGetSeconds(videoPlayer.currentTime()))
        if currentTime == totleTime {
            releaseDisplayLink()
            videoPlayer.pause()
            audioPlayer.pause()
            
//            //存到本地
//            self.isWriting = false
//            self.assetWriterPixelBufferInput = nil
//            self.assetWriter?.finishWriting(completionHandler: {
//                if let finishWritingHandler = self.finishWritingHandler {
//                    finishWritingHandler()//保存到本地完毕回调
//                }
//            })
        }else{
            if videoOutput.hasNewPixelBuffer(forItemTime: itemTime) {//有新的像素时
                var presentationItemTime = kCMTimeZero
                if let pixelBuffer = videoOutput.copyPixelBuffer(forItemTime: itemTime, itemTimeForDisplay: &presentationItemTime){
                    let time = CFAbsoluteTimeGetCurrent()
                    currentVideoSize = CVImageBufferGetCleanRect(pixelBuffer)//输出视频的尺寸,用于后面写入视频的时候
                    let inputImage = CIImage(cvPixelBuffer: pixelBuffer)
                    let outputImage = newPixelBufferCallBack!(inputImage)//回调新一帧的像素，返回的是添加滤镜后的
                    print("time:::::::::\(CFAbsoluteTimeGetCurrent() - time)")

//                    //开始写操作
//                    if !self.isWriting {
//                        self.isWriting = true
//                        self.createWriter()
//                        self.assetWriter?.startWriting()
//                        self.assetWriter?.startSession(atSourceTime: itemTime)
//                    }
//                    
//                    // 本地存储视频的处理
//                    if self.isWriting {
//                        //视频
//                        if self.assetWriterPixelBufferInput?.assetWriterInput.isReadyForMoreMediaData == true {
//                            var newPixelBuffer: CVPixelBuffer? = nil
//                            CVPixelBufferPoolCreatePixelBuffer(nil, self.assetWriterPixelBufferInput!.pixelBufferPool!, &newPixelBuffer)
//                            if let ciImage = outputImage {
//                                self.context.render(ciImage, to: newPixelBuffer!, bounds: (ciImage.extent), colorSpace: nil)//这个没有就输出黑屏
//                                self.assetWriterPixelBufferInput?.append(newPixelBuffer!, withPresentationTime: itemTime)//拼接视频PixelBuffer
//                            }
//                        }
//                    }
                }
            }
        }
    }
    
    
    private func startDisplayLink() {
        releaseDisplayLink()
        displayLink = CADisplayLink(target: self, selector: #selector(displayLinkDidRefresh(_:)))
        displayLink?.add(to: RunLoop.main, forMode: RunLoopMode.commonModes)
    }
    
    private func releaseDisplayLink() {
        print("释放::::::::")
        if displayLink != nil {
            displayLink?.remove(from: RunLoop.main, forMode: RunLoopMode.commonModes)
            displayLink?.invalidate()
            displayLink = nil
        }
    }
    
    
    /// 控制当前播放器及背景音乐的播放器
    func resetBgmMusic(musicUrl: URL?) {
        
        if videoPlayer.timeControlStatus == .paused {
            videoPlayer.play()
            startDisplayLink()
        }
        let time = CMTimeMakeWithSeconds(0.0,videoPlayer.currentTime().timescale);
        videoPlayer.seek(to: time)
        
        isWriting = false
        assetWriterPixelBufferInput = nil
        assetWriter?.cancelWriting()
        
        if let bgmUrl = musicUrl {
            videoPlayer.volume = 0
            let bgmItem = AVPlayerItem(url: bgmUrl)
            audioPlayer.replaceCurrentItem(with: bgmItem)
            audioPlayer.play()
        }else{
            if let currentVolum = videoPlayerVolum {
                videoPlayer.volume = currentVolum
            }
            audioPlayer.pause()
        }
    }
    
    
    /// 控制vedio音量
    func reseVideoPlayerVolum() {
        if videoPlayer.volume == 0 {
            if let currentVolum = videoPlayerVolum {
                videoPlayer.volume = currentVolum
            }else{
                
            }
        }else{
            videoPlayer.volume = 0
        }

    }
    
    
    // MARK: -  添加滤镜后视频导出功能:通过一张一张的CIImage合成视频，如果有音频就添加音频
    private func createWriter() {
        checkForAndDeleteFile()
        do {
            assetWriter = try AVAssetWriter(outputURL: exportURL, fileType: AVFileTypeQuickTimeMovie)
        } catch let error as NSError {
            print("创建writer失败")
            print(error.localizedDescription)
            return
        }
        
        let outputSettings = [
            AVVideoCodecKey : AVVideoCodecH264,
            AVVideoWidthKey : currentVideoSize.width ,
            AVVideoHeightKey : currentVideoSize.height
            ] as [String : Any]
        
        let assetWriterVideoInput = AVAssetWriterInput(mediaType: AVMediaTypeVideo, outputSettings: outputSettings)
        assetWriterVideoInput.expectsMediaDataInRealTime = true
//          assetWriterVideoInput.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI / 2.0))
        
        let sourcePixelBufferAttributesDictionary = [
            String(kCVPixelBufferPixelFormatTypeKey) : Int(kCVPixelFormatType_32BGRA),
            String(kCVPixelBufferWidthKey) : currentVideoSize.width ,
            String(kCVPixelBufferHeightKey) : currentVideoSize.height ,
            String(kCVPixelFormatOpenGLESCompatibility) : kCFBooleanTrue
            ] as [String : Any]
        
        assetWriterPixelBufferInput = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: assetWriterVideoInput,sourcePixelBufferAttributes: sourcePixelBufferAttributesDictionary)
        
        if assetWriter!.canAdd(assetWriterVideoInput) {
            assetWriter!.add(assetWriterVideoInput)
        }
        
        audioInput = AVAssetWriterInput(mediaType: AVMediaTypeAudio, outputSettings: nil)
        audioInput?.expectsMediaDataInRealTime = true

        if assetWriter!.canAdd(audioInput!) {
            assetWriter?.add(audioInput!)
        }
        
    }
    
    private func checkForAndDeleteFile() {
        let fm = FileManager.default
        let exist = fm.fileExists(atPath: exportURL.path)
        if exist {
            print("删除之前的临时文件")
            do {
                try fm.removeItem(at: exportURL)
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    }
    
    
    
    // MARK: -  导出到系统相册
    func exportToPHPhotoLibrary()  {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: self.exportURL)
        }, completionHandler: { (finish, error) in
            print("finish:::::::::\(finish)")
            print("error:::::::::\(error.debugDescription)")
        })
    }
    
    
    
    
    // MARK: -  获取关键帧
    func userAVAssetImageGenerator(vedioURL:URL) {
        let videoAsset = AVURLAsset(url: vedioURL)
        let imageGenerator = AVAssetImageGenerator(asset: videoAsset)
        
        print("videoAsset.duration:::::::::\(videoAsset.duration)")

        let durationSeconds = CMTimeGetSeconds(videoAsset.duration)
        print("durationSeconds:::::::::\(durationSeconds)")

        var times = [NSValue]()
        for i in 1...Int(durationSeconds) {
            let time = CMTimeMakeWithSeconds(Float64(i), videoAsset.duration.timescale) as NSValue
            times.append(time)
        }
        var imageCount = 0
        

        
        imageGenerator.generateCGImagesAsynchronously(forTimes: times) { (requestedTime, image, actualTime, result, error) in
//            print(error.debugDescription)
//            print(requestedTime)
            print("CMTimeGetSeconds(actualTime):::::::::\(CMTimeGetSeconds(actualTime))")
            print("CMTimeGetSeconds(requestedTime):::::::::\(CMTimeGetSeconds(requestedTime))")
            if let cgImage = image {
                if imageCount % 2 == 0 {
                    print("cgImage:::::::::\(cgImage)")
                    print("imageCount:::::::::\(imageCount)")
                }
                imageCount += 1
            }
        }
    }
    
    
}
