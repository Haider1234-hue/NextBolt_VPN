import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
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
        applicationId = "com.torcia.secure.vpn.proxy"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // Both ARM ABIs are required: Amazon Fire TV sticks (and older Fire
        // tablets) run a 32-bit armeabi-v7a userspace, and an APK with no
        // matching ABI simply fails to install there. x86/x86_64 stay out —
        // no Fire or retail Android device uses them, only emulators.
        // Must live here, not in buildTypes, or AGP ignores it for the .so
        // files inside dependency AARs (e.g. amneziawg-android). Flutter's
        // own engine/app libs are controlled separately via `--target-platform`.
        ndk {
            abiFilters += listOf("arm64-v8a", "armeabi-v7a")
        }
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties.getProperty("keyAlias")
            keyPassword = keystoreProperties.getProperty("keyPassword")
            storeFile = keystoreProperties.getProperty("storeFile")?.let { file(it) }
            storePassword = keystoreProperties.getProperty("storePassword")
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }

    packaging {
        jniLibs {
            // defaultConfig.ndk.abiFilters doesn't filter prebuilt .so files
            // that ship inside dependency AARs (e.g. amneziawg-android) in
            // this AGP version — exclude the emulator-only ABIs directly.
            excludes += listOf("lib/x86/**", "lib/x86_64/**")
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
