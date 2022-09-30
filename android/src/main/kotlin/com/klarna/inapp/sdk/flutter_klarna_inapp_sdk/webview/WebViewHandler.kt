package com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.webview

import com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.core.handler.BaseMethodHandler
import com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.core.webview.WebViewManager
import io.flutter.plugin.common.MethodChannel

internal object WebViewHandler : BaseMethodHandler<WebViewMethod>(WebViewMethod.Parser) {

    var webViewManager = WebViewManager()

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
        webViewManager.initialize(result)
    }

    private fun destroy(method: WebViewMethod.Destroy, result: MethodChannel.Result) {
        webViewManager.destroy(result)
    }

    private fun show(method: WebViewMethod.Show, result: MethodChannel.Result) {
        webViewManager.show(result)
    }

    private fun hide(method: WebViewMethod.Hide, result: MethodChannel.Result) {
        webViewManager.hide(result)
    }

    private fun loadURL(method: WebViewMethod.LoadURL, result: MethodChannel.Result) {
        webViewManager.loadURL(method.url, result)
    }

    private fun loadJS(method: WebViewMethod.LoadJS, result: MethodChannel.Result) {
        webViewManager.loadJS(method.js, result)
    }

}