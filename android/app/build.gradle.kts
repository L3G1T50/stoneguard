// android/app/build.gradle.kts
//
// Fix 10 — Android release hardening
//   • proguardFiles() now explicitly references our proguard-rules.pro so R8
//     uses both the default Android rules AND our custom keep rules.
//     Without this line, isMinifyEnabled=true runs R8 with only the default
//     rules, which strips FlutterSecureStorage, SQLCipher, and AdMob
//     reflection-loaded classes — causing silent production crashes.
//
// Batch C — AdMob App ID injection
//   • admobAppId is loaded from android/local.properties (gitignored).
//   • Falls back to Google's official test App ID on CI / fresh clones.
//   • manifestPlaceholders["admobAppId"] wires the value into AndroidManifest.

import java.util.Properties

val keyProperties = Properties()
val keyPropertiesFile = rootProject.file("key.properties")
if (keyPropertiesFile.exists()) {
    keyProperties.load(keyPropertiesFile.inputStream())
}

// Load local.properties for secrets that must never be committed
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
        // Non-example applicationId required by Google Play.
        applicationId = "com.lacaprara.kidneyshield"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // Batch C: inject AdMob App ID from local.properties.
        // Fallback is Google's official test App ID — safe for CI / fresh clones.
        manifestPlaceholders["admobAppId"] = localProperties.getProperty(
            "admobAppId",
            "ca-app-pub-3940256099942544~3347511713"
        )
    }

    signingConfigs {
        create("release") {
            keyAlias     = keyProperties["keyAlias"]     as String
            keyPassword  = keyProperties["keyPassword"]  as String
            storeFile    = file(keyProperties["storeFile"] as String)
            storePassword = keyProperties["storePassword"] as String
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")

            // R8 minification + resource shrinking reduces APK size and makes
            // reverse engineering significantly harder.
            isMinifyEnabled   = true
            isShrinkResources = true

            // Fix 10: Wire in our custom keep rules alongside the default ones.
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
