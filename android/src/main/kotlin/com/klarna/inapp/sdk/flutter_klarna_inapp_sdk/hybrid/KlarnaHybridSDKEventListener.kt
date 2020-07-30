package com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.hybrid

import com.klarna.mobile.sdk.api.KlarnaEvent
import com.klarna.mobile.sdk.api.KlarnaEventListener

internal class KlarnaHybridSDKEventListener : KlarnaEventListener {
    override fun onEvent(event: KlarnaEvent?) {
        KlarnaHybridSDKEventHandler.sendValue(event?.bodyString)
    }
}