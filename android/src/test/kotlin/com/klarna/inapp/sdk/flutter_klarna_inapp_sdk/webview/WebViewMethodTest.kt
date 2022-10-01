package com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.webview

import io.flutter.plugin.common.MethodCall
import org.junit.Assert
import org.junit.Test

class WebViewMethodTest {

    @Test
    fun testInitialize() {
        val method = WebViewMethod.Parser.parse(MethodCall("initialize", null)) as? WebViewMethod.Initialize
        Assert.assertNotNull(method)
    }

    @Test
    fun testDestroy() {
        val method = WebViewMethod.Parser.parse(MethodCall("destroy", null)) as? WebViewMethod.Destroy
        Assert.assertNotNull(method)
    }

    @Test
    fun testShow() {
        val method = WebViewMethod.Parser.parse(MethodCall("show", null)) as? WebViewMethod.Show
        Assert.assertNotNull(method)
    }

    @Test
    fun testHide() {
        val method = WebViewMethod.Parser.parse(MethodCall("hide", null)) as? WebViewMethod.Hide
        Assert.assertNotNull(method)
    }

    @Test
    fun testLoadURL() {
        val method = WebViewMethod.Parser.parse(MethodCall("loadURL", mapOf(
                "url" to "url"
        ))) as? WebViewMethod.LoadURL
        Assert.assertNotNull(method)
        Assert.assertEquals("url", method?.url)
    }

    @Test(expected = IllegalArgumentException::class)
    fun testLoadURLInvalid() {
        WebViewMethod.Parser.parse(MethodCall("loadURL", mapOf(
                "url" to null
        )))
    }

    @Test
    fun testLoadJS() {
        val method = WebViewMethod.Parser.parse(MethodCall("loadJS", mapOf(
                "js" to "js"
        ))) as? WebViewMethod.LoadJS
        Assert.assertNotNull(method)
        Assert.assertEquals("js", method?.js)
    }

    @Test(expected = IllegalArgumentException::class)
    fun testLoadJSInvalid() {
        WebViewMethod.Parser.parse(MethodCall("loadJS", mapOf(
                "js" to null
        )))
    }
}