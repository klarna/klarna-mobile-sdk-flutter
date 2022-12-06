package com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.postpurchaseexperience

import android.graphics.Color
import android.util.Log
import android.view.View
import android.webkit.WebChromeClient
import com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.ErrorCallbackHandler
import com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.ResultError
import com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.core.manager.AssetManager
import com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.core.util.jsScriptString
import com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.core.webview.WebViewManager
import com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.hybrid.KlarnaHybridSDKCallback
import com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.hybrid.KlarnaHybridSDKEventListener
import com.klarna.mobile.sdk.api.hybrid.KlarnaHybridSDK
import io.flutter.plugin.common.MethodChannel

internal class PostPurchaseExperienceManager {

    companion object {
        private const val NOT_INITIALIZED = "PostPurchaseExperience is not initialized"

        fun notInitialized(result: MethodChannel.Result?) {
            result?.error(
                ResultError.POST_PURCHASE_ERROR.errorCode,
                NOT_INITIALIZED,
                "Call 'PostPurchaseExperience.initialize' before this."
            )
        }
    }

    var hybridSDK: KlarnaHybridSDK? = null

    var webViewManager: WebViewManager = WebViewManager()

    var webViewClient: PostPurchaseExperienceWebViewClient? = null

    var initialized = false

    private var initResult: MethodChannel.Result? = null
    private var authResult: MethodChannel.Result? = null
    private var renderResult: MethodChannel.Result? = null

    private val jsInterface = PostPurchaseExperienceJSInterface(PPEResultCallback())
    private val hybridSDKCallback = KlarnaHybridSDKCallback()

    fun initialize(method: PostPurchaseExperienceMethod.Initialize, result: MethodChannel.Result?) {
        if (webViewManager.webView != null || initialized) {
            result?.error(ResultError.POST_PURCHASE_ERROR.errorCode, "Already initialized.", null)
            return
        }

        KlarnaHybridSDK(
            method.returnUrl,
            hybridSDKCallback
        ).let { klarnaHybridSDK: KlarnaHybridSDK ->
            hybridSDK = klarnaHybridSDK
            webViewClient = PostPurchaseExperienceWebViewClient(klarnaHybridSDK)
            klarnaHybridSDK.registerEventListener(
                KlarnaHybridSDKEventListener(PostPurchaseExperienceEventHandler)
            )

            webViewManager.initialize(null)
        }

        val webView = webViewManager.requireWebView()
        webView.webChromeClient = WebChromeClient()
        webViewClient?.let {
            webView.webViewClient = it
        } ?: run {
            result?.error(ResultError.POST_PURCHASE_ERROR.errorCode, "Failed to initialize.", null)
            return
        }
        webView.settings.javaScriptEnabled = true
        webView.settings.domStorageEnabled = true
        webView.visibility = View.INVISIBLE
        webView.setBackgroundColor(Color.TRANSPARENT)

        hybridSDK?.addWebView(webView)

        webView.addJavascriptInterface(jsInterface, "PPECallback")

        val defaultLibrarySource = "https://x.klarnacdn.net/postpurchaseexperience/lib/v1/sdk.js"
        if (method.sdkSource.isNullOrBlank() || method.sdkSource == defaultLibrarySource) {
            webView.loadUrl("file:///android_asset/ppe.html")
        } else {
            AssetManager.readAsset("ppe.html")?.let { html ->
                html.replace(defaultLibrarySource, method.sdkSource).let {
                    webView.loadDataWithBaseURL(
                        "https://app.klarna.com",
                        it,
                        "text/html",
                        "UTF-8",
                        null
                    )
                }
            } ?: webView.loadUrl("file:///android_asset/ppe.html")
        }

        initResult = result
        initialized = false
        val initScript =
            "initialize(${method.locale.jsScriptString()}, ${method.purchaseCountry.jsScriptString()}, ${method.design.jsScriptString()})"
        webViewClient?.queueJS(webViewManager, initScript)
    }

    fun destroy(method: PostPurchaseExperienceMethod.Destroy, result: MethodChannel.Result?) {
        webViewManager.destroy(null)
        webViewManager = WebViewManager()
        webViewClient = null
        initialized = false
        initResult = null
        renderResult = null
        authResult = null
        hybridSDK = null
        result?.success(null)
    }

    fun renderOperation(
        method: PostPurchaseExperienceMethod.RenderOperation,
        result: MethodChannel.Result?
    ) {
        if (!initialized) {
            notInitialized(result)
            return
        }
        renderResult = result
        webViewClient?.queueJS(
            webViewManager,
            "renderOperation(${method.locale.jsScriptString()}, ${method.operationToken.jsScriptString()})"
        )
        showWebView()
    }

    fun authorizationRequest(
        method: PostPurchaseExperienceMethod.AuthorizationRequest,
        result: MethodChannel.Result?
    ) {
        if (!initialized) {
            notInitialized(result)
            return
        }
        authResult = result
        webViewClient?.queueJS(
            webViewManager, "authorizationRequest(${method.locale.jsScriptString()}, " +
                    "${method.clientId.jsScriptString()}, " +
                    "${method.scope.jsScriptString()}, " +
                    "${method.redirectUri.jsScriptString()}, " +
                    "${method.state.jsScriptString()}, " +
                    "${method.loginHint.jsScriptString()}, " +
                    "${method.responseType.jsScriptString()})"
        )
        showWebView()
    }

    private fun showWebView() {
        webViewManager.show(null)
    }

    private fun hideWebView() {
        webViewManager.hide(null)
    }

    inner class PPEResultCallback : PostPurchaseExperienceJSInterface.ResultCallback {

        override fun onInitialize(success: Boolean, message: String?, error: String?) {
            if (success) {
                initResult?.success(message)
                initialized = true
                Log.d("PPEResultCallback", "initialize successful: $message - $error")
            } else {
                initResult?.error(ResultError.POST_PURCHASE_ERROR.errorCode, message, error)
                Log.d("PPEResultCallback", "initialize failed: $message - $error")
            }
            initResult = null
        }

        override fun onRenderOperation(success: Boolean, message: String?, error: String?) {
            if (success) {
                renderResult?.success(message)
                Log.d("PPEResultCallback", "renderOperation successful: $message - $error")
            } else {
                renderResult?.error(ResultError.POST_PURCHASE_ERROR.errorCode, message, error)
                Log.d("PPEResultCallback", "renderOperation failed: $message - $error")
            }
            renderResult = null
            hideWebView()
        }

        override fun onAuthorizationRequest(success: Boolean, message: String?, error: String?) {
            if (success) {
                authResult?.success(message)
                Log.d("PPEResultCallback", "authorizationRequest successful: $message - $error")
            } else {
                authResult?.error(ResultError.POST_PURCHASE_ERROR.errorCode, message, error)
                Log.d("PPEResultCallback", "authorizationRequest failed: $message - $error")
            }
            authResult = null
            hideWebView()
        }

        override fun onError(message: String?, throwable: Throwable?) {
            ErrorCallbackHandler.sendValue(message)
            hideWebView()
            Log.d("PPEResultCallback", "error: $message")
        }
    }
}