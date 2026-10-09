import SwiftUI

struct TabItem: View {
  var title: String?
  var icon: PlatformImage?
  var sfSymbol: String?
  var labeled: Bool?
  var iconRenderingMode: String?
  var iconPreservesOriginalColors: Bool = false
  var isFocused: Bool = false
  var inactiveTintColor: PlatformColor?

  var body: some View {
    if let icon {
#if os(macOS)
      Image(nsImage: icon)
#else
      Image(uiImage: renderedIcon(icon))
#endif
    } else if let sfSymbol, !sfSymbol.isEmpty {
      Image(systemName: sfSymbol)
        .noneSymbolVariant()
    }
    if labeled != false {
      Text(title ?? "")
    }
  }

#if !os(macOS)
  private var preservesOriginalIconColors: Bool {
    iconRenderingMode == "original"
  }

  private func renderedIcon(_ icon: UIImage) -> UIImage {
    if iconPreservesOriginalColors {
      if isFocused {
        return icon.withRenderingMode(.alwaysOriginal)
      }
      if let inactiveTintColor {
        return icon.withTintColor(inactiveTintColor, renderingMode: .alwaysOriginal)
      }
      return icon.withRenderingMode(.alwaysTemplate)
    }
    return preservesOriginalIconColors ? icon.withRenderingMode(.alwaysOriginal) : icon
  }
#endif
}
