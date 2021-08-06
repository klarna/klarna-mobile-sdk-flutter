package com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.payment

import com.klarna.mobile.sdk.api.payments.KlarnaPaymentView
import com.klarna.mobile.sdk.api.payments.KlarnaPaymentViewCallback
import com.klarna.mobile.sdk.api.payments.KlarnaPaymentsSDKError
import io.flutter.plugin.common.MethodChannel

internal class KlarnaPaymentSDKCallback constructor(methodChannel: MethodChannel) : KlarnaPaymentViewCallback {
    private val callbackMethodChannel = methodChannel;

    override fun onAuthorized(view: KlarnaPaymentView, approved: Boolean, authToken: String?, finalizedRequired: Boolean?) {
        val args = mapOf("authToken" to authToken, "approved" to approved, "finalizedRequired" to finalizedRequired)
        callbackMethodChannel.invokeMethod("onAuthorized", args)
    }

    override fun onErrorOccurred(view: KlarnaPaymentView, error: KlarnaPaymentsSDKError) {
        val args = mapOf(
                "message" to error.message,
                "action" to error.action,
                "name" to error.name,
                "invalidFields" to error.invalidFields,
                "isFatal" to error.isFatal
        )
        callbackMethodChannel.invokeMethod("onErrorOccurred", args)
    }

    override fun onFinalized(view: KlarnaPaymentView, approved: Boolean, authToken: String?) {
        val args = mapOf("approved" to approved, "authToken" to authToken)
        callbackMethodChannel.invokeMethod("onFinalized", args)
    }

    override fun onInitialized(view: KlarnaPaymentView) {
        callbackMethodChannel.invokeMethod("onInitialized", null)
    }

    override fun onLoadPaymentReview(view: KlarnaPaymentView, showForm: Boolean) {
        val args = mapOf("showForm" to showForm)
        callbackMethodChannel.invokeMethod("onLoadPaymentReview", args)
    }

    override fun onLoaded(view: KlarnaPaymentView) {
        callbackMethodChannel.invokeMethod("onLoaded", null)
    }

    override fun onReauthorized(view: KlarnaPaymentView, approved: Boolean, authToken: String?) {
        val args = mapOf("approved" to approved, "authToken" to authToken)
        callbackMethodChannel.invokeMethod("onReauthorized", args)
    }
}