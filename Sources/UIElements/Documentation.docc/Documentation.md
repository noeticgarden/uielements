# ``UIElements``

The UIElements package contains additions to SwiftUI that are meant to be generally useful.

## Overview

This package currently contains the ``Envelopment`` and ``Concentric`` containers. It is meant to eventually contain other elements, such as additional 3D-aware containers, debug visualizers, RealityKit integrations, and more.

All types in this package support all Apple OSes that have SwiftUI. Currently, it requires Fall 2022 Apple OS releases or later, including at least:

- macOS 13
- iOS 16
- tvOS 16
- watchOS 11
- visionOS 1

> Note: This package will compile correctly outside of these platform, but exposes no API surface unless the SwiftUI module is available.

## Topics

- <doc:What's-New>

### Envelopments

- ``Envelopment``
- ``Envelopment/Placement``
- ``Envelopment/State``
- ``EnvelopmentFace``
- ``Envelopment/Adaptation``
- ``SwiftUICore/View/envelopmentZeroDepthAdaptation(_:)``

### Concentric Placement
- ``Concentric``
