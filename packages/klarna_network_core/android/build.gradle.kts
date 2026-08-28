group = "com.klarna.mobile.sdk.klarna_network_core"
version = "1.0-SNAPSHOT"

buildscript {
    val kotlinVersion = "2.4.10"
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath("com.android.tools.build:gradle:9.0.1")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlinVersion")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url = uri("https://x.klarnacdn.net/mobile-sdk/") }
    }
}

plugins {
    id("com.android.library")
}

android {
    namespace = "com.klarna.mobile.sdk.klarna_network_core"

    compileSdk = 36

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    sourceSets {
        getByName("main") {
            java.srcDirs("src/main/kotlin")
        }
        getByName("test") {
            java.srcDirs("src/test/kotlin")
        }
    }

    defaultConfig {
        minSdk = 24
    }

    testOptions {
        unitTests {
            isIncludeAndroidResources = true
            all {
                it.useJUnitPlatform()

                it.outputs.upToDateWhen { false }

                it.testLogging {
                    events("passed", "skipped", "failed", "standardOut", "standardError")
                    showStandardStreams = true
                }
            }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

configurations.all {
    resolutionStrategy {
        // CVE-2021-33813: force patched jdom2 version
        force("org.jdom:jdom2:2.0.6.1")
        // CVE-2024-29371: force patched jose4j version
        force("org.bitbucket.b_c:jose4j:0.9.6")
        // CVE-2025-48924: force patched commons-lang3 version
        force("org.apache.commons:commons-lang3:3.20.0")
        // CVE-2026-5588: force patched bcpkix-jdk18on version
        force("org.bouncycastle:bcpkix-jdk18on:1.85")
        // CVE-2026-0636: force patched bcprov-jdk18on version
        force("org.bouncycastle:bcprov-jdk18on:1.85.2")
    }
}

dependencies {
    // Klarna Network core SDK (exposes the Klarna factory used by KN packages).
    implementation("com.klarna.mobile.sdk:klarna-network-core:2.11.5")

    // @RestrictTo on the instance-store accessor. Declared without a version:
    // the Flutter embedding pins `androidx.annotation` `strictly 1.9.0` under
    // consistent resolution, so an explicit version (e.g. 1.9.1) fails the strict
    // constraint and breaks the release build. compileOnly — needed only to
    // compile the annotation, provided at runtime by the embedding.
    compileOnly("androidx.annotation:annotation")

    testImplementation("org.jetbrains.kotlin:kotlin-test")
    testImplementation("org.mockito:mockito-core:5.23.0")
}
