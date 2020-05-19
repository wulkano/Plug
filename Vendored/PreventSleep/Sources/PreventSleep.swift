//
//	PreventSleep.swift
//	PreventSleep
//
//	Created by Jesse Claven on 12/07/2016.
//	Copyright © 2016 Jesse Claven. All rights reserved.
//

import Foundation
import IOKit.pwr_mgt

open class PreventSleep {
	var sleepAssertionID: IOPMAssertionID? = IOPMAssertionID(0)
	var sleepAssertionType: String?
	var sleepAssertion: IOReturn?

	let sleepAssertionMsg: String?

	public init?(sleepAssertionMsg: String, sleepAssertionType: String) {
		// Check if the assertion type is valid
		if sleepAssertionType != kIOPMAssertionTypeNoIdleSleep &&
			sleepAssertionType != kIOPMAssertionTypeNoDisplaySleep {
			return nil
		}

		self.sleepAssertionMsg = sleepAssertionMsg
		self.sleepAssertionType = sleepAssertionType
	}

	deinit {
		if !self.canSleep() {
			self.allowSleep()
		}
	}

	// MARK: Power assertion handling

	// Prevent the computer going to sleep
	// Returns whether the power assertion was successful or not.
	@objc open func preventSleep() -> Bool {
		if !canSleep() {
			return true
		}

		sleepAssertion = IOPMAssertionCreateWithName(
			sleepAssertionType! as CFString,
			IOPMAssertionLevel(kIOPMAssertionLevelOn),
			sleepAssertionMsg! as CFString,
			&sleepAssertionID!
		)

		if sleepAssertion == kIOReturnSuccess {
			return true
		} else {
			return false
		}
	}

	// Allow the computer to go to sleep
	// Returns whether the power assertion was successful or not.
	@objc @discardableResult open func allowSleep() -> Bool {
		if canSleep() {
			return true
		}

		let sleepAssertionRelease = IOPMAssertionRelease(sleepAssertionID!)

		if sleepAssertionRelease == kIOReturnSuccess {
			/* Updat the sleepAssertion to no longer return as a success
			 * Preferably don't use nil but no other IOReturns' seemed fitting
			 * https://opensource.apple.com/source/xnu/xnu-792.13.8/iokit/IOKit/IOReturn.h
			 */
			sleepAssertion = nil

			return true
		} else {
			return false
		}
	}

	// Can the computer go to sleep, or is it being prevented?
	@objc open func canSleep() -> Bool {
		// Check if the assertion already exists
		if sleepAssertion == kIOReturnSuccess {
			return false
		} else {
			return true
		}
	}
}
