package com.klarna.mobile.sdk.flutter

internal enum class ResultError(val errorCode: String) {
    UNKNOWN_ERROR("UnknownError"),
    PLUGIN_METHOD_ERROR("KlarnaFlutterPluginMethodError"),
    KLARNA_POST_PURCHASE_SDK_ERROR("KlarnaPostPurchaseSDKError")
}