package com.klarna.inapp.sdk.flutter_klarna_inapp_sdk

import org.junit.Assert
import org.junit.Test

class StreamCallHandlerManagerTest {

    @Test
    fun testMap() {
        val map = StreamCallHandlerManager.streamHandlerMap
        Assert.assertEquals(2, map.size)
        Assert.assertEquals(EventCallbackHandler, map["klarna_events"])
        Assert.assertEquals(ErrorCallbackHandler, map["klarna_errors"])
    }
}