package com.klarna.inapp.sdk.klarna_inapp_flutter_plugin.handler.hybrid

import android.webkit.WebView
import android.webkit.WebViewClient

class KlarnaWebViewClient : WebViewClient() {

    override fun shouldOverrideUrlLoading(view: WebView, url: String): Boolean {
        return !KlarnaHybridSDKHandler.hybridSDK.shouldFollowNavigation(url)
    }

    override fun onPageFinished(view: WebView, url: String) {
        KlarnaHybridSDKHandler.hybridSDK.newPageLoad(view)
    }
}