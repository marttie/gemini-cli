# Autopatch (fixed): insert npmCmd helper and replace simple execSync('npm ...') / execSync("npm ...")
# Usage: .\autopatch-npm-windows-fixed.ps1

$path = 'scripts/lint.js'
if (-not (Test-Path $path)) {
  Write-Error "File not found: $path"
  exit 1
}

# Backup
$bak = "$path.bak.$((Get-Date).ToString('yyyyMMddHHmmss'))"
Copy-Item $path $bak -Force
Write-Host "Backup created at $bak"

# Read file as array of lines for safe insertion
$lines = Get-Content $path -Encoding UTF8

# Helper to insert (with CRLF to match Windows)
$helperLines = @(
"function npmCmd(args) {",
"  const bin = process.platform === 'win32' ? 'npm.cmd' : 'npm';",
"  return `\${bin} ${args};",
"}",
""
)

# Find insertion point after a line that defines TEMP_DIR
$insertAt = -1
for ($i = 0; $i -lt $lines.Count; $i++) {
  if ($lines[$i] -match '^\s*const\s+TEMP_DIR\b') {
    $insertAt = $i
    break
  }
}

if ($insertAt -ge 0) {
  $insertPos = $insertAt + 1
  $newLines = $lines[0..$insertAt] + $helperLines + $lines[($insertPos)..($lines.Count - 1)]
  $lines = $newLines
  Write-Host "Inserted helper after TEMP_DIR line (line $insertAt)."
} else {
  # Fallback: insert after YAMLLINT_VERSION line if present
  $insertAt = -1
  for ($i = 0; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -match '^\s*const\s+YAMLLINT_VERSION\b') {
      $insertAt = $i
      break
    }
  }
  if ($insertAt -ge 0) {
    $insertPos = $insertAt + 1
    $newLines = $lines[0..$insertAt] + $helperLines + $lines[($insertPos)..($lines.Count - 1)]
    $lines = $newLines
    Write-Host "Inserted helper after YAMLLINT_VERSION line (line $insertAt)."
  } else {
    Write-Warning "Could not find TEMP_DIR or YAMLLINT_VERSION lines to insert helper. Aborting autopatch."
    exit 2
  }
}

# Join back to a single text for regex replacements
$text = $lines -join "`r`n"

# Replace execSync('npm ...') occurrences (single-quoted)
$pattern1 = "execSync\(\s*'npm\s+([^']+)'\s*\)"
$replacement1 = 'execSync(npmCmd(''$1''))'
$text = [regex]::Replace($text, $pattern1, $replacement1)

# Replace execSync("npm ...") occurrences (double-quoted)
$pattern2 = 'execSync\(\s*"npm\s+([^"]+)"\s*\)'
$replacement2 = 'execSync(npmCmd(''$1''))'
$text = [regex]::Replace($text, $pattern2, $replacement2)

# Write patched file
Set-Content -Path $path -Value $text -Encoding UTF8
Write-Host "Patched $path written."

# Show git diff for review (if git is available)
if (Get-Command git -ErrorAction SilentlyContinue) {
  Write-Host "`n--- git diff (scripts/lint.js) ---`n"
  git --no-pager diff -- scripts/lint.js
} else {
  Write-Warning "git not found in PATH; open scripts/lint.js to review manually."
}

Write-Host "`nAutopatch complete. Review the diff above. If OK, run:"
Write-Host "  git add scripts/lint.js"
Write-Host "  git commit -m `"fix(lint): invoke npm.cmd on Windows to ensure npm is found`""
Write-Host "  git push"