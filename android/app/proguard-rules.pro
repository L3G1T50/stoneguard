# ─── KidneyShield ProGuard / R8 Rules ──────────────────────────────────────────
#
# Fix 10: R8 minification is enabled for release builds (isMinifyEnabled = true).
# These rules prevent R8 from stripping classes that are loaded at runtime
# via reflection or JNI — which would cause silent crashes in production.
#
# Rule of thumb:
#   -keep       → class stays in the APK and its name is not changed
#   -keepnames  → class stays but may be moved/merged; name is preserved
#   -dontwarn   → suppress warnings for classes not in the compile classpath

# ── Flutter core ────────────────────────────────────────────────────────────
-keep class io.flutter.** { *; }
-keep class io.flutter.embedding.** { *; }
-dontwarn io.flutter.embedding.**

# ── flutter_secure_storage ───────────────────────────────────────────────────
-keep class com.it_nomads.fluttersecurestorage.** { *; }
-dontwarn com.it_nomads.fluttersecurestorage.**

# ── sqflite_sqlcipher ──────────────────────────────────────────────────────────
-keep class net.zetetic.database.** { *; }
-keep class io.flutter.plugins.sqflite.** { *; }
-dontwarn net.zetetic.database.**
-dontwarn io.flutter.plugins.sqflite.**

# ── google_mobile_ads (AdMob) ────────────────────────────────────────────────
-keep class com.google.android.gms.ads.** { *; }
-keep class com.google.ads.** { *; }
-dontwarn com.google.android.gms.ads.**

# ── flutter_local_notifications ────────────────────────────────────────────────
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-dontwarn com.dexterous.flutterlocalnotifications.**

# ── share_plus ─────────────────────────────────────────────────────────────────
-keep class dev.fluttercommunity.plus.share.** { *; }
-dontwarn dev.fluttercommunity.plus.share.**

# ── permission_handler ─────────────────────────────────────────────────────────
-keep class com.baseflow.permissionhandler.** { *; }
-dontwarn com.baseflow.permissionhandler.**

# ── path_provider ──────────────────────────────────────────────────────────────
-keep class io.flutter.plugins.pathprovider.** { *; }
-dontwarn io.flutter.plugins.pathprovider.**

# ── General Android / Kotlin safety nets ────────────────────────────────────
-keepclassmembers class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator CREATOR;
}

-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses
-keepattributes EnclosingMethod

# ── Suppress noisy warnings from transitive deps ───────────────────────────────
-dontwarn org.conscrypt.**
-dontwarn org.bouncycastle.**
-dontwarn org.openjsse.**
-dontwarn javax.annotation.**
-dontwarn sun.misc.Unsafe
