# Generated Proguard / R8 rules for Android release build

# Google ML Kit Text Recognition
-dontwarn com.google.mlkit.vision.text.**
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**
-keep class com.google.mlkit.vision.text.** { *; }

# Flutter CallKit Incoming
-keep class com.hiennv.flutter_callkit_incoming.** { *; }
-dontwarn com.hiennv.flutter_callkit_incoming.**

# WebRTC & Agora / Iris
-keep class org.webrtc.** { *; }
-dontwarn org.webrtc.**
-keep class io.agora.** { *; }
-dontwarn io.agora.**

# Native JNI Methods
-keepclasseswithmembernames class * {
    native <methods>;
}
