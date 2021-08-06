package com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.payment

import android.content.Context
import com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.payment.KlarnaPaymentViewWidget
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class KlarnaPaymentViewWidgetFactory(private val messenger: BinaryMessenger) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, id: Int, args: Any?): PlatformView {
        return KlarnaPaymentViewWidget(context = context, id = id, messenger = messenger, creationParams = args as Map<String?, Any?>?)
    }
}