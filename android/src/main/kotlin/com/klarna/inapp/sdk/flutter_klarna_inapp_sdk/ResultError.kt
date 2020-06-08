package com.klarna.inapp.sdk.flutter_klarna_inapp_sdk

internal enum class ResultError(val errorCode: String) {
    UNKNOWN_ERROR("UnknownError"),
    PLUGIN_METHOD_ERROR("KlarnaFlutterPluginMethodError"),
    HYBRID_SDK_ERROR("KlarnaHybridSDKError"),
    WEB_VIEW_ERROR("KlarnaWebViewError"),
    POST_PURCHASE_ERROR("KlarnaPostPurchaseExperieneError")
}