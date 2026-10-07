plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.premium_downloader"
    compileSdk = 37
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

defaultConfig {
minSdk = 24
targetSdk = 36
}
android {
packaging { jniLibs { useLegacyPackaging = true } }
}
buildTypes {
    release {
        signingConfig = signingConfigs.getByName("debug")
        isMinifyEnabled = false
        isShrinkResources = false
    }
}
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
  dependencies {
      implementation("io.github.junkfood02.youtubedl-android:library:0.18.1")
      implementation("io.github.junkfood02.youtubedl-android:ffmpeg:0.18.1")
      implementation("androidx.core:core-ktx:1.13.1")
  }