package com.klarna.inapp.sdk.klarna_inapp_flutter_plugin

import com.klarna.inapp.sdk.klarna_inapp_flutter_plugin.hybrid.KlarnaHybridSDKHandler
import com.klarna.inapp.sdk.klarna_inapp_flutter_plugin.postpurchase.PostPurchaseExperienceHandler
import com.klarna.inapp.sdk.klarna_inapp_flutter_plugin.webview.WebViewHandler
import io.flutter.plugin.common.MethodChannel

internal object MethodCallHandlerManager {

    val handlerMap: Map<String, MethodChannel.MethodCallHandler> = mapOf(
            "klarna_web_view" to WebViewHandler(),
            "klarna_hybrid_sdk" to KlarnaHybridSDKHandler(),
            "klarna_post_purchase_experience" to PostPurchaseExperienceHandler()
    )
}