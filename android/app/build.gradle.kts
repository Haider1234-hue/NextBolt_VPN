plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.nextboltvpn"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.nextboltvpn"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Restrict to ARM only for release APK size.
            ndk {
                abiFilters += listOf("armeabi-v7a")
            }
            signingConfig = signingConfigs.getByName("debug")
        }
        // Debug builds include all ABIs so the x86 emulator works.
    }

    packaging {
        jniLibs {
            // Only strip arm64/x86_64 in release; debug needs x86 for emulator.
        }

        resources {
            // amneziawg-android pulls in okhttp + jspecify transitively, and
            // they both ship the same META-INF path — keep just one copy.
            excludes += "META-INF/versions/9/OSGI-INF/MANIFEST.MF"
        }
    }
}

flutter {
    source = "../.."
}
