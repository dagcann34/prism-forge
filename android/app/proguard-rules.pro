# PRISM FORGE — Android R8 / ProGuard keep rules for Google Mobile Ads & UMP SDK.

-keep class com.google.android.gms.ads.** { *; }
-keep class com.google.ads.** { *; }
-keep class com.google.android.ump.** { *; }
-keep class io.flutter.plugins.googlemobileads.** { *; }

# Keep AndroidX Startup & WorkManager components initialized by GMA SDK in release AAB builds.
-keep class * extends androidx.startup.Initializer { *; }
-keep class androidx.work.** { *; }
-dontwarn com.google.android.gms.ads.**
-dontwarn com.google.android.ump.**
