param(
    [string]$LibRoot = "lib"
)

function Get-VersionToken {
    param([string]$Line)

    $candidate = $Line.Trim()
    if ($candidate -match '^#{1,2}\s*') {
        $candidate = ($candidate -replace '^#{1,2}\s*', '').Trim()
    }

    # Allow date prefixes like: (2025-10-18) v0.4.2
    $candidate = [regex]::Replace($candidate, '^\(?\d{4}-\d{2}-\d{2}\)?\s*', '')

    $match = [regex]::Match(
        $candidate,
        '^(?:v)?(\d+\.\d+\.\d+|\d+\.\d+\.x|\d+\.\d+)\b',
        [System.Text.RegularExpressions.RegexOptions]::IgnoreCase
    )
    if ($match.Success) {
        return $match.Groups[1].Value
    }

    return $null
}

function Normalize-Entry {
    param([string]$Text)

    if (-not $Text) { return "" }

    $entry = $Text.Trim()
    $entry = $entry -replace '\s+', ' '
    return $entry
}

function Classify-Entry {
    param([string]$Entry)

    $lower = $Entry.ToLowerInvariant()

    if ($lower -match 'breaking') {
        return 'Breaking Changes'
    }

    if ($lower -match 'fix|bug|hotfix|error|race|leak|warnung|fehl') {
        return 'Bug'
    }

    return 'Feature'
}

function Parse-Changelog {
    param([string]$Path)

    $versionEntries = New-Object System.Collections.Generic.List[object]
    $current = $null
    $lastCategory = $null
    $lastIndex = -1

    foreach ($line in (Get-Content $Path)) {
        $trimmed = $line.Trim()

        if (-not $trimmed) { continue }

        $isHeading = $trimmed -match '^#{1,2}\s+' -or $trimmed -match '^\(?\d{4}-\d{2}-\d{2}\)?\s*v?\d+\.\d+' -or $trimmed -match '^v?\d+\.\d+'
        if ($isHeading) {
            $version = Get-VersionToken -Line $trimmed
            if ($version) {
                $current = [ordered]@{
                    Version = $version
                    Feature = New-Object System.Collections.Generic.List[string]
                    Bug = New-Object System.Collections.Generic.List[string]
                    Breaking = New-Object System.Collections.Generic.List[string]
                }
                $versionEntries.Add($current)
                $lastCategory = $null
                $lastIndex = -1
                continue
            }
        }

        if (-not $current) { continue }

        if ($trimmed -match '^[\*\-]\s+(.+)$') {
            $entry = Normalize-Entry -Text $Matches[1]
            if (-not $entry) { continue }

            $category = Classify-Entry -Entry $entry
            switch ($category) {
                'Breaking Changes' {
                    $current.Breaking.Add($entry)
                    $lastCategory = 'Breaking'
                    $lastIndex = $current.Breaking.Count - 1
                }
                'Bug' {
                    $current.Bug.Add($entry)
                    $lastCategory = 'Bug'
                    $lastIndex = $current.Bug.Count - 1
                }
                default {
                    $current.Feature.Add($entry)
                    $lastCategory = 'Feature'
                    $lastIndex = $current.Feature.Count - 1
                }
            }
            continue
        }

        # Attach continuation lines to the last captured bullet entry.
        $continuation = Normalize-Entry -Text ($trimmed.TrimStart('>'))
        if (-not $continuation) { continue }

        if ($lastCategory -eq 'Feature' -and $lastIndex -ge 0) {
            $current.Feature[$lastIndex] = ($current.Feature[$lastIndex] + ' ' + $continuation).Trim()
            continue
        }
        if ($lastCategory -eq 'Bug' -and $lastIndex -ge 0) {
            $current.Bug[$lastIndex] = ($current.Bug[$lastIndex] + ' ' + $continuation).Trim()
            continue
        }
        if ($lastCategory -eq 'Breaking' -and $lastIndex -ge 0) {
            $current.Breaking[$lastIndex] = ($current.Breaking[$lastIndex] + ' ' + $continuation).Trim()
            continue
        }

        # If no bullet exists yet in this version block, keep free text as feature note.
        $current.Feature.Add($continuation)
        $lastCategory = 'Feature'
        $lastIndex = $current.Feature.Count - 1
    }

    return $versionEntries
}

function Build-ReleaseNotesContent {
    param($Entries)

    $lines = New-Object System.Collections.Generic.List[string]
    $lines.Add("# Release Notes")
    $lines.Add("")

    foreach ($entry in $Entries) {
        $lines.Add("## $($entry.Version)")

        $lines.Add("### Feature")
        if ($entry.Feature.Count -gt 0) {
            foreach ($item in $entry.Feature) { $lines.Add("- $item") }
        } else {
            $lines.Add("- none")
        }
        $lines.Add("")

        $lines.Add("### Bug")
        if ($entry.Bug.Count -gt 0) {
            foreach ($item in $entry.Bug) { $lines.Add("- $item") }
        } else {
            $lines.Add("- none")
        }
        $lines.Add("")

        $lines.Add("### Breaking Changes")
        if ($entry.Breaking.Count -gt 0) {
            foreach ($item in $entry.Breaking) { $lines.Add("- $item") }
        } else {
            $lines.Add("- none")
        }
        $lines.Add("")
    }

    return ($lines -join "`n") + "`n"
}

if (-not (Test-Path $LibRoot)) {
    throw "Lib root not found: $LibRoot"
}

Get-ChildItem -Path $LibRoot -Directory | ForEach-Object {
    $moduleDir = $_.FullName
    $moduleName = $_.Name
    $changelogPath = Join-Path $moduleDir "CHANGELOG.md"
    $releaseNotesPath = Join-Path $moduleDir "release_notes.md"

    if (-not (Test-Path $changelogPath)) {
        return
    }

    $parsed = Parse-Changelog -Path $changelogPath
    if ($parsed.Count -eq 0) {
        Write-Host "WARN: No parseable versions in $moduleName/CHANGELOG.md" -ForegroundColor Yellow
        return
    }

    $content = Build-ReleaseNotesContent -Entries $parsed
    Set-Content -Path $releaseNotesPath -Value $content -Encoding UTF8
    Write-Host "Migrated $moduleName/release_notes.md" -ForegroundColor Green
}
