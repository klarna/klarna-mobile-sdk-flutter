package com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.core.stream

import io.flutter.plugin.common.EventChannel

internal class BaseStreamHandler : EventChannel.StreamHandler {

    var sink: EventChannel.EventSink? = null
        private set

    override fun onListen(args: Any?, eventSink: EventChannel.EventSink?) {
        sink = eventSink
    }

    override fun onCancel(args: Any?) {
        sink = null
    }

}