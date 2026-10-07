import Flutter
import KlarnaCore
import KlarnaNetworkCore
import KlarnaNetworkPayment
import KlarnaNetworkPaymentButton
import UIKit
@_spi(FlutterKlarnaNetworkCore) import klarna_network_core

class KlarnaPaymentButtonFactory: NSObject, FlutterPlatformViewFactory {
  private let messenger: FlutterBinaryMessenger

  init(messenger: FlutterBinaryMessenger) {
    self.messenger = messenger
    super.init()
  }

  func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
    FlutterStandardMessageCodec.sharedInstance()
  }

  func create(
    withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?
  ) -> FlutterPlatformView {
    let params = args as? [String: Any] ?? [:]
    return KlarnaPaymentButtonView(frame: frame, params: params, messenger: messenger)
  }
}

/// Platform view wrapping the native Klarna Payment Button, bound to a `Klarna`
/// instance from `KnInstanceStore` by `instanceId`; empty container if missing.
class KlarnaPaymentButtonView: NSObject, FlutterPlatformView {
  private let container: UIView
  private let viewId: Int64
  private let flutterApi: KnPaymentFlutterApi
  private let methodChannel: FlutterMethodChannel

  private var button: KlarnaPaymentButton?

  private var currentProps: Props

  struct Props {
    var instanceId: String
    var state: String?
    var intent: String?
    var shape: String?
    var buttonStyle: String?
    var theme: String?

    init(_ params: [String: Any]) {
      self.instanceId = params["instanceId"] as? String ?? ""
      self.state = params["state"] as? String
      self.intent = params["intent"] as? String
      self.shape = params["shape"] as? String
      self.buttonStyle = params["buttonStyle"] as? String
      self.theme = params["theme"] as? String
    }

    /// Non-destructive merge: absent keys keep their existing value.
    func merging(_ params: [String: Any]) -> Props {
      var merged = self
      if let value = params["instanceId"] as? String { merged.instanceId = value }
      if params.keys.contains("state") { merged.state = params["state"] as? String }
      if params.keys.contains("intent") { merged.intent = params["intent"] as? String }
      if params.keys.contains("shape") { merged.shape = params["shape"] as? String }
      if params.keys.contains("buttonStyle") {
        merged.buttonStyle = params["buttonStyle"] as? String
      }
      if params.keys.contains("theme") { merged.theme = params["theme"] as? String }
      return merged
    }

    func hasSameNativeValues(as other: Props) -> Bool {
      instanceId == other.instanceId
        && state == other.state
        && intent == other.intent
        && shape == other.shape
        && buttonStyle == other.buttonStyle
        && theme == other.theme
    }

    /// True when only `state` differs — the change can be applied in place.
    func differsOnlyInState(from other: Props) -> Bool {
      instanceId == other.instanceId
        && intent == other.intent
        && shape == other.shape
        && buttonStyle == other.buttonStyle
        && theme == other.theme
        && state != other.state
    }
  }

  init(frame: CGRect, params: [String: Any], messenger: FlutterBinaryMessenger) {
    self.container = UIView(frame: frame)
    self.viewId = (params["viewId"] as? Int64) ?? Int64(params["viewId"] as? Int ?? 0)
    self.flutterApi = KnPaymentFlutterApi(binaryMessenger: messenger)
    self.currentProps = Props(params)
    self.methodChannel = FlutterMethodChannel(
      name: "com.klarna.mobile.sdk/payment_button/\(viewId)",
      binaryMessenger: messenger
    )
    super.init()

    methodChannel.setMethodCallHandler { [weak self] call, result in
      guard let self else {
        result(FlutterMethodNotImplemented)
        return
      }
      switch call.method {
      case "setProps":
        self.setProps(call.arguments as? [String: Any] ?? [:])
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    buildButton(props: currentProps)
  }

  deinit {
    methodChannel.setMethodCallHandler(nil)
    button?.gestureRecognizers?
      .filter { $0 is UITapGestureRecognizer }
      .forEach { $0.removeTarget(self, action: #selector(handleTap)) }
  }

  func view() -> UIView { container }

  /// State-only changes mutate the button in place; any other change recreates
  /// the button while reusing `container` so Flutter does not remount the view.
  private func setProps(_ params: [String: Any]) {
    let newProps = currentProps.merging(params)

    guard !newProps.hasSameNativeValues(as: currentProps) else {
      return
    }

    if newProps.differsOnlyInState(from: currentProps), let button = button {
      button.state = Self.parseState(newProps.state)
      currentProps = newProps
      return
    }

    button?.removeFromSuperview()
    button = nil
    currentProps = newProps
    buildButton(props: newProps)
  }

  /// Builds the SDK button and pins it to `container`. Leaves the empty container
  /// as a graceful fallback when the instance cannot be resolved.
  private func buildButton(props: Props) {
    guard let klarna = KnInstanceStore.shared.getInstance(props.instanceId) else {
      return
    }

    let configuration = KlarnaPaymentButtonConfiguration(
      state: Self.parseState(props.state),
      intent: Self.parseIntent(props.intent),
      shape: Self.parseShape(props.shape),
      style: Self.parseStyle(props.buttonStyle),
      theme: Self.parseTheme(props.theme)
    )
    let button = KlarnaPaymentButton(klarna: klarna, configuration: configuration)
    button.translatesAutoresizingMaskIntoConstraints = false

    container.addSubview(button)
    NSLayoutConstraint.activate([
      button.topAnchor.constraint(equalTo: container.topAnchor),
      button.bottomAnchor.constraint(equalTo: container.bottomAnchor),
      button.leadingAnchor.constraint(equalTo: container.leadingAnchor),
      button.trailingAnchor.constraint(equalTo: container.trailingAnchor),
    ])

    // The SDK button has no tap callback; its internal recognizer has no delegate,
    // so add our target/action onto it directly (after it's in the hierarchy).
    if let sdkTap = button.gestureRecognizers?.first(where: { $0 is UITapGestureRecognizer }) {
      sdkTap.addTarget(self, action: #selector(handleTap))
    }

    self.button = button
  }

  @objc private func handleTap() {
    flutterApi.onButtonPressed(viewId: viewId) { _ in }
  }

  static func parseState(_ value: String?) -> KlarnaButtonState {
    switch value {
    case "disabled": return .disabled
    case "loading": return .loading
    default: return .default
    }
  }

  static func parseIntent(_ value: String?) -> KlarnaPaymentButtonIntent {
    switch value {
    case "subscribe": return .subscribe
    case "addToWallet": return .addToWallet
    default: return .pay
    }
  }

  static func parseShape(_ value: String?) -> KlarnaButtonShape {
    switch value {
    case "pill": return .pill
    case "rectangle": return .rectangle
    default: return .roundedRect
    }
  }

  static func parseStyle(_ value: String?) -> KlarnaButtonStyle {
    switch value {
    case "outlined": return .outlined
    default: return .filled
    }
  }

  static func parseTheme(_ value: String?) -> KlarnaTheme {
    switch value {
    case "light": return .light
    case "automatic": return .automatic
    default: return .dark
    }
  }
}
