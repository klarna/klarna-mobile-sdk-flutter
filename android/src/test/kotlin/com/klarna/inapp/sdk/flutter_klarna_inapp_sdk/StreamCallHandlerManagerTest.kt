package com.klarna.inapp.sdk.flutter_klarna_inapp_sdk

import com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.hybrid.KlarnaHybridSDKEventHandler
import com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.postpurchaseexperience.PostPurchaseExperienceEventHandler
import org.junit.Assert
import org.junit.Test

class StreamCallHandlerManagerTest {

    @Test
    fun testMap() {
        val map = StreamCallHandlerManager.streamHandlerMap
        Assert.assertEquals(4, map.size)
        Assert.assertEquals(EventCallbackHandler, map["klarna_events"])
        Assert.assertEquals(ErrorCallbackHandler, map["klarna_errors"])
        Assert.assertEquals(KlarnaHybridSDKEventHandler, map["klarna_hybrid_sdk_events"])
        Assert.assertEquals(
            PostPurchaseExperienceEventHandler,
            map["klarna_post_purchase_experience_events"]
        )
    }
}