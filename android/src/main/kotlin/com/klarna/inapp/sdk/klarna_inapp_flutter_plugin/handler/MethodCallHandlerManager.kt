package com.klarna.inapp.sdk.klarna_inapp_flutter_plugin.handler

import com.klarna.inapp.sdk.klarna_inapp_flutter_plugin.handler.hybrid.KlarnaHybridSDKHandler
import com.klarna.inapp.sdk.klarna_inapp_flutter_plugin.handler.webview.WebViewHandler
import io.flutter.plugin.common.MethodChannel

internal object MethodCallHandlerManager {

    val handlerMap: Map<String, MethodChannel.MethodCallHandler> = mapOf(
            "klarna_web_view" to WebViewHandler(),
            "klarna_hybrid_sdk" to KlarnaHybridSDKHandler()
    )
}