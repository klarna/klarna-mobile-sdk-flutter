package com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.webview

import android.view.View
import android.view.ViewGroup
import android.webkit.WebView
import android.widget.FrameLayout
import com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.PluginContext
import com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.ResultError
import com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.core.handler.BaseMethodHandler
import com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.core.util.evaluateJavascriptCompat
import io.flutter.plugin.common.MethodChannel


internal class WebViewHandler : BaseMethodHandler<WebViewMethod>(WebViewMethod.Parser) {

    companion object {
        internal var webView: WebView? = null
            private set

        internal fun notInitialized(result: MethodChannel.Result) {
            result.error(
                    ResultError.WEB_VIEW_ERROR.errorCode,
                    "WebView is not initialized.",
                    "Call 'KlarnaWebView.initialize()' before using this method."
            )
        }
    }

    override fun onMethod(method: WebViewMethod, result: MethodChannel.Result) {
        when (method) {
            is WebViewMethod.Initialize -> initialize(method, result)
            is WebViewMethod.Destroy -> destroy(method, result)
            is WebViewMethod.Show -> show(method, result)
            is WebViewMethod.Hide -> hide(method, result)
            is WebViewMethod.LoadURL -> loadURL(method, result)
            is WebViewMethod.LoadJS -> loadJS(method, result)
        }
    }

    private fun initialize(method: WebViewMethod.Initialize, result: MethodChannel.Result) {
        if (webView == null) {
            webView = WebView(PluginContext.activity)
            addToActivityIfDetached()
            result.success(null)
            return
        }
        result.error(ResultError.WEB_VIEW_ERROR.errorCode, "WebView is already initialized.", null)
    }

    private fun destroy(method: WebViewMethod.Destroy, result: MethodChannel.Result) {
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

    private fun show(method: WebViewMethod.Show, result: MethodChannel.Result) {
        webView?.apply {
            visibility = View.VISIBLE
            result.success(null)
            return
        }
        notInitialized(result)
    }

    private fun hide(method: WebViewMethod.Hide, result: MethodChannel.Result) {
        webView?.apply {
            visibility = View.GONE
            result.success(null)
            return
        }
        notInitialized(result)
    }

    private fun loadURL(method: WebViewMethod.LoadURL, result: MethodChannel.Result) {
        webView?.apply {
            loadUrl(method.url)
            result.success(method.url)
            return
        }
        notInitialized(result)
    }

    private fun loadJS(method: WebViewMethod.LoadJS, result: MethodChannel.Result) {
        webView?.apply {
            evaluateJavascriptCompat(method.js, null)
            result.success(method.js)
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