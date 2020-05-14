package com.klarna.inapp.sdk.klarna_inapp_flutter_plugin

internal enum class ResultError(val errorCode: String) {
    UNKNOWN_ERROR("UnknownError"),
    PLUGIN_METHOD_ERROR("KlarnaFlutterPluginMethodError"),
    HYBRID_SDK_ERROR("KlarnaMobileSDKError"),
    WEB_VIEW_ERROR("KlarnaWebViewError")
}