package com.klarna.inapp.sdk.flutter_klarna_inapp_sdk

import com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.core.stream.BaseStreamHandler

// Usage:
//EventCallbackHandler.sendValue("web view initialized")

internal object EventCallbackHandler: BaseStreamHandler<String>()