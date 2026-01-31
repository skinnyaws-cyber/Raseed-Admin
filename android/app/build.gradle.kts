plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
    id("org.jetbrains.kotlin.android")
    // ✅ 1. إضافة بلاجن خدمات جوجل (Firebase)
    id("com.google.gms.google-services")
}

android {
    // تأكد أن هذا الاسم يطابق ما سجلته في Firebase
    namespace = "com.raseed.admin"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    sourceSets {
        getByName("main").java.srcDirs("src/main/kotlin")
    }

    defaultConfig {
        // تأكد من تطابق الـ ID
        applicationId = "com.raseed.admin"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // توقيع النسخة النهائية (يمكن إعداده لاحقاً)
            isMinifyEnabled = false
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // ✅ 2. إضافة مكتبة Firebase BOM لتوحيد النسخ
    implementation(platform("com.google.firebase:firebase-bom:34.8.0"))

    // لا داعي لإضافة المكتبات الأخرى يدوياً (مثل Analytics) لأن Flutter يديرها
}
