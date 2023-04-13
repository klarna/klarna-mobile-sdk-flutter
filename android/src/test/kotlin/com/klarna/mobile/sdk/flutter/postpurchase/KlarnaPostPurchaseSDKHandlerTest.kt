package com.klarna.mobile.sdk.flutter.postpurchase

import com.klarna.mobile.sdk.flutter.postpurchase.manager.KlarnaPostPurchaseSDKManager
import com.klarna.mobile.sdk.flutter.postpurchase.method.KlarnaPostPurchaseSDKMethod
import io.flutter.plugin.common.MethodChannel
import io.mockk.clearAllMocks
import io.mockk.every
import io.mockk.just
import io.mockk.mockk
import io.mockk.runs
import io.mockk.verify
import org.junit.After
import org.junit.Before
import org.junit.Test
import kotlin.random.Random

class KlarnaPostPurchaseSDKHandlerTest {

    private val postPurchaseSDKHandler = KlarnaPostPurchaseSDKHandler
    private val postPurchaseSDKManager: KlarnaPostPurchaseSDKManager = mockk()
    private val id: Int = Random.nextInt()
    private val result: MethodChannel.Result = mockk()

    @Before
    fun setup() {
        every { postPurchaseSDKManager.create(any(), any()) } just runs
        every { postPurchaseSDKManager.initialize(any(), any()) } just runs
        every { postPurchaseSDKManager.destroy(any(), any()) } just runs
        every { postPurchaseSDKManager.renderOperation(any(), any()) } just runs
        every { postPurchaseSDKManager.authorizationRequest(any(), any()) } just runs

        every { result.error(any(), any(), any()) } just runs
        every { result.success(any()) } just runs

        postPurchaseSDKHandler.postPurchaseSDKManagerMap[id] = postPurchaseSDKManager
    }

    @After
    fun teardown() {
        clearAllMocks()
    }

    @Test
    fun testCreate() {
        val method = KlarnaPostPurchaseSDKMethod.Create(id, "staging", "na", null)
        postPurchaseSDKHandler.onMethod(method, result)
        verify { postPurchaseSDKManager.create(method, result) }
    }

    @Test
    fun testInitialize() {
        val method = KlarnaPostPurchaseSDKMethod.Initialize(id, "sv-SE", "SE", null)
        postPurchaseSDKHandler.onMethod(method, result)
        verify { postPurchaseSDKManager.initialize(method, result) }
    }

    @Test
    fun testAuthorizationRequest() {
        val method = KlarnaPostPurchaseSDKMethod.AuthorizationRequest(
            id,
            "client",
            "scope",
            "redirectUrl",
            "sv-SE",
            null,
            null,
            null
        )
        postPurchaseSDKHandler.onMethod(method, result)
        verify { postPurchaseSDKManager.authorizationRequest(method, result) }
    }

    @Test
    fun testRenderOperation() {
        val method =
            KlarnaPostPurchaseSDKMethod.RenderOperation(id, "token", "sv-SE", "redirectUrl")
        postPurchaseSDKHandler.onMethod(method, result)
        verify { postPurchaseSDKManager.renderOperation(method, result) }
    }

    @Test
    fun testDestroy() {
        val method = KlarnaPostPurchaseSDKMethod.Destroy(id)
        postPurchaseSDKHandler.onMethod(method, result)
        verify { postPurchaseSDKManager.destroy(method, result) }
    }
}