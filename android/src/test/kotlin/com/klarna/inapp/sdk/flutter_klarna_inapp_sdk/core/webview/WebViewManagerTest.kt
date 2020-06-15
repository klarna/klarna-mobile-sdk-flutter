package com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.core.webview

import com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.hybrid.KlarnaHybridSDKHandler
import com.klarna.mobile.sdk.api.hybrid.KlarnaHybridSDK
import io.flutter.plugin.common.MethodChannel
import io.mockk.*
import org.junit.After
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

        webViewManager.initialize(result)
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
        webViewManager.addToHybridSdk(result)
        verify(exactly = 6) { WebViewManager.notInitialized(result) }
    }

    @Test
    fun testInitialize() {
        val webViewManager = WebViewManager()
        webViewManager.initialize(result)
        verify { result.success(any()) }
    }

    @Test
    fun testDestroy() {
        webViewManager.destroy(result)
        verify { result.success(any()) }
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

    @Test
    fun testAddToHybridSDK() {
        webViewManager.addToHybridSdk(result)
        verify { KlarnaHybridSDKHandler.notInitialized(result) }

        every { KlarnaHybridSDKHandler.hybridSDK } returns hybridSDK
        webViewManager.addToHybridSdk(result)
        verify { result.success(any()) }
    }
}