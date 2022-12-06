package com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.core.util

import com.klarna.mobile.sdk.api.KlarnaEnvironment
import com.klarna.mobile.sdk.api.KlarnaRegion
import com.klarna.mobile.sdk.api.KlarnaResourceEndpoint

internal object KlarnaParamMapper {

    fun getEnvironment(param: String?): KlarnaEnvironment? {
        KlarnaEnvironment.values().forEach {
            if (it.name.lowercase() == param?.lowercase()) {
                return it
            }
        }
        return null
    }

    fun getEnvironmentOrDefault(param: String?): KlarnaEnvironment {
        return getEnvironment(param) ?: KlarnaEnvironment.getDefault()
    }

    fun getRegion(param: String?): KlarnaRegion? {
        KlarnaRegion.values().forEach {
            if (it.name.lowercase() == param?.lowercase()) {
                return it
            }
        }
        return null
    }

    fun getRegionOrDefault(param: String?): KlarnaRegion {
        return getRegion(param) ?: KlarnaRegion.getDefault()
    }

    fun getResourceEndpoint(param: String?): KlarnaResourceEndpoint? {
        KlarnaResourceEndpoint.values().forEach {
            if (it.name.lowercase() == param?.lowercase()) {
                return it
            }
        }
        return null
    }

    fun getResourceEndpointOrDefault(param: String?): KlarnaResourceEndpoint? {
        return getResourceEndpoint(param) ?: KlarnaResourceEndpoint.getDefault()
    }
}