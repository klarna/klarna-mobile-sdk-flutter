package com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.core.network

import okhttp3.OkHttpClient

internal object NetworkContext {

    private val client: OkHttpClient by lazy {
        OkHttpClient.Builder().build()
    }

    fun client() = client

    fun newClient() = builder().build()

    fun builder() = client.newBuilder()
}