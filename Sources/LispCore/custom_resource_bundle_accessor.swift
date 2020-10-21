//
//  custom_resource_bundle_accessor.swift
//  LispMac
//
//  Created by Roman Podymov on 10/21/20.
//  Copyright © 2020 Roman Podymov. All rights reserved.
//

import Foundation

#if SWIFT_PACKAGE
#else
private class BundleFinder {}

extension Foundation.Bundle {
    /// Returns the resource bundle associated with the current Swift module.
    static var module: Bundle = {
        let bundleName = "LispCore_LispCore"

        let candidates = [
            // Bundle should be present here when the package is linked into an App.
            Bundle.main.resourceURL,

            // Bundle should be present here when the package is linked into a framework.
            Bundle(for: BundleFinder.self).resourceURL,

            // For command-line tools.
            Bundle.main.bundleURL,
        ]

        for candidate in candidates {
            let bundlePath = candidate?.appendingPathComponent(bundleName + ".bundle")
            if let bundle = bundlePath.flatMap(Bundle.init(url:)) {
                return bundle
            }
        }
        fatalError("unable to find bundle named LispCore_LispCore")
    }()
}
#endif
