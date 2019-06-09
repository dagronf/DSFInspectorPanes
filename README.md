# Mimic the inspector panels in Apple's Pages

![](https://dagronf.github.io/art/projects/DSFPropertyPanes/full.gif) ![](https://dagronf.github.io/art/projects/DSFPropertyPanes/panel_simple.gif)

## Features

* Basic inspector pane. Show and hide panes
* Configurable from interface builder as inspectables
* Optional supply a view as a header view
* Optional automatic scroll view support
* Optional animation
* Optional separators or bounding boxes
* Show or hide individual panes
* Expand or contract individual panes

## Why?

I've fought with this on a number of projects. I finally decided to make a drop-in class that would do everything that I wanted.  This class is fully autolayout managed.

I really like Apple 'Pages' implementation which allows having a header view which can be used to configure items even when the pane itself is hidden.  A good example of this is the 'Spacing' inspector pane, where when the pane is hidden the user can still change the line spacing at a lower granularity.

## Installation

### Direct

Copy the swift files from the `DSFInspectorPanes` subfolder to your project

### CocoaPods

Add the following to your `Podfiles` file

```ruby
pod 'DSFInspectorPanes', :git => 'https://github.com/dagronf/DSFInspectorPanes'
```

## API

### Create

1. Create an instance of `DSFInspectorPanesView` and add it to a view, or
2. Use Interface Builder to add a custom view, and change the class to `DSFInspectorPanesView`

### Properties

* `animated`: Animate the expanding/hiding of the panes
* `usesScrollView`: Embed the panes view in a scroll view
* `showSeparators`: Insert a separator between each pane
* `titleFont`: Set the font to use for the title for the panes
* `spacing`: Set the vertical spacing between each pane

### Methods

#### Add

Add a new inspector pane to the container

```swift
@objc public func add(
   title: String,                        // The title of the pane
   view: NSView,                         // The property pane to display
   headerAccessoryView: NSView? = nil,   // If the pane has a header view, the view
   canHide: Bool = true,                 // Can the pane be expanded/hidden?
   expanded: Bool = true                 // Is the property pane hidden by default?
```

Example :-

```swift
var propertyPanes = DSFInspectorPanesView(frame: .zero,
                                          animated: true,
                                          embeddedInScrollView: false,
                                          titleFont: NSFont.systemFont(ofSize: 13))

var inspectorView = NSView()       // <--- your inspector pane view
var inspectorHeaderView = NSView()  // <--- your inspector pane header view
	
propertyPanes.add(
   title: "My inspector Pane", 
   view: inspectorView,
   headerAccessoryView: inspectorHeaderView,
   expanded: true)
}
```

### Pane access

You can access the panes using the `panes` variable on the class which returns the panes as an array of `DSFInspectorPaneProtocol`

#### Expand an existing pane

```swift
var propertyPanes = DSFInspectorPanesView()
...
func expandFirstPane(shouldExpand: Bool) {
	propertyPanes.panes[1].expanded = shouldExpand
}
```

#### Show or hide a pane

```swift
var propertyPanes = DSFInspectorPanesView()
...
func hideFirstPane(shouldHide: Bool) {
	propertyPanes.panes[1].hide = shouldHide
}
```

## Thanks

### RSVerticallyCenteredTextFieldCell
* Red Sweater Software, LLC for [RSVerticallyCenteredTextFieldCell](http://www.red-sweater.com/blog/148/what-a-difference-a-cell-makes) component  — [License](http://opensource.org/licenses/mit-license.php)


## License
```
MIT License

Copyright (c) 2019 Darren Ford

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
