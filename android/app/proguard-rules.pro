# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# If your project uses WebView with JS, uncomment the following
# and specify the fully qualified class name to the JavaScript interface
# class:
#-keepclassmembers class fqcn.of.javascript.interface.for.webview {
#   public *;
#}

# Uncomment this to preserve the line number information for
# debugging stack traces.
#-keepattributes SourceFile,LineNumberTable

#Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-keep class androidx.lifecycle.** { *; }

-keepclassmembers enum * { *; }
-keep class com.google.firebase.** { *; }

#-keep class tvi.webrtc.** { *; }
#-dontwarn tvi.webrtc.**
#-keep class com.twilio.video.** { *; }
#-keep class com.twilio.common.** { *; }
#-keepattributes InnerClasses

-keep class com.twilio.** {*;}
-keep class tvo.webrtc.** {*;}
-dontwarn tvo.webrtc.**
-keep class com.twilio.voice.** {*;}
-keepattributes InnerClasses

-keep class org.apache.** {*;}