#!/data/data/com.termux/files/usr/bin/bash
set -e

echo "=========================================="
echo " MONU MOBILE COMMAND OS - LEVEL 0 SETUP"
echo "=========================================="

PROJECT="MONU-Mobile"

mkdir -p app/src/main/java/com/monu/mobile/{core,ui,feature/{home,chat,connection,voice,tasks,media,files,security,device,memory,notifications,server},data/{local,remote},domain}
mkdir -p app/src/main/res/{drawable,mipmap-hdpi,mipmap-mdpi,mipmap-xhdpi,mipmap-xxhdpi,mipmap-xxxhdpi,values}
mkdir -p .github/workflows
mkdir -p docs

cat > settings.gradle.kts <<'EOF'
pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.name = "MONU-Mobile"
include(":app")
EOF

cat > build.gradle.kts <<'EOF'
plugins {
    id("com.android.application") version "8.7.3" apply false
    id("org.jetbrains.kotlin.android") version "2.0.21" apply false
}
EOF

cat > gradle.properties <<'EOF'
org.gradle.jvmargs=-Xmx2048m -Dfile.encoding=UTF-8
android.useAndroidX=true
kotlin.code.style=official
EOF

cat > app/build.gradle.kts <<'EOF'
plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
}

android {
    namespace = "com.monu.mobile"
    compileSdk = 35

    defaultConfig {
        applicationId = "com.monu.mobile"
        minSdk = 26
        targetSdk = 35
        versionCode = 1
        versionName = "0.1.0"

        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
    }

    buildFeatures {
        compose = true
        buildConfig = true
    }

    composeOptions {
        kotlinCompilerExtensionVersion = "1.5.15"
    }
}

dependencies {
    implementation(platform("androidx.compose:compose-bom:2024.09.03"))

    implementation("androidx.core:core-ktx:1.15.0")
    implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.8.7")
    implementation("androidx.activity:activity-compose:1.9.3")

    implementation("androidx.compose.ui:ui")
    implementation("androidx.compose.ui:ui-tooling-preview")
    implementation("androidx.compose.material3:material3")

    implementation("androidx.navigation:navigation-compose:2.8.5")

    debugImplementation("androidx.compose.ui:ui-tooling")
    debugImplementation("androidx.compose.ui:ui-test-manifest")

    testImplementation("junit:junit:4.13.2")
}
EOF

cat > app/src/main/AndroidManifest.xml <<'EOF'
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <application
        android:allowBackup="true"
        android:label="MONU"
        android:supportsRtl="true"
        android:theme="@style/Theme.MONU">

        <activity
            android:name=".MainActivity"
            android:exported="true">

            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>

        </activity>

    </application>

</manifest>
EOF

cat > app/src/main/res/values/themes.xml <<'EOF'
<resources xmlns:tools="http://schemas.android.com/tools">
    <style name="Theme.MONU" parent="android:style/Theme.Material.NoActionBar">
        <item name="android:fontFamily">sans</item>
        <item name="android:windowLightStatusBar">false</item>
        <item name="android:statusBarColor">#0B1020</item>
        <item name="android:navigationBarColor">#0B1020</item>
    </style>
</resources>
EOF

cat > app/src/main/java/com/monu/mobile/MainActivity.kt <<'EOF'
package com.monu.mobile

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import com.monu.mobile.ui.MONUApp

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        setContent {
            MONUApp()
        }
    }
}
EOF

cat > app/src/main/java/com/monu/mobile/ui/MONUApp.kt <<'EOF'
package com.monu.mobile.ui

import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp

@Composable
fun MONUApp() {
    MaterialTheme(
        colorScheme = darkColorScheme(
            primary = Color(0xFF4FC3F7),
            background = Color(0xFF0B1020),
            surface = Color(0xFF121A2B)
        )
    ) {
        Surface(
            modifier = Modifier.fillMaxSize()
        ) {
            MONUHome()
        }
    }
}

