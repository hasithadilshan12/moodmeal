# Builds the production web bundle with the Supabase project in supabase.json.
#
#   .\tool\build_web.ps1
$root = Split-Path -Parent $PSScriptRoot
$flutter = "$env:LOCALAPPDATA\flutter-sdk\flutter\bin\flutter.bat"
if (-not (Test-Path $flutter)) { $flutter = "flutter" }

& $flutter build web --release --no-wasm-dry-run `
  --dart-define-from-file="$root\supabase.json"
exit $LASTEXITCODE
