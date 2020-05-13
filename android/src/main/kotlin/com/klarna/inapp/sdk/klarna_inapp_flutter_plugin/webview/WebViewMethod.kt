package com.klarna.inapp.sdk.klarna_inapp_flutter_plugin.webview

import com.klarna.inapp.sdk.klarna_inapp_flutter_plugin.core.method.MethodParser
import io.flutter.plugin.common.MethodCall

internal sealed class WebViewMethod {
    object Show : WebViewMethod()
    object Hide : WebViewMethod()
    class LoadURL(val url: String?) : WebViewMethod()
    class LoadJS(val js: String) : WebViewMethod()

    internal object Parser : MethodParser<WebViewMethod> {
        override fun parse(call: MethodCall): WebViewMethod? {
            return when (call.method) {
                "show" -> Show
                "hide" -> Hide
                "loadURL" -> LoadURL(call.argument("url"))
                "loadJS" -> LoadJS(call.argument("js")
                        ?: return null)
                else -> null
            }
        }
    }
}