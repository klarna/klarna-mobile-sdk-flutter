package com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.core.util

internal fun String?.jsScriptString(): String {
    return if (this != null) {
        "\"${this.replace("\"", "\\\"", false)}\""
    } else {
        "null"
    }
}

internal fun String?.jsIsNullOrUndefined(): Boolean {
    this?.let {
        return it == "null" || it == "undefined"
    }
    return true
}

internal fun String?.jsValue(): String? {
    return if (this.jsIsNullOrUndefined()) null else this
}