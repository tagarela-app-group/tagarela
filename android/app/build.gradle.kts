import java.io.ByteArrayOutputStream
import javax.inject.Inject
import org.gradle.process.ExecOperations

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
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
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.tagarela.tagarela"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 26
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
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

tasks.matching { it.name == "preDebugBuild" }.configureEach {
    dependsOn(adbReverse)
}
