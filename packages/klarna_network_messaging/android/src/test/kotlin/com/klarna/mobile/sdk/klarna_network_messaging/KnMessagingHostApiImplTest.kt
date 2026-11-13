package com.klarna.mobile.sdk.klarna_network_messaging

import com.klarna.mobile.sdk.klarna.network.core.api.klarna.Klarna
import com.klarna.mobile.sdk.klarna_network_core.KnInstanceStore
import org.mockito.Mockito.mock
import kotlin.test.AfterTest
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertIs
import kotlin.test.assertNotNull

class KnMessagingHostApiImplTest {
    private val data = KnPrequalificationData(amount = 1000L, currency = "USD")

    @AfterTest
    fun tearDown() {
        KnInstanceStore.remove("with-instance")
    }

    @Test
    fun unknownInstanceFailsWithInstanceNotFound() {
        var result: Result<KnPrequalificationResult>? = null

        KnMessagingHostApiImpl().prequalificationInitiate("missing-instance", data) { result = it }

        val error = assertNotNull(result).exceptionOrNull()
        assertIs<FlutterError>(error)
        assertEquals("KlarnaNetworkMessaging", error.code)
        assertEquals(
            "No instance found for the given instanceId. Call initialize first.",
            error.message,
        )
    }

    @Test
    fun missingActivityFailsWithActivityNotFound() {
        KnInstanceStore.put("with-instance", mock(Klarna::class.java))
        val impl = KnMessagingHostApiImpl()
        var result: Result<KnPrequalificationResult>? = null

        impl.prequalificationInitiate("with-instance", data) { result = it }

        val error = assertNotNull(result).exceptionOrNull()
        assertIs<FlutterError>(error)
        assertEquals("KlarnaNetworkMessaging", error.code)
        assertEquals("Main Activity not found.", error.message)
    }
}
