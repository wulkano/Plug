import Foundation
import IOKit.pwr_mgt

public final class PreventSleep {
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
		if !canSleep() {
			allowSleep()
		}
	}

	// MARK: Power assertion handling

	// Prevent the computer going to sleep
	// Returns whether the power assertion was successful or not.
	@objc
	public func preventSleep() -> Bool {
		guard canSleep() else {
			return true
		}

		sleepAssertion = IOPMAssertionCreateWithName(
			sleepAssertionType! as CFString,
			IOPMAssertionLevel(kIOPMAssertionLevelOn),
			sleepAssertionMsg! as CFString,
			&sleepAssertionID!
		)

		return sleepAssertion == kIOReturnSuccess
	}

	// Allow the computer to go to sleep
	// Returns whether the power assertion was successful or not.
	@objc
	@discardableResult
	public func allowSleep() -> Bool {
		guard !canSleep() else {
			return true
		}

		let sleepAssertionRelease = IOPMAssertionRelease(sleepAssertionID!)

		if sleepAssertionRelease == kIOReturnSuccess {
			/* Update the sleepAssertion to no longer return as a success
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
	@objc
	public func canSleep() -> Bool {
		// Check if the assertion already exists
		return sleepAssertion == kIOReturnSuccess
	}
}
