package com.klarna.mobile.sdk.klarna_network_messaging

internal enum class MessagingPlacementKind(
    val wireValue: String,
) {
    AUTO_SIZE("CreditPromotionAutoSize"),
    BADGE("CreditPromotionBadge"),
    ;

    companion object {
        fun fromWire(value: String?): MessagingPlacementKind = entries.find { it.wireValue == value } ?: AUTO_SIZE
    }
}

internal enum class MessagingThemeKind(
    val wireValue: String,
) {
    LIGHT("light"),
    DARK("dark"),
    AUTOMATIC("automatic"),
    ;

    companion object {
        fun fromWire(value: String?): MessagingThemeKind? = entries.find { it.wireValue == value }
    }
}

internal object KlarnaMessagingParsing {
    fun parseAmount(value: String?): Long? = if (value.isNullOrEmpty()) null else value.toLongOrNull()

    fun resolvePlacementKind(value: String?): MessagingPlacementKind = MessagingPlacementKind.fromWire(value)

    fun resolveThemeKind(value: String?): MessagingThemeKind? = MessagingThemeKind.fromWire(value)
}
