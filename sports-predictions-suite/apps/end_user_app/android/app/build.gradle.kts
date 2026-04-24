import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.flore.footballtips"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.flore.footballtips"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 24
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            storeFile = file("keystore.jks")
            storePassword = keystoreProperties["storePassword"] as String? ?: ""
            keyAlias = keystoreProperties["keyAlias"] as String? ?: ""
            keyPassword = keystoreProperties["keyPassword"] as String? ?: ""
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}

val flutterProjectRoot = rootProject.projectDir.parentFile ?: rootProject.projectDir
val flutterApkOutputDir = flutterProjectRoot.resolve("build/app/outputs/flutter-apk")
val flutterBundleOutputDir = flutterProjectRoot.resolve("build/app/outputs/bundle/release")

val copyDebugApkToFlutterBuild = tasks.register<Copy>("copyDebugApkToFlutterBuild") {
    from(layout.buildDirectory.file("outputs/flutter-apk/app-debug.apk"))
    into(flutterApkOutputDir)
}

val copyReleaseAabToFlutterBuild = tasks.register<Copy>("copyReleaseAabToFlutterBuild") {
    from(layout.buildDirectory.file("outputs/bundle/release/app-release.aab"))
    into(flutterBundleOutputDir)
}

tasks.matching { it.name == "assembleDebug" }.configureEach {
    finalizedBy(copyDebugApkToFlutterBuild)
}

tasks.matching { it.name == "bundleRelease" }.configureEach {
    finalizedBy(copyReleaseAabToFlutterBuild)
}

// Add at the very bottom
apply(plugin = "com.google.gms.google-services")
