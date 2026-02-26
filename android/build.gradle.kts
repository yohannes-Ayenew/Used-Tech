// android/build.gradle.kts

buildscript {
    val kotlin_version = "1.7.10"
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        // Note: Check that your gradle version matches what was there before (likely 7.3.0 or 8.x)
        classpath("com.android.tools.build:gradle:7.3.0")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version")
        
         
        classpath("com.google.gms:google-services:4.4.0")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.buildDir = file("../build")
subprojects {
    project.buildDir = file("${rootProject.buildDir}/${project.name}")
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.buildDir)
}