package com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.core.util

import android.os.Build
import android.webkit.ValueCallback
import android.webkit.WebView

private const val JAVASCRIPT_PREFIX = "javascript:"

internal fun WebView.evaluateJavascriptCompat(
        script: String,
        valueCallback: ValueCallback<String>? = null
) {
    when {
        Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT -> {
            this.evaluateJavascript(script, valueCallback)
        }
        script.startsWith(JAVASCRIPT_PREFIX) -> {
            this.loadUrl(script)
        }
        else -> {
            this.loadUrl("$JAVASCRIPT_PREFIX$script")
        }
    }
}