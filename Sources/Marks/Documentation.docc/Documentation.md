# ``Marks``

Displays geometric primitives at marked locations visibly during runtime.

## Overview

The Marks module contains infrastructure to mark geometric primitives in a coordinate space and make them visible at runtime. It can be used for display tasks during an app — for example, for debugging purposes during development.

The ``MarksView`` view is the main entry point in this module. Provide it a set of ``Mark``s (through a ``Marks`` collection), and update that set when relevant. The view will display the marks in its bounds, reacting to the model changing.

Marks are specified in a 3D coordinate system. On visionOS, this will place the marks in the appropriate location in space, as long as the ``MarksView`` has sufficient depth to display them. On other OSes, and if the view has depth zero on visionOS, the marks will be projected on a plane, with their Z coordinates only used for layering and sorting, but otherwise ignored.

Experimentally, this module contains modifiers that manage marks for common user interactions. See the ``ExperimentalViewMethods/marksDragGestures(coordinateSpace:amongst:)``, ``ExperimentalViewMethods/marksContinuousHover(coordinateSpace:amongst:)-8m7gu`` and ``ExperimentalViewMethods/marksSpatialEvents(coordinateSpace:amongst:)`` modifiers to get started.

> Important: Modifiers in the ``ExperimentalViewMethods`` type are experimental, and their API is marked as subject to change or be replaced.


## Topics

### Displaying Marks

- ``MarksView``
- ``Mark``
- ``Marks``
- ``IdentifiedMark``

### Experimental API

- ``ExperimentalViewMethods``
- ``SwiftUICore/View/experimental``
- ``ExperimentalViewMethods/marksDragGestures(coordinateSpace:amongst:)``
- ``ExperimentalViewMethods/marksContinuousHover(coordinateSpace:amongst:)-8m7gu``
- ``ExperimentalViewMethods/marksSpatialEvents(coordinateSpace:amongst:)``

