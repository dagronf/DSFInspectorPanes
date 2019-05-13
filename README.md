# Mimic the inspector panels in Apple's Pages

![](https://dagronf.github.io/art/projects/DSFPropertyPanes/full.gif)

![](https://dagronf.github.io/art/projects/DSFPropertyPanes/panel_simple.gif)

## Features

* Basic inspector pane. Show and hide panes
* Optional supply a view as a header view
* Optional automatic scroll view support
* Optional animation

## Why?

I've fought with this on a number of projects. I finally decided to make a drop-in class that would do everything that I wanted.  This class is fully autolayout managed.

I really like Apple 'Pages' implementation which allows having a header view which can be used to configure items even when the pane itself is hidden.  A good example of this is the 'Spacing' inspector pane, where when the pane is hidden the user can still change the line spacing at a lower granularity.

## Usage

### Installation

#### Direct

* Copy `DSFInspectorPanesView.swift` to your project

#### CocoaPods

Add the following to your `Podfiles` file

* `pod 'DSFInspectorPanes', :git => 'https://github.com/dagronf/DSFInspectorPanes'`

### API

1. Create an instance of `DSFInspectorPanesView` and add it to a view, or
2. Use Interface Builder to add a custom view, and change the class to `DSFInspectorPanesView`

The API is very simple

#### Properties

* `animated`: Animate the expanding/hiding of the panes
* `usesScrollView`: Embed the panes view in a scroll view
* `titleFont`: Set the font to use for the title for the panes

#### Methods

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
@IBOutlet weak var propertyPanes: DSFInspectorPanesView!

@IBOutlet weak var freeTextView: NSView!
@IBOutlet weak var freeTextHeaderView: NSView!
	
func setupPanes {
   propertyPanes.add(
      title: "Description", 
      view: self.freeTextView,
      headerAccessoryView: freeTextHeaderView,
      expanded: true)
}
```


## License

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
