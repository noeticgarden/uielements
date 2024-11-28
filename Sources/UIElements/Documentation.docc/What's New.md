# What's New

Release notes for changes to this package, by version.

## Overview

This document tracks changes to each published version of UIElements.

> Important: Until version 1.0, the API in this package is not stable and may change release to release. When it does, it will be noted below.

### UIElements 0.2

This version includes:

- A new ``Envelopment`` placement, ``Envelopment/Placement/frontOutward``, which places a view at the front of the bounds, facing outward (toward the user) rather than inward.

- A way for you to customize how the view adapts when the environment that displays an envelopment gives it zero depth. This can happen if you're executing on a 2D OS, or if you're running on visionOS and the current layout collapses the depth to zero. Check out the ``Envelopment/Adaptation`` and ``SwiftUICore/View/envelopmentZeroDepthAdaptation(_:)`` modifiers for more information.

- A new Examples app, available as part of the sources in this package. Open the Xcode project in [the Examples directory](https://github.com/noeticgarden/uielements/tree/main/Apps/Examples) to get started.

This version is source-compatible with UIElements 0.1.
