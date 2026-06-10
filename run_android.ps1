# Adds Flutter to PATH for this session and runs on the Android emulator.
$env:Path = "D:\dev\flutter\bin;D:\dev\Android\Sdk\platform-tools;D:\dev\tools\ninja;D:\dev\Android\Sdk\cmake\3.22.1\bin;" + $env:Path
$env:ANDROID_HOME = "D:\dev\Android\Sdk"
$env:ANDROID_SDK_ROOT = "D:\dev\Android\Sdk"
$env:TEMP = "D:\dev\tmp"
$env:TMP = "D:\dev\tmp"
$env:GRADLE_USER_HOME = "D:\dev\gradle-home"
$env:JAVA_HOME = "C:\Program Files\Android\Android Studio\jbr"

Set-Location $PSScriptRoot
flutter pub get
flutter run -d emulator-5554 @args
