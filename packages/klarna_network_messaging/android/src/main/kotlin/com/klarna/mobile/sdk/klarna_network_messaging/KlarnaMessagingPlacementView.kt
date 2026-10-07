package com.klarna.mobile.sdk.klarna_network_messaging

import android.content.ComponentCallbacks
import android.content.Context
import android.content.res.Configuration
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.view.View
import android.view.ViewGroup
import android.view.ViewTreeObserver
import android.widget.FrameLayout
import com.klarna.mobile.sdk.api.KlarnaTheme
import com.klarna.mobile.sdk.klarna.network.messaging.api.KlarnaMessagingPlacementConfiguration
import com.klarna.mobile.sdk.klarna.network.messaging.api.KlarnaMessagingPlacementView
import com.klarna.mobile.sdk.klarna_network_core.KnInstanceStore
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MessageCodec
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class KlarnaMessagingPlacementViewFactory(
    private val messenger: BinaryMessenger? = null,
    codec: MessageCodec<Any?> = StandardMessageCodec.INSTANCE,
) : PlatformViewFactory(codec) {
    override fun create(
        context: Context,
        viewId: Int,
        args: Any?,
    ): PlatformView {
        @Suppress("UNCHECKED_CAST")
        val params = args as? Map<String, Any?> ?: emptyMap()
        return KlarnaMessagingPlacementViewImpl(context, params, messenger)
    }
}

private class KlarnaMessagingPlacementViewImpl(
    private val context: Context,
    params: Map<String, Any?>,
    private val messenger: BinaryMessenger?,
) : PlatformView,
    MethodChannel.MethodCallHandler {
    private val container = FrameLayout(context)

    private val viewId = (params["viewId"] as? Number)?.toLong() ?: 0L

    private val flutterApi: KnMessagingFlutterApi? =
        messenger?.let { KnMessagingFlutterApi(it) }

    private val methodChannel: MethodChannel? =
        messenger?.let {
            MethodChannel(it, "com.klarna.mobile.sdk/messaging_placement/$viewId")
        }

    private val handler = Handler(Looper.getMainLooper())

    private val currentParams: MutableMap<String, Any?> = params.toMutableMap()

    private var placementView: View? = null
    private var preDrawListener: ViewTreeObserver.OnPreDrawListener? = null
    private var preDrawTarget: View? = null
    private var lastReportedHeightDp: Int? = null
    private var lastNightMode: Int = context.resources.configuration.uiMode and Configuration.UI_MODE_NIGHT_MASK

    companion object {
        private const val TAG = "KlarnaMessaging"

        private val HEIGHT_CHECK_DELAYS_MS = longArrayOf(100, 500, 1500, 3000, 6000)
    }

    private val configCallbacks =
        object : ComponentCallbacks {
            override fun onConfigurationChanged(newConfig: Configuration) {
                handleConfigurationChanged(newConfig)
            }

            @Suppress("OVERRIDE_DEPRECATION")
            override fun onLowMemory() {}
        }

    init {
        methodChannel?.setMethodCallHandler(this)
        context.registerComponentCallbacks(configCallbacks)
        buildPlacement(currentParams)
    }

    override fun getView(): View = container

    override fun dispose() {
        methodChannel?.setMethodCallHandler(null)
        context.unregisterComponentCallbacks(configCallbacks)
        removeLayoutListener()
        handler.removeCallbacksAndMessages(null)
        container.removeAllViews()
        placementView = null
    }

    private fun handleConfigurationChanged(newConfig: Configuration) {
        val newNightMode = newConfig.uiMode and Configuration.UI_MODE_NIGHT_MASK
        if (newNightMode == lastNightMode) return
        lastNightMode = newNightMode

        val isAutomatic = KlarnaMessagingParsing.resolveThemeKind(currentParams["theme"] as? String) == MessagingThemeKind.AUTOMATIC
        if (isAutomatic) {
            val themedContext = context.createConfigurationContext(newConfig)
            handler.post { buildPlacement(currentParams, themedContext) }
        }
    }

    override fun onMethodCall(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        when (call.method) {
            "setProps" -> {
                @Suppress("UNCHECKED_CAST")
                val newProps = call.arguments as? Map<String, Any?> ?: emptyMap()
                val previous = currentParams.toMap()
                currentParams.putAll(newProps)

                fun changed(key: String): Boolean = newProps.containsKey(key) && newProps[key] != previous[key]

                val needsRebuild =
                    changed("instanceId") ||
                        changed("placementType") ||
                        changed("theme") ||
                        changed("amount") ||
                        changed("currency")

                if (needsRebuild) {
                    handler.post { buildPlacement(currentParams) }
                }
                result.success(null)
            }

            else -> {
                result.notImplemented()
            }
        }
    }

    private fun buildPlacement(
        params: Map<String, Any?>,
        viewContext: Context = context,
    ) {
        removeLayoutListener()
        handler.removeCallbacksAndMessages(null)
        container.removeAllViews()
        placementView = null
        lastReportedHeightDp = null

        val amount = KlarnaMessagingParsing.parseAmount(params["amount"] as? String) ?: return
        val currency = params["currency"] as? String
        if (currency.isNullOrEmpty()) return

        val instanceId = params["instanceId"] as? String
        if (instanceId.isNullOrEmpty()) return
        val klarna =
            KnInstanceStore.getInstance(instanceId) ?: run {
                dispatchResized(0.0)
                return
            }

        try {
            val theme = parseTheme(params["theme"] as? String)
            val configuration =
                buildConfiguration(
                    params["placementType"] as? String,
                    theme,
                    amount,
                    currency,
                )
            val view = KlarnaMessagingPlacementView(viewContext, klarna, configuration)
            container.addView(
                view,
                FrameLayout.LayoutParams(
                    FrameLayout.LayoutParams.MATCH_PARENT,
                    FrameLayout.LayoutParams.WRAP_CONTENT,
                ),
            )
            placementView = view
            attachMeasurementObserver(view)
        } catch (e: Exception) {
            Log.e(TAG, "Failed to create KlarnaMessagingPlacementView", e)
            dispatchResized(0.0)
        }
    }

    private fun attachMeasurementObserver(view: View) {
        val listener =
            ViewTreeObserver.OnPreDrawListener {
                reportHeight(view)
                true
            }
        view.viewTreeObserver.addOnPreDrawListener(listener)
        preDrawListener = listener
        preDrawTarget = view

        for ((index, delay) in HEIGHT_CHECK_DELAYS_MS.withIndex()) {
            val isLastCheck = index == HEIGHT_CHECK_DELAYS_MS.size - 1
            handler.postDelayed({
                reportHeight(view)
                if (isLastCheck && lastReportedHeightDp == null) {
                    dispatchResized(0.0)
                }
            }, delay)
        }
    }

    private fun reportHeight(view: View) {
        if (!view.isAttachedToWindow) return
        val width = container.width
        if (width <= 0) return

        val widthSpec = View.MeasureSpec.makeMeasureSpec(width, View.MeasureSpec.EXACTLY)
        val heightSpec = View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED)
        view.measure(widthSpec, heightSpec)

        val contentHeightPx = view.measuredHeight
        if (contentHeightPx <= 0) return

        val density = context.resources.displayMetrics.density
        val heightDp = Math.round(contentHeightPx / density)
        if (heightDp <= 0 || lastReportedHeightDp == heightDp) return
        lastReportedHeightDp = heightDp
        dispatchResized(heightDp.toDouble())
    }

    private fun removeLayoutListener() {
        val target = preDrawTarget
        val listener = preDrawListener
        if (target != null && listener != null) {
            val observer = target.viewTreeObserver
            if (observer.isAlive) {
                observer.removeOnPreDrawListener(listener)
            }
        }
        preDrawTarget = null
        preDrawListener = null
    }

    private fun dispatchResized(height: Double) {
        flutterApi?.onResized(viewId, height) { }
    }

    private fun parseTheme(value: String?): KlarnaTheme? =
        when (KlarnaMessagingParsing.resolveThemeKind(value)) {
            MessagingThemeKind.LIGHT -> KlarnaTheme.LIGHT
            MessagingThemeKind.DARK -> KlarnaTheme.DARK
            MessagingThemeKind.AUTOMATIC -> KlarnaTheme.AUTOMATIC
            null -> null
        }

    private fun buildConfiguration(
        placementType: String?,
        theme: KlarnaTheme?,
        amount: Long,
        currency: String,
    ): KlarnaMessagingPlacementConfiguration =
        when (KlarnaMessagingParsing.resolvePlacementKind(placementType)) {
            MessagingPlacementKind.BADGE -> {
                KlarnaMessagingPlacementConfiguration.CreditPromotionBadge(theme, amount, currency)
            }

            MessagingPlacementKind.AUTO_SIZE -> {
                KlarnaMessagingPlacementConfiguration.CreditPromotionAutoSize(theme, amount, currency)
            }
        }

}
