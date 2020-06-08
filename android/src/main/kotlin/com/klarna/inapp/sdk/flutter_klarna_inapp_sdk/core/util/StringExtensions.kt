package com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.core.util

internal fun String?.jsScriptString(): String {
    return if (this != null) {
        "\"${this.replace("\"", "\\\"", false)}\""
    } else {
        "null"
    }
}