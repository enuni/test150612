//
//  TrimView.swift
//  Test150528
//
//  Created by 中原規之 on 2015/06/04.
//  Copyright (c) 2015年 中原規之. All rights reserved.
//

import UIKit

class TrimView: UIView {
    
    var extScale:CGFloat = 1.0
    var currentScale:CGFloat = 1.0
    var beforePoint:CGPoint = CGPointMake(0.0, 0.0)
    var beforeRotation:CGFloat = 0.0
    var panStartPoint:CGPoint = CGPointMake(0.0, 0.0)
    var orgTrimFrame:CGRect = CGRectMake(0.0, 0.0, 0.0, 0.0)
    
    var trimImageView:UIImageView!
    
    var master:Master!
    var trimFrameLayer:CALayer!
    
    enum TRIM_TRANSFORM_POSITION {
        case LEFT_UP
        case RIGHT_UP
        case LEFT_DOWN
        case RIGHT_DOWN
    }
    
    var trimTransformPosition:TRIM_TRANSFORM_POSITION = .LEFT_UP
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.userInteractionEnabled = true
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: "handleGesture:")
        self.addGestureRecognizer(pinchGesture)
        
        let rotationGesture = UIRotationGestureRecognizer(target: self, action: "handleGesture:")
        self.addGestureRecognizer(rotationGesture)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: "handleGesture:")
        self.addGestureRecognizer(panGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: "handleGesture:")
        self.addGestureRecognizer(tapGesture)
    }
    
    func handleGesture(gesture: UIGestureRecognizer){
        if let rotationGesuture = gesture as? UIRotationGestureRecognizer{
            rotate(rotationGesuture)
        }else if let pinchGesture = gesture as? UIPinchGestureRecognizer{
            pinch(pinchGesture)
        }else if let panGesture = gesture as? UIPanGestureRecognizer{
            pan(panGesture)
        }else if let tapGesture = gesture as? UITapGestureRecognizer{
            
        }
    }
    
    private func rotate(gesture:UIRotationGestureRecognizer) {
        var rotation = gesture.rotation + self.beforeRotation
        
        switch gesture.state{
        case .Changed:
            let rotationTransform = CGAffineTransformMakeRotation(rotation)
            let scaleTransform = CGAffineTransformMakeScale(self.currentScale * self.extScale, self.currentScale * self.extScale)
            let translationTransform = CGAffineTransformMakeTranslation(self.beforePoint.x, self.beforePoint.y)
            self.trimImageView.transform = CGAffineTransformConcat(rotationTransform, scaleTransform)
            self.trimImageView.transform = CGAffineTransformConcat(self.trimImageView.transform, translationTransform)
        case .Ended , .Cancelled:
            self.beforeRotation = rotation
        default:
            NSLog("no action")
        }
    }
    
    private func pan(gesture:UIPanGestureRecognizer){
        if let gestureView = gesture.view{
            var translation = gesture.translationInView(gestureView)
            
            let touch_n:Int = gesture.numberOfTouches()
            for var i:Int = 0; i < touch_n; i++ {
                let location:CGPoint = gesture.locationOfTouch(i, inView: self)
                NSLog("start: x = %4.1f y = %4.1f", self.panStartPoint.x, self.panStartPoint.y)
                NSLog("touch %02d: x = %4.1f y = %4.1f", i, location.x, location.y)
                NSLog("tarns %02d: x = %4.1f y = %4.1f", i, translation.x, translation.y)
                NSLog("trim : x = %4.1f y = %4.1f w = %4.1f h = %4.1f",
                    self.master.trimFrame.origin.x,
                    self.master.trimFrame.origin.y,
                    self.master.trimFrame.size.width,
                    self.master.trimFrame.size.height
                )
            }
            
            switch gesture.state{
            case .Began:
                if touch_n == 1 {
                    self.panStartPoint = gesture.locationOfTouch(0, inView: self)
                    var len:[CGFloat] = [
                        sqrt(
                            (self.panStartPoint.x - self.master.trimFrame.origin.x) * (self.panStartPoint.x - self.master.trimFrame.origin.x)
                            +
                            (self.panStartPoint.y - self.master.trimFrame.origin.y) * (self.panStartPoint.y - self.master.trimFrame.origin.y)
                        ),
                        sqrt(
                            (self.panStartPoint.x - (self.master.trimFrame.origin.x + self.master.trimFrame.size.width)) *
                            (self.panStartPoint.x - (self.master.trimFrame.origin.x + self.master.trimFrame.size.width))
                            +
                            (self.panStartPoint.y - self.master.trimFrame.origin.y) * (self.panStartPoint.y - self.master.trimFrame.origin.y)
                        ),
                        sqrt(
                            (self.panStartPoint.x - self.master.trimFrame.origin.x) * (self.panStartPoint.x - self.master.trimFrame.origin.x)
                            +
                            (self.panStartPoint.y - (self.master.trimFrame.origin.y + self.master.trimFrame.size.height)) *
                            (self.panStartPoint.y - (self.master.trimFrame.origin.y + self.master.trimFrame.size.height))
                        ),
                        sqrt(
                            (self.panStartPoint.x - (self.master.trimFrame.origin.x + self.master.trimFrame.size.width)) *
                            (self.panStartPoint.x - (self.master.trimFrame.origin.x + self.master.trimFrame.size.width))
                            +
                            (self.panStartPoint.y - (self.master.trimFrame.origin.y + self.master.trimFrame.size.height)) *
                            (self.panStartPoint.y - (self.master.trimFrame.origin.y + self.master.trimFrame.size.height))                        ),


                    ]
                    var position:[TRIM_TRANSFORM_POSITION] = [
                        TRIM_TRANSFORM_POSITION.LEFT_UP,
                        TRIM_TRANSFORM_POSITION.RIGHT_UP,
                        TRIM_TRANSFORM_POSITION.LEFT_DOWN,
                        TRIM_TRANSFORM_POSITION.RIGHT_DOWN,
                    ]
                    var min_len:CGFloat = CGFloat.max
                    var min_position = TRIM_TRANSFORM_POSITION.LEFT_UP
                    for var i:Int = 0; i < len.count; i++ {
                        if min_len > len[i] {
                            min_len = len[i]
                            min_position = position[i]
                        }
                    }
                    self.trimTransformPosition = min_position
                    self.orgTrimFrame = self.master.trimFrame
                }
            case .Changed:
                if touch_n == 1 {
                    if self.trimTransformPosition == TRIM_TRANSFORM_POSITION.LEFT_UP ||
                        self.trimTransformPosition == TRIM_TRANSFORM_POSITION.LEFT_DOWN {
                            let let_w:CGFloat = self.orgTrimFrame.width - translation.x
                            if let_w < 0.0 {
                                self.master.trimFrame.origin.x = self.orgTrimFrame.origin.x + self.orgTrimFrame.size.width
                                self.master.trimFrame.size.width = translation.x - self.orgTrimFrame.size.width
                            }else {
                                self.master.trimFrame.origin.x = self.orgTrimFrame.origin.x + translation.x
                                self.master.trimFrame.size.width = self.orgTrimFrame.size.width - translation.x
                            }
                    }
                    if self.trimTransformPosition == TRIM_TRANSFORM_POSITION.RIGHT_UP ||
                        self.trimTransformPosition == TRIM_TRANSFORM_POSITION.RIGHT_DOWN {
                            let let_w:CGFloat = self.orgTrimFrame.width + translation.x
                            if let_w < 0.0 {
                                self.master.trimFrame.origin.x = self.orgTrimFrame.origin.x + self.orgTrimFrame.size.width + translation.x
                                self.master.trimFrame.size.width = -let_w
                            }else {
                                self.master.trimFrame.size.width = self.orgTrimFrame.size.width + translation.x
                            }
                    }
                    if self.trimTransformPosition == TRIM_TRANSFORM_POSITION.LEFT_UP ||
                        self.trimTransformPosition == TRIM_TRANSFORM_POSITION.RIGHT_UP {
                            let let_h:CGFloat = self.orgTrimFrame.height - translation.y
                            if let_h < 0.0 {
                                self.master.trimFrame.origin.y = self.orgTrimFrame.origin.y + self.orgTrimFrame.size.height
                                self.master.trimFrame.size.height = translation.y - self.orgTrimFrame.size.height
                            }else {
                                self.master.trimFrame.origin.y = self.orgTrimFrame.origin.y + translation.y
                                self.master.trimFrame.size.height = self.orgTrimFrame.size.height - translation.y
                            }
                    }
                    if self.trimTransformPosition == TRIM_TRANSFORM_POSITION.LEFT_DOWN ||
                        self.trimTransformPosition == TRIM_TRANSFORM_POSITION.RIGHT_DOWN {
                            let let_h:CGFloat = self.orgTrimFrame.height + translation.y
                            if let_h < 0.0 {
                                self.master.trimFrame.origin.y = self.orgTrimFrame.origin.y + self.orgTrimFrame.size.height + translation.y
                                self.master.trimFrame.size.height = -let_h
                            }else {
                                self.master.trimFrame.size.height = self.orgTrimFrame.size.height + translation.y
                            }
                    }
                    self.trimFrameLayer.setNeedsDisplay()
                }else if touch_n == 2 {
                    if abs(self.beforePoint.x) > 0.0 || abs(self.beforePoint.y) > 0.0{
                        translation = CGPointMake(self.beforePoint.x + translation.x, self.beforePoint.y + translation.y)
                    }
                    let rotationTransform = CGAffineTransformMakeRotation(self.beforeRotation)
                    let scaleTransform = CGAffineTransformMakeScale(self.currentScale * self.extScale, self.currentScale * self.extScale)
                    let translationTransform = CGAffineTransformMakeTranslation(translation.x, translation.y)
                    self.trimImageView.transform = CGAffineTransformConcat(rotationTransform, scaleTransform)
                    self.trimImageView.transform = CGAffineTransformConcat(self.trimImageView.transform, translationTransform)
                }
            case .Ended , .Cancelled:
                self.beforePoint = translation
            default:
                NSLog("no action")
            }
        }
    }
    
    private func pinch(gesture:UIPinchGestureRecognizer){
        var scale = self.currentScale * gesture.scale
        
        switch gesture.state{
        case .Changed:
            let rotationTransform = CGAffineTransformMakeRotation(self.beforeRotation)
            let scaleTransform = CGAffineTransformMakeScale(scale * self.extScale, scale * self.extScale)
            let translationTransform = CGAffineTransformMakeTranslation(self.beforePoint.x, self.beforePoint.y)
            self.trimImageView.transform = CGAffineTransformConcat(rotationTransform, scaleTransform)
            self.trimImageView.transform = CGAffineTransformConcat(self.trimImageView.transform, translationTransform)
        case .Ended , .Cancelled:
            self.currentScale = scale
        default:
            NSLog("not action")
        }
    }

}
