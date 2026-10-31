import java.io.ByteArrayOutputStream
import java.util.Properties
import javax.inject.Inject
import org.gradle.process.ExecOperations

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keyProperties = Properties().apply {
    val file = rootProject.file("key.properties")
    if (file.exists()) file.inputStream().use { load(it) }
}

android {
    namespace = "com.tagarela.tagarela"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 26
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    flavorDimensions += "environment"
    productFlavors {
        create("dsv") {
            dimension = "environment"
            applicationId = "com.tagarela.dsv"
            manifestPlaceholders["appName"] = "Tagarela DSV"
        }
        create("prd") {
            dimension = "environment"
            applicationId = "com.tagarela.app"
            manifestPlaceholders["appName"] = "Tagarela"
        }
    }

    signingConfigs {
        if (keyProperties.isNotEmpty()) {
            create("release") {
                storeFile = rootProject.file(keyProperties.getProperty("storeFile"))
                storePassword = keyProperties.getProperty("storePassword")
                keyAlias = keyProperties.getProperty("keyAlias")
                keyPassword = keyProperties.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.findByName("release") ?: signingConfigs.getByName("debug")
        }
    }
}

androidComponents {
    beforeVariants { variant ->
        if (variant.flavorName == "dsv" && variant.buildType == "release") {
            variant.enable = false
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

abstract class AdbReverse : DefaultTask() {
    @get:Internal
    abstract val adb: RegularFileProperty

    @get:Input
    abstract val port: Property<Int>

    @get:Inject
    abstract val exec: ExecOperations

    @TaskAction
    fun reverse() {
        val adb = adb.get().asFile
        if (!adb.exists()) return
        val devices = ByteArrayOutputStream()
        exec.exec {
            commandLine(adb.absolutePath, "devices")
            standardOutput = devices
            isIgnoreExitValue = true
        }
        val tcp = "tcp:${port.get()}"
        devices.toString().lineSequence()
            .map { it.trim().split(Regex("\\s+")) }
            .filter { it.size == 2 && it[1] == "device" }
            .forEach { (serial) ->
                exec.exec {
                    commandLine(adb.absolutePath, "-s", serial, "reverse", tcp, tcp)
                    isIgnoreExitValue = true
                }
            }
    }
}

val adbReverse = tasks.register<AdbReverse>("adbReverse") {
    adb.set(androidComponents.sdkComponents.adb)
    port.set(8000)
}

tasks.matching { it.name == "preDsvDebugBuild" }.configureEach {
    dependsOn(adbReverse)
}
