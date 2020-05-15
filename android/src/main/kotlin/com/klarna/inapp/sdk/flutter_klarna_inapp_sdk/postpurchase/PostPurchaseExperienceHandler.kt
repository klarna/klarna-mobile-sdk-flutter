package com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.postpurchase

import android.view.View
import android.webkit.WebChromeClient
import com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.ResultError
import com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.core.handler.BaseMethodHandler
import com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.hybrid.KlarnaWebViewClient
import com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.webview.WebViewManager
import com.klarna.mobile.sdk.api.hybrid.KlarnaHybridSDK
import io.flutter.plugin.common.MethodChannel

internal class PostPurchaseExperienceHandler : BaseMethodHandler<PostPurchaseExperienceMethod>(PostPurchaseExperienceMethod.Parser) {

    private var webViewManager: WebViewManager = WebViewManager()
    private var klarnaHybridSDK: KlarnaHybridSDK? = null
    private val hybridSDKCallback: PPEKlarnaHybridSDKCallback = PPEKlarnaHybridSDKCallback()

    override fun onMethod(method: PostPurchaseExperienceMethod, result: MethodChannel.Result) {
        when (method) {
            is PostPurchaseExperienceMethod.Initialize -> initialize(method, result)
            is PostPurchaseExperienceMethod.RenderOperation -> renderOperation(method, result)
            is PostPurchaseExperienceMethod.AuthorizationRequest -> authorizationRequest(method, result)
        }
    }

    private fun initialize(method: PostPurchaseExperienceMethod.Initialize, result: MethodChannel.Result) {
        if (klarnaHybridSDK == null) {
            klarnaHybridSDK = KlarnaHybridSDK(method.returnUrl, hybridSDKCallback)
        } else {
            result.error(ResultError.POST_PURCHASE_ERROR.errorCode, "Already initialized.", null)
            return
        }

        webViewManager.initialize(result)
        webViewManager.webView?.apply {
            webViewClient = KlarnaWebViewClient(klarnaHybridSDK!!)
            webChromeClient = WebChromeClient()
            settings.javaScriptEnabled = true
            settings.domStorageEnabled = true
            visibility = View.INVISIBLE

            klarnaHybridSDK?.addWebView(this)

            // TODO: html & callback interface
//            addJavascriptInterface(javascriptInterface, "PPECallback")
//            loadDataWithBaseURL("", html, "text/html", "utf-8", null)
        }
    }

    private fun renderOperation(method: PostPurchaseExperienceMethod.RenderOperation, result: MethodChannel.Result) {
        TODO()
    }

    private fun authorizationRequest(method: PostPurchaseExperienceMethod.AuthorizationRequest, result: MethodChannel.Result) {
        TODO()
    }

}