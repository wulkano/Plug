# Plug 2

## Hype Machine API Codes

Our Hype Machine API codes are embedded in the source. If those codes get out it will very much jeopardize our relationship with Hype Machine. Please be careful with this source. Please do not publish it openly or attempt to create you own forks of Plug.

## Dev Setup

```sh
# Get the code
git clone git@github.com:PlugForMac/Plug2.git
cd Plug2

# Install CocoaPods (make sure you have CocoaPods installed on you machine https://cocoapods.org/)
pod install

# Install Carthage packages (make sure you have Carthage installed on your machine https://github.com/Carthage/Carthage)
carthage build
```

You should be set up. Open Plug.xcworkspace to get started.

## Contributing

Please create a pull request for any code you'd like merged into the master branch. If its a large change or a change to the UI please make talk to Alex/Glenn first (Slack probably).

Alex will need to sign, version, and publish new releases.