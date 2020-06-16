package com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.core.util

import org.junit.Assert
import org.junit.Test

class StringExtensionsTest {

    @Test
    fun testJsScriptString() {
        Assert.assertEquals("\"test\"", "test".jsScriptString())
        Assert.assertEquals("\"\\test\\\"", "\\test\\".jsScriptString())
        Assert.assertEquals("null", null.jsScriptString())
    }

    @Test
    fun testJsIsNullOrUndefined() {
        Assert.assertTrue(null.jsIsNullOrUndefined())
        Assert.assertTrue("null".jsIsNullOrUndefined())
        Assert.assertTrue("undefined".jsIsNullOrUndefined())
        Assert.assertFalse("nulll".jsIsNullOrUndefined())
    }

    @Test
    fun testJsValue() {
        Assert.assertNull("null".jsValue())
        Assert.assertNull("undefined".jsValue())
        Assert.assertEquals("true", "true".jsValue())
    }
}