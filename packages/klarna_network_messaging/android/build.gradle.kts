group = "com.klarna.mobile.sdk.klarna_network_messaging"
version = "1.0-SNAPSHOT"

buildscript {
    val kotlinVersion = "2.4.20"

    configurations.classpath {
        resolutionStrategy {
            force("io.netty:netty-codec:4.1.137.Final")
            force("io.netty:netty-codec-http:4.1.137.Final")
            force("io.netty:netty-codec-http2:4.1.137.Final")
            force("io.netty:netty-handler:4.1.137.Final")
            force("io.netty:netty-handler-proxy:4.1.137.Final")
            force("io.netty:netty-common:4.1.137.Final")
            force("io.grpc:grpc-netty:1.75.0")
            force("org.bouncycastle:bcprov-jdk18on:1.85")
            force("org.bouncycastle:bcpkix-jdk18on:1.85")
            force("org.bouncycastle:bcutil-jdk18on:1.85")
            force("org.jdom:jdom2:2.0.6.1")
            force("org.bitbucket.b_c:jose4j:0.9.6")
            force("org.apache.commons:commons-compress:1.26.0")
        }
    }

    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath("com.android.tools.build:gradle:8.13.2")
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
    id("org.jetbrains.kotlin.android")
}

android {
    namespace = "com.klarna.mobile.sdk.klarna_network_messaging"

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

dependencies {
    implementation("com.klarna.mobile.sdk:klarna-network-messaging:2.15.0")
    implementation("com.klarna.mobile.sdk:klarna-network-core:2.15.0")

    testImplementation("org.jetbrains.kotlin:kotlin-test")
    testImplementation("org.mockito:mockito-core:5.23.0")
}
