//
//  PendantImageView.swift
//  pictureHandel
//
//  Created by minsol on 2017/6/7.
//  Copyright © 2017年 极目. All rights reserved.
//

import UIKit

class PendantImageView: UIView {
    
    var imageName : String?
    var imageView = UIImageView()
    var isImageView : Bool?

    
    var textView = UITextView()

    var delBtn = UIImageView()
    var rotationBtn = UIImageView()
    let subViewWidth = 200
    var subViewHeight = 200

    let subButtonWidthAndHeight = 40

    


    convenience init(frame: CGRect,imageName:String? = nil,isImageView:Bool? = true) {
        self.init(frame: frame)
        self.isImageView = isImageView
        if isImageView! {
            subViewHeight = subViewWidth
            imageView = UIImageView(image: UIImage(named:imageName!))
            imageView.frame = CGRect(x: 0, y: 0, width: subViewWidth, height: subViewHeight)
            imageView.layer.borderWidth = 1
            imageView.layer.borderColor = UIColor.white.cgColor
            imageView.isUserInteractionEnabled = true
            imageView.isMultipleTouchEnabled = true
            //捏合图片手势
            let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(pinchGestureAction))
            imageView.addGestureRecognizer(pinchGestureRecognizer)
            
            //拖拽
            let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerAction))
            imageView.addGestureRecognizer(panGestureRecognizer)
            
            //旋转
            let rotationGestureRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(rotationGestureRecognizerAction))
            imageView.addGestureRecognizer(rotationGestureRecognizer)
            self.insertSubview(imageView, at: 0)
//            self.layer.insertSublayer(imageView.layer, at: 0)
        }else{
            subViewHeight = 80
            textView = UITextView(frame: CGRect(x: 0, y: 0, width: subViewWidth, height: subViewHeight))
            textView.textAlignment = .center
            textView.backgroundColor = UIColor.clear
            textView.font = UIFont.systemFont(ofSize: 30)
            textView.layer.borderWidth = 1
            textView.layer.borderColor = UIColor.white.cgColor
            textView.isUserInteractionEnabled = true
            textView.isMultipleTouchEnabled = true
            //点击
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapGestureRecognizerAction))
            tapGestureRecognizer.numberOfTouchesRequired = 1
