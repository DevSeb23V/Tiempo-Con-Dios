# Flutter Local Notifications rules
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-keep class com.google.gson.** { *; }
-keepattributes Signature
-keepattributes *Annotation*
-keepclassmembers enum * { *; }

# Drift & SQLite rules
-keep class androidx.sqlite.db.** { *; }
-keep class com.simonbinder.sqlite3_flutter_libs.** { *; }
-keep class org.sqlite.** { *; }

# Keep resource identifiers for dynamic lookup (sounds, drawables, raw)
-keepclassmembers class **.R$* {
    public static <fields>;
}
