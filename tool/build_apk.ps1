# Builds a release APK with the Supabase project in supabase.json.
#
#   .\tool\build_apk.ps1
$root = Split-Path -Parent $PSScriptRoot
$flutter = "$env:LOCALAPPDATA\flutter-sdk\flutter\bin\flutter.bat"
if (-not (Test-Path $flutter)) { $flutter = "flutter" }

& $flutter build apk --release --dart-define-from-file="$root\supabase.json"
exit $LASTEXITCODE
