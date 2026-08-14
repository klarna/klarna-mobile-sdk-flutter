package com.klarna.mobile.sdk.klarna_network_core

import android.content.Context
import androidx.annotation.RestrictTo
import com.klarna.mobile.sdk.klarna.network.core.api.common.KlarnaResult
import com.klarna.mobile.sdk.klarna.network.core.api.klarna.Klarna
import com.klarna.mobile.sdk.klarna.network.core.api.klarna.KlarnaAcquiringConfig
import com.klarna.mobile.sdk.klarna.network.core.api.klarna.KlarnaConfiguration
import com.klarna.mobile.sdk.klarna.network.core.api.metadata.KlarnaIntegrationMetadata
import com.klarna.mobile.sdk.klarna.network.core.api.metadata.KlarnaIntegratorMetadata
import com.klarna.mobile.sdk.klarna.network.core.api.metadata.KlarnaOriginatorMetadata
import io.flutter.embedding.engine.plugins.FlutterPlugin
import java.util.concurrent.ConcurrentHashMap

/**
 * Holds the real native [Klarna] instances keyed by instanceId, so sibling
 * feature packages can resolve the same instance this plugin created.
 * Restricted to the library group to keep it out of the module's public API.
 */
@RestrictTo(RestrictTo.Scope.LIBRARY_GROUP_PREFIX)
object KnInstanceStore {
    private val storage = ConcurrentHashMap<String, Klarna>()

    fun put(id: String, instance: Klarna) {
        storage[id] = instance
    }

    @RestrictTo(RestrictTo.Scope.LIBRARY_GROUP_PREFIX)
    fun getInstance(id: String): Klarna? = storage[id]

    fun remove(id: String): Klarna? = storage.remove(id)
}

class KlarnaNetworkCorePlugin : FlutterPlugin {
    private var applicationContext: Context? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        applicationContext = binding.applicationContext
        KnCoreHostApi.setUp(binding.binaryMessenger, KnCoreHostApiImpl(binding.applicationContext))
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        KnCoreHostApi.setUp(binding.binaryMessenger, null)
        applicationContext = null
    }
}

private class KnCoreHostApiImpl(
    private val context: Context,
) : KnCoreHostApi {

    companion object {
        private const val NAME = "KlarnaNetworkCore"
        private const val ERROR_INSTANCE_NOT_FOUND =
            "No instance found for the given instanceId. Call initialize first."
    }

    override fun initialize(
        instanceId: String,
        configuration: KnConfiguration,
        callback: (Result<Unit>) -> Unit,
    ) {
        // appReturnUrl from KnConfiguration is not needed on Android.
        val acquiringConfig = configuration.acquiringConfig?.let {
            KlarnaAcquiringConfig(it.paymentAccountReference, it.paymentAcquiringAccountId)
        }
        val config = KlarnaConfiguration(
            clientId = configuration.clientId,
            accountId = configuration.accountId,
            locale = configuration.locale,
            klarnaNetworkSessionToken = configuration.klarnaNetworkSessionToken,
            acquiringConfig = acquiringConfig,
        )
        when (val result = Klarna.initialize(context, config)) {
            is KlarnaResult.Success -> {
                KnInstanceStore.put(instanceId, result.value)
                callback(Result.success(Unit))
            }
            is KlarnaResult.Failure -> {
                callback(Result.failure(FlutterError(result.error.name, result.error.message)))
            }
        }
    }

    override fun getSessionToken(
        instanceId: String,
        callback: (Result<String>) -> Unit,
    ) {
        val klarna = KnInstanceStore.getInstance(instanceId) ?: run {
            callback(Result.failure(FlutterError(NAME, ERROR_INSTANCE_NOT_FOUND)))
            return
        }
        klarna.network.session.token { result ->
            when (result) {
                is KlarnaResult.Success -> callback(Result.success(result.value))
                is KlarnaResult.Failure ->
                    callback(Result.failure(FlutterError(result.error.name, result.error.message)))
            }
        }
    }

    override fun clearSession(instanceId: String, callback: (Result<Unit>) -> Unit) {
        val klarna = KnInstanceStore.getInstance(instanceId) ?: run {
            callback(Result.failure(FlutterError(NAME, ERROR_INSTANCE_NOT_FOUND)))
            return
        }
        klarna.network.session.clear { result ->
            when (result) {
                is KlarnaResult.Success -> callback(Result.success(Unit))
                is KlarnaResult.Failure ->
                    callback(Result.failure(FlutterError(result.error.name, result.error.message)))
            }
        }
    }

    override fun setIntegrationMetadata(instanceId: String, metadata: KnIntegrationMetadata) {
        val klarna = KnInstanceStore.getInstance(instanceId) ?: return
        val integrator = KlarnaIntegratorMetadata(
            name = metadata.integrator.name,
            sessionReference = metadata.integrator.sessionReference,
            moduleName = metadata.integrator.moduleName,
            moduleVersion = metadata.integrator.moduleVersion,
        )
        val originators = metadata.originators?.map {
            KlarnaOriginatorMetadata(
                name = it.name,
                sessionReference = it.sessionReference,
                moduleName = it.moduleName,
                moduleVersion = it.moduleVersion,
            )
        }
        klarna.integrationMetadata = KlarnaIntegrationMetadata(integrator, originators)
    }

    override fun handleReturnUrl(url: String, callback: (Result<Boolean>) -> Unit) {
        // handleReturnUrl is not supported on Android; always false.
        callback(Result.success(false))
    }

    override fun dispose(instanceId: String) {
        KnInstanceStore.remove(instanceId)
    }
}
