import Foundation

enum MessagingPlacementKind: String {
  case autoSize = "CreditPromotionAutoSize"
  case badge = "CreditPromotionBadge"

  init(wire: String?) {
    self = MessagingPlacementKind(rawValue: wire ?? "") ?? .autoSize
  }
}

enum MessagingThemeKind: String {
  case light
  case dark
  case automatic

  init?(wire: String?) {
    guard let wire, let value = MessagingThemeKind(rawValue: wire) else { return nil }
    self = value
  }
}

enum KlarnaMessagingParsing {
  static func parseAmount(_ value: String?) -> Int? {
    guard let value, !value.isEmpty, let parsed = Int(value) else { return nil }
    return parsed
  }

  static func resolvePlacementKind(_ value: String?) -> MessagingPlacementKind {
    MessagingPlacementKind(wire: value)
  }

  static func resolveThemeKind(_ value: String?) -> MessagingThemeKind? {
    MessagingThemeKind(wire: value)
  }
}
