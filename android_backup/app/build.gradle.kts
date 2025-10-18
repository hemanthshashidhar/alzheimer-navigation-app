plugins {
    id("com.android.application")
    kotlin("android")
}

val flutterRoot = localProperties.getProperty("flutter.sdk")
if (flutterRoot == null) {
    throw GradleException("Flutter SDK not found. Define location with flutter.sdk in the local.properties file.")
}

val flutterVersionCode = localProperties.getProperty("flutter.versionCode")
val flutterVersionName = localProperties.getProperty("flutter.versionName")

apply(from = "$flutterRoot/packages/flutter_tools/gradle/flutter.gradle")

android {
    compileSdk = 33

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    sourceSets {
        getByName("main").java.srcDirs("src/main/kotlin")
    }

    defaultConfig {
        applicationId = "com.example.alzheimer_navigation_app"
        minSdk = 21
        targetSdk = 33
        versionCode = flutterVersionCode?.toInt() ?: 1
        versionName = flutterVersionName ?: "1.0"
    }

    buildTypes {
        getByName("release") {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation(kotlin("stdlib"))
}