package com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.core.webview

import com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.PluginContext
import com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.hybrid.KlarnaHybridSDKHandler
import com.klarna.mobile.sdk.api.hybrid.KlarnaHybridSDK
import io.flutter.plugin.common.MethodChannel
import io.mockk.*
import org.junit.After
import org.junit.Assert
import org.junit.Before
import org.junit.Test

class WebViewManagerTest {

    private val webViewManager = WebViewManager()
    private val result: MethodChannel.Result = mockk()
    private val hybridSDK: KlarnaHybridSDK = mockk()

    @Before
    fun setup() {
        mockkObject(WebViewManager)
        mockkObject(KlarnaHybridSDKHandler)

        every { result.success(any()) } just runs
        every { result.error(any(), any(), any()) } just runs

        every { hybridSDK.addWebView(any()) } just runs

        mockkObject(PluginContext)
        every { PluginContext.activity } returns mockk(relaxed = true)

        webViewManager.initialize(null)
    }

    @After
    fun teardown() {
        clearAllMocks()
    }

    @Test
    fun testNotInitialized() {
        every { KlarnaHybridSDKHandler.hybridSDK } returns mockk()
        val webViewManager = WebViewManager()
        webViewManager.destroy(result)
        webViewManager.hide(result)
        webViewManager.show(result)
        webViewManager.loadURL("", result)
        webViewManager.loadJS("", result)
        verify(exactly = 5) { WebViewManager.notInitialized(result) }
    }

    @Test
    fun testInitialize() {
        val webViewManager = WebViewManager()
        webViewManager.initialize(result)
        verify { result.success(any()) }
        Assert.assertNotNull(webViewManager.webView)
    }

    @Test
    fun testDestroy() {
        webViewManager.destroy(result)
        verify { result.success(any()) }
        Assert.assertNull(webViewManager.webView)
    }

    @Test
    fun testShow() {
        webViewManager.show(result)
        verify { result.success(any()) }
    }

    @Test
    fun testHide() {
        webViewManager.hide(result)
        verify { result.success(any()) }
    }

    @Test
    fun testLoadURL() {
        webViewManager.loadURL("", result)
        verify { result.success(any()) }
    }

    @Test
    fun testLoadJS() {
        webViewManager.loadJS("", result)
        verify { result.success(any()) }
    }
}