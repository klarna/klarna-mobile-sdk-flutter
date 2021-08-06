package com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.payment

import android.content.Context
import android.view.View
import com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.PluginContext
import com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.core.util.requireArgument
import com.klarna.mobile.sdk.api.payments.KlarnaPaymentCategory
import com.klarna.mobile.sdk.api.payments.KlarnaPaymentView
import io.flutter.Log
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.platform.PlatformView

class KlarnaPaymentViewWidget internal constructor(context: Context, id: Int, messenger: BinaryMessenger, creationParams: Map<String?, Any?>?) : PlatformView, MethodCallHandler {
    private val methodChannel: MethodChannel

    private val paymentView: KlarnaPaymentView

    private val paymentCategories = mapOf(
            "pay_now" to KlarnaPaymentCategory.PAY_NOW,
            "pay_later" to KlarnaPaymentCategory.PAY_LATER,
            "pay_over_time" to KlarnaPaymentCategory.SLICE_IT
    )

    override fun getView(): View {
        return paymentView
    }

    init {
        val paymentCategory = creationParams!!["category"] as String

        methodChannel = MethodChannel(messenger, "plugins/klarna_payment_view_$id")
        methodChannel.setMethodCallHandler(this)
        paymentView = KlarnaPaymentView(PluginContext.context!!, paymentCategories[paymentCategory]!!, KlarnaPaymentSDKCallback(methodChannel))
    }

    override fun onMethodCall(methodCall: MethodCall, result: Result) {
        when (methodCall.method) {
            "initialize" -> initialize(methodCall, result)
            "load" -> load(methodCall, result)
            "authorize" -> authorize(methodCall, result)
            "finalize" -> finalize(methodCall, result)
            "reauthorize" -> reauthorize(methodCall, result)
            "loadPaymentReview" -> loadPaymentReview(methodCall, result)
            else -> result.notImplemented()
        }
    }

    private fun initialize(methodCall: MethodCall, result: Result) {
        paymentView.initialize(methodCall.requireArgument("clientToken"), methodCall.requireArgument("returnUrl"))
        result.success(null)
    }

    private fun load(methodCall: MethodCall, result: Result) {
        paymentView.load(methodCall.argument("args"))
        result.success(null)
    }

    private fun authorize(methodCall: MethodCall, result: Result) {
        paymentView.authorize(methodCall.requireArgument("autoFinalize"), methodCall.argument("sessionData"))
        result.success(null)
    }

    private fun finalize(methodCall: MethodCall, result: Result) {
        paymentView.finalize(methodCall.argument("sessionData"));
        result.success(null)
    }

    private fun reauthorize(methodCall: MethodCall, result: Result) {
        paymentView.reauthorize(methodCall.argument("sessionData"));
        result.success(null)
    }

    private fun loadPaymentReview(methodCall: MethodCall, result: Result) {
        paymentView.loadPaymentReview();
        result.success(null)
    }

    override fun dispose() {
    }
}