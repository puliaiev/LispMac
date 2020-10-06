# LispMac
Common Lisp interpreter for macOS and iOS.

### Adding library using Swift Package Manager

The [Swift Package Manager][] is a tool for managing the distribution of
Swift code.

1. Add the following to your `Package.swift` file:

  ```swift
  dependencies: [
      .package(url: "https://github.com/puliaiev/LispMac.git", .branch("master")),
  ]
  ```

2. Build your project:

  ```sh
  $ swift build
  ```

[Swift Package Manager]: https://swift.org/package-manager

### Xcode

Xcode 11 and up directly supports adding packages from File > Swift Packages > Add Package Dependency.

## Building Library

```sh
xcrun swift build
```

## Testing

```sh
xcrun swift test
```

## Playground

Open `Playground/LispPlayground.xcworkspace` in Xcode
