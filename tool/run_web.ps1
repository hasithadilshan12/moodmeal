# Runs MoodMeal with the Supabase project configured in supabase.json.
#
#   .\tool\run_web.ps1              # Chrome
#   .\tool\run_web.ps1 -Device windows
param([string]$Device = "chrome")

$root = Split-Path -Parent $PSScriptRoot
$flutter = "$env:LOCALAPPDATA\flutter-sdk\flutter\bin\flutter.bat"
if (-not (Test-Path $flutter)) { $flutter = "flutter" }

& $flutter run -d $Device --dart-define-from-file="$root\supabase.json"
exit $LASTEXITCODE
