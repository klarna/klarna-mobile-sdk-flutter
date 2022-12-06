package com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.postpurchaseexperience

import android.webkit.WebView
import com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.core.webview.WebViewManager
import com.klarna.mobile.sdk.api.hybrid.KlarnaHybridSDK
import io.mockk.clearAllMocks
import io.mockk.mockk
import io.mockk.verify
import org.junit.After
import org.junit.Test

class PostPurchaseExperienceWebViewClientTest {

    private val hybridSDK: KlarnaHybridSDK = mockk(relaxed = true)
    private val client = PostPurchaseExperienceWebViewClient(hybridSDK)
    private val webView: WebView = mockk(relaxed = true)
    private val webViewManager: WebViewManager = mockk(relaxed = true)

    @After
    fun teardown() {
        clearAllMocks()
    }

    @Test
    fun testLoadJSLoaded() {
        client.onPageFinished(webView, "url")
        client.queueJS(webViewManager, "script")
        verify { webViewManager.loadJS("script", null) }
    }

    @Test
    fun testLoadJSNotLoaded() {
        client.queueJS(webViewManager, "script")
        verify(exactly = 0) { webViewManager.loadJS("script", null) }

        client.onPageFinished(webView, "url")
        verify { webView.evaluateJavascript("script", any()) }
    }

}