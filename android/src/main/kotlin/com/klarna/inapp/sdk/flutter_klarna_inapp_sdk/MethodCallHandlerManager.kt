package com.klarna.inapp.sdk.flutter_klarna_inapp_sdk

import com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.hybrid.KlarnaHybridSDKHandler
import com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.postpurchase.PostPurchaseExperienceHandler
import com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.webview.WebViewHandler
import io.flutter.plugin.common.MethodChannel

internal object MethodCallHandlerManager {

    val handlerMap: Map<String, MethodChannel.MethodCallHandler> = mapOf(
            "klarna_web_view" to WebViewHandler(),
            "klarna_hybrid_sdk" to KlarnaHybridSDKHandler(),
            "klarna_post_purchase_experience" to PostPurchaseExperienceHandler()
    )
}