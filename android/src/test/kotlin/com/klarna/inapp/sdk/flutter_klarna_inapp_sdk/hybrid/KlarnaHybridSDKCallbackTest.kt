package com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.hybrid

import android.webkit.WebView
import com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.ErrorCallbackHandler
import com.klarna.mobile.sdk.api.OnCompletion
import com.klarna.mobile.sdk.api.hybrid.KlarnaMobileSDKError
import io.mockk.*
import org.junit.After
import org.junit.Before
import org.junit.Test

class KlarnaHybridSDKCallbackTest {

    private val callback: KlarnaHybridSDKCallback = KlarnaHybridSDKCallback()
    private val webView: WebView = mockk()
    private val completion: OnCompletion = mockk()
    private val error: KlarnaMobileSDKError = KlarnaMobileSDKError("testError", "test", true)

    @Before
    fun setup() {
        mockkObject(ErrorCallbackHandler)
        every { completion.run() } just runs
    }

    @After
    fun teardown() {
        clearAllMocks()
    }

    @Test
    fun testCompletions() {
        callback.didHideFullscreenContent(webView, completion)
        callback.didShowFullscreenContent(webView, completion)
        callback.willHideFullscreenContent(webView, completion)
        callback.willShowFullscreenContent(webView, completion)

        verify(exactly = 4) { completion.run() }
    }

    @Test
    fun testOnErrorOccurred() {
        callback.onErrorOccurred(webView, error)

        verify { ErrorCallbackHandler.sendValue(any()) }
    }
}