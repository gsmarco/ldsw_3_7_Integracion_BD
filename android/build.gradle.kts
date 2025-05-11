allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

buildscript {
    repositories {
        google()      // Este es esencial para resolver com.google.gms
        mavenCentral()
    }    
    
    dependencies {
        // classpath("com.google.gms:google-services:4.3.15") // usa la versión adecuada
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:2.1.0")
        classpath("com.android.tools.build:gradle:8.3.1") // o la que uses
        classpath("com.google.gms:google-services:4.3.15") // AQUÍ está el plugin
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
