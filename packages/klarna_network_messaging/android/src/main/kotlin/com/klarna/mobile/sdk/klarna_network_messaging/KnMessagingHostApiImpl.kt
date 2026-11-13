package com.klarna.mobile.sdk.klarna_network_messaging

import android.app.Activity
import com.klarna.mobile.sdk.klarna.network.messaging.api.messaging
import com.klarna.mobile.sdk.klarna.network.messaging.api.models.KlarnaMessagingPrequalificationData
import com.klarna.mobile.sdk.klarna_network_core.KnInstanceStore

/** Host API backed by the native messaging SDK; resolves `Klarna` from [KnInstanceStore]. */
internal class KnMessagingHostApiImpl : KnMessagingHostApi {
    @Volatile
    var activity: Activity? = null

    companion object {
        private const val NAME = "KlarnaNetworkMessaging"
        private const val ERROR_INSTANCE_NOT_FOUND =
            "No instance found for the given instanceId. Call initialize first."
        private const val ERROR_ACTIVITY_NOT_FOUND = "Main Activity not found."
    }

    override fun prequalificationInitiate(
        instanceId: String,
        data: KnPrequalificationData,
        callback: (Result<KnPrequalificationResult>) -> Unit,
    ) {
        val sdk = KnInstanceStore.getInstance(instanceId)
        if (sdk == null) {
            callback(Result.failure(FlutterError(NAME, ERROR_INSTANCE_NOT_FOUND)))
            return
        }
        val currentActivity = activity
        if (currentActivity == null) {
            callback(Result.failure(FlutterError(NAME, ERROR_ACTIVITY_NOT_FOUND)))
            return
        }
        val nativeData =
            KlarnaMessagingPrequalificationData(amount = data.amount, currency = data.currency)
        sdk.messaging.prequalification.initiate(
            activity = currentActivity,
            data = nativeData,
        ) { result ->
            callback(KlarnaMessagingPrequalificationMapping.toOutcome(result))
        }
    }
}
