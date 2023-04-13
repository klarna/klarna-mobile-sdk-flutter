package com.klarna.mobile.sdk.flutter.core.util

internal fun Any?.toJson(): String? {
    return ParserUtil.toJson(this)
}

internal inline fun <T> tryOptional(expression: () -> T): T? {
    return try {
        expression()
    } catch (ignore: Throwable) {
        null
    }
}