@Composable
fun MONUHome() {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(20.dp),
        verticalArrangement = Arrangement.SpaceBetween
    ) {

        Column {
            Text(
                text = "MONU",
                style = MaterialTheme.typography.displaySmall
            )

            Spacer(modifier = Modifier.height(8.dp))

            Text(
                text = "Personal Mobile Command Center",
                style = MaterialTheme.typography.bodyLarge
            )
        }

        Column(
            verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {

            StatusCard(
                title = "MONU SERVER",
                status = "NOT CONFIGURED",
                color = Color(0xFFFFA726)
            )

            StatusCard(
                title = "INTERNET",
                status = "CHECKING",
                color = Color(0xFF42A5F5)
            )

            StatusCard(
                title = "LOCAL INTELLIGENCE",
                status = "FOUNDATION READY",
                color = Color(0xFF66BB6A)
            )
        }

        Button(
            modifier = Modifier.fillMaxWidth(),
            onClick = { }
        ) {
            Text("OPEN COMMAND CENTER")
        }
    }
}

@Composable
fun StatusCard(
    title: String,
    status: String,
    color: Color
) {
    Card(
        modifier = Modifier.fillMaxWidth()
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(18.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {

            Box(
                modifier = Modifier
                    .size(12.dp)
                    .padding(end = 8.dp)
            ) {
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = color,
                    shape = MaterialTheme.shapes.small
                ) {}
            }

            Column {
                Text(
                    text = title,
                    style = MaterialTheme.typography.titleMedium
                )

                Text(
                    text = status,
                    style = MaterialTheme.typography.bodyMedium
                )
            }
        }
    }
}
EOF

cat > README.md <<'EOF'
# MONU Mobile Command OS

MONU Mobile is the personal mobile command center for the MONU ecosystem.

## Core Vision

- Voice-first interaction
- Universal command interface
- Real server connectivity
- WebSocket communication
- Server heartbeat and update collection
- Local mobile intelligence
- Internet fallback intelligence
- Personal memory
- Task monitoring
- Media operations
- File operations
- Device intelligence
- Security center
- Dynamic home dashboard
- Multiple conversations
- Accessibility and audio-first interaction

## Architecture

MONU Mobile
|
+-- Core
+-- UI
+-- Chat
+-- Voice
+-- Connection
+-- Server
+-- Tasks
+-- Media
+-- Files
+-- Memory
+-- Device
+-- Security
+-- Notifications

## Development Principle

No fake connection status.
No fake task progress.
No fake health reports.

Every displayed system state must come from a real test or real data source.
EOF

cat > .gitignore <<'EOF'
*.iml
.gradle
/local.properties
/.idea
.DS_Store
/build
/captures
.externalNativeBuild
.cxx
app/build
EOF

cat > .github/workflows/android.yml <<'EOF'
name: Build MONU Android APK

on:
  push:
    branches: ["main"]
  pull_request:
    branches: ["main"]
  workflow_dispatch:

jobs:
  build:
    name: Build Debug APK
    runs-on: ubuntu-latest

    steps:
      - name: Checkout source
        uses: actions/checkout@v4

      - name: Set up JDK
        uses: actions/setup-java@v4
        with:
          distribution: temurin
          java-version: "17"

      - name: Set up Gradle
        uses: gradle/actions/setup-gradle@v4

      - name: Build APK
        run: gradle :app:assembleDebug

      - name: Upload APK
        uses: actions/upload-artifact@v4
        with:
          name: MONU-Mobile-debug
          path: app/build/outputs/apk/debug/app-debug.apk
EOF

cat > docs/ARCHITECTURE.md <<'EOF'
# MONU MOBILE ARCHITECTURE

## Intelligence Sources

1. MONU Server
2. Internet Intelligence
3. Local Mobile Intelligence
4. Cached Knowledge

## Connection Truth

Two independent checks:

- APK -> Server
- Server -> APK

Neither status may be simulated.

## Future Modules

- REST API client
- WebSocket engine
- Heartbeat engine
- Offline queue
- Local database
- Voice system
- File transfer engine
- Device intelligence
- Security center
- Screen context
- Notification center
- Personal identity
EOF

echo ""
echo "=========================================="
echo " MONU MOBILE PROJECT CREATED SUCCESSFULLY"
echo "=========================================="
echo ""
echo "Project location:"
pwd
echo ""
echo "Important files:"
find . -maxdepth 3 -type f | sort
echo ""
echo "Next: Commit this project to GitHub."
