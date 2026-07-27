import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile: File? = rootProject.file("key.properties")
if (keystorePropertiesFile?.exists() ?: false) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.likhithpraveenk.sudoku"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.likhithpraveenk.sudoku"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            keyAlias = System.getenv("KEY_ALIAS") ?: (keystoreProperties["keyAlias"] as String?)
            keyPassword =
                System.getenv("KEY_PASSWORD") ?: (keystoreProperties["keyPassword"] as String?)
            storePassword =
                System.getenv("STORE_PASSWORD") ?: (keystoreProperties["storePassword"] as String?)
            val keystorePath =
                System.getenv("KEYSTORE_PATH") ?: (keystoreProperties["storeFile"] as String?)
            storeFile = keystorePath?.let { file(it) }
        }
    }

    buildTypes {
        release {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            signingConfig = when {
                System.getenv("KEY_ALIAS") != null -> signingConfigs.getByName("release")
                keystorePropertiesFile?.exists() == true -> signingConfigs.getByName("release")
                else -> {
                    println("WARNING: No signing credentials found. Building unsigned apk")
                    null
                }
            }
        }
        debug {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
    dependenciesInfo {
        includeInApk = false
        includeInBundle = false
    }
    val abiCodes = mapOf("armeabi-v7a" to 1, "arm64-v8a" to 2, "x86_64" to 3)
    applicationVariants.configureEach {
        val variant = this
        variant.outputs.forEach { output ->
            val abiVersionCode =
                abiCodes[output.filters.find { it.filterType == "ABI" }?.identifier]
            if (abiVersionCode != null) {
                (output as com.android.build.gradle.internal.api.ApkVariantOutputImpl).versionCodeOverride =
                    variant.versionCode * 10 + abiVersionCode
            }
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
