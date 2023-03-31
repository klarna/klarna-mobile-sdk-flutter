package com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.postpurchase.callback

import com.klarna.mobile.sdk.api.postpurchase.KlarnaPostPurchaseError
import com.klarna.mobile.sdk.api.postpurchase.KlarnaPostPurchaseRenderResult
import com.klarna.mobile.sdk.api.postpurchase.KlarnaPostPurchaseSDK
import io.mockk.clearAllMocks
import io.mockk.mockk
import io.mockk.mockkObject
import io.mockk.verify
import org.junit.After
import org.junit.Before
import org.junit.Test
import kotlin.random.Random

class KlarnaPostPurchaseSDKCallbackImplTest {

    private val id: Int = Random.nextInt()
    private lateinit var postPurchaseSDKCallbackImpl: KlarnaPostPurchaseSDKCallbackImpl
    private val postPurchaseSDK: KlarnaPostPurchaseSDK = mockk()

    @Before
    fun setup() {
        mockkObject(KlarnaPostPurchaseSDKCallbackHandler)

        postPurchaseSDKCallbackImpl = KlarnaPostPurchaseSDKCallbackImpl(id)
    }

    @After
    fun teardown() {
        clearAllMocks()
    }

    @Test
    fun testOnInitialized() {
        postPurchaseSDKCallbackImpl.onInitialized(postPurchaseSDK)
        verify { KlarnaPostPurchaseSDKCallbackHandler.sendValue("{\"id\":$id,\"name\":\"onInitialized\"}") }
    }

    @Test
    fun testOnAuthorizeRequested() {
        postPurchaseSDKCallbackImpl.onAuthorizeRequested(postPurchaseSDK)
        verify { KlarnaPostPurchaseSDKCallbackHandler.sendValue("{\"id\":$id,\"name\":\"onAuthorizeRequested\"}") }
    }

    @Test
    fun testOnRenderedOperation() {
        val renderResult = KlarnaPostPurchaseRenderResult.NO_STATE_CHANGE
        postPurchaseSDKCallbackImpl.onRenderedOperation(postPurchaseSDK, renderResult)
        verify { KlarnaPostPurchaseSDKCallbackHandler.sendValue("{\"renderResult\":\"NO_STATE_CHANGE\",\"id\":$id,\"name\":\"onRenderedOperation\"}") }
    }

    @Test
    fun testOnError() {
        val error = KlarnaPostPurchaseError("name", "message", "status", true)
        postPurchaseSDKCallbackImpl.onError(postPurchaseSDK, error)
        verify { KlarnaPostPurchaseSDKCallbackHandler.sendValue("{\"error\":{\"name\":\"name\",\"message\":\"message\",\"status\":\"status\",\"isFatal\":true},\"id\":$id,\"name\":\"onError\"}") }
    }
}