package com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.postpurchase

import android.webkit.WebView
import com.klarna.mobile.sdk.KlarnaMobileSDKError
import com.klarna.mobile.sdk.api.OnCompletion
import com.klarna.mobile.sdk.api.hybrid.KlarnaHybridSDKCallback

internal class PPEKlarnaHybridSDKCallback : KlarnaHybridSDKCallback {
    override fun didHideFullscreenContent(webView: WebView, completion: OnCompletion) {
        completion.run()
    }

    override fun didShowFullscreenContent(webView: WebView, completion: OnCompletion) {
        completion.run()
    }

    override fun onErrorOccurred(webView: WebView, error: KlarnaMobileSDKError) {
        TODO()
    }

    override fun willHideFullscreenContent(webView: WebView, completion: OnCompletion) {
        completion.run()
    }

    override fun willShowFullscreenContent(webView: WebView, completion: OnCompletion) {
        completion.run()
    }
}