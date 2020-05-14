package com.klarna.inapp.sdk.klarna_inapp_flutter_plugin.hybrid

import com.klarna.inapp.sdk.klarna_inapp_flutter_plugin.core.handler.BaseMethodHandler
import com.klarna.inapp.sdk.klarna_inapp_flutter_plugin.webview.WebViewHandler
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
        WebViewHandler.webView?.let {
            hybridSDKCallback.result = result
            it.webViewClient = KlarnaWebViewClient()
            hybridSDK.addWebView(it)
            result.success(null)
            return
        }
        WebViewHandler.notInitialized(result)
    }
}