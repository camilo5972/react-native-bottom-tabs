import SwiftUI

#if !os(macOS)
private extension UIImage {
  /// Returns a flat, single-color silhouette of the receiver tinted with
  /// `color`. We use `withTintColor(_:renderingMode:)` (iOS 13+) instead of
  /// drawing the template manually because the latter occasionally fails to
  /// pick up the fill color when the source UIImage carries multicolor
  /// content (e.g. an icon configured with `iconPreservesOriginalColors`).
  func tinted(with color: UIColor) -> UIImage {
    let template = withRenderingMode(.alwaysTemplate)
    if #available(iOS 13.0, tvOS 13.0, *) {
      return template.withTintColor(color, renderingMode: .alwaysOriginal)
    }
    let renderer = UIGraphicsImageRenderer(size: size)
    return renderer.image { _ in
      color.set()
      template.draw(in: CGRect(origin: .zero, size: size))
    }.withRenderingMode(.alwaysOriginal)
  }
}
#endif

struct TabItem: View {
  var title: String?
  var icon: PlatformImage?
  var sfSymbol: String?
  var labeled: Bool?
  var preservesOriginalIconColors: Bool = false
  var isFocused: Bool = false
  var inactiveTintColor: PlatformColor? = nil

  var body: some View {
    if let icon {
#if os(macOS)
      Image(nsImage: icon)
#else
      // Resolve the UIImage we hand to SwiftUI.
      //
      // The iOS 18+ SwiftUI TabView (Liquid Glass) ignores
      // UITabBar.unselectedItemTintColor, so when an inactiveTintColor
      // is provided we pre-tint the icon and hand it over as
      // .alwaysOriginal to prevent the system from overriding it.
      //
      // preservesOriginalIconColors controls how the *focused* icon is
      // rendered: when true the original multicolor artwork is shown;
      // otherwise the icon is rendered as a template so the active tint
      // color applies.
      let resolved: UIImage = {
        if isFocused {
          return preservesOriginalIconColors
            ? icon.withRenderingMode(.alwaysOriginal)
            : icon.withRenderingMode(.alwaysTemplate)
        }
        if let inactiveTintColor {
          return icon.tinted(with: inactiveTintColor)
        }
        return icon.withRenderingMode(.alwaysTemplate)
      }()
      Image(uiImage: resolved)
#endif
    } else if let sfSymbol, !sfSymbol.isEmpty {
      Image(systemName: sfSymbol)
        .noneSymbolVariant()
    }
    if labeled != false {
      Text(title ?? "")
    }
  }
}
