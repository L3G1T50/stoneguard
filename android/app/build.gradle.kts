// android/app/build.gradle.kts
//
// Fix 10 — Android release hardening (confirmed complete)
//   • proguardFiles() wires in proguard-rules.pro alongside default rules.
//   • isMinifyEnabled + isShrinkResources = true for release.
//   • signingConfig reads from key.properties (gitignored).
//
// Fix 10 branding patch:
//   • namespace + applicationId changed from com.lacaprara.kidneyshield
//     to com.lacaprara.stoneguard so the Play Store listing matches the app name.
//
// Batch C — AdMob App ID injection
//   • admobAppId loaded from local.properties (gitignored).
//   • Falls back to Google’s official test App ID on CI / fresh clones.

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
    namespace = "com.lacaprara.stoneguard"
    compileSdk = flutter.compileSdkVersion
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
        applicationId = "com.lacaprara.stoneguard"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // Inject AdMob App ID from local.properties.
        // Fallback is Google’s official test App ID — safe for CI / fresh clones.
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
