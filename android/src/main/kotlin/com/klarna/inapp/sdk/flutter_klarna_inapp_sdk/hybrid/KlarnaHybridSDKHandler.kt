package com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.hybrid

import com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.core.handler.BaseMethodHandler
import com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.core.webview.KlarnaWebViewClient
import com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.webview.WebViewHandler
import com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.core.webview.WebViewManager
import com.klarna.mobile.sdk.api.hybrid.KlarnaHybridSDK
import io.flutter.plugin.common.MethodChannel

internal class KlarnaHybridSDKHandler : BaseMethodHandler<KlarnaHybridSDKMethod>(KlarnaHybridSDKMethod.Parser) {

    companion object {
        internal lateinit var hybridSDK: KlarnaHybridSDK
        internal lateinit var hybridSDKCallback: KlarnaHybridSDKCallback
    }

    override fun onMethod(method: KlarnaHybridSDKMethod, result: MethodChannel.Result) {
        when (method) {
            is KlarnaHybridSDKMethod.Initialize -> initialize(method, result)
            is KlarnaHybridSDKMethod.SetupWebView -> setupWebView(method, result)
        }
    }

    private fun initialize(method: KlarnaHybridSDKMethod.Initialize, result: MethodChannel.Result) {
        hybridSDKCallback = KlarnaHybridSDKCallback()
        hybridSDKCallback.result = result
        hybridSDK = KlarnaHybridSDK(method.returnUrl, hybridSDKCallback)
        result.success(null)
    }

    private fun setupWebView(method: KlarnaHybridSDKMethod.SetupWebView, result: MethodChannel.Result) {
        WebViewHandler.webViewManager.webView?.let {
            hybridSDKCallback.result = result
            it.webViewClient = KlarnaWebViewClient(hybridSDK)
            hybridSDK.addWebView(it)
            result.success(null)
            return
        }
        WebViewManager.notInitialized(result)
    }
}