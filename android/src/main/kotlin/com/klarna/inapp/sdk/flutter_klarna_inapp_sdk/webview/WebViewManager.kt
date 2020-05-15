package com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.webview

import android.view.View
import android.view.ViewGroup
import android.webkit.WebView
import android.widget.FrameLayout
import com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.PluginContext
import com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.ResultError
import com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.core.util.evaluateJavascriptCompat
import io.flutter.plugin.common.MethodChannel

internal class WebViewManager {

    companion object {
        internal fun notInitialized(result: MethodChannel.Result) {
            result.error(
                    ResultError.WEB_VIEW_ERROR.errorCode,
                    "WebView is not initialized.",
                    "Call 'initialize' before using this method."
            )
        }
    }

    var webView: WebView? = null
        private set

    fun initialize(result: MethodChannel.Result) {
        if (webView == null) {
            webView = WebView(PluginContext.activity)
            addToActivityIfDetached()
            result.success(null)
            return
        }
        result.error(ResultError.WEB_VIEW_ERROR.errorCode, "WebView is already initialized.", null)
    }

    fun destroy(result: MethodChannel.Result) {
        webView?.parent?.let {
            if (it is ViewGroup) {
                it.removeView(webView)
                webView = null
                result.success(null)
                return
            }
        }
        notInitialized(result)
    }

    fun show(result: MethodChannel.Result) {
        webView?.apply {
            visibility = View.VISIBLE
            result.success(null)
            return
        }
        notInitialized(result)
    }

    fun hide(result: MethodChannel.Result) {
        webView?.apply {
            visibility = View.GONE
            result.success(null)
            return
        }
        notInitialized(result)
    }

    fun loadURL(url: String, result: MethodChannel.Result) {
        webView?.apply {
            loadUrl(url)
            result.success(url)
            return
        }
        notInitialized(result)
    }

    fun loadJS(js: String, result: MethodChannel.Result) {
        webView?.apply {
            evaluateJavascriptCompat(js, null)
            result.success(js)
            return
        }
        notInitialized(result)
    }

    private fun addToActivityIfDetached() {
        PluginContext.activity?.let {
            if (webView?.parent == null) {
                val params: FrameLayout.LayoutParams = FrameLayout.LayoutParams(
                        ViewGroup.LayoutParams.MATCH_PARENT,
                        ViewGroup.LayoutParams.MATCH_PARENT
                )

                it.addContentView(webView, params)
            }
        }
    }
}