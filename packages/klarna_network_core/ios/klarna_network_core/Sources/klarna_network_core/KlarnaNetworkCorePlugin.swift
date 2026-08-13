import Flutter
import KlarnaNetworkCore
import UIKit

/// Holds the real native `Klarna` instances keyed by instanceId, so sibling
/// feature packages can resolve the same instance the core plugin created.
/// Gated behind `@_spi` to keep it out of the module's public surface.
@_spi(FlutterKlarnaNetworkCore)
public final class KnInstanceStore {
  @_spi(FlutterKlarnaNetworkCore)
  public static let shared = KnInstanceStore()
  private let queue = DispatchQueue(label: "com.klarna.flutter.kncore.instances")
  private var storage: [String: Klarna] = [:]

  func put(_ id: String, _ instance: Klarna) { queue.sync { storage[id] = instance } }
  @_spi(FlutterKlarnaNetworkCore)
  public func getInstance(_ id: String) -> Klarna? { queue.sync { storage[id] } }
  @discardableResult
  func remove(_ id: String) -> Klarna? { queue.sync { storage.removeValue(forKey: id) } }
}

public class KlarnaNetworkCorePlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    KnCoreHostApiSetup.setUp(
      binaryMessenger: registrar.messenger(), api: KnCoreHostApiImpl())
  }
}

final class KnCoreHostApiImpl: KnCoreHostApi {
  private static let moduleName = "KlarnaNetworkCore"
  private static let errorInstanceNotFound =
    "No instance found for the given instanceId. Call initialize first."

  func initialize(
    instanceId: String, configuration: KnConfiguration,
    completion: @escaping (Result<Void, Error>) -> Void
  ) {
    let acquiringConfig = configuration.acquiringConfig.map {
      KlarnaAcquiringConfig(
        paymentAccountReference: $0.paymentAccountReference,
        paymentAcquiringAccountId: $0.paymentAcquiringAccountId
      )
    }
    let klarnaConfiguration = KlarnaConfiguration(
      accountId: configuration.accountId,
      clientId: configuration.clientId,
      locale: configuration.locale,
      appReturnUrl: configuration.appReturnUrl,
      klarnaNetworkSessionToken: configuration.klarnaNetworkSessionToken,
      acquiringConfig: acquiringConfig
    )
    // `Klarna.initialize` returns `KlarnaResult<Klarna>` ==
    // `Result<Klarna, KlarnaSDKError>`.
    switch Klarna.initialize(configuration: klarnaConfiguration) {
    case .success(let klarna):
      KnInstanceStore.shared.put(instanceId, klarna)
      completion(.success(()))
    case .failure(let error):
      completion(.failure(PigeonError(code: error.name, message: error.message, details: nil)))
    }
  }

  func getSessionToken(
    instanceId: String, completion: @escaping (Result<String, Error>) -> Void
  ) {
    guard let klarna = KnInstanceStore.shared.getInstance(instanceId) else {
      completion(.failure(PigeonError(
        code: Self.moduleName, message: Self.errorInstanceNotFound, details: nil)))
      return
    }
    klarna.network.session.token { result in
      switch result {
      case .success(let token):
        completion(.success(token))
      case .failure(let error):
        completion(.failure(PigeonError(code: error.name, message: error.message, details: nil)))
      }
    }
  }

  func clearSession(
    instanceId: String, completion: @escaping (Result<Void, Error>) -> Void
  ) {
    guard let klarna = KnInstanceStore.shared.getInstance(instanceId) else {
      completion(.failure(PigeonError(
        code: Self.moduleName, message: Self.errorInstanceNotFound, details: nil)))
      return
    }
    klarna.network.session.clear { result in
      switch result {
      case .success:
        completion(.success(()))
      case .failure(let error):
        completion(.failure(PigeonError(code: error.name, message: error.message, details: nil)))
      }
    }
  }

  func setIntegrationMetadata(
    instanceId: String, metadata: KnIntegrationMetadata
  ) throws {
    guard let klarna = KnInstanceStore.shared.getInstance(instanceId) else {
      return
    }
    let integrator = KlarnaIntegratorMetadata(
      name: metadata.integrator.name,
      sessionReference: metadata.integrator.sessionReference,
      moduleName: metadata.integrator.moduleName,
      moduleVersion: metadata.integrator.moduleVersion
    )
    let originators = metadata.originators?.map {
      KlarnaOriginatorMetadata(
        name: $0.name,
        sessionReference: $0.sessionReference,
        moduleName: $0.moduleName,
        moduleVersion: $0.moduleVersion
      )
    }
    klarna.integrationMetadata = KlarnaIntegrationMetadata(
      integrator: integrator,
      originators: originators
    )
  }

  func handleReturnUrl(
    url: String, completion: @escaping (Result<Bool, Error>) -> Void
  ) {
    guard let parsedUrl = URL(string: url) else {
      completion(.success(false))
      return
    }
    DispatchQueue.main.async {
      completion(.success(Klarna.handleReturnUrl(url: parsedUrl)))
    }
  }

  func dispose(instanceId: String) throws {
    KnInstanceStore.shared.remove(instanceId)
  }
}
