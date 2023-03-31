package com.klarna.mobile.sdk.flutter

import com.klarna.mobile.sdk.flutter.postpurchase.KlarnaPostPurchaseSDKHandler
import io.flutter.plugin.common.MethodChannel

internal object MethodCallHandlerManager {

    val methodHandlerMap: Map<String, MethodChannel.MethodCallHandler> = mapOf(
        "klarna_post_purchase_sdk" to KlarnaPostPurchaseSDKHandler
    )
}