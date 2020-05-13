package com.klarna.inapp.sdk.klarna_inapp_flutter_plugin.hybrid

import android.webkit.WebView
import com.klarna.inapp.sdk.klarna_inapp_flutter_plugin.ResultError
import com.klarna.mobile.sdk.KlarnaMobileSDKError
import com.klarna.mobile.sdk.api.OnCompletion
import com.klarna.mobile.sdk.api.hybrid.KlarnaHybridSDKCallback
import io.flutter.plugin.common.MethodChannel

internal class KlarnaHybridSDKCallback : KlarnaHybridSDKCallback {

    var result: MethodChannel.Result? = null

    override fun didHideFullscreenContent(webView: WebView, completion: OnCompletion) {
        completion.run()
    }

    override fun didShowFullscreenContent(webView: WebView, completion: OnCompletion) {
        completion.run()
    }

    override fun onErrorOccurred(webView: WebView, error: KlarnaMobileSDKError) {
        result?.error(ResultError.HYBRID_SDK_ERROR.errorCode, "${error.name}:${error.message}:${error.isFatal}", error.message)
    }

    override fun willHideFullscreenContent(webView: WebView, completion: OnCompletion) {
        completion.run()
    }

    override fun willShowFullscreenContent(webView: WebView, completion: OnCompletion) {
        completion.run()
    }
}