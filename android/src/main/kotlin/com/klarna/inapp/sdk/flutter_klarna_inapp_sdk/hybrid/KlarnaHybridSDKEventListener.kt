package com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.hybrid

import com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.core.stream.BaseStreamHandler
import com.klarna.mobile.sdk.api.KlarnaEvent
import com.klarna.mobile.sdk.api.KlarnaEventListener

internal class KlarnaHybridSDKEventListener(private val eventHandler: BaseStreamHandler<String>) :
    KlarnaEventListener {
    override fun onEvent(event: KlarnaEvent?) {
        event?.bodyString?.let {
            eventHandler.sendValue(it)
        }
    }
}