package com.klarna.mobile.sdk.klarna_mobile_sdk_flutter_example

import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant

// The Klarna SDK opens its payment custom tab from the host Activity and
// requires it to be a FragmentActivity. FlutterFragmentActivity extends
// AndroidX FragmentActivity (which extends ComponentActivity -> Activity),
// whereas the default FlutterActivity extends Activity directly and is not
// a FragmentActivity — hence the override.
class MainActivity : FlutterFragmentActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
    }
}