//            textView.addGestureRecognizer(tapGestureRecognizer)
            
            //捏合图片手势
            let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(pinchGestureAction))
            textView.addGestureRecognizer(pinchGestureRecognizer)
            
            //拖拽
            let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerAction))
            textView.addGestureRecognizer(panGestureRecognizer)
            
            //旋转
            let rotationGestureRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(rotationGestureRecognizerAction))
            textView.addGestureRecognizer(rotationGestureRecognizer)
            self.insertSubview(textView, at: 0)
        }
        
        //删除的按钮
        let delBtnGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(delBtnAction))
        delBtnGestureRecognizer.numberOfTapsRequired = 1
        delBtn = UIImageView(image: UIImage(named:"btn_delete_black"))
        delBtn.frame = CGRect(x: 0, y: 0, width: subButtonWidthAndHeight, height: subButtonWidthAndHeight)
        delBtn.center = imageView.convert(CGPoint(x: subViewWidth, y: 0), to: delBtn)
        delBtn.addGestureRecognizer(delBtnGestureRecognizer)
        delBtn.isUserInteractionEnabled = true
        self.addSubview(delBtn)
        
        
        //旋转的按钮
        let rotationBtnpanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(rotationPanGestureRecognizerAction))
        rotationBtn = UIImageView(image: UIImage(named:"rotate"))
        rotationBtn.frame = CGRect(x: 0, y: 0, width: subButtonWidthAndHeight, height: subButtonWidthAndHeight)
        rotationBtn.center = imageView.convert(CGPoint(x: subViewWidth, y: subViewHeight), to: rotationBtn)
        rotationBtn.addGestureRecognizer(rotationBtnpanGestureRecognizer)
        rotationBtn.isUserInteractionEnabled = true
        self.addSubview(rotationBtn)
    }
    
    public func makeImageWithView() -> CGImage {
        let size = self.bounds.size
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        self.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return (image?.cgImage)!
    }
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        self.isUserInteractionEnabled = true
        self.isMultipleTouchEnabled = true
        self.autoresizesSubviews = false
    }
    
    
    
    func tapGestureRecognizerAction(tap:UIPinchGestureRecognizer) {
        hideDelBtn()
        if tap.state == .began || tap.state == .changed {
            textView.text = "hello"
        }else{
            reSetSubViewFrame()
        }
    }
    
    func pinchGestureAction(tap:UIPinchGestureRecognizer) {
        hideDelBtn()
        let view = tap.view
        if tap.state == .began || tap.state == .changed {
            view?.transform = (view?.transform)!.scaledBy(x: tap.scale, y: tap.scale)
            tap.scale = 1
        }else{
            reSetSubViewFrame()
        }
    }
    
    
    func panGestureRecognizerAction(tap:UIPanGestureRecognizer) {
        hideDelBtn()
        let view = tap.view
        if tap.state == .began || tap.state == .changed {
            let translation = tap.translation(in: view?.superview)
            view?.center = CGPoint(x: view!.center.x + translation.x, y: (view?.center.y)! + translation.y)
            tap.setTranslation(CGPoint.zero, in: view?.superview)
        }else{
            print("view:::::::::\(view?.frame)")
            print("self:::::::::\(self.frame)")
            if (view?.frame.origin.x)! > self.frame.size.width || Double((view?.frame.origin.x)!) < -Double((view?.frame.size.width)!) || (view?.frame.origin.y)! > self.frame.size.height || Double((view?.frame.origin.y)!) < -Double((view?.frame.size.height)!){
                view?.removeFromSuperview()
                self.removeFromSuperview()
            }
            reSetSubViewFrame()
        }
    }
    
    
    func rotationGestureRecognizerAction(tap:UIRotationGestureRecognizer) {
        hideDelBtn()
        let view = tap.view
        if tap.state == .began || tap.state == .changed {
            view?.transform = view!.transform.rotated(by: tap.rotation)
            tap.rotation = 0
        }else{
            reSetSubViewFrame()
        }
    }
    
    
    //删除按钮
    func delBtnAction() {
        self.removeFromSuperview()
    }

    
    //拖动旋转按钮
    func rotationPanGestureRecognizerAction(tap:UIPanGestureRecognizer) {
        hideDelBtn()
        let viewCtrl = tap.view
        var viewImg = UIView()

        if isImageView! {
            viewImg = imageView
        }else{
            viewImg = textView
        }
        
        
        let center = viewImg.center
        let prePoint = viewCtrl?.center
        let translation = tap.translation(in: viewCtrl)
        let curPoint = CGPoint(x: (prePoint?.x)!+translation.x, y:  (prePoint?.y)!+translation.y)

        
        // 计算缩放
        let preDistance = getDistance(pointA: prePoint!, pointB: center)
        let curDistance = getDistance(pointA: curPoint, pointB: center)
        let scale = curDistance / preDistance;
        print("scale:::::::::\(scale)")
        
        // 计算弧度
        let preRadius = getRadius(pointA: center, pointB: prePoint!)
        let curRadius = getRadius(pointA: center, pointB: curPoint)
        var radius = curRadius - preRadius
        radius = -radius
        
        if tap.state == .began || tap.state == .changed {
            viewImg.transform = (viewImg.transform).scaledBy(x: scale, y: scale).rotated(by: radius)
            tap.setTranslation(CGPoint.zero, in: viewCtrl)
        }else{
            reSetSubViewFrame()
        }
    }
    
    func reSetSubViewFrame()  {
        if self.isImageView! {
            rotationBtn.center = imageView.convert(CGPoint(x: subViewWidth, y: subViewHeight), to: self)
            delBtn.center = imageView.convert(CGPoint(x: subViewWidth, y: 0), to: self)
        }else{
            rotationBtn.center = textView.convert(CGPoint(x: subViewWidth, y: subViewHeight), to: self)
            delBtn.center = textView.convert(CGPoint(x: subViewWidth, y: 0), to: self)
        }
        showDelBtn()
    }
    
    func getDistance(pointA:CGPoint,pointB:CGPoint) -> CGFloat {
        let x = pointA.x - pointB.x
        let y = pointA.y - pointB.y
        return sqrt(x*x + y*y)
    }
    
    //两个点形成的斜率的角度
    func getRadius(pointA:CGPoint,pointB:CGPoint) -> CGFloat {
        let x = pointA.x - pointB.x
        let y = pointA.y - pointB.y
        return atan2(x, y)
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func draw(_ rect: CGRect) {
        
    }
    

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        hideDelBtn()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        showDelBtn()
    }

    func hideDelBtn() {
        self.endEditing(true)
        self.delBtn.alpha = 0
        self.rotationBtn.alpha = 0
    }
    
    func showDelBtn()  {
        UIView.animate(withDuration: 0.2) {
            self.delBtn.alpha = 1
            self.rotationBtn.alpha = 1
        }
    }

}
