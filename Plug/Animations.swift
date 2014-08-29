//
//  Animations.swift
//  Plug
//
//  Created by Alex Marchant on 8/28/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

struct Animations {
    static func RotateClockwise(view: NSView) {
        view.wantsLayer = true
        
        let duration: Double = 0.8
        var rotate = CABasicAnimation(keyPath: "transform.rotation.z")
        rotate.removedOnCompletion = false
        rotate.fillMode = kCAFillModeForwards
        
        //Do a series of 5 quarter turns for a total of a 1.25 turns
        //(2PI is a full turn, so pi/2 is a quarter turn)
        rotate.toValue = -M_PI / 2
        rotate.repeatCount = HUGE
        
        rotate.duration = duration / M_PI
        rotate.beginTime = 0
        rotate.cumulative = true
        rotate.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        
        var center = CGPointMake(CGRectGetMidX(view.frame), CGRectGetMidY(view.frame));
        view.layer!.position = center
        view.layer!.anchorPoint = CGPointMake(0.5, 0.5)
        view.layer!.addAnimation(rotate, forKey: "rotateAnimation")
    }
    
    static func RotateCounterClockwise(view: NSView) {
        view.wantsLayer = true
        
        let duration: Double = 0.8
        var rotate = CABasicAnimation(keyPath: "transform.rotation.z")
        rotate.removedOnCompletion = false
        rotate.fillMode = kCAFillModeForwards
        
        //Do a series of 5 quarter turns for a total of a 1.25 turns
        //(2PI is a full turn, so pi/2 is a quarter turn)
        rotate.toValue = M_PI / 2
        rotate.repeatCount = HUGE
        
        rotate.duration = duration / M_PI
        rotate.beginTime = 0
        rotate.cumulative = true
        rotate.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        
        var center = CGPointMake(CGRectGetMidX(view.frame), CGRectGetMidY(view.frame));
        view.layer!.position = center
        view.layer!.anchorPoint = CGPointMake(0.5, 0.5)
        view.layer!.addAnimation(rotate, forKey: "rotateAnimation")
    }
    
    static func RemoveAllAnimations(view: NSView) {
        view.layer!.removeAllAnimations()
    }
}