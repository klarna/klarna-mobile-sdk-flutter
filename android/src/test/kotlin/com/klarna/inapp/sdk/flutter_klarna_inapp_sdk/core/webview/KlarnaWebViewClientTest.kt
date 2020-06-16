package com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.core.webview

import android.webkit.WebView
import com.klarna.mobile.sdk.api.hybrid.KlarnaHybridSDK
import io.mockk.*
import org.junit.After
import org.junit.Before
import org.junit.Test

class KlarnaWebViewClientTest {

    private val hybridSDK: KlarnaHybridSDK = mockk()
    private val klarnaWebViewClient = KlarnaWebViewClient(hybridSDK)

    @Before
    fun setup() {
        every { hybridSDK.shouldFollowNavigation(any()) } returns true
        every { hybridSDK.newPageLoad(any()) } just runs
    }

    @After
    fun teardown() {
        clearAllMocks()
    }

    @Test
    fun testShouldOverrideUrlLoading() {
        klarnaWebViewClient.shouldOverrideUrlLoading(mockk(), "test")
        verify { hybridSDK.shouldFollowNavigation("test") }
    }

    @Test
    fun testOnPageFinished() {
        val webView: WebView = mockk()
        klarnaWebViewClient.onPageFinished(webView, "test")
        verify { hybridSDK.newPageLoad(webView) }
    }
}