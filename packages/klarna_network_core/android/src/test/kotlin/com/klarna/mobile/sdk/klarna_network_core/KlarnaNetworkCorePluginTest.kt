package com.klarna.mobile.sdk.klarna_network_core

import android.content.Context
import com.klarna.mobile.sdk.klarna.network.core.api.klarna.Klarna
import kotlin.test.AfterTest
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertNull
import kotlin.test.assertSame
import kotlin.test.assertTrue
import org.mockito.Mockito.mock

class KnInstanceStoreTest {

    @AfterTest
    fun tearDown() {
        // Keep the shared singleton store clean between tests.
        KnInstanceStore.remove("a")
        KnInstanceStore.remove("b")
    }

    @Test
    fun putThenGetReturnsSameInstance() {
        val klarna = mock(Klarna::class.java)
        KnInstanceStore.put("a", klarna)

        assertSame(klarna, KnInstanceStore.getInstance("a"))
    }

    @Test
    fun getUnknownInstanceReturnsNull() {
        assertNull(KnInstanceStore.getInstance("missing"))
    }

    @Test
    fun removeReturnsAndClearsInstance() {
        val klarna = mock(Klarna::class.java)
        KnInstanceStore.put("b", klarna)

        assertSame(klarna, KnInstanceStore.remove("b"))
        assertNull(KnInstanceStore.getInstance("b"))
    }

    @Test
    fun removeUnknownInstanceReturnsNull() {
        assertNull(KnInstanceStore.remove("never-added"))
    }
}

class KnCoreHostApiImplTest {

    private fun newApi(): KnCoreHostApi {
        // The impl is package-private; reach it via reflection on its constructor.
        val cls = Class.forName(
            "com.klarna.mobile.sdk.klarna_network_core.KnCoreHostApiImpl",
        )
        val ctor = cls.getDeclaredConstructor(Context::class.java)
        ctor.isAccessible = true
        return ctor.newInstance(mock(Context::class.java)) as KnCoreHostApi
    }

    @Test
    fun getSessionTokenFailsWhenInstanceNotFound() {
        var result: Result<String>? = null
        newApi().getSessionToken("no-such-instance") { result = it }

        assertTrue(result!!.isFailure)
    }

    @Test
    fun clearSessionFailsWhenInstanceNotFound() {
        var result: Result<Unit>? = null
        newApi().clearSession("no-such-instance") { result = it }

        assertTrue(result!!.isFailure)
    }

    @Test
    fun handleReturnUrlIsNotSupportedOnAndroid() {
        var result: Result<Boolean>? = null
        newApi().handleReturnUrl("app://return") { result = it }

        assertTrue(result!!.isSuccess)
        assertEquals(false, result!!.getOrNull())
    }

    @Test
    fun disposeRemovesTheInstance() {
        val klarna = mock(Klarna::class.java)
        KnInstanceStore.put("to-dispose", klarna)

        newApi().dispose("to-dispose")

        assertNull(KnInstanceStore.getInstance("to-dispose"))
    }
}
