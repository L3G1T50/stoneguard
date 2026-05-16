// android/app/build.gradle.kts
// Preflight Batch 1: targetSdk pinned explicitly to 35 (2026 Play Store mandate).
// Branding: applicationId + namespace = com.lacaprara.kidneyshield

import java.util.Properties

val keyProperties = Properties()
val keyPropertiesFile = rootProject.file("key.properties")
if (keyPropertiesFile.exists()) {
    keyProperties.load(keyPropertiesFile.inputStream())
}

val localProperties = Properties()
val localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    localProperties.load(localPropertiesFile.inputStream())
}

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.lacaprara.kidneyshield"
    compileSdk = 35
    ndkVersion = "28.2.13676358"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlin {
        compilerOptions {
            jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
        }
    }

    defaultConfig {
        applicationId = "com.lacaprara.kidneyshield"
        minSdk = 21
        targetSdk = 35   // pinned — never delegate to flutter.targetSdkVersion
        compileSdk = 35
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        manifestPlaceholders["admobAppId"] = localProperties.getProperty(
            "admobAppId",
            "ca-app-pub-3940256099942544~3347511713"
        )
    }

    signingConfigs {
        create("release") {
            keyAlias      = keyProperties["keyAlias"]      as String
            keyPassword   = keyProperties["keyPassword"]   as String
            storeFile     = file(keyProperties["storeFile"] as String)
            storePassword = keyProperties["storePassword"] as String
        }
    }

    buildTypes {
        release {
            signingConfig     = signingConfigs.getByName("release")
            isMinifyEnabled   = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
}

flutter {
    source = "../.."
}
