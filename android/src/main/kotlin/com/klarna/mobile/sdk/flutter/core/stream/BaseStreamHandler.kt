package com.klarna.mobile.sdk.flutter.core.stream

import io.flutter.plugin.common.EventChannel

internal open class BaseStreamHandler<T> : EventChannel.StreamHandler {

    private var sink: EventChannel.EventSink? = null

    override fun onListen(args: Any?, eventSink: EventChannel.EventSink?) {
        sink = eventSink
    }

    override fun onCancel(args: Any?) {
        sink = null
    }

    fun sendValue(value: T) {
        sink?.success(value)
    }

}