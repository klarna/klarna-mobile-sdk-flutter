package com.klarna.inapp.sdk.klarna_inapp_flutter_plugin

internal enum class ResultError(val errorCode: String) {
    EXCEPTION("Exception"),
    HYBRID_SDK_ERROR("KlarnaMobileSDKError")
}