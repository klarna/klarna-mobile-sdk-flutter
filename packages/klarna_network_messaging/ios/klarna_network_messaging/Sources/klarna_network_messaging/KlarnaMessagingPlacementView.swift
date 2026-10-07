import Flutter
import KlarnaCore
import KlarnaNetworkCore
import KlarnaNetworkMessaging
import UIKit
@_spi(FlutterKlarnaNetworkCore) import klarna_network_core

class KlarnaMessagingPlacementViewFactory: NSObject, FlutterPlatformViewFactory {
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
    return KlarnaMessagingPlacementViewWrapper(frame: frame, params: params, messenger: messenger)
  }
}

class KlarnaMessagingPlacementViewWrapper: NSObject, FlutterPlatformView {
  private let container: UIView
  private let viewId: Int64
  private let flutterApi: KnMessagingFlutterApi
  private let methodChannel: FlutterMethodChannel

  private var placementView: UIView?
  private var heightObserver: KlarnaMessagingHeightObserver?

  private struct Props {
    var instanceId: String
    var placementType: String
    var theme: String
    var amount: String
    var currency: String

    init(_ params: [String: Any]) {
      self.instanceId = params["instanceId"] as? String ?? ""
      self.placementType = params["placementType"] as? String ?? ""
      self.theme = params["theme"] as? String ?? ""
      self.amount = params["amount"] as? String ?? ""
      self.currency = params["currency"] as? String ?? ""
    }

    func merging(_ params: [String: Any]) -> Props {
      var merged = self
      if let value = params["instanceId"] as? String { merged.instanceId = value }
      if let value = params["placementType"] as? String { merged.placementType = value }
      if let value = params["theme"] as? String { merged.theme = value }
      if let value = params["amount"] as? String { merged.amount = value }
      if let value = params["currency"] as? String { merged.currency = value }
      return merged
    }
  }

  private var currentProps: Props

  init(frame: CGRect, params: [String: Any], messenger: FlutterBinaryMessenger) {
    self.container = UIView(frame: frame)
    self.container.backgroundColor = .clear
    self.container.clipsToBounds = true
    self.viewId = (params["viewId"] as? Int64) ?? Int64(params["viewId"] as? Int ?? 0)
    self.flutterApi = KnMessagingFlutterApi(binaryMessenger: messenger)
    self.currentProps = Props(params)
    self.methodChannel = FlutterMethodChannel(
      name: "com.klarna.mobile.sdk/messaging_placement/\(viewId)",
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

    buildPlacement(props: currentProps)
  }

  deinit {
    methodChannel.setMethodCallHandler(nil)
    heightObserver?.stopObserving()
  }

  func view() -> UIView { container }

  private func setProps(_ params: [String: Any]) {
    currentProps = currentProps.merging(params)
    buildPlacement(props: currentProps)
  }

  private func buildPlacement(props: Props) {
    heightObserver?.stopObserving()
    heightObserver = nil
    placementView?.removeFromSuperview()
    placementView = nil

    guard !props.instanceId.isEmpty, !props.currency.isEmpty,
      let amount = KlarnaMessagingParsing.parseAmount(props.amount)
    else {
      return
    }

    guard let klarna = KnInstanceStore.shared.getInstance(props.instanceId) else {
      flutterApi.onResized(viewId: viewId, height: 0) { _ in }
      return
    }

    let theme = Self.parseTheme(props.theme)
    let configuration = Self.makeConfiguration(
      placementType: props.placementType,
      theme: theme,
      amount: amount,
      currency: props.currency
    )
    let view = KlarnaMessagingPlacementView(klarna: klarna, configuration: configuration)
    switch theme {
    case .light:
      view.overrideUserInterfaceStyle = .light
    case .dark:
      view.overrideUserInterfaceStyle = .dark
    default:
      view.overrideUserInterfaceStyle = .unspecified
    }
    view.backgroundColor = .clear
    view.translatesAutoresizingMaskIntoConstraints = false

    container.addSubview(view)
    NSLayoutConstraint.activate([
      view.topAnchor.constraint(equalTo: container.topAnchor),
      view.leadingAnchor.constraint(equalTo: container.leadingAnchor),
      view.trailingAnchor.constraint(equalTo: container.trailingAnchor),
    ])
    placementView = view

    let observer = KlarnaMessagingHeightObserver(delayIntervals: [0.1, 0.5, 1.5, 3.0, 6.0])
    observer.onHeightChanged = { [weak self] height in
      self?.flutterApi.onResized(viewId: self?.viewId ?? 0, height: Double(height)) { _ in }
    }
    observer.onNoContent = { [weak self] in
      self?.flutterApi.onResized(viewId: self?.viewId ?? 0, height: 0) { _ in }
    }
    observer.observe(view, in: container)
    heightObserver = observer
  }

  static func parseTheme(_ value: String) -> KlarnaTheme? {
    switch KlarnaMessagingParsing.resolveThemeKind(value) {
    case .light: return .light
    case .dark: return .dark
    case .automatic: return .automatic
    case nil: return nil
    }
  }

  static func makeConfiguration(
    placementType: String,
    theme: KlarnaTheme?,
    amount: Int,
    currency: String
  ) -> KlarnaMessagingPlacementConfiguration {
    switch KlarnaMessagingParsing.resolvePlacementKind(placementType) {
    case .badge:
      return .creditPromotionBadge(amount: amount, currency: currency, theme: theme)
    case .autoSize:
      return .creditPromotionAutoSize(amount: amount, currency: currency, theme: theme)
    }
  }
}

final class KlarnaMessagingHeightObserver: NSObject {
  var onHeightChanged: ((CGFloat) -> Void)?
  var onNoContent: (() -> Void)?

  private weak var observedView: UIView?
  private weak var containerView: UIView?
  private var isObserving = false
  private var lastReportedHeight: CGFloat = 0
  private var pendingDelayedChecks = 0
  private let delayIntervals: [Double]

  init(delayIntervals: [Double]) {
    self.delayIntervals = delayIntervals
    super.init()
  }

  func observe(_ view: UIView, in container: UIView) {
    stopObserving()
    observedView = view
    containerView = container
    lastReportedHeight = 0
    pendingDelayedChecks = delayIntervals.count
    isObserving = true
    view.addObserver(self, forKeyPath: "bounds", options: .new, context: nil)

    for delay in delayIntervals {
      DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
        guard let self else { return }
        self.checkAndReportHeight()
        self.pendingDelayedChecks -= 1
        if self.pendingDelayedChecks <= 0 && self.lastReportedHeight == 0 {
          self.onNoContent?()
        }
      }
    }
  }

  func stopObserving() {
    if isObserving, let view = observedView {
      view.removeObserver(self, forKeyPath: "bounds")
    }
    isObserving = false
    observedView = nil
    containerView = nil
  }

  private func checkAndReportHeight() {
    guard let view = observedView else { return }
    let containerWidth = containerView?.bounds.size.width ?? view.superview?.bounds.size.width ?? 0
    let fittingWidth = containerWidth > 0 ? containerWidth : UIScreen.main.bounds.width

    view.setNeedsLayout()
    view.layoutIfNeeded()
    let fittingSize = view.systemLayoutSizeFitting(
      CGSize(width: fittingWidth, height: UIView.layoutFittingCompressedSize.height),
      withHorizontalFittingPriority: .required,
      verticalFittingPriority: .fittingSizeLevel
    )
    var height = fittingSize.height
    if height <= 0 { height = view.frame.size.height }

    if height > 0 && height != lastReportedHeight {
      lastReportedHeight = height
      onHeightChanged?(height)
    }
  }

  override func observeValue(
    forKeyPath keyPath: String?,
    of object: Any?,
    change: [NSKeyValueChangeKey: Any]?,
    context: UnsafeMutableRawPointer?
  ) {
    if keyPath == "bounds", (object as? UIView) === observedView {
      DispatchQueue.main.async { [weak self] in
        self?.checkAndReportHeight()
      }
    }
  }

  deinit {
    stopObserving()
  }
}
