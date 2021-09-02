# SwiftUI Layout Guides
This micro-library exposes UIKit's layout margins and readable content guides to SwiftUI.
 
## Usage
### Make a view fit the readable content width
Simply call the `fitToReadableContentWidth()` modifier:
```swift
List {
 ForEach(…) {
   Cell()
     .fitToReadableContentWidth()
 }
}
```
### Expose the layout margins in a block
Wrap your view in the `WithLayoutMargins` view. The initializer supports two variants: one closure without argument and one closure with a `EdgeInsets` argument. In this last case, the insets correspond to the layout margins for the content:
```swift
WithLayoutMargins { layoutMarginsInsets in
 Text("ABC")
   .padding(.leading, layoutMarginsInsets.leading) 
}
```
### Expose layout margins and readable content guides in a view
You need two wrap your view in `WithLayoutMargins` (you can use the argument-less closure). This will populate the content's `Environment` with the layout margins and readable content in the form of insets. 
```swift
WithLayoutMargins {
 Content()
}

struct Content: View {
  @Environment(\.layoutMarginsInsets) var layoutMarginsInsets
  @Environment(\.readableContentInsets) var readableContentInsets
  var body: some View {
    Text("ABC")
      .padding(.leading, layoutMarginsInsets.leading)
      …
  }
}
```
These insets are only valid for the bounds of the root content view. Using them deeper in the hierachy may lead to insconsitent results.

## Installation
Add `.package(url: "https://github.com/tgrapperon/swiftui-layout-guides", from: "0.0.1")` to your Package dependencies, and then 
```
.product(name: "SwiftUILayoutGuides", package: "swiftui-layout-guides")
```
to your target's dependencies.

