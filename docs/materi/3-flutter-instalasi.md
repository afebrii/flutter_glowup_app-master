# Flutter Instalasi

## Daftar Isi
1. [Persyaratan Sistem](#persyaratan-sistem)
2. [Instalasi Windows](#instalasi-windows)
3. [Instalasi macOS](#instalasi-macos)
4. [Instalasi Linux (Ubuntu)](#instalasi-linux-ubuntu)
5. [Konfigurasi IDE](#konfigurasi-ide)
6. [Menjalankan Proyek GlowUp](#menjalankan-proyek-glowup)
7. [Troubleshooting](#troubleshooting)

---

## Persyaratan Sistem

### Minimum Requirements

| OS | RAM | Disk Space | Display |
|----|-----|------------|---------|
| Windows 10 64-bit | 8 GB | 10 GB | 1280 x 800 |
| macOS 10.15 (Catalina) | 8 GB | 10 GB | 1280 x 800 |
| Ubuntu 20.04 LTS | 8 GB | 10 GB | 1280 x 800 |

### Recommended Requirements

| OS | RAM | Disk Space | Display |
|----|-----|------------|---------|
| Windows 11 64-bit | 16 GB | 20 GB | 1920 x 1080 |
| macOS 12+ (Monterey) | 16 GB | 20 GB | Retina |
| Ubuntu 22.04 LTS | 16 GB | 20 GB | 1920 x 1080 |

### Software Requirements

- Git (version control)
- IDE: VS Code atau Android Studio
- Chrome browser (untuk web development)

---

## Instalasi Windows

### Step 1: Download Flutter SDK

1. Buka https://docs.flutter.dev/get-started/install/windows
2. Klik **"Download Flutter SDK"**
3. Download file `flutter_windows_x.x.x-stable.zip`

### Step 2: Extract Flutter SDK

1. Extract ZIP ke folder yang **tidak memerlukan admin privileges**
2. **Recommended path**: `C:\flutter` atau `C:\src\flutter`

```
❌ HINDARI folder berikut:
   - C:\Program Files\
   - C:\Program Files (x86)\
   - Folder dengan spasi di nama

✅ GUNAKAN:
   - C:\flutter
   - C:\src\flutter
   - D:\flutter
```

### Step 3: Update Path Environment Variable

**Cara GUI:**

1. Tekan `Windows + R`, ketik `sysdm.cpl`, Enter
2. Klik tab **Advanced** → **Environment Variables**
3. Di bagian **User variables**, cari **Path**
4. Klik **Edit** → **New**
5. Tambahkan: `C:\flutter\bin`
6. Klik **OK** di semua dialog

**Cara PowerShell (Admin):**

```powershell
# Tambahkan ke User Path
[Environment]::SetEnvironmentVariable(
    "Path",
    [Environment]::GetEnvironmentVariable("Path", "User") + ";C:\flutter\bin",
    "User"
)
```

### Step 4: Install Git for Windows

1. Download dari https://git-scm.com/download/win
2. Jalankan installer
3. Gunakan setting default, klik Next sampai selesai

### Step 5: Install Android Studio

1. Download dari https://developer.android.com/studio
2. Jalankan installer
3. Pilih **Standard** installation
4. Tunggu download SDK selesai

**Setup Android SDK:**

1. Buka Android Studio
2. Klik **More Actions** → **SDK Manager**
3. Tab **SDK Platforms**: Centang **Android 14 (API 34)**
4. Tab **SDK Tools**: Centang:
   - Android SDK Build-Tools
   - Android SDK Command-line Tools
   - Android Emulator
   - Android SDK Platform-Tools
5. Klik **Apply** dan tunggu download

### Step 6: Accept Android Licenses

Buka Command Prompt atau PowerShell:

```bash
flutter doctor --android-licenses
```

Tekan `y` untuk semua pertanyaan.

### Step 7: Verify Installation

```bash
flutter doctor
```

**Output yang diharapkan:**

```
Doctor summary (to see all details, run flutter doctor -v):
[✓] Flutter (Channel stable, 3.x.x, on Microsoft Windows 11)
[✓] Windows Version (Installed version of Windows is version 10 or higher)
[✓] Android toolchain - develop for Android devices (Android SDK version 34.x.x)
[✓] Chrome - develop for the web
[✓] Visual Studio - develop Windows apps (Visual Studio Community 2022)
[✓] Android Studio (version 2023.x)
[✓] VS Code (version 1.x.x)
[✓] Connected device (2 available)
[✓] Network resources

• No issues found!
```

### Step 8: Create Android Emulator

1. Buka Android Studio
2. **More Actions** → **Virtual Device Manager**
3. Klik **Create Device**
4. Pilih **Pixel 7** (atau device lain) → **Next**
5. Pilih **Android 14 (API 34)** → Download jika belum
6. Klik **Next** → **Finish**

### Step 9: (Optional) Install Visual Studio untuk Windows Development

Untuk develop aplikasi Windows native:

1. Download Visual Studio Community dari https://visualstudio.microsoft.com/
2. Jalankan installer
3. Pilih workload: **Desktop development with C++**
4. Install

---

## Instalasi macOS

### Step 1: Install Xcode

```bash
# Install Xcode dari App Store
# atau via command line:
xcode-select --install
```

Buka App Store → Search "Xcode" → Install

**Setelah install:**

```bash
# Accept license
sudo xcodebuild -license accept

# Install additional tools
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
```

### Step 2: Install Homebrew (Package Manager)

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

**Setelah install, tambahkan ke PATH:**

Untuk Apple Silicon (M1/M2/M3):
```bash
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
```

Untuk Intel:
```bash
echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/usr/local/bin/brew shellenv)"
```

### Step 3: Install Flutter via Homebrew

```bash
# Install Flutter
brew install --cask flutter

# Verify installation
flutter --version
```

**Atau manual download:**

1. Download dari https://docs.flutter.dev/get-started/install/macos
2. Extract ke folder, misalnya `~/development/flutter`
3. Tambahkan ke PATH:

```bash
# Tambahkan ke ~/.zshrc atau ~/.bash_profile
export PATH="$HOME/development/flutter/bin:$PATH"

# Reload
source ~/.zshrc
```

### Step 4: Install CocoaPods

CocoaPods diperlukan untuk iOS development:

```bash
# Install via gem
sudo gem install cocoapods

# Atau via Homebrew
brew install cocoapods
```

### Step 5: Install Android Studio

1. Download dari https://developer.android.com/studio
2. Drag ke Applications folder
3. Buka Android Studio
4. Ikuti setup wizard

**Setup Android SDK:**

1. Android Studio → **Preferences** (⌘,)
2. **Appearance & Behavior** → **System Settings** → **Android SDK**
3. Tab **SDK Platforms**: Centang **Android 14 (API 34)**
4. Tab **SDK Tools**: Centang:
   - Android SDK Build-Tools
   - Android SDK Command-line Tools
   - Android Emulator
   - Android SDK Platform-Tools
5. **Apply**

### Step 6: Accept Android Licenses

```bash
flutter doctor --android-licenses
```

Tekan `y` untuk semua.

### Step 7: Setup iOS Simulator

```bash
# Buka iOS Simulator
open -a Simulator

# Atau via Xcode
# Xcode → Open Developer Tool → Simulator
```

### Step 8: Verify Installation

```bash
flutter doctor
```

**Output yang diharapkan:**

```
Doctor summary (to see all details, run flutter doctor -v):
[✓] Flutter (Channel stable, 3.x.x, on macOS 14.x)
[✓] Android toolchain - develop for Android devices (Android SDK version 34.x.x)
[✓] Xcode - develop for iOS and macOS (Xcode 15.x)
[✓] Chrome - develop for the web
[✓] Android Studio (version 2023.x)
[✓] VS Code (version 1.x.x)
[✓] Connected device (3 available)
[✓] Network resources

• No issues found!
```

### Step 9: Create Android Emulator

1. Buka Android Studio
2. **More Actions** → **Virtual Device Manager**
3. **Create Device** → Pilih **Pixel 7** → **Next**
4. Pilih **Android 14 (API 34)** → Download
5. **Finish**

---

## Instalasi Linux (Ubuntu)

### Step 1: Update System

```bash
sudo apt update && sudo apt upgrade -y
```

### Step 2: Install Dependencies

```bash
# Install required packages
sudo apt install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    clang \
    cmake \
    ninja-build \
    pkg-config \
    libgtk-3-dev \
    liblzma-dev \
    libstdc++-12-dev
```

### Step 3: Install Flutter SDK

**Menggunakan Snap (Recommended):**

```bash
# Install Flutter via Snap
sudo snap install flutter --classic

# Verify
flutter --version
```

**Atau Manual Download:**

```bash
# Download Flutter SDK
cd ~
wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.19.0-stable.tar.xz

# Extract
tar xf flutter_linux_3.19.0-stable.tar.xz

# Pindahkan ke /opt (optional)
sudo mv flutter /opt/flutter

# Tambahkan ke PATH
echo 'export PATH="/opt/flutter/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

# Verify
flutter --version
```

### Step 4: Install Chrome

Flutter web memerlukan Chrome:

```bash
# Download dan install Chrome
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i google-chrome-stable_current_amd64.deb
sudo apt --fix-broken install -y
```

### Step 5: Install Android Studio

**Option A: Snap (Recommended)**

```bash
sudo snap install android-studio --classic
```

**Option B: Manual Download**

1. Download dari https://developer.android.com/studio
2. Extract:

```bash
cd ~/Downloads
tar -xzf android-studio-*.tar.gz
sudo mv android-studio /opt/
```

3. Jalankan:

```bash
/opt/android-studio/bin/studio.sh
```

4. Ikuti setup wizard

**Setup Android SDK:**

1. Android Studio → **File** → **Settings** (Ctrl+Alt+S)
2. **Appearance & Behavior** → **System Settings** → **Android SDK**
3. Tab **SDK Platforms**: Centang **Android 14 (API 34)**
4. Tab **SDK Tools**: Centang:
   - Android SDK Build-Tools
   - Android SDK Command-line Tools
   - Android Emulator
   - Android SDK Platform-Tools
5. **Apply**

### Step 6: Configure Android SDK Path

```bash
# Tambahkan ke ~/.bashrc
echo 'export ANDROID_HOME=$HOME/Android/Sdk' >> ~/.bashrc
echo 'export PATH=$PATH:$ANDROID_HOME/emulator' >> ~/.bashrc
echo 'export PATH=$PATH:$ANDROID_HOME/platform-tools' >> ~/.bashrc
source ~/.bashrc
```

### Step 7: Accept Android Licenses

```bash
flutter doctor --android-licenses
```

Tekan `y` untuk semua.

### Step 8: Setup KVM for Android Emulator

```bash
# Install KVM
sudo apt install -y qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils

# Add user to kvm group
sudo adduser $USER kvm

# Verify
egrep -c '(vmx|svm)' /proc/cpuinfo
# Output harus > 0
```

**Logout dan login kembali** agar group permission aktif.

### Step 9: Verify Installation

```bash
flutter doctor -v
```

**Output yang diharapkan:**

```
Doctor summary (to see all details, run flutter doctor -v):
[✓] Flutter (Channel stable, 3.x.x, on Ubuntu 22.04 LTS)
[✓] Android toolchain - develop for Android devices (Android SDK version 34.x.x)
[✓] Chrome - develop for the web
[✓] Linux toolchain - develop for Linux desktop
[✓] Android Studio (version 2023.x)
[✓] VS Code (version 1.x.x)
[✓] Connected device (2 available)
[✓] Network resources

• No issues found!
```

### Step 10: Create Android Emulator

1. Buka Android Studio
2. **More Actions** → **Virtual Device Manager**
3. **Create Device** → Pilih **Pixel 7** → **Next**
4. Pilih **Android 14 (API 34)** → Download
5. **Finish**

---

## Konfigurasi IDE

### VS Code (Recommended)

#### Install VS Code

**Windows:**
Download dari https://code.visualstudio.com/

**macOS:**
```bash
brew install --cask visual-studio-code
```

**Linux:**
```bash
sudo snap install code --classic
```

#### Install Extensions

Buka VS Code, tekan `Ctrl+Shift+X` (atau `Cmd+Shift+X` di Mac), cari dan install:

| Extension | Publisher | Deskripsi |
|-----------|-----------|-----------|
| **Flutter** | Dart Code | Flutter development |
| **Dart** | Dart Code | Dart language support |
| **Error Lens** | usernamehw | Inline error display |
| **Pubspec Assist** | Jeroen Meijer | Dependency management |
| **bloc** | Felix Angelov | BLoC snippets |
| **GitLens** | GitKraken | Git integration |

#### Configure VS Code Settings

Buka Settings JSON (`Ctrl+Shift+P` → "Preferences: Open Settings (JSON)"):

```json
{
  // Dart/Flutter
  "dart.flutterSdkPath": "C:\\flutter",  // Sesuaikan path
  "dart.previewFlutterUiGuides": true,
  "dart.previewFlutterUiGuidesCustomTracking": true,

  // Editor
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll": "explicit",
    "source.organizeImports": "explicit"
  },
  "[dart]": {
    "editor.formatOnSave": true,
    "editor.formatOnType": true,
    "editor.rulers": [80],
    "editor.selectionHighlight": false,
    "editor.suggest.snippetsPreventQuickSuggestions": false,
    "editor.suggestSelection": "first",
    "editor.tabCompletion": "onlySnippets",
    "editor.wordBasedSuggestions": "off"
  },

  // Files
  "files.watcherExclude": {
    "**/.git/objects/**": true,
    "**/.git/subtree-cache/**": true,
    "**/node_modules/**": true,
    "**/.dart_tool/**": true,
    "**/build/**": true
  },

  // Terminal
  "terminal.integrated.defaultProfile.windows": "PowerShell",
  "terminal.integrated.defaultProfile.linux": "bash",
  "terminal.integrated.defaultProfile.osx": "zsh"
}
```

### Android Studio

#### Install Flutter Plugin

1. Buka Android Studio
2. **File** → **Settings** (Windows/Linux) atau **Android Studio** → **Preferences** (macOS)
3. **Plugins** → **Marketplace**
4. Search "Flutter" → **Install**
5. Restart Android Studio

#### Configure SDK Path

1. **File** → **Settings**
2. **Languages & Frameworks** → **Flutter**
3. Set **Flutter SDK path**: `C:\flutter` atau `/opt/flutter`

---

## Menjalankan Proyek GlowUp

### Step 1: Clone Repository

```bash
# Clone project
git clone https://github.com/your-repo/flutter_glowup_app.git

# Masuk ke folder
cd flutter_glowup_app
```

### Step 2: Install Dependencies

```bash
# Get all packages
flutter pub get
```

### Step 3: Verify Project Setup

```bash
# Check project status
flutter doctor

# Analyze code
flutter analyze
```

### Step 4: Run Application

#### Menggunakan Command Line

```bash
# List available devices
flutter devices

# Run on specific device
flutter run -d <device_id>

# Run on Android Emulator
flutter run -d android

# Run on iOS Simulator (macOS only)
flutter run -d ios

# Run on Chrome (web)
flutter run -d chrome

# Run in release mode
flutter run --release

# Run in profile mode (untuk performance testing)
flutter run --profile
```

#### Menggunakan VS Code

1. Buka folder project di VS Code
2. Tekan `F5` atau **Run** → **Start Debugging**
3. Pilih device di status bar (kiri bawah)

#### Menggunakan Android Studio

1. Buka folder project
2. Pilih device di toolbar
3. Klik tombol **Run** (▶️)

### Step 5: Build APK

```bash
# Build debug APK
flutter build apk --debug

# Build release APK
flutter build apk --release

# Build APK per ABI (ukuran lebih kecil)
flutter build apk --split-per-abi

# Output di: build/app/outputs/flutter-apk/
```

### Step 6: Build iOS (macOS only)

```bash
# Build iOS release
flutter build ios --release

# Output di: build/ios/iphoneos/
```

### Hot Reload & Hot Restart

Saat development:

| Shortcut | Aksi | Deskripsi |
|----------|------|-----------|
| `r` | Hot Reload | Reload perubahan UI tanpa restart |
| `R` | Hot Restart | Restart app dengan state baru |
| `q` | Quit | Keluar dari flutter run |
| `d` | Detach | Detach debugger |

---

## Troubleshooting

### Windows Issues

#### 1. Flutter command not found

```powershell
# Pastikan Path sudah benar
echo $env:Path

# Tambahkan manual jika belum ada
$env:Path += ";C:\flutter\bin"

# Restart terminal
```

#### 2. Android licenses not accepted

```bash
flutter doctor --android-licenses
# Tekan 'y' untuk semua
```

#### 3. Android SDK not found

```powershell
# Set ANDROID_HOME
[Environment]::SetEnvironmentVariable("ANDROID_HOME", "$env:LOCALAPPDATA\Android\Sdk", "User")

# Restart terminal
```

#### 4. Visual Studio not detected

```bash
# Install Visual Studio dengan C++ workload
# atau disable Windows desktop:
flutter config --no-enable-windows-desktop
```

### macOS Issues

#### 1. CocoaPods not installed

```bash
sudo gem install cocoapods
# atau
brew install cocoapods
```

#### 2. Xcode command line tools error

```bash
sudo xcode-select --reset
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
```

#### 3. iOS simulator not starting

```bash
# Kill simulator
killall Simulator

# Reset simulator
xcrun simctl erase all

# Restart
open -a Simulator
```

#### 4. Permission denied pada flutter folder

```bash
sudo chown -R $(whoami) /opt/flutter
```

### Linux Issues

#### 1. libstdc++ error

```bash
sudo apt install libstdc++-12-dev
```

#### 2. KVM permission denied

```bash
sudo adduser $USER kvm
# Logout dan login kembali
```

#### 3. Chrome not found

```bash
# Set Chrome path
export CHROME_EXECUTABLE=/usr/bin/google-chrome-stable
echo 'export CHROME_EXECUTABLE=/usr/bin/google-chrome-stable' >> ~/.bashrc
```

#### 4. Android emulator tidak jalan

```bash
# Check KVM support
egrep -c '(vmx|svm)' /proc/cpuinfo
# Harus > 0

# Check KVM group
groups $USER
# Harus ada 'kvm'

# Jika tidak ada:
sudo adduser $USER kvm
# Logout dan login kembali
```

### Common Issues (All Platforms)

#### 1. flutter pub get error

```bash
# Clean dan get ulang
flutter clean
flutter pub cache repair
flutter pub get
```

#### 2. Gradle build failed

```bash
# Clear Gradle cache
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

#### 3. iOS build failed (macOS)

```bash
# Update pods
cd ios
pod deintegrate
pod install --repo-update
cd ..
flutter clean
flutter run
```

#### 4. Cannot find device

```bash
# Restart ADB
adb kill-server
adb start-server

# Check devices
flutter devices
```

#### 5. "Waiting for another flutter command to release the startup lock"

```bash
# Windows
del /f /s /q "%USERPROFILE%\flutter\bin\cache\lockfile"

# macOS/Linux
rm -f ~/flutter/bin/cache/lockfile
# atau
rm -f /opt/flutter/bin/cache/lockfile
```

---

## Quick Reference

### Perintah Flutter Umum

```bash
# Setup & Info
flutter doctor              # Check setup
flutter doctor -v           # Verbose check
flutter devices             # List devices
flutter --version           # Flutter version

# Project
flutter create app_name     # Create new project
flutter pub get             # Install dependencies
flutter pub upgrade         # Upgrade dependencies
flutter clean               # Clean build files

# Development
flutter run                 # Run app
flutter run -d chrome       # Run on Chrome
flutter run -d android      # Run on Android
flutter run --release       # Run release mode
flutter analyze             # Analyze code
flutter test                # Run tests

# Build
flutter build apk           # Build Android APK
flutter build apk --release # Build release APK
flutter build ios           # Build iOS (macOS only)
flutter build web           # Build web
flutter build windows       # Build Windows
flutter build linux         # Build Linux
flutter build macos         # Build macOS
```

### Shortcuts di VS Code

| Shortcut | Aksi |
|----------|------|
| `F5` | Run & Debug |
| `Ctrl+F5` | Run without Debug |
| `Shift+F5` | Stop |
| `Ctrl+Shift+F5` | Restart |
| `Ctrl+.` | Quick Actions |
| `Ctrl+Space` | Suggestions |
| `F2` | Rename symbol |
| `F12` | Go to Definition |
| `Ctrl+Shift+R` | Refactor |

---

## Checklist Instalasi

### Windows
- [ ] Flutter SDK extracted
- [ ] PATH environment variable set
- [ ] Git installed
- [ ] Android Studio installed
- [ ] Android SDK installed (API 34)
- [ ] Android licenses accepted
- [ ] Android Emulator created
- [ ] VS Code + Flutter extension installed
- [ ] `flutter doctor` no issues

### macOS
- [ ] Xcode installed
- [ ] Xcode license accepted
- [ ] Homebrew installed
- [ ] Flutter SDK installed
- [ ] CocoaPods installed
- [ ] Android Studio installed
- [ ] Android SDK installed (API 34)
- [ ] Android licenses accepted
- [ ] VS Code + Flutter extension installed
- [ ] `flutter doctor` no issues

### Linux (Ubuntu)
- [ ] System dependencies installed
- [ ] Flutter SDK installed
- [ ] Chrome installed
- [ ] Android Studio installed
- [ ] Android SDK installed (API 34)
- [ ] Android licenses accepted
- [ ] KVM configured
- [ ] VS Code + Flutter extension installed
- [ ] `flutter doctor` no issues

---

## Resources

### Official Documentation
- Flutter: https://docs.flutter.dev
- Dart: https://dart.dev/guides
- Flutter Packages: https://pub.dev

### Learning
- Flutter Codelabs: https://codelabs.developers.google.com/?cat=Flutter
- Flutter YouTube: https://www.youtube.com/c/flutterdev
- Dart Pad: https://dartpad.dev

### Community
- Flutter GitHub: https://github.com/flutter/flutter
- Stack Overflow: https://stackoverflow.com/questions/tagged/flutter

---

*Dokumentasi ini dibuat untuk event AFC (Apprentice Flutter Challenge)*
