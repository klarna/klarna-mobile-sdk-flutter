package com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.postpurchase

import android.graphics.Color
import android.view.View
import android.webkit.WebChromeClient
import com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.ErrorCallbackHandler
import com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.ResultError
import com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.core.util.jsScriptString
import com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.core.webview.WebViewManager
import com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.hybrid.KlarnaHybridSDKHandler
import io.flutter.plugin.common.MethodChannel

internal class PostPurchaseExperienceManager {

    companion object {
        private const val NOT_INITIALIZED = "PostPurchaseExperience is not initialized"

        private fun notInitialized(result: MethodChannel.Result?) {
            result?.error(
                    ResultError.POST_PURCHASE_ERROR.errorCode,
                    NOT_INITIALIZED,
                    "Call 'PostPurchaseExperience.initialize' before this."
            )
        }
    }

    private var webViewManager: WebViewManager = WebViewManager()

    private var webViewClient: PostPurchaseExperienceWebViewClient? = null

    private var initialized = false

    private var initResult: MethodChannel.Result? = null
    private var authResult: MethodChannel.Result? = null
    private var renderResult: MethodChannel.Result? = null

    private val jsInterface = PostPurchaseExperienceJSInterface(PPEResultCallback())

    fun initialize(method: PostPurchaseExperienceMethod.Initialize, result: MethodChannel.Result?) {
        if (webViewManager.webView != null || initialized) {
            result?.error(ResultError.POST_PURCHASE_ERROR.errorCode, "Already initialized.", null)
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
        webView.setBackgroundColor(Color.TRANSPARENT)

        webView.addJavascriptInterface(jsInterface, "PPECallback")
        webView.loadUrl("file:///android_asset/ppe.html")

        val initScript = "initialize(${method.locale.jsScriptString()}, ${method.purchaseCountry.jsScriptString()}, ${method.design.jsScriptString()})"
        webViewClient?.queueJS(webViewManager, initScript)

        initResult = result
    }

    fun destroy(method: PostPurchaseExperienceMethod.Destroy, result: MethodChannel.Result?) {
        webViewManager.destroy(null)
        webViewManager = WebViewManager()
        webViewClient = null
        initialized = false
        initResult = null
        renderResult = null
        authResult = null
        result?.success(null)
    }

    fun renderOperation(method: PostPurchaseExperienceMethod.RenderOperation, result: MethodChannel.Result?) {
        if (!initialized) {
            notInitialized(result)
            return
        }
        renderResult = result
        webViewClient?.queueJS(webViewManager, "renderOperation(${method.locale.jsScriptString()}, ${method.operationToken.jsScriptString()})")
        showWebView()
    }

    fun authorizationRequest(method: PostPurchaseExperienceMethod.AuthorizationRequest, result: MethodChannel.Result?) {
        if (!initialized) {
            notInitialized(result)
            return
        }
        authResult = result
        webViewClient?.queueJS(webViewManager, "authorizationRequest(${method.locale.jsScriptString()}, " +
                "${method.clientId.jsScriptString()}, " +
                "${method.scope.jsScriptString()}, " +
                "${method.redirectUri.jsScriptString()}, " +
                "${method.state.jsScriptString()}, " +
                "${method.loginHint.jsScriptString()}, " +
                "${method.responseType.jsScriptString()})")
        showWebView()
    }

    private fun showWebView() {
        webViewManager.show(null)
    }

    private fun hideWebView() {
        webViewManager.hide(null)
    }

    inner class PPEResultCallback : PostPurchaseExperienceJSInterface.ResultCallback {

        override fun onInitialized(success: Boolean, error: String?) {
            if (success) {
                initResult?.success(null)
                initialized = true
            } else {
                initResult?.error(ResultError.POST_PURCHASE_ERROR.errorCode, error, null)
            }
            initResult = null
        }

        override fun onRenderOperation(success: Boolean, data: String?, error: String?) {
            if (success) {
                renderResult?.success(data)
            } else {
                renderResult?.error(ResultError.POST_PURCHASE_ERROR.errorCode, error, data)
            }
            renderResult = null
            hideWebView()
        }

        override fun onAuthorizationRequest(success: Boolean, error: String?) {
            if (success) {
                authResult?.success(null)
            } else {
                authResult?.error(ResultError.POST_PURCHASE_ERROR.errorCode, error, null)
            }
            authResult = null
            hideWebView()
        }

        override fun onError(message: String?, throwable: Throwable?) {
            ErrorCallbackHandler.sendValue(message)
            hideWebView()
        }
    }
}