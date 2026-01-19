plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

// Este es el BoM de Firebase
val firebaseBomVersion = "32.8.0" // Usamos una versión específica y reciente del BoM

android {
    namespace = "com.example.aqualog"
    compileSdk = 35
    ndkVersion = "27.0.12077973" // <-- SOLUCIÓN 1: AÑADIMOS LA VERSIÓN DEL NDK

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    sourceSets {
        getByName("main") {
            java.srcDirs("src/main/kotlin")
        }
    }

    defaultConfig {
        applicationId = "com.example.aqualog"
        minSdk = 21 // Flutter establece esto, puedes dejar la variable
        targetSdk = 35
        versionCode = 1
        versionName = "1.0"
    }

    buildTypes {
        getByName("release") {
            isMinifyEnabled = true
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

dependencies {
    // <-- SOLUCIÓN 2: CONFIGURAMOS LAS DEPENDENCIAS DE FORMA EXPLÍCITA
    // Importamos el BoM para que gestione las versiones
    implementation(platform("com.google.firebase:firebase-bom:$firebaseBomVersion"))

    // AÑADIMOS LAS DEPENDENCIAS SIN ESPECIFICAR VERSIÓN,
    // el BoM se encargará de ello
    implementation("com.google.firebase:firebase-analytics")
    implementation("com.google.firebase:firebase-auth") // Usamos el base, el ktx se añade transitivamente
    implementation("com.google.firebase:firebase-firestore")
    implementation("com.google.firebase:firebase-storage")
    implementation("androidx.multidex:multidex:2.0.1") // Buena práctica para apps con muchas dependencias
}