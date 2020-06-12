package com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.postpurchase

import android.os.Handler
import android.os.Looper
import android.webkit.JavascriptInterface
import com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.core.util.ParserUtil
import com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.core.util.jsValue

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
        val error = message.jsValue()
        val success = error == null
        resultCallback?.onInitialized(success, error)
    }

    private fun onRenderOperation(message: String?) {
        val result = ParserUtil.fromJson<Map<String, String?>>(message)

        val resultData = result?.get("data").jsValue()
        val resultError = result?.get("error").jsValue()
        val success = resultError == null

        resultCallback?.onRenderOperation(success, resultData, resultError)
    }

    private fun onAuthorizationRequest(message: String?) {
        val error = message.jsValue()
        val success = error == null
        resultCallback?.onAuthorizationRequest(success, error)
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