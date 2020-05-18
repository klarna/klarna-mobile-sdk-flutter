package com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.postpurchase

import android.os.Handler
import android.os.Looper
import android.webkit.JavascriptInterface

internal class PostPurchaseExperienceJSInterface(private val resultCallback: ResultCallback?) {

    private val mainHandler = Handler(Looper.getMainLooper())

    @JavascriptInterface
    fun onInitialized(ppe: String?) {
        val success = ppe != null && ppe != "undefined"
        mainHandler.post {
            resultCallback?.onInitialized(success)
        }
    }

    @JavascriptInterface
    fun onRenderOperation(data: String?, error: String?) {
        val resultData = if (data == "null") null else data
        val resultError = if (error == "null") null else error

        mainHandler.post {
            resultCallback?.onRenderOperation(JSResult(resultData, resultError))
        }
    }

    @JavascriptInterface
    fun onAuthorizationRequest() {
        mainHandler.post {
            resultCallback?.onAuthorizationRequest()
        }
    }

    internal data class JSResult(
            val data: String?,
            val error: String?
    )

    internal interface ResultCallback {
        fun onInitialized(success: Boolean)
        fun onAuthorizationRequest()
        fun onRenderOperation(result: JSResult)
    }
}