package com.klarna.inapp.sdk.flutter_klarna_inapp_sdk

import io.flutter.plugin.common.EventChannel

internal object StreamCallHandlerManager {

    val streamHandlerMap: Map<String, EventChannel.StreamHandler> = mapOf(
            "klarna_events" to EventCallbackHandler,
            "klarna_errors" to ErrorCallbackHandler
    )
}