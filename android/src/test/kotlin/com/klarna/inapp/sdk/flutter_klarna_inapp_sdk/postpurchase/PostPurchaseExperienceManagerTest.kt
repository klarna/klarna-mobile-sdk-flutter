package com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.postpurchase

import android.webkit.WebView
import com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.core.webview.WebViewManager
import com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.hybrid.KlarnaHybridSDKHandler
import com.klarna.mobile.sdk.api.hybrid.KlarnaHybridSDK
import io.flutter.plugin.common.MethodChannel
import io.mockk.*
import org.junit.After
import org.junit.Before
import org.junit.Test

class PostPurchaseExperienceManagerTest {

    private val ppeManager = PostPurchaseExperienceManager()
    private val result: MethodChannel.Result = mockk()
    private val webViewManager: WebViewManager = mockk(relaxed = true)
    private val webView: WebView = mockk(relaxed = true)
    private val hybridSDK: KlarnaHybridSDK = mockk()

    @Before
    fun setup() {
        mockkObject(PostPurchaseExperienceManager)
        mockkObject(KlarnaHybridSDKHandler)

        every { KlarnaHybridSDKHandler.hybridSDK } returns hybridSDK
        every { hybridSDK.addWebView(any()) } just runs

        every { result.success(any()) } just runs
        every { result.error(any(), any(), any()) } just runs

        ppeManager.webViewManager = webViewManager

        mockkConstructor(PostPurchaseExperienceWebViewClient::class)

        every { webViewManager.webView } returns null andThen webView
        every { webViewManager.requireWebView() } returns webView
        every { webView.settings } returns mockk(relaxed = true)
    }

    @After
    fun teardown() {
        clearAllMocks()
    }

    @Test
    fun testNotInitialized() {
        val ppeManager = PostPurchaseExperienceManager()
        ppeManager.renderOperation(mockk(), result)
        ppeManager.authorizationRequest(mockk(), result)
        verify(exactly = 2) { PostPurchaseExperienceManager.notInitialized(result) }
    }

    @Test
    fun testInitialize() {
        ppeManager.initialize(mockk(relaxed = true), result)
        verify { KlarnaHybridSDKHandler.hybridSDK }
        verify { webViewManager.initialize(null) }
        verify { webViewManager.addToHybridSdk(null) }
        verify { webView.webViewClient = any() }
        verify { webView.webChromeClient = any() }
        verify { webView.addJavascriptInterface(any(), "PPECallback") }
        verify { webView.loadUrl("file:///android_asset/ppe.html") }
        verify { ppeManager.webViewClient?.queueJS(any(), any()) }
    }

    @Test
    fun testDestroy() {
        ppeManager.destroy(mockk(relaxed = true), result)
        verify { webViewManager.destroy(null) }
        verify { result.success(null) }
    }

    @Test
    fun testRenderOperation() {
        ppeManager.initialized = true
        ppeManager.webViewClient = mockk(relaxed = true)
        ppeManager.renderOperation(mockk(relaxed = true), result)
        verify { ppeManager.webViewClient?.queueJS(any(), any()) }
        verify { webViewManager.show(null) }
    }

    @Test
    fun testAuthorizationRequest() {
        ppeManager.initialized = true
        ppeManager.webViewClient = mockk(relaxed = true)
        ppeManager.authorizationRequest(mockk(relaxed = true), result)
        verify { ppeManager.webViewClient?.queueJS(any(), any()) }
        verify { webViewManager.show(null) }
    }
}