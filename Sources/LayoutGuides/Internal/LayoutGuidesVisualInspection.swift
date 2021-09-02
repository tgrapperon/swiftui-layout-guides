#if DEBUG
import SwiftUI

struct Cell: View {
  var value: String
  var body: some View {
    ZStack {
      Text(value)
        .frame(maxWidth: .infinity)
    }
    .background(Color.blue.opacity(0.3))
    .border(Color.blue)
    .fitToReadableContentWidth()
  }
}

struct ListTest: View {
  var body: some View {
    List {
      ForEach(0 ..< 100) {
        Cell(value: "\($0)")
      }
    }
  }
}

struct ScrollViewTest: View {
  var body: some View {
    ScrollView {
      VStack(spacing: 0) {
        ForEach(0 ..< 100) {
          Cell(value: "\($0)")
        }
      }
    }
  }
}

struct LayoutGuides_Previews: PreviewProvider {
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
      sample("List.grouped") { ListTest().listStyle(.grouped) }
      if #available(iOS 14.0, *) {
      sample("List.insetGrouped") { ListTest().listStyle(.insetGrouped) }
      }
    }
   .previewDevice("iPad Pro (11-inch) (3rd generation)")
  }
}
#endif
