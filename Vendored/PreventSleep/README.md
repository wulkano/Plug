# PreventSleep

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage) [![CocoaPods compatible](https://img.shields.io/cocoapods/v/PreventSlep.svg)]() [![License](https://img.shields.io/github/license/mashape/apistatus.svg)]()

PreventSleep is a simple library to prevent a Mac from allowing a display to sleep, or from prevent idle sleep.

It differs from another common approach on Mac which is to handle a `caffeinate` process.

## Example

```swift
import PreventSleep
import IOKit.pwr_mgt

let preventSleep = PreventSleep(
    sleepAssertionMsg: "Prevent idle sleep when playing audio.",
    sleepAssertionType: kIOPMAssertionTypeNoIdleSleep
)!

preventSleep.preventSleep()

sleep(10)

preventSlep.allowSleep()

```

To check that the power assertion was correctly created/removed, run `pmset -g assertions` and look for your assertion.

## Installation

__Carthage__

`github "jesse-c/PreventSleep" ~> VERSION_NUMBER`

## Usage

__Initialisation__
```swift
PreventSleep(sleepAssertionMsg: String, sleepAssertionType)
```

`sleepAssertionMsg: String` is the message that will be attached to the power assertion.
`sleepAssertionType: String` is either `kIOPMAssertionTypeNoIdleSleep` or `kIOPMAssertionTypeNoDisplaySleep` which are available after importing `IOKit.pwr_mgt`.

__Prevent sleeping__
```swift
preventSleep() -> Bool
```
Indefinitely prevents the type of sleep specified.  Returns true if a power assertion was create successfully, false otherwise.

__Allow sleeping__
```swift
allowSleep() -> Bool
```
Allow the Mac to go to sleep following the user's energy prefernces. Returns true if a power assertion was removed successfully, false otherwise.

__Check current sleeping status__
```swift
canSleep() -> Bool
```
Returns true if there is currently no power assertion preventing sleeping, false otherwise.


## Contributing

See [Contributing](https://github.com/jesse-c/PreventSleep/blob/master/CONTRIBUTING.md).
