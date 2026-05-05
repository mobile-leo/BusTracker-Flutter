-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

-keep class com.google.android.gms.** { *; }
-keep class com.google.maps.** { *; }

-keep class com.mobileleo.bustracker.** { *; }

-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable

-dontwarn com.google.android.gms.**
-dontwarn io.flutter.**

-keep class * extends com.google.android.gms.maps.model.** { *; }
