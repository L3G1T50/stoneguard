# ─── StoneGuard ProGuard / R8 Rules ─────────────────────────────────────────
#
# Fix 10: R8 minification is enabled for release builds (isMinifyEnabled = true).
# These rules prevent R8 from stripping classes that are loaded at runtime
# via reflection or JNI — which would cause silent crashes in production.
#
# Rule of thumb:
#   -keep       → class stays in the APK and its name is not changed
#   -keepnames  → class stays but may be moved/merged; name is preserved
#   -dontwarn   → suppress warnings for classes not in the compile classpath

# ── Flutter core ─────────────────────────────────────────────────────────────
# Flutter's embedding uses reflection to load the FlutterMain class and
# platform channels. These must never be renamed or removed.
-keep class io.flutter.** { *; }
-keep class io.flutter.embedding.** { *; }
-dontwarn io.flutter.embedding.**

# ── flutter_secure_storage ────────────────────────────────────────────────────
# Uses Android Keystore APIs via reflection. The plugin class must be kept
# so Flutter's plugin registry can find it at runtime.
-keep class com.it_nomads.fluttersecurestorage.** { *; }
-dontwarn com.it_nomads.fluttersecurestorage.**

# ── sqflite_sqlcipher ─────────────────────────────────────────────────────────
# SQLCipher loads its native library and accesses JNI bridge classes by name.
# Stripping or renaming these causes a crash on first database open.
-keep class net.zetetic.database.** { *; }
-keep class io.flutter.plugins.sqflite.** { *; }
-dontwarn net.zetetic.database.**
-dontwarn io.flutter.plugins.sqflite.**

# ── google_mobile_ads (AdMob) ─────────────────────────────────────────────────
# AdMob SDK uses reflection and class loading internally.
# Google's own published keep rules are included transitively via the AAR,
# but we add an explicit top-level keep as a safety net.
-keep class com.google.android.gms.ads.** { *; }
-keep class com.google.ads.** { *; }
-dontwarn com.google.android.gms.ads.**

# ── flutter_local_notifications ───────────────────────────────────────────────
# BroadcastReceivers for scheduled notifications are referenced by name
# in AndroidManifest.xml — R8 must not rename them.
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-dontwarn com.dexterous.flutterlocalnotifications.**

# ── encrypt (Dart encrypt package / PointyCastle JVM bridge) ─────────────────
# The encrypt package uses PointyCastle on Dart side, but on Android the
# flutter_secure_storage + Android Keystore do the heavy lifting.
# No extra Java-side keep needed beyond flutter_secure_storage above.

# ── share_plus ────────────────────────────────────────────────────────────────
-keep class dev.fluttercommunity.plus.share.** { *; }
-dontwarn dev.fluttercommunity.plus.share.**

# ── permission_handler ────────────────────────────────────────────────────────
-keep class com.baseflow.permissionhandler.** { *; }
-dontwarn com.baseflow.permissionhandler.**

# ── path_provider ─────────────────────────────────────────────────────────────
-keep class io.flutter.plugins.pathprovider.** { *; }
-dontwarn io.flutter.plugins.pathprovider.**

# ── General Android / Kotlin safety nets ─────────────────────────────────────
# Parcelable implementations use field names at runtime via the CREATOR field.
-keepclassmembers class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator CREATOR;
}

# Enum values are accessed by name in some libraries.
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Serializable classes need their field names preserved for serialization.
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# Keep all annotations (used by Kotlin, Gson, etc.)
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses
-keepattributes EnclosingMethod

# ── Suppress noisy warnings from transitive deps ──────────────────────────────
-dontwarn org.conscrypt.**
-dontwarn org.bouncycastle.**
-dontwarn org.openjsse.**
-dontwarn javax.annotation.**
-dontwarn sun.misc.Unsafe
