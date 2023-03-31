package com.klarna.inapp.sdk.flutter_klarna_inapp_sdk

import com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.postpurchase.KlarnaPostPurchaseSDKHandler
import org.junit.Assert
import org.junit.Test


class MethodCallHandlerManagerTest {

    @Test
    fun testMap() {
        val map = MethodCallHandlerManager.methodHandlerMap
        Assert.assertEquals(1, map.size)
        Assert.assertEquals(KlarnaPostPurchaseSDKHandler, map["klarna_post_purchase_sdk"])
    }
}