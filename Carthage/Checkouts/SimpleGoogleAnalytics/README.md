# SimpleGoogleAnalytics

SimpleGoogleAnalytics is fairly simple way to use Google Analytics on OSX. We use it for the new version of [Plug](http://www.plugformac.com).

Thanks to Coppertio's [AnalyticEverything](https://github.com/Coppertino/AnalyticEverything) for most of the system profiling code.

## Usage


### Setup

```swift
let tracker = SimpleGoogleAnalytics.Manager(trackingID: "UA-XXXXXXXX-X", appBundle: NSBundle.mainBundle(), userID: nil)
```

### Pageviews

```swift
tracker.trackPageview("Main Window")
```

### Events

```swift
tracker.trackEvent(category: "Button", action: "Click", label: "Sign In", value: nil)
```

### Exceptions

```swift
tracker.trackException(description: "Exception", fatal: true)
```

## Installation

### Carthage

```ogdl
github "PlugForMac/SimpleGoogleAnalytics" ~> VERSION_NUMBER
```

### CocoaPods

Please create an issue if you'd like CocoaPods support.
