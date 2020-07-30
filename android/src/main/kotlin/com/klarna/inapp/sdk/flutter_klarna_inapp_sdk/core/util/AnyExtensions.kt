package com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.core.util

internal fun Any?.toJson(): String? {
    return ParserUtil.toJson(this)
}