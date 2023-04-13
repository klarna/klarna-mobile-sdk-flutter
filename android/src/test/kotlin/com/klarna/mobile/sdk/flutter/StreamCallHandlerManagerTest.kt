package com.klarna.mobile.sdk.flutter

import com.klarna.mobile.sdk.flutter.postpurchase.callback.KlarnaPostPurchaseSDKCallbackHandler
import org.junit.Assert
import org.junit.Test

class StreamCallHandlerManagerTest {

    @Test
    fun testMap() {
        val map = StreamCallHandlerManager.streamHandlerMap
        Assert.assertEquals(1, map.size)
        Assert.assertEquals(
            KlarnaPostPurchaseSDKCallbackHandler,
            map["klarna_post_purchase_sdk_events"]
        )
    }
}