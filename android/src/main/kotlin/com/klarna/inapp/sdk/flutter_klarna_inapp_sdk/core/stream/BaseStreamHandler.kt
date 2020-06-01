package com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.core.stream

import io.flutter.plugin.common.EventChannel

internal open class BaseStreamHandler : EventChannel.StreamHandler {

    private var sink: EventChannel.EventSink? = null

    override fun onListen(args: Any?, eventSink: EventChannel.EventSink?) {
        sink = eventSink
    }

    override fun onCancel(args: Any?) {
        sink = null
    }

    fun sendValue(value: String?){
        value?.let {
            sink?.success(it)
        }
    }

}