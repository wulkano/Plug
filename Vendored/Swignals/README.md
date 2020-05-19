# Swignals

Swignals is an observable pattern system written entirely in Swift.

[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/Swignals.svg)](https://img.shields.io/cocoapods/v/Swignals.svg)
[![Platform](https://img.shields.io/cocoapods/p/Swignals.svg?style=flat)](http://cocoadocs.org/docsets/Swignals)

## Installing

You can either drag all the files from the Source folder into your project, or install it using CocoaPods.

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```
> CocoaPods 0.39.0+ is required to build Swignals.

To integrate Swignals into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'
use_frameworks!

target '<Your Target Name>' do
    pod 'Swignals', '~> 1.0'
end
```

Then, run the following command:

```bash
$ pod install
```

## Example

Lets say we wanted to add a swignal to an AudioPlayer class whenever shuffle is set. It could look something like this:

```swift
typealias OnShuffleChangedSwignal = Swignal1Arg<Bool>

class AudioPlayer {
    static let sharedInstance = AudioPlayer()

    let onShuffleChanged = OnShuffleChangedSwignal()
    var shuffle: Bool = false {
        didSet {
            onShuffleChanged.fire(shuffle)
        }
    }
}
```

Then to subscribe to that signal you'd do the following:

```swift
class ControlsViewController: UIViewController {
    init() {
        AudioPlayer.sharedInstance.onShuffleChanged.addObserver(self) { (observer, arg1) in
        // note: you can rename the variables in the callback such as
        // callback: { (weakSelf, shuffle) in
            if let favoriteTracksDataSource = observer.tracksDataSource as? FavoriteTracksDataSource {
                favoriteTracksDataSource.shuffle = arg1
                favoriteTracksDataSource.refresh()
            }
        }
    }

    func updateViewBasedOnShuffle(shuffle: Bool) {
        // do important things
    }
}
```

## Authors

* **[Joseph Neuman](https://twitter.com/finder39)** - *Initial work*

## Acknowledgements

* This is based on [Uber's Signals library](https://github.com/uber/signals-ios) which was written by [Tuomas Artman](https://github.com/artman)

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details
