package com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.hybrid

import com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.ResultError
import io.flutter.plugin.common.MethodChannel
import io.mockk.*
import org.junit.After
import org.junit.Before
import org.junit.Test

class KlarnaHybridSDKHandlerTest {

    private val hybridSDKHandler = KlarnaHybridSDKHandler
    private val result: MethodChannel.Result = mockk()

    @Before
    fun setup() {
        every { result.error(any(), any(), any()) } just runs
        every { result.success(any()) } just runs
    }

    @After
    fun teardown() {
        clearAllMocks()
    }

    @Test
    fun testNotInitialized() {
        KlarnaHybridSDKHandler.notInitialized(result)
        verify {
            result.error(ResultError.HYBRID_SDK_ERROR.errorCode,
                    KlarnaHybridSDKHandler.NOT_INITIALIZED,
                    "Call 'KlarnaHybridSDK.initialize' before this.")
        }
    }

    @Test
    fun testInitialize() {
        hybridSDKHandler.onMethod(KlarnaHybridSDKMethod.Initialize("returnUrl"), result)
        verify { result.success(null) }

        hybridSDKHandler.onMethod(KlarnaHybridSDKMethod.Initialize("error"), result)
        verify { result.error(ResultError.HYBRID_SDK_ERROR.errorCode, "Already initialized.", null) }
    }
}