import com.android.build.gradle.LibraryExtension

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

// --------------------------------------------------------
// THE JVM TOOLCHAIN FIX
// This forces all plugins to sync Kotlin and Java to 17
// --------------------------------------------------------
subprojects {
    // 1. Force the JVM Toolchain for all Kotlin plugins
    pluginManager.withPlugin("org.jetbrains.kotlin.android") {
        val kotlin = extensions.getByName("kotlin") as org.jetbrains.kotlin.gradle.dsl.KotlinProjectExtension
        kotlin.jvmToolchain(17)
    }

    // 2. Force Java 17 for the Android Library base
    pluginManager.withPlugin("com.android.library") {
        val android = project.extensions.getByType(LibraryExtension::class.java)
        if (android.namespace == null) {
            android.namespace = project.group.toString()
        }
        android.compileOptions {
            sourceCompatibility = JavaVersion.VERSION_17
            targetCompatibility = JavaVersion.VERSION_17
        }
    }

    // 3. Catch any lingering pure Java compilation tasks
    tasks.withType<JavaCompile>().configureEach {
        sourceCompatibility = JavaVersion.VERSION_17.toString()
        targetCompatibility = JavaVersion.VERSION_17.toString()
    }
}
// --------------------------------------------------------

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}