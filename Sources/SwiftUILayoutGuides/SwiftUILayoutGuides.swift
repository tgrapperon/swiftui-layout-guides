import SwiftUI

/// This view populates its content's ``layoutMarginsInsets`` and ``readableContentInsets``.
public struct WithLayoutMargins<Content>: View where Content: View {
  let content: (EdgeInsets) -> Content

  public init(@ViewBuilder content: @escaping (EdgeInsets) -> Content) {
    self.content = content
  }

  public init(@ViewBuilder content: @escaping () -> Content) {
    self.content = { _ in content() }
  }

  public var body: some View {
    InsetContent(content: content)
      .measureLayoutMargins()
  }

  private struct InsetContent: View {
    let content: (EdgeInsets) -> Content
    @Environment(\.layoutMarginsInsets) var layoutMarginsInsets
    var body: some View {
      content(layoutMarginsInsets)
    }
  }
}

/// This view makes its content `View` fit the readable content width.
///
/// - Note: This modifier is equivalent to calling ``.fitToReadableContentWidth()`` on the content view.
public struct FitReadableContentWidth<Content>: View where Content: View {
  let alignment: Alignment
  let content: Content
  
  public init(alignment: Alignment = .center, @ViewBuilder content: () -> Content) {
    self.alignment = alignment
    self.content = content()
  }

  public var body: some View {
    InsetContent(alignment: alignment, content: content)
      .measureLayoutMargins()
  }

  private struct InsetContent: View {
    let alignment: Alignment
    let content: Content
    @Environment(\.readableContentInsets) var readableContentInsets
    var body: some View {
      content
        .frame(maxWidth: .infinity, alignment: alignment)
        .padding(.leading, readableContentInsets.leading)
        .padding(.trailing, readableContentInsets.trailing)
    }
  }
}

public extension View {
  /// Use this modifier to make the view fit the readable content width.
  ///
  /// - Note: You don't have to wrap this view inside a ``WithLayoutMargins`` view.
  /// - Note: This modifier is equivalent to wrapping the view inside a ``FitReadableContentWidth`` view.
  func fitToReadableContentWidth(alignment: Alignment = .center) -> some View {
    FitReadableContentWidth(alignment: alignment) { self }
  }
  
  /// Use this modifier to populate the ``layoutMarginsInsets`` and ``readableContentInsets`` for the target view.
  ///
  /// - Note: You don't have to wrap this view inside a ``WithLayoutMargins`` view.
  func measureLayoutMargins() -> some View {
    modifier(LayoutGuidesModifier())
  }
}

private struct LayoutMarginsGuidesKey: EnvironmentKey {
  static var defaultValue: EdgeInsets { .init() }
}

private struct ReadableContentGuidesKey: EnvironmentKey {
  static var defaultValue: EdgeInsets { .init() }
}

public extension EnvironmentValues {
  /// The `EdgeInsets` corresponding to the layout margins of the nearest ``WithLayoutMargins``'s content.
  var layoutMarginsInsets: EdgeInsets {
    get { self[LayoutMarginsGuidesKey.self] }
    set { self[LayoutMarginsGuidesKey.self] = newValue }
  }

  /// The `EdgeInsets` corresponding to the readable content of the nearest ``WithLayoutMargins``'s content.
  var readableContentInsets: EdgeInsets {
    get { self[ReadableContentGuidesKey.self] }
    set { self[ReadableContentGuidesKey.self] = newValue }
  }
}

struct LayoutGuidesModifier: ViewModifier {
  @State var layoutMarginsInsets: EdgeInsets = .init()
  @State var readableContentInsets: EdgeInsets = .init()

  func body(content: Content) -> some View {
    content
    #if os(iOS) || os(tvOS)
      .environment(\.layoutMarginsInsets, layoutMarginsInsets)
      .environment(\.readableContentInsets, readableContentInsets)
      .background(
        LayoutGuides(onLayoutMarginsGuideChange: {
          layoutMarginsInsets = $0
        }, onReadableContentGuideChange: {
          readableContentInsets = $0
        })
      )
    #endif
  }
}

#if os(iOS) || os(tvOS)
  import UIKit
  struct LayoutGuides: UIViewRepresentable {
    let onLayoutMarginsGuideChange: (EdgeInsets) -> Void
    let onReadableContentGuideChange: (EdgeInsets) -> Void

    func makeUIView(context: Context) -> LayoutGuidesView {
      let uiView = LayoutGuidesView()
      uiView.onLayoutMarginsGuideChange = onLayoutMarginsGuideChange
      uiView.onReadableContentGuideChange = onReadableContentGuideChange
      return uiView
    }

    func updateUIView(_ uiView: LayoutGuidesView, context: Context) {
      uiView.onLayoutMarginsGuideChange = onLayoutMarginsGuideChange
      uiView.onReadableContentGuideChange = onReadableContentGuideChange
    }

    final class LayoutGuidesView: UIView {
      var onLayoutMarginsGuideChange: (EdgeInsets) -> Void = { _ in }
      var onReadableContentGuideChange: (EdgeInsets) -> Void = { _ in }

      override func layoutMarginsDidChange() {
        super.layoutMarginsDidChange()
        updateLayoutMargins()
        updateReadableContent()
      }

      override func layoutSubviews() {
        super.layoutSubviews()
        updateReadableContent()
      }
      
      override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.layoutDirection != previousTraitCollection?.layoutDirection {
          updateReadableContent()
        }
      }

      var previousLayoutMargins: EdgeInsets? = nil
      func updateLayoutMargins() {
        let edgeInsets = EdgeInsets(
          top: directionalLayoutMargins.top,
          leading: directionalLayoutMargins.leading,
          bottom: directionalLayoutMargins.bottom,
          trailing: directionalLayoutMargins.trailing
        )
        guard previousLayoutMargins != edgeInsets else { return }
        onLayoutMarginsGuideChange(edgeInsets)
        previousLayoutMargins = edgeInsets
      }

      var previousReadableContentGuide: EdgeInsets? = nil
      func updateReadableContent() {
        let isRightToLeft = traitCollection.layoutDirection == .rightToLeft
        let layoutFrame = readableContentGuide.layoutFrame

        let readableContentInsets =
          UIEdgeInsets(
            top: layoutFrame.minY - bounds.minY,
            left: layoutFrame.minX - bounds.minX,
            bottom: -(layoutFrame.maxY - bounds.maxY),
            right: -(layoutFrame.maxX - bounds.maxX)
          )
        let edgeInsets = EdgeInsets(
          top: readableContentInsets.top,
          leading: isRightToLeft ? readableContentInsets.right : readableContentInsets.left,
          bottom: readableContentInsets.bottom,
          trailing: isRightToLeft ? readableContentInsets.left : readableContentInsets.right
        )
        guard previousReadableContentGuide != edgeInsets else { return }
        onReadableContentGuideChange(edgeInsets)
        previousReadableContentGuide = edgeInsets
      }
    }
  }
#endif

#if DEBUG
struct Cell: View {
  var value: String
  var body: some View {
    ZStack {
      Text(value)
        .frame(maxWidth: .infinity)
    }
    .background(Color.blue.opacity(0.3))
    .border(Color.blue) // This view fits in readable content width
    .fitToReadableContentWidth()
    .border(Color.red) // This view is unconstrained
  }
}

struct ListTest: View {
  var body: some View {
    List {
      ForEach(0 ..< 30) {
        Cell(value: "\($0)")
      }
    }
  }
}

struct ScrollViewTest: View {
  var body: some View {
    ScrollView {
      VStack(spacing: 0) {
        ForEach(0 ..< 30) {
          Cell(value: "\($0)")
        }
      }
    }
  }
}

struct SwiftUILayoutGuides_Previews: PreviewProvider {
  static func sample<Content>(_ title: String, _ content: () -> Content) -> some View
  where Content: View {
    VStack(alignment: .leading) {
      Text(title)
        .font(Font.system(size: 20, weight: .bold))
        .padding()
      content()
    }
    .border(Color.primary, width: 2)
  }
  
  static var previews: some View {
    VStack(spacing: 0) {
      sample("ScrollView") { ScrollViewTest() }
      sample("List.plain") { ListTest().listStyle(.plain) }
      #if os(iOS) || os(tvOS)
      sample("List.grouped") { ListTest().listStyle(.grouped) }
      if #available(iOS 14.0, *) {
      sample("List.insetGrouped") { ListTest().listStyle(.insetGrouped) }
      }
      #endif
    }
   .previewDevice("iPad Pro (11-inch) (3rd generation)")
  }
}
#endif
