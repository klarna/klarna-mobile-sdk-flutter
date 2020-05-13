package com.klarna.inapp.sdk.klarna_inapp_flutter_plugin.handler.webview

import io.flutter.plugin.common.MethodCall

sealed class WebViewMethod(val methodName: String) {
    class Show : WebViewMethod("show")
    class Hide : WebViewMethod("hide")
    class LoadURL(val url: String?) : WebViewMethod("loadURL")
    class LoadJS(val js: String) : WebViewMethod("loadJS")

    companion object {
        fun findMethod(call: MethodCall): WebViewMethod? {
            return when (call.method) {
                "show" -> Show()
                "hide" -> Hide()
                "loadURL" -> LoadURL(call.argument("url"))
                "loadJS" -> LoadJS(call.argument("js") ?: return null)
                else -> null
            }
        }
    }
}