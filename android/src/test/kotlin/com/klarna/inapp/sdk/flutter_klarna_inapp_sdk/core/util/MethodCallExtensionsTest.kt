package com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.core.util

import io.flutter.plugin.common.MethodCall
import io.mockk.every
import io.mockk.mockk
import org.junit.Assert
import org.junit.Test

class MethodCallExtensionsTest {

    @Test
    fun testRequireArgumentValid() {
        val methodCall: MethodCall = mockk()
        every { methodCall.argument<Boolean>("test") } returns true

        Assert.assertTrue(methodCall.requireArgument("test"))
    }

    @Test(expected = IllegalArgumentException::class)
    fun testRequireArgumentInvalid() {
        val methodCall: MethodCall = mockk()
        every { methodCall.argument<Boolean>("test") } returns null

        methodCall.requireArgument<Boolean>("test")
    }
}