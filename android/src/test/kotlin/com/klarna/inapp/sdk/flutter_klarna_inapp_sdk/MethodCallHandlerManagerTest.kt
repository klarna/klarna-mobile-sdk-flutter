package com.klarna.inapp.sdk.flutter_klarna_inapp_sdk

import com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.hybrid.KlarnaHybridSDKHandler
import com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.postpurchase.PostPurchaseExperienceHandler
import org.junit.Assert
import org.junit.Test


class MethodCallHandlerManagerTest {

    @Test
    fun testMap() {
        val map = MethodCallHandlerManager.methodHandlerMap
        Assert.assertEquals(2, map.size)
        Assert.assertEquals(KlarnaHybridSDKHandler, map["klarna_hybrid_sdk"])
        Assert.assertEquals(PostPurchaseExperienceHandler, map["klarna_post_purchase_experience"])
//        Assert.assertEquals(WebViewHandler, map["klarna_web_view"])
    }
}