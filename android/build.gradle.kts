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

    afterEvaluate {
        if (plugins.hasPlugin("com.android.library")) {
            configure<com.android.build.gradle.LibraryExtension> {
                compileSdk = 35
                if (namespace == null) {
                    namespace = when (name) {
                        "isar_flutter_libs" -> "dev.isar.isar_flutter_libs"
                        else -> "com.antigravity.${name.replace('-', '_')}"
                    }
                }
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
