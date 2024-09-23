import SwiftUI

public struct TestView2: View {
  public init() {}
  public var body: some View {
    Text(String(localized: "loading", bundle: .module))
      .frame(width: 100, height: 100)
  }
}

#Preview("Italian") {
  TestView2()
    .environment(\.locale, Locale(identifier: "it"))
}

struct TestView_Previews: PreviewProvider {
  static var previews: some View {
    TestView2()
      .environment(\.locale, Locale(identifier: "it"))
  }
}
