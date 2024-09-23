import SwiftUI

public struct TestView: View {
  public init() {}
  public var body: some View {
    Text(String(localized: "Hello", bundle: .module))
      .frame(width: 100, height: 100)
  }
}

#Preview("Italian") {
  TestView()
    .environment(\.locale, .init(identifier: "it"))
}

struct TestView_Previews: PreviewProvider {
  static var previews: some View {
    TestView()
      .environment(\.locale, .init(identifier: "it"))
  }
}
