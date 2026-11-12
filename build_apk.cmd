@echo off
setlocal
rem ---------------------------------------------------------------------------
rem FoldFlow APK build script (Windows)
rem
rem Why this exists: Smart App Control on this PC blocks two unsigned Flutter
rem engine binaries (impellerc.exe = shader compiler, font-subset.exe = icon
rem subsetter). This script:
rem   1. moves Flutter's two sideloaded shader folders aside for the build
rem      (the FoldFlow app never loads a fragment shader), and
rem   2. passes --no-tree-shake-icons so font-subset.exe is never called, and
rem   3. restores the Flutter SDK folders afterwards, even if the build fails.
rem
rem It changes no security setting. On a machine without Smart App Control you
rem can just run:  flutter build apk --release
rem ---------------------------------------------------------------------------

set "FLUTTER_ROOT=C:\Users\user\flutter"
set "JAVA_HOME=C:\Users\user\tools\jdk-17.0.20.1+1"
set "ANDROID_SDK_ROOT=C:\Users\user\android-sdk"
set "PATH=%FLUTTER_ROOT%\bin;%JAVA_HOME%\bin;%PATH%"

set "MAT=%FLUTTER_ROOT%\packages\flutter\lib\src\material\shaders"
set "WID=%FLUTTER_ROOT%\packages\flutter\lib\src\widgets\shaders"

if exist "%MAT%" ren "%MAT%" shaders.disabled
if exist "%WID%" ren "%WID%" shaders.disabled

call flutter build apk --release --no-tree-shake-icons
set "RC=%ERRORLEVEL%"

if exist "%MAT%.disabled" ren "%MAT%.disabled" shaders
if exist "%WID%.disabled" ren "%WID%.disabled" shaders

if "%RC%"=="0" (
  echo.
  echo APK: build\app\outputs\flutter-apk\app-release.apk
) else (
  echo.
  echo Build failed with exit code %RC% - Flutter SDK folders were restored.
)
exit /b %RC%
