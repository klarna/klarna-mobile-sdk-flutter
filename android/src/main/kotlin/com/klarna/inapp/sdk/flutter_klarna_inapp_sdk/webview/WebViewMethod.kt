package com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.webview

import com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.core.method.MethodParser
import io.flutter.plugin.common.MethodCall

internal sealed class WebViewMethod {
    object Initialize : WebViewMethod()
    object Destroy : WebViewMethod()
    object Show : WebViewMethod()
    object Hide : WebViewMethod()
    class LoadURL(val url: String?) : WebViewMethod()
    class LoadJS(val js: String) : WebViewMethod()

    internal object Parser : MethodParser<WebViewMethod> {
        override fun parse(call: MethodCall): WebViewMethod? {
            return when (call.method) {
                "initialize" -> Initialize
                "destroy" -> Destroy
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