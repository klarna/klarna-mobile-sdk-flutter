package com.klarna.mobile.sdk.flutter

import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

/** FlutterKlarnaMobileSdk */
public class KlarnaMobileSDKFlutter : FlutterPlugin, ActivityAware {
    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        MethodCallHandlerManager.methodHandlerMap.forEach {
            val channel = MethodChannel(flutterPluginBinding.binaryMessenger, it.key)
            channel.setMethodCallHandler(it.value)
        }

        StreamCallHandlerManager.streamHandlerMap.forEach {
            val eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, it.key)
            eventChannel.setStreamHandler(it.value)
        }

        PluginContext.context = flutterPluginBinding.applicationContext
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {

    }

    override fun onDetachedFromActivity() {
        PluginContext.activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {

    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        PluginContext.activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {

    }

}
