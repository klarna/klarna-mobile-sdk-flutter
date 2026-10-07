package com.klarna.mobile.sdk.klarna_network_payment

import android.content.Context
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import com.klarna.mobile.sdk.api.KlarnaTheme
import com.klarna.mobile.sdk.api.button.KlarnaButtonShape
import com.klarna.mobile.sdk.api.button.KlarnaButtonStyle
import com.klarna.mobile.sdk.klarna.network.core.api.button.KlarnaButtonState
import com.klarna.mobile.sdk.klarna.network.payment.button.api.KlarnaPaymentButton
import com.klarna.mobile.sdk.klarna.network.payment.button.api.KlarnaPaymentButtonConfiguration
import com.klarna.mobile.sdk.klarna.network.payment.button.api.KlarnaPaymentButtonIntent
import com.klarna.mobile.sdk.klarna_network_core.KnInstanceStore
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MessageCodec
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class KlarnaPaymentButtonFactory(
    private val messenger: BinaryMessenger? = null,
    codec: MessageCodec<Any?> = StandardMessageCodec.INSTANCE,
) : PlatformViewFactory(codec) {
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        @Suppress("UNCHECKED_CAST")
        val params = args as? Map<String, Any?> ?: emptyMap()
        return KlarnaPaymentButtonView(context, params, messenger)
    }
}

private class KlarnaPaymentButtonView(
    private val context: Context,
    params: Map<String, Any?>,
    private val messenger: BinaryMessenger?,
) : PlatformView, MethodChannel.MethodCallHandler {

    private val container = FrameLayout(context)

    private val viewId = (params["viewId"] as? Number)?.toLong() ?: 0L

    private val currentParams: MutableMap<String, Any?> = params.toMutableMap()

    private var button: KlarnaPaymentButton? = null

    private val mainHandler = Handler(Looper.getMainLooper())
    private var disposed = false
    private val flutterApi: KnPaymentFlutterApi? =
        messenger?.let { KnPaymentFlutterApi(it) }
    private val methodChannel: MethodChannel? = messenger?.let {
        MethodChannel(it, "com.klarna.mobile.sdk/payment_button/$viewId")
    }

    init {
        methodChannel?.setMethodCallHandler(this)
        buildButton(currentParams)
    }

    override fun getView(): View = container

    override fun dispose() {
        disposed = true
        mainHandler.removeCallbacksAndMessages(null)
        methodChannel?.setMethodCallHandler(null)
        container.removeAllViews()
        button = null
    }

    private fun buildButton(params: Map<String, Any?>) {
        button = null
        val instanceId = params["instanceId"] as? String
        val sdk = instanceId?.let { KnInstanceStore.getInstance(it) }
        if (sdk == null) {
            Log.e(
                "KlarnaPaymentButton",
                "Klarna instance '$instanceId' is not available; cannot render the payment button.",
            )
            return
        }
        try {
            val configuration = KlarnaPaymentButtonConfiguration(
                intent = parseIntent(params["intent"] as? String),
                state = parseState(params["state"] as? String),
                shape = parseShape(params["shape"] as? String),
                style = parseStyle(params["buttonStyle"] as? String),
                theme = parseTheme(params["theme"] as? String),
            )
            val newButton = KlarnaPaymentButton(context, sdk, configuration)
            newButton.setOnClickListener {
                flutterApi?.onButtonPressed(viewId) { }
            }
            container.addView(
                newButton,
                ViewGroup.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT,
                    heightPx(params),
                ),
            )
            button = newButton
        } catch (e: Exception) {
            Log.e("KlarnaPaymentButton", "Failed to create KlarnaPaymentButton", e)
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "setProps" -> {
                @Suppress("UNCHECKED_CAST")
                val newProps = call.arguments as? Map<String, Any?> ?: emptyMap()
                mainHandler.post {
                    if (!disposed) {
                        applyProps(newProps)
                    }
                }
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    private fun applyProps(newProps: Map<String, Any?>) {
        val previous = currentParams.toMap()
        currentParams.putAll(newProps)

        fun changed(key: String): Boolean =
            newProps.containsKey(key) && newProps[key] != previous[key]

        val recreateNeeded = changed("instanceId") ||
            changed("intent") ||
            changed("shape") ||
            changed("buttonStyle") ||
            changed("theme")

        // Recreate the native button for structural prop changes; state/height
        // can be applied in place without remounting the platform view.
        if (recreateNeeded) {
            container.removeAllViews()
            buildButton(currentParams)
            return
        }

        if (changed("state")) {
            button?.state = parseState(currentParams["state"] as? String)
        }

        if (changed("height")) {
            button?.let {
                val lp = it.layoutParams ?: ViewGroup.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT,
                    ViewGroup.LayoutParams.WRAP_CONTENT,
                )
                lp.height = heightPx(currentParams)
                it.layoutParams = lp
            }
        }
    }

    private fun heightPx(params: Map<String, Any?>): Int {
        val logical = (params["height"] as? Number)?.toDouble()
            ?: return ViewGroup.LayoutParams.WRAP_CONTENT
        if (logical <= 0.0) return ViewGroup.LayoutParams.WRAP_CONTENT
        val density = context.resources.displayMetrics.density
        return (logical * density).toInt()
    }

    private fun parseState(value: String?): KlarnaButtonState = when (value) {
        "disabled" -> KlarnaButtonState.DISABLED
        "loading" -> KlarnaButtonState.LOADING
        else -> KlarnaButtonState.DEFAULT
    }

    private fun parseIntent(value: String?): KlarnaPaymentButtonIntent = when (value) {
        "subscribe" -> KlarnaPaymentButtonIntent.SUBSCRIBE
        "addToWallet" -> KlarnaPaymentButtonIntent.ADD_TO_WALLET
        else -> KlarnaPaymentButtonIntent.PAY
    }

    private fun parseShape(value: String?): KlarnaButtonShape = when (value) {
        "pill" -> KlarnaButtonShape.PILL
        "rectangle" -> KlarnaButtonShape.RECTANGLE
        else -> KlarnaButtonShape.ROUNDED_RECT
    }

    private fun parseStyle(value: String?): KlarnaButtonStyle = when (value) {
        "outlined" -> KlarnaButtonStyle.OUTLINED
        else -> KlarnaButtonStyle.FILLED
    }

    private fun parseTheme(value: String?): KlarnaTheme = when (value) {
        "light" -> KlarnaTheme.LIGHT
        "automatic" -> KlarnaTheme.AUTOMATIC
        else -> KlarnaTheme.DARK
    }

}
