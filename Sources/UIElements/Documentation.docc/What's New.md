# What's New

Release notes for changes to this package, by version.

## Overview

This document tracks changes to each published version of UIElements.

> Important: Until version 1.0, the API in this package is not stable and may change release to release. When it does, it will be noted below.

### UIElements 0.3

This version of UIElements introduces two advances:

- The Marks module provides a way to mark elements in a bounds region through its `MarksView` class. This initial release provides the ability to mark points, but the intent is to introduce other elements such as rectangles, vectors and 3D regions.

The Marks module has its own documentation.

- The ``Vector`` type allows you to work with vectors component by component. This allows you to scale sizes, add offsets, and convert `CGPoint`s into `Point3D`s without duplicating code:

```swift
let cgPoint = CGPoint(…)
let point = Point3D(componentsOf: cgPoint, missing: 0)
let offset = Size3D(…)

let pointWithOffset = Point3D {
    point[$0] + offset[matching: $0]
}
```

### UIElements 0.2.3

In this version:

- The ``Concentric`` container now has an ideal size equal to the maximum size of its subviews.

- The ``SwiftUICore/View/surround(_:)`` modifier acts as an '`overlay3D`' of sorts, allowing you to tightly surround a view with another that will have the same bounds. Unlike a notional '`overlay3D`', surrounding works in all view hierarchies, including 2D ones.

Prior to this version, the ``Concentric`` container acted as if its `maxWidth`, `maxHeight` and `maxDepth` were set to `.infinity`; this is no longer true, and if you want to preserve this, you may need to use the [`frame`](https://developer.apple.com/documentation/swiftui/view/frame(minwidth:idealwidth:maxwidth:minheight:idealheight:maxheight:alignment:)) family of modifiers to set these values manually.


#### Features from 0.2 and later:

You also get all other new features from UIElements 0.2 and later:

- A new ``Envelopment`` placement, ``Envelopment/Placement/frontOutward``, which places a view at the front of the bounds, facing outward (toward the user) rather than inward.

- A way for you to customize how the view adapts when the environment that displays an envelopment gives it zero depth. This can happen if you're executing on a 2D OS, or if you're running on visionOS and the current layout collapses the depth to zero. Check out the ``Envelopment/Adaptation`` and ``SwiftUICore/View/envelopmentZeroDepthAdaptation(_:)`` modifiers for more information.

- A new Examples app, available as part of the sources in this package. Open the Xcode project in [the Examples directory](https://github.com/noeticgarden/uielements/tree/main/Apps/Examples) to get started.

This version is source-compatible with UIElements 0.1.
