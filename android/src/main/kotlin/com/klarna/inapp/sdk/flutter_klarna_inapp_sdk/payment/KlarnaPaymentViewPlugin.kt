package com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.payment

import io.flutter.plugin.common.PluginRegistry

object KlarnaPaymentViewPlugin {
    fun registerWith(registrar: PluginRegistry.Registrar) {
        registrar
                .platformViewRegistry()
                .registerViewFactory(
                        "plugins/klarna_payment_view", KlarnaPaymentViewWidgetFactory(registrar.messenger()))
    }
}