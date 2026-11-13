package com.klarna.mobile.sdk.klarna_network_messaging

import com.klarna.mobile.sdk.klarna.network.core.api.common.KlarnaResult
import com.klarna.mobile.sdk.klarna.network.core.api.common.KlarnaSDKError
import com.klarna.mobile.sdk.klarna.network.messaging.api.models.KlarnaMessagingPrequalificationResult

internal object KlarnaMessagingPrequalificationMapping {
    /** Maps the native prequalification result to the Pigeon transport type. */
    fun toKnResult(result: KlarnaMessagingPrequalificationResult): KnPrequalificationResult =
        when (result) {
            is KlarnaMessagingPrequalificationResult.Approved ->
                KnPrequalificationResult(
                    status = KnPrequalificationStatus.APPROVED,
                    expiresAtMillis = result.expiresAt.time,
                )

            is KlarnaMessagingPrequalificationResult.Aborted ->
                KnPrequalificationResult(status = KnPrequalificationStatus.ABORTED)
        }

    /**
     * Maps a native prequalification outcome to the Pigeon callback result. A failure
     * carries the native error name and message as a [FlutterError].
     */
    fun toOutcome(
        result: KlarnaResult<KlarnaMessagingPrequalificationResult, KlarnaSDKError>,
    ): Result<KnPrequalificationResult> =
        when (result) {
            is KlarnaResult.Success -> Result.success(toKnResult(result.value))
            is KlarnaResult.Failure ->
                Result.failure(FlutterError(result.error.name, result.error.message))
        }
}
