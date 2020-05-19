//
//	Animations.swift
//	Plug
//
//	Created by Alex Marchant on 8/28/14.
//	Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

struct Animations {
	static func rotateClockwise(_ view: NSView) {
		view.wantsLayer = true

		let duration: Double = 0.8
		let rotate = CABasicAnimation(keyPath: "transform.rotation.z")
		rotate.isRemovedOnCompletion = false
		rotate.fillMode = CAMediaTimingFillMode.forwards

		// Do a series of 5 quarter turns for a total of a 1.25 turns
		// (2PI is a full turn, so pi/2 is a quarter turn)
		rotate.toValue = -M_PI / 2
		rotate.repeatCount = HUGE

		rotate.duration = duration / M_PI
		rotate.beginTime = 0
		rotate.isCumulative = true
		rotate.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)

		let center = CGPoint(x: view.frame.midX, y: view.frame.midY)
		view.layer!.position = center
		view.layer!.anchorPoint = CGPoint(x: 0.5, y: 0.5)
		view.layer!.add(rotate, forKey: "rotateAnimation")
	}

	static func rotateCounterClockwise(_ view: NSView) {
		view.wantsLayer = true

		let duration: Double = 0.8
		let rotate = CABasicAnimation(keyPath: "transform.rotation.z")
		rotate.isRemovedOnCompletion = false
		rotate.fillMode = CAMediaTimingFillMode.forwards

		// Do a series of 5 quarter turns for a total of a 1.25 turns
		// (2PI is a full turn, so pi/2 is a quarter turn)
		rotate.toValue = M_PI / 2
		rotate.repeatCount = HUGE

		rotate.duration = duration / M_PI
		rotate.beginTime = 0
		rotate.isCumulative = true
		rotate.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)

		let center = CGPoint(x: view.frame.midX, y: view.frame.midY)
		view.layer!.position = center
		view.layer!.anchorPoint = CGPoint(x: 0.5, y: 0.5)
		view.layer!.add(rotate, forKey: "rotateAnimation")
	}

	static func removeAllAnimations(_ view: NSView) {
		view.layer?.removeAllAnimations()
	}
}
