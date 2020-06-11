package com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.postpurchase

import android.os.Handler
import android.os.Looper
import android.webkit.JavascriptInterface
import com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.core.util.ParserUtil

internal class PostPurchaseExperienceJSInterface(private val resultCallback: ResultCallback?) {

    private val mainHandler = Handler(Looper.getMainLooper())

    @JavascriptInterface
    fun postMessage(jsonMessage: String?) {
        mainHandler.post {
            val message: PPECallbackMessage
            try {
                message = ParserUtil.fromJson(jsonMessage)!!
            } catch (t: Throwable) {
                resultCallback?.onError("Can not parse web message", t)
                return@post
            }
            when (message.action) {
                "onInitialize" -> {
                    onInitialized(message.message)
                }
                "onRenderOperation" -> {
                    onRenderOperation(message.message)
                }
                "onAuthorizationRequest" -> {
                    onAuthorizationRequest(message.message)
                }
                else -> resultCallback?.onError("No handler for action ${message.action}", null)
            }
        }
    }

    private fun onInitialized(message: String?) {
        val success = message == null || message == "undefined"
        resultCallback?.onInitialized(success, message)
    }

    private fun onRenderOperation(message: String?) {
        val result = ParserUtil.fromJson<Map<String, String?>>(message)
        val data = result?.get("data")
        val error = result?.get("error")

        val resultData = if (data == "null") null else data
        val resultError = if (error == "null") null else error
        val success = resultError == null

        resultCallback?.onRenderOperation(success, resultData, resultError)
    }

    private fun onAuthorizationRequest(message: String?) {
        val success = message == null || message == "undefined"
        resultCallback?.onAuthorizationRequest(success, message)
    }

    internal interface ResultCallback {
        fun onInitialized(success: Boolean, error: String?)
        fun onAuthorizationRequest(success: Boolean, error: String?)
        fun onRenderOperation(success: Boolean, data: String?, error: String?)
        fun onError(message: String?, throwable: Throwable?)
    }

    internal data class PPECallbackMessage(
            var action: String,
            var message: String?
    )
}