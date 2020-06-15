package com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.postpurchase

import io.flutter.plugin.common.MethodChannel
import io.mockk.*
import org.junit.After
import org.junit.Before
import org.junit.Test
import kotlin.random.Random

class PostPurchaseExperienceHandlerTest {

    private val ppeHandler = PostPurchaseExperienceHandler
    private val ppeManager: PostPurchaseExperienceManager = mockk()
    private val id: Int = Random.nextInt()
    private val result: MethodChannel.Result = mockk()

    @Before
    fun setup() {
        every { ppeManager.initialize(any(), any()) } just runs
        every { ppeManager.destroy(any(), any()) } just runs
        every { ppeManager.renderOperation(any(), any()) } just runs
        every { ppeManager.authorizationRequest(any(), any()) } just runs

        every { result.error(any(), any(), any()) } just runs
        every { result.success(any()) } just runs

        ppeHandler.ppeManagerMap[id] = ppeManager
    }

    @After
    fun teardown() {
        clearAllMocks()
    }

    @Test
    fun testInitialize() {
        val method = PostPurchaseExperienceMethod.Initialize(id, "sv-SE", "SE", null)
        ppeHandler.onMethod(method, result)
        verify { ppeManager.initialize(method, result) }
    }

    @Test
    fun testDestroy() {
        val method = PostPurchaseExperienceMethod.Destroy(id)
        ppeHandler.onMethod(method, result)
        verify { ppeManager.destroy(method, result) }
    }

    @Test
    fun testRenderOperation() {
        val method = PostPurchaseExperienceMethod.RenderOperation(id, "sv-SE", "token")
        ppeHandler.onMethod(method, result)
        verify { ppeManager.renderOperation(method, result) }
    }

    @Test
    fun testAuthorizationRequest() {
        val method = PostPurchaseExperienceMethod.AuthorizationRequest(id, "sv-SE", "client", "scope", "redirectUrl", null, null, null)
        ppeHandler.onMethod(method, result)
        verify { ppeManager.authorizationRequest(method, result) }
    }
}