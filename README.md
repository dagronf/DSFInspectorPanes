# Inspector Panes for macOS

![](https://dagronf.github.io/art/projects/DSFPropertyPanes/screenshot.jpg)

![](https://img.shields.io/github/v/tag/dagronf/DSFInspectorPanes)
![](https://img.shields.io/badge/macOS-10.13+-red)

![](https://img.shields.io/badge/License-MIT-lightgrey) 
[![](https://img.shields.io/badge/pod-compatible-informational)](https://cocoapods.org) 
[![](https://img.shields.io/badge/spm-compatible-brightgreen.svg?style=flat)](https://swift.org/package-manager)

A Cocoa, auto-layout managed view to build and manage inspector panes equivalent to the inspectors in Apple's Pages and Numbers applications.

## Why?

I've implemented and fought with this on a number of different projects and decided to make a drop-in class that would do everything that I wanted. This class is fully autolayout managed.

I really like Apple 'Pages' implementation which allows having a header view which can be used to configure items even when the pane itself is hidden.  A good example of this is the 'Spacing' inspector pane, where when the pane is hidden the user can still change the line spacing at a lower granularity.

| Expanded | Contracted |
|-----|-----|
| ![](https://dagronf.github.io/art/projects/DSFPropertyPanes/pane_expanded.png) | ![](https://dagronf.github.io/art/projects/DSFPropertyPanes/pane_contracted.png) |

## Features

* Show and hide panes
* Configurable from interface builder as inspectables
* Optional supply a view as a header view, and set its visibility (always show, show when collapsed)
* Optional automatic scroll view support
* Optional animation
* Optional separators or bounding boxes
* Optional drag/drop reordering of panes
* Show or hide individual panes without removing them
* Expand or contract individual panes

# Installation

## Direct

Copy the swift files from the `DSFInspectorPanes` subfolder to your project

## CocoaPods

Add the following to your `Podfiles` file

```ruby
pod 'DSFInspectorPanes', :git => 'https://github.com/dagronf/DSFInspectorPanes'
```

# API

## Create

1. Create an instance of `DSFInspectorPanesView` and add it to a view, or
2. Use Interface Builder to add a custom view, and change the class to `DSFInspectorPanesView`

## Properties

* `animated` : Animate the expanding/hiding of the panes
* `embeddedInScrollView` : Embed the panes view in a scroll view
* `showSeparators` : Insert a separator between each pane (optional)
* `showBoxes` : Show a box around each inspector pane (optional)
* `titleFont` : Specify a custom font to use for the title for the panes
* `spacing` : Set the vertical spacing between each pane
* `canDragRearrange` : Allow the user to change the ordering of the panes via drag/drop or touchbar

## Methods

### Add an inspector pane

Add a new inspector pane to the container

```swift
var propertyPanes = DSFInspectorPanesView(
   frame: .zero,
   animated: true,
   embeddedInScrollView: false,
   titleFont: NSFont.systemFont(ofSize: 13)
)

var inspectorView = NSView()        // <--- your inspector pane view
var inspectorHeaderView = NSView()  // <--- your inspector pane header view
	
propertyPanes.addPane(
   title: "My inspector Pane", 
   view: inspectorView,
   headerAccessoryView: inspectorHeaderView,
   expansionType: .expanded)
}
```

## Expand an existing pane

```swift
var propertyPanes = DSFInspectorPanesView()
…
propertyPanes.panes[0].expanded = true
propertyPanes.panes[1].expanded = false
```
## Show or hide a pane

```swift
var propertyPanes = DSFInspectorPanesView()
…
propertyPanes.panes[0].isHidden = true
propertyPanes.panes[1].isHidden = false
```

## Reordering and moving

Move the property pane at index 0 to index 4

```swift
propertyPanes.move(index: 0, to: 4)
```

Swap property panes at index 0 and index 4

```swift
propertyPanes.swap(index: 0, with: 4)
```

## Removing
Remove the pane at index 1

```swift
propertyPanes.remove(at: 1)
```

Remove all panes

```swift
propertyPanes.removeAll()
```

# Thanks

### RSVerticallyCenteredTextFieldCell - Red Sweater Software
* Red Sweater Software, LLC for [RSVerticallyCenteredTextFieldCell](http://www.red-sweater.com/blog/148/what-a-difference-a-cell-makes) component  — [License](http://opensource.org/licenses/mit-license.php)

### DraggableStackView - Mark Onyschuk
* Mark Onyschuk on [GitHub](https://github.com/monyschuk) -- [Draggable Stack View](https://gist.github.com/monyschuk/cbca3582b6b996ab54c32e2d7eceaf25)

# Screenshots

[(Movie) Drag Drop Reordering](https://dagronf.github.io/art/projects/DSFPropertyPanes/drag_drop_reorder.mp4)

## Interface Builder integration

![](https://dagronf.github.io/art/projects/DSFPropertyPanes/inspector_pane_ibdesignable.jpg) 

## Pane modes

Showing the ability to display a secondary UI element for when the pane is contracted

![](https://dagronf.github.io/art/projects/DSFPropertyPanes/expand_contract.gif) 
  
# License
```
MIT License

Copyright (c) 2024 Darren Ford

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
