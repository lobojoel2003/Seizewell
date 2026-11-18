import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

/*
 * Release signing.
 *
 * Provide the upload/release keystore either through android/key.properties
 * (local builds, never committed) or through environment variables (CI):
 *   SEIZEWELL_KEYSTORE_PATH, SEIZEWELL_KEYSTORE_PASSWORD,
 *   SEIZEWELL_KEY_ALIAS, SEIZEWELL_KEY_PASSWORD
 * Without them, release builds fall back to the debug key so that
 * `flutter run --release` keeps working.
 */
val keystoreProperties = Properties().apply {
    val file = rootProject.file("key.properties")
    if (file.exists()) FileInputStream(file).use { load(it) }
}

fun signingValue(property: String, env: String): String? =
    keystoreProperties.getProperty(property) ?: System.getenv(env)?.takeIf { it.isNotBlank() }

val releaseStoreFile = signingValue("storeFile", "SEIZEWELL_KEYSTORE_PATH")
val hasReleaseSigning = releaseStoreFile != null && file(releaseStoreFile).exists()

android {
    namespace = "io.github.lobojoel2003.seizewell"
    // flutter_local_notifications requires compileSdk 37.
    compileSdk = 37
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // Needed by flutter_local_notifications for scheduled alerts.
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "io.github.lobojoel2003.seizewell"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // From pubspec.yaml "version: x.y.z+build". With --split-per-abi,
        // Flutter adds 1000 × ABI index to the build number automatically.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseSigning) {
            create("release") {
                storeFile = file(releaseStoreFile!!)
                storePassword = signingValue("storePassword", "SEIZEWELL_KEYSTORE_PASSWORD")
                keyAlias = signingValue("keyAlias", "SEIZEWELL_KEY_ALIAS")
                keyPassword = signingValue("keyPassword", "SEIZEWELL_KEY_PASSWORD")
            }
        }
    }

    buildTypes {
        release {
            signingConfig =
                if (hasReleaseSigning) signingConfigs.getByName("release")
                else signingConfigs.getByName("debug")
        }
    }

    // Reproducible, store-friendly APKs: no dependency metadata blob
    // (F-Droid rejects it).
    dependenciesInfo {
        includeInApk = false
        includeInBundle = false
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
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    // AppCompat themes keep the biometric prompt working on Android 8 and older.
    implementation("androidx.appcompat:appcompat:1.7.0")
}
