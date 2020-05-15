package com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.hybrid

import android.webkit.WebView
import android.webkit.WebViewClient

internal class KlarnaWebViewClient : WebViewClient() {

    override fun shouldOverrideUrlLoading(view: WebView, url: String): Boolean {
        return !KlarnaHybridSDKHandler.hybridSDK.shouldFollowNavigation(url)
    }

    override fun onPageFinished(view: WebView, url: String) {
        KlarnaHybridSDKHandler.hybridSDK.newPageLoad(view)
    }
}