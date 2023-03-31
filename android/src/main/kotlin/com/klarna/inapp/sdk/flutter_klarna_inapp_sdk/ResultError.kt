package com.klarna.inapp.sdk.flutter_klarna_inapp_sdk

internal enum class ResultError(val errorCode: String) {
    UNKNOWN_ERROR("UnknownError"),
    PLUGIN_METHOD_ERROR("KlarnaFlutterPluginMethodError"),
    KLARNA_POST_PURCHASE_SDK_ERROR("KlarnaPostPurchaseSDKError")
}