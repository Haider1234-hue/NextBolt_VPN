# Flutter's embedding optionally references Play Core's deferred-component
# classes for dynamic feature delivery, which this app doesn't use. Without
# this, R8 fails the build with "Missing class
# com.google.android.play.core.splitcompat.SplitCompatApplication" (etc).
-dontwarn com.google.android.play.core.**
