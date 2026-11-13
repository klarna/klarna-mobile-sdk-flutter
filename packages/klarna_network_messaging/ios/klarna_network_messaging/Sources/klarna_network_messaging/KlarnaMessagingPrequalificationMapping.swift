import Foundation
import KlarnaNetworkCore
import KlarnaNetworkMessaging

enum KlarnaMessagingPrequalificationMapping {
  /// Maps the native prequalification result to the Pigeon transport type.
  static func toKnResult(_ result: KlarnaMessagingPrequalificationResult)
    -> KnPrequalificationResult
  {
    switch result {
    case .approved(let expiresAt):
      return KnPrequalificationResult(
        status: .approved,
        expiresAtMillis: Int64((expiresAt.timeIntervalSince1970 * 1000).rounded()))
    case .aborted:
      return KnPrequalificationResult(status: .aborted, expiresAtMillis: nil)
    @unknown default:
      // A result added by a newer native SDK is reported as aborted: nothing was approved.
      return KnPrequalificationResult(status: .aborted, expiresAtMillis: nil)
    }
  }

  /// Maps a native prequalification outcome to the Pigeon completion result. A failure
  /// carries the native error name and message as a `PigeonError`.
  static func toCompletionResult(
    _ result: KlarnaResult<KlarnaMessagingPrequalificationResult>
  ) -> Result<KnPrequalificationResult, Error> {
    switch result {
    case .success(let value):
      return .success(toKnResult(value))
    case .failure(let error):
      return .failure(PigeonError(code: error.name, message: error.message, details: nil))
    }
  }
}
