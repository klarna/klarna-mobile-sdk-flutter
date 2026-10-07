package com.klarna.mobile.sdk.klarna_network_messaging

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertNull

class KlarnaMessagingParsingTest {
    @Test
    fun parseAmountReturnsNullForEmptyOrInvalid() {
        assertNull(KlarnaMessagingParsing.parseAmount(null))
        assertNull(KlarnaMessagingParsing.parseAmount(""))
        assertNull(KlarnaMessagingParsing.parseAmount("abc"))
        assertNull(KlarnaMessagingParsing.parseAmount("12.5"))
    }

    @Test
    fun parseAmountParsesIntegers() {
        assertEquals(0L, KlarnaMessagingParsing.parseAmount("0"))
        assertEquals(19900L, KlarnaMessagingParsing.parseAmount("19900"))
    }

    @Test
    fun resolvePlacementKindDefaultsToAutoSize() {
        assertEquals(MessagingPlacementKind.AUTO_SIZE, KlarnaMessagingParsing.resolvePlacementKind(null))
        assertEquals(MessagingPlacementKind.AUTO_SIZE, KlarnaMessagingParsing.resolvePlacementKind("unknown"))
        assertEquals(
            MessagingPlacementKind.AUTO_SIZE,
            KlarnaMessagingParsing.resolvePlacementKind("CreditPromotionAutoSize"),
        )
    }

    @Test
    fun resolvePlacementKindResolvesBadge() {
        assertEquals(
            MessagingPlacementKind.BADGE,
            KlarnaMessagingParsing.resolvePlacementKind("CreditPromotionBadge"),
        )
    }

    @Test
    fun resolveThemeKindMapsKnownValues() {
        assertEquals(MessagingThemeKind.LIGHT, KlarnaMessagingParsing.resolveThemeKind("light"))
        assertEquals(MessagingThemeKind.DARK, KlarnaMessagingParsing.resolveThemeKind("dark"))
        assertEquals(MessagingThemeKind.AUTOMATIC, KlarnaMessagingParsing.resolveThemeKind("automatic"))
    }

    @Test
    fun resolveThemeKindReturnsNullForUnknownOrEmpty() {
        assertNull(KlarnaMessagingParsing.resolveThemeKind(null))
        assertNull(KlarnaMessagingParsing.resolveThemeKind(""))
        assertNull(KlarnaMessagingParsing.resolveThemeKind("teal"))
    }
}
