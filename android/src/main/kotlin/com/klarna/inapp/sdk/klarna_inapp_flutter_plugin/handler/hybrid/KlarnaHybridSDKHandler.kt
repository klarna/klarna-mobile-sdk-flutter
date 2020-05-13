package com.klarna.inapp.sdk.klarna_inapp_flutter_plugin.handler.hybrid

import com.klarna.inapp.sdk.klarna_inapp_flutter_plugin.ResultError
import com.klarna.inapp.sdk.klarna_inapp_flutter_plugin.handler.webview.WebViewHandler
import com.klarna.mobile.sdk.api.hybrid.KlarnaHybridSDK
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

internal class KlarnaHybridSDKHandler : MethodChannel.MethodCallHandler {

    companion object {
        internal lateinit var hybridSDK: KlarnaHybridSDK
        internal lateinit var hybridSDKCallback: KlarnaHybridSDKCallback
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        try {
            val method = KlarnaHybridSDKMethod.findMethod(call)
            method?.let { onMethod(it, result) } ?: result.notImplemented()
        } catch (e: Throwable) {
            result.error(ResultError.EXCEPTION.errorCode, call.method, e.message)
        }
    }

    private fun onMethod(method: KlarnaHybridSDKMethod, result: MethodChannel.Result) {
        when (method) {
            is KlarnaHybridSDKMethod.Initialize -> initialize(method, result)
            is KlarnaHybridSDKMethod.SetupWebView -> addWebView(method, result)
        }
    }

    private fun initialize(method: KlarnaHybridSDKMethod.Initialize, result: MethodChannel.Result) {
        hybridSDKCallback = KlarnaHybridSDKCallback()
        hybridSDKCallback.result = result
        hybridSDK = KlarnaHybridSDK(method.returnUrl, hybridSDKCallback)
        result.success(null)
    }

    private fun addWebView(method: KlarnaHybridSDKMethod.SetupWebView, result: MethodChannel.Result) {
        hybridSDKCallback.result = result
        WebViewHandler.webView.webViewClient = KlarnaWebViewClient()
        hybridSDK.addWebView(WebViewHandler.webView)
        result.success(null)
    }
}