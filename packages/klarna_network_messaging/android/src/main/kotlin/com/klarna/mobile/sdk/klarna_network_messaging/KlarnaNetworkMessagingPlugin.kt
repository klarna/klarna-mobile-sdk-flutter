package com.klarna.mobile.sdk.klarna_network_messaging

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding

class KlarnaNetworkMessagingPlugin :
    FlutterPlugin,
    ActivityAware {
    private var impl: KnMessagingHostApiImpl? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        val implementation = KnMessagingHostApiImpl()
        impl = implementation
        KnMessagingHostApi.setUp(binding.binaryMessenger, implementation)

        binding.platformViewRegistry.registerViewFactory(
            "com.klarna.mobile.sdk/messaging_placement",
            KlarnaMessagingPlacementViewFactory(binding.binaryMessenger),
        )
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        KnMessagingHostApi.setUp(binding.binaryMessenger, null)
        impl = null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        impl?.activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        impl?.activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        impl?.activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        impl?.activity = null
    }
}
