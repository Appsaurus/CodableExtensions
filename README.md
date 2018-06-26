# CodableExtensions
![Swift](http://img.shields.io/badge/swift-4.1-orange.svg)
[![Swift Package Manager](https://img.shields.io/badge/SPM-compatible-4BC51D.svg?style=flat)](https://swift.org/package-manager/)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-blue.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
![License](http://img.shields.io/badge/license-MIT-CCCCCC.svg)

## Installation

**CodableExtensions** is available through [Swift Package Manager](https://swift.org/package-manager/). To install, simply add the following line to the dependencies in your Package.swift file.

```swift
let package = Package(
    name: "YourProject",
    dependencies: [
        ...
        .package(url: "https://github.com/Appsaurus/CodableExtensions", from: "1.0.0"),
    ],
    targets: [
      .testTarget(name: "YourApp", dependencies: ["CodableExtensions", ... ])
    ]
)
        
```

**CodableExtensions** is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'CodableExtensions', :git => "https://github.com/Appsaurus/CodableExtensions"
```

**CodableExtensions** is also available through [Carthage](https://github.com/Carthage/Carthage).
To install just write into your Cartfile:

```ruby
github "Appsaurus/CodableExtensions"
```

## Usage
Examples coming soon.

## Contributing

We would love you to contribute to **CodableExtensions**, check the [CONTRIBUTING](github.com/Appsaurus/CodableExtensions/blob/master/CONTRIBUTING.md) file for more info.

## License

**CodableExtensions** is available under the MIT license. See the [LICENSE](github.com/Appsaurus/CodableExtensions/blob/master/LICENSE.md) file for more info.
