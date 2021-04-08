import org.jetbrains.kotlin.gradle.tasks.KotlinCompile

plugins {
    kotlin("jvm") version "1.4.31"
    application
//    mainClassName = "net.mydomain.kotlinlearn.MainKt"

}

group = "me.serdjuk"
version = "1.0-SNAPSHOT"

repositories {
    mavenCentral()

}



tasks.withType<KotlinCompile>() {
    kotlinOptions.jvmTarget = "1.8"
}

tasks.register<Jar>("uberJar") {
    archiveClassifier.set("uber")

    manifest {
        attributes(
            "Main-Class" to "mytest.AppKt",
            "Implementation-Title" to "Gradle",
            "Implementation-Version" to archiveVersion
        )
    }

    from(sourceSets.main.get().output)

    dependsOn(configurations.runtimeClasspath)
    from({
        configurations.runtimeClasspath.get().filter { it.name.endsWith("jar") }.map { zipTree(it) }
    })
}

application {
    mainClassName = "MainKt"
}