# SimpleGoogleAnalytics

SimpleGoogleAnalytics is fairly simple way to use Google Analytics on OSX. We use it for the new version of [Plug](http://www.plugformac.com).

Thanks to Coppertio's [AnalyticEverything](https://github.com/Coppertino/AnalyticEverything) for most of the system profiling code.

## Usage

```swift
var analytics = SimpleGoogleAnalytics(trackingID: "UA-XXXXXXXX-X")

// Track page view
analytics.trackPageview("Main Window")

// Track button click (or any other event)
analytics.trackEvent(category: "Button", action: "Click", label: "Sign In", value: nil)
```

## Installation

### Carthage

Carthage is a decentralized dependency manager that automates the process of adding frameworks to your Cocoa application.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate SimpleGoogleAnalytics into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "PlugForMac/SimpleGoogleAnalytics" ~> 0.1.0
```

### CocoaPods

Please create an issue if you'd like CocoaPods support.
