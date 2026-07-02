# Regles Proguard pour preserver Firebase Messaging et Flutter Local Notifications
-keep class com.google.firebase.** { *; }
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.dexterous.flutterlocalnotifications.**
