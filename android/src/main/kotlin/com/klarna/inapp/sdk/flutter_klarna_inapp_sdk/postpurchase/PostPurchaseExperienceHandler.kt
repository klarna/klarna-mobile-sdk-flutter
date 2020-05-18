package com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.postpurchase

import android.view.View
import android.webkit.WebChromeClient
import com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.core.handler.BaseMethodHandler
import com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.core.webview.WebViewManager
import io.flutter.plugin.common.MethodChannel

internal object PostPurchaseExperienceHandler : BaseMethodHandler<PostPurchaseExperienceMethod>(PostPurchaseExperienceMethod.Parser) {

    private var webViewManager: WebViewManager = WebViewManager()

    override fun onMethod(method: PostPurchaseExperienceMethod, result: MethodChannel.Result) {
        when (method) {
            is PostPurchaseExperienceMethod.Initialize -> initialize(method, result)
            is PostPurchaseExperienceMethod.RenderOperation -> renderOperation(method, result)
            is PostPurchaseExperienceMethod.AuthorizationRequest -> authorizationRequest(method, result)
        }
    }

    private fun initialize(method: PostPurchaseExperienceMethod.Initialize, result: MethodChannel.Result) {
        webViewManager.initialize(result)
        webViewManager.addToHybridSdk(result)

        val webView = webViewManager.requireWebView()
        webView.webChromeClient = WebChromeClient()
        webView.settings.javaScriptEnabled = true
        webView.settings.domStorageEnabled = true
        webView.visibility = View.INVISIBLE

        // TODO: html & callback interface
//        webView.addJavascriptInterface(javascriptInterface, "PPECallback")
//        webView.loadDataWithBaseURL("", html, "text/html", "utf-8", null)
    }

    private fun renderOperation(method: PostPurchaseExperienceMethod.RenderOperation, result: MethodChannel.Result) {
        TODO()
    }

    private fun authorizationRequest(method: PostPurchaseExperienceMethod.AuthorizationRequest, result: MethodChannel.Result) {
        TODO()
    }

}