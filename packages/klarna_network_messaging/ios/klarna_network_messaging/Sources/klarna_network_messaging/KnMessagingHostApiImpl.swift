import Flutter
import Foundation
import KlarnaNetworkCore
import KlarnaNetworkMessaging
@_spi(FlutterKlarnaNetworkCore) import klarna_network_core

/// Host API implementation backed by the KlarnaNetworkMessaging SDK. The `Klarna`
/// instance is resolved from the core plugin's `KnInstanceStore` by instanceId.
final class KnMessagingHostApiImpl: KnMessagingHostApi {
  private static let moduleName = "KlarnaNetworkMessaging"
  private static let errorInstanceNotFound =
    "No instance found for the given instanceId. Call initialize first."

  func prequalificationInitiate(
    instanceId: String, data: KnPrequalificationData,
    completion: @escaping (Result<KnPrequalificationResult, Error>) -> Void
  ) {
    guard let klarna = KnInstanceStore.shared.getInstance(instanceId) else {
      completion(
        .failure(
          PigeonError(
            code: Self.moduleName,
            message: Self.errorInstanceNotFound,
            details: nil)))
      return
    }
    let nativeData = KlarnaMessagingPrequalificationData(
      amount: data.amount, currency: data.currency)
    klarna.messaging.prequalification.initiate(data: nativeData) { result in
      completion(KlarnaMessagingPrequalificationMapping.toCompletionResult(result))
    }
  }
}
