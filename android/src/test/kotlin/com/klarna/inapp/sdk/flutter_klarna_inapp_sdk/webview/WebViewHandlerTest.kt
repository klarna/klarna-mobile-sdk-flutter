package com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.webview

import com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.core.webview.WebViewManager
import io.flutter.plugin.common.MethodChannel
import io.mockk.clearAllMocks
import io.mockk.mockk
import io.mockk.mockkObject
import io.mockk.verify
import org.junit.After
import org.junit.Before
import org.junit.Test

class WebViewHandlerTest {

    private val handler = WebViewHandler
    private val result: MethodChannel.Result = mockk()
    private val webViewManager: WebViewManager = mockk(relaxed = true)

    @Before
    fun setup() {
        mockkObject(WebViewHandler)
        handler.webViewManager = webViewManager
    }

    @After
    fun teardown() {
        clearAllMocks()
    }

    @Test
    fun testInitialize() {
        handler.onMethod(WebViewMethod.Initialize, result)
        verify { webViewManager.initialize(result) }
    }

    @Test
    fun testDestroy() {
        handler.onMethod(WebViewMethod.Destroy, result)
        verify { webViewManager.destroy(result) }
    }

    @Test
    fun testShow() {
        handler.onMethod(WebViewMethod.Show, result)
        verify { webViewManager.show(result) }
    }

    @Test
    fun testHide() {
        handler.onMethod(WebViewMethod.Hide, result)
        verify { webViewManager.hide(result) }
    }

    @Test
    fun testLoadURL() {
        handler.onMethod(WebViewMethod.LoadURL("url"), result)
        verify { webViewManager.loadURL("url", result) }
    }

    @Test
    fun testLoadJS() {
        handler.onMethod(WebViewMethod.LoadJS("js"), result)
        verify { webViewManager.loadJS("js", result) }
    }
}