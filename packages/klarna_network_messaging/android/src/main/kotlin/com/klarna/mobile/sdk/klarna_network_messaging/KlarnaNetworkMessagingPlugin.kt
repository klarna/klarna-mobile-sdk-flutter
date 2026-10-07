package com.klarna.mobile.sdk.klarna_network_messaging

import io.flutter.embedding.engine.plugins.FlutterPlugin

class KlarnaNetworkMessagingPlugin : FlutterPlugin {
    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        binding.platformViewRegistry.registerViewFactory(
            "com.klarna.mobile.sdk/messaging_placement",
            KlarnaMessagingPlacementViewFactory(binding.binaryMessenger),
        )
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    }
}
