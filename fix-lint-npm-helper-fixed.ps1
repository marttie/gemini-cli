# fix-lint-npm-helper-fixed.ps1
# Removes any existing npmCmd blocks and inserts a single correct helper after TEMP_DIR or YAMLLINT_VERSION.
# Usage: .\fix-lint-npm-helper-fixed.ps1

$path = 'scripts/lint.js'
if (-not (Test-Path $path)) {
  Write-Error "File not found: $path"
  exit 1
}

# Backup current file
$bak = "$path.bak.fix.$((Get-Date).ToString('yyyyMMddHHmmss'))"
Copy-Item $path $bak -Force
Write-Host "Backup created at $bak"

# Read file
$text = Get-Content $path -Raw -Encoding UTF8

# Remove any existing npmCmd function blocks (safe global remove)
$text = [regex]::Replace($text, '(?s)function\s+npmCmd\s*\(.*?\}\s*', '')

# Helper to insert (here-string avoids quoting issues)
$helper = @'
function npmCmd(args) {
  const bin = process.platform === 'win32' ? 'npm.cmd' : 'npm';
  return bin + ' ' + args;
}

'@

# Find insertion point after TEMP_DIR line
$match = [regex]::Match($text, '^\s*const\s+TEMP_DIR\b.*$', [System.Text.RegularExpressions.RegexOptions]::Multiline)
if ($match.Success) {
  $insertPos = $match.Index + $match.Length
  $text = $text.Substring(0, $insertPos) + [Environment]::NewLine + $helper + $text.Substring($insertPos)
  Set-Content -Path $path -Value $text -Encoding UTF8
  Write-Host "Inserted corrected npmCmd helper after TEMP_DIR and removed duplicates."
} else {
  Write-Warning "TEMP_DIR line not found. Trying to insert after YAMLLINT_VERSION..."
  $match2 = [regex]::Match($text, '^\s*const\s+YAMLLINT_VERSION\b.*$', [System.Text.RegularExpressions.RegexOptions]::Multiline)
  if ($match2.Success) {
    $insertPos = $match2.Index + $match2.Length
    $text = $text.Substring(0, $insertPos) + [Environment]::NewLine + $helper + $text.Substring($insertPos)
    Set-Content -Path $path -Value $text -Encoding UTF8
    Write-Host "Inserted corrected npmCmd helper after YAMLLINT_VERSION and removed duplicates."
  } else {
    Write-Error "Could not find insertion point (TEMP_DIR or YAMLLINT_VERSION). Aborting."
    exit 2
  }
}