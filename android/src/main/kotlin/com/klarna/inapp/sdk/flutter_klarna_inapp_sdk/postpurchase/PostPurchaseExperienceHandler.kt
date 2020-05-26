package com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.postpurchase

import android.view.View
import android.webkit.WebChromeClient
import com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.ResultError
import com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.core.handler.BaseMethodHandler
import com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.core.webview.WebViewManager
import com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.hybrid.KlarnaHybridSDKHandler
import io.flutter.plugin.common.MethodChannel

internal object PostPurchaseExperienceHandler : BaseMethodHandler<PostPurchaseExperienceMethod>(PostPurchaseExperienceMethod.Parser) {

    private var webViewManager: WebViewManager = WebViewManager()

    private var webViewClient: PostPurchaseExperienceWebViewClient? = null

    private var initialized = false

    private var initResult: MethodChannel.Result? = null
    private var authResult: MethodChannel.Result? = null
    private var renderResult: MethodChannel.Result? = null

    private val jsInterface = PostPurchaseExperienceJSInterface(object : PostPurchaseExperienceJSInterface.ResultCallback {

        override fun onInitialized(success: Boolean, error: String?) {
            if (success) {
                initResult?.success(null)
                initialized = true
            } else {
                initResult?.error(ResultError.POST_PURCHASE_ERROR.errorCode, error, null)
            }
            initResult = null
        }

        override fun onRenderOperation(result: PostPurchaseExperienceJSInterface.JSResult) {
            if (result.error == null) {
                renderResult?.success(result.data)
            } else {
                renderResult?.error(ResultError.POST_PURCHASE_ERROR.errorCode, result.error, result.data)
            }
            renderResult = null
        }

        override fun onAuthorizationRequest(success: Boolean, error: String?) {
            if (success) {
                authResult?.success(null)
            } else {
                authResult?.error(ResultError.POST_PURCHASE_ERROR.errorCode, error, null)
            }
            authResult = null
        }
    })

    private const val NOT_INITIALIZED = "PostPurchaseExperience is not initialized"

    private fun notInitialized(result: MethodChannel.Result?) {
        result?.error(
                ResultError.POST_PURCHASE_ERROR.errorCode,
                NOT_INITIALIZED,
                "Call 'PostPurchaseExperience.initialize' before this."
        )
    }

    override fun onMethod(method: PostPurchaseExperienceMethod, result: MethodChannel.Result) {
        when (method) {
            is PostPurchaseExperienceMethod.Initialize -> initialize(method, result)
            is PostPurchaseExperienceMethod.RenderOperation -> renderOperation(method, result)
            is PostPurchaseExperienceMethod.AuthorizationRequest -> authorizationRequest(method, result)
        }
    }

    private fun initialize(method: PostPurchaseExperienceMethod.Initialize, result: MethodChannel.Result) {
        if (webViewManager.webView != null || initialized) {
            result.error(ResultError.POST_PURCHASE_ERROR.errorCode, "Already initialized.", null)
            return
        }

        val hybridSDK = KlarnaHybridSDKHandler.hybridSDK
        if (hybridSDK != null) {
            webViewClient = PostPurchaseExperienceWebViewClient(hybridSDK)
        } else {
            KlarnaHybridSDKHandler.notInitialized(result)
            return
        }

        webViewManager.initialize(null)
        webViewManager.addToHybridSdk(null)

        val webView = webViewManager.requireWebView()
        webView.webChromeClient = WebChromeClient()
        webView.webViewClient = webViewClient
        webView.settings.javaScriptEnabled = true
        webView.settings.domStorageEnabled = true
        webView.visibility = View.INVISIBLE

        webView.addJavascriptInterface(jsInterface, "PPECallback")
        webView.loadUrl("file:///android_asset/ppe.html")

        val initScript = "initialize('${method.locale}', '${method.purchaseCountry}', '${method.design}')"
        webViewClient?.queueJS(webViewManager, initScript)

        initResult = result
    }

    private fun renderOperation(method: PostPurchaseExperienceMethod.RenderOperation, result: MethodChannel.Result) {
        if (!initialized) {
            notInitialized(result)
            return
        }
        renderResult = result
        webViewClient?.queueJS(webViewManager, "renderOperation('${method.locale}', '${method.operationToken}')")
    }

    private fun authorizationRequest(method: PostPurchaseExperienceMethod.AuthorizationRequest, result: MethodChannel.Result) {
        if (!initialized) {
            notInitialized(result)
            return
        }
        authResult = result
        webViewClient?.queueJS(webViewManager, "authorizationRequest('${method.locale}', " +
                "'${method.clientId}', " +
                "'${method.scope}', " +
                "'${method.redirectUri}', " +
                "'${method.state}', " +
                "'${method.loginHint}', " +
                "'${method.responseType}')")
    }
}