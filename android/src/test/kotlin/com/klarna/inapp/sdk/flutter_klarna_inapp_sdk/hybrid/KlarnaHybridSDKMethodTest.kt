package com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.hybrid

import io.flutter.plugin.common.MethodCall
import org.junit.Assert
import org.junit.Test

class KlarnaHybridSDKMethodTest {

    @Test
    fun testInitializeValid() {
        val method = KlarnaHybridSDKMethod.Parser.parse(MethodCall("initialize", mapOf("returnUrl" to "test")))
        Assert.assertNotNull(method)
        Assert.assertEquals("test", (method as KlarnaHybridSDKMethod.Initialize).returnUrl)
    }

    @Test(expected = IllegalArgumentException::class)
    fun testInitializeInvalid() {
        KlarnaHybridSDKMethod.Parser.parse(MethodCall("initialize", mapOf("returnUrl" to null)))
    }

    @Test
    fun testInvalidMethod() {
        val method = KlarnaHybridSDKMethod.Parser.parse(MethodCall("invalid", mapOf("returnUrl" to "test")))
        Assert.assertNull(method)
    }
}