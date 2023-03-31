package com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.hybrid

import com.klarna.mobile.sdk.api.KlarnaEvent
import io.mockk.clearAllMocks
import io.mockk.mockkObject
import io.mockk.verify
import org.junit.After
import org.junit.Before
import org.junit.Test

class KlarnaHybridSDKEventListenerTest {

    private val eventListener = KlarnaHybridSDKEventListener(KlarnaHybridSDKEventHandler)

    @Before
    fun setup() {
        mockkObject(KlarnaHybridSDKEventHandler)
    }

    @After
    fun teardown() {
        clearAllMocks()
    }

    @Test
    fun testEventStreamIsSent() {
        val event = KlarnaEvent("someEventString")
        eventListener.onEvent(event)
        verify { KlarnaHybridSDKEventHandler.sendValue(event.bodyString!!) }
    }
}