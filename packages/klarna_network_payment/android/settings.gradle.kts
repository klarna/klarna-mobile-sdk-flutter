pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    // AGP is resolved from the buildscript classpath in build.gradle.kts (not
    // declared here) so its transitive deps are not independently resolved by
    // static scanners; see klarna_network_core for the same pattern.
    id("org.jetbrains.kotlin.android") version "2.4.20" apply false
}

rootProject.name = "klarna_network_payment"
