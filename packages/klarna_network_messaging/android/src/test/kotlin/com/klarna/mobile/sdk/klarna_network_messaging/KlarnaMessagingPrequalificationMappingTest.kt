package com.klarna.mobile.sdk.klarna_network_messaging

import com.klarna.mobile.sdk.klarna.network.core.api.common.KlarnaResult
import com.klarna.mobile.sdk.klarna.network.core.api.common.KlarnaSDKError
import com.klarna.mobile.sdk.klarna.network.messaging.api.models.KlarnaMessagingPrequalificationResult
import java.util.Date
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertIs
import kotlin.test.assertNull
import kotlin.test.assertTrue

class KlarnaMessagingPrequalificationMappingTest {
    @Test
    fun approvedMapsToApprovedWithExpiresAtMillis() {
        val result =
            KlarnaMessagingPrequalificationMapping.toKnResult(
                KlarnaMessagingPrequalificationResult.Approved(Date(1_798_761_600_000L)),
            )

        assertEquals(KnPrequalificationStatus.APPROVED, result.status)
        assertEquals(1_798_761_600_000L, result.expiresAtMillis)
    }

    @Test
    fun abortedMapsToAbortedWithoutExpiresAt() {
        val result =
            KlarnaMessagingPrequalificationMapping.toKnResult(
                KlarnaMessagingPrequalificationResult.Aborted,
            )

        assertEquals(KnPrequalificationStatus.ABORTED, result.status)
        assertNull(result.expiresAtMillis)
    }

    @Test
    fun successOutcomeMapsToSuccessResult() {
        val outcome =
            KlarnaMessagingPrequalificationMapping.toOutcome(
                KlarnaResult.Success(KlarnaMessagingPrequalificationResult.Approved(Date(42L))),
            )

        assertTrue(outcome.isSuccess)
        assertEquals(42L, outcome.getOrNull()?.expiresAtMillis)
    }

    @Test
    fun failureOutcomeMapsNativeErrorNameAndMessage() {
        for (name in listOf("OPERATION_FAILED", "INITIATE_ALREADY_IN_PROGRESS")) {
            val outcome =
                KlarnaMessagingPrequalificationMapping.toOutcome(
                    KlarnaResult.Failure(KlarnaSDKError(name, "boom")),
                )

            val error = outcome.exceptionOrNull()
            assertIs<FlutterError>(error)
            assertEquals(name, error.code)
            assertEquals("boom", error.message)
        }
    }
}
