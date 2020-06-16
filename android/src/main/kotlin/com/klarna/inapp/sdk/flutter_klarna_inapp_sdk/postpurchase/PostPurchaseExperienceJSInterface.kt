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
            val callbackMessage: PPECallbackMessage
            try {
                callbackMessage = ParserUtil.fromJson(jsonMessage)!!
            } catch (t: Throwable) {
                resultCallback?.onError("Can not parse web message", t)
                return@post
            }
            val message = callbackMessage.message.jsValue()
            val error = callbackMessage.error.jsValue()
            val success = error == null
            when (callbackMessage.action) {
                "onInitialize" -> {
                    resultCallback?.onInitialize(success, message, error)
                }
                "onRenderOperation" -> {
                    resultCallback?.onRenderOperation(success, message, error)
                }
                "onAuthorizationRequest" -> {
                    resultCallback?.onAuthorizationRequest(success, message, error)
                }
                else -> resultCallback?.onError("No handler for callback message: $jsonMessage", null)
            }
        }
    }

    internal interface ResultCallback {
        fun onInitialize(success: Boolean, message: String?, error: String?)
        fun onAuthorizationRequest(success: Boolean, message: String?, error: String?)
        fun onRenderOperation(success: Boolean, message: String?, error: String?)
        fun onError(message: String?, throwable: Throwable?)
    }

    internal data class PPECallbackMessage(
            var action: String,
            var message: String?,
            var error: String?
    )
}