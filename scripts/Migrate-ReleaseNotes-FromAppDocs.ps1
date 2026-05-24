param(
    [string]$LibRoot = "lib"
)

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

    if ($lower -match 'breaking|nicht kompatibel|inkompatibel') {
        return 'Breaking Changes'
    }
    if ($lower -match 'fix|bugfix|fehler|hotfix') {
        return 'Bug'
    }
    return 'Feature'
}

function Parse-ReleaseNotesFile {
    param([string]$Path)

    $result = @{}
    if (-not (Test-Path $Path)) {
        return $result
    }

    $currentVersion = $null
    $currentCategory = $null

    foreach ($line in (Get-Content $Path)) {
        if ($line -match '^##\s+(.+)$') {
            $currentVersion = $Matches[1].Trim()
            if (-not $result.ContainsKey($currentVersion)) {
                $result[$currentVersion] = [ordered]@{
                    Feature = New-Object System.Collections.Generic.List[string]
                    Bug = New-Object System.Collections.Generic.List[string]
                    'Breaking Changes' = New-Object System.Collections.Generic.List[string]
                }
            }
            $currentCategory = $null
            continue
        }

        if ($line -match '^###\s+(Feature|Bug|Breaking Changes)\s*$') {
            $currentCategory = $Matches[1]
            continue
        }

        if ($line -match '^-\s+(.+)$' -and $currentVersion -and $currentCategory) {
            $entry = Normalize-Entry $Matches[1]
            if ($entry) {
                $result[$currentVersion][$currentCategory].Add($entry)
            }
        }
    }

    return $result
}

function Parse-AppDocHistory {
    param([string]$Path)

    $history = @{}
    $inHistory = $false
    $currentVersion = $null

    foreach ($line in (Get-Content $Path)) {
        $trimmed = $line.Trim()

        if (-not $inHistory) {
            if ($trimmed -match '^##\s+Änderungshistorie\s*$') {
                $inHistory = $true
            }
            continue
        }

        if ($trimmed -match '^##\s+' -and $trimmed -notmatch '^##\s+Änderungshistorie\s*$') {
            break
        }

        if ($trimmed -match '^\d{2}\.\d{2}\.\d{4}:\s*Firmware\s*[^,]+,\s*Applikation\s*([0-9]+(?:\.[0-9]+)*)') {
            $currentVersion = $Matches[1]
            if (-not $history.ContainsKey($currentVersion)) {
                $history[$currentVersion] = [ordered]@{
                    Feature = New-Object System.Collections.Generic.List[string]
                    Bug = New-Object System.Collections.Generic.List[string]
                    'Breaking Changes' = New-Object System.Collections.Generic.List[string]
                }
            }
            continue
        }

        if ($trimmed -match '^\*\s+(.+)$' -and $currentVersion) {
            $entry = Normalize-Entry $Matches[1]
            if (-not $entry) { continue }

            $category = Classify-Entry $entry
            $history[$currentVersion][$category].Add($entry)
        }
    }

    return $history
}

function Merge-HistoryIntoReleaseNotes {
    param(
        [hashtable]$Existing,
        [hashtable]$History,
        [string[]]$VersionOrder
    )

    foreach ($version in $VersionOrder) {
        if (-not $Existing.ContainsKey($version)) {
            $Existing[$version] = [ordered]@{
                Feature = New-Object System.Collections.Generic.List[string]
                Bug = New-Object System.Collections.Generic.List[string]
                'Breaking Changes' = New-Object System.Collections.Generic.List[string]
            }
        }

        foreach ($category in @('Feature', 'Bug', 'Breaking Changes')) {
            foreach ($entry in $History[$version][$category]) {
                if (-not $Existing[$version][$category].Contains($entry)) {
                    # Replace placeholder "none" when real entries exist.
                    [void]$Existing[$version][$category].Remove('none')
                    $Existing[$version][$category].Add($entry)
                }
            }
        }
    }

    return $Existing
}

function Build-ReleaseNotesContent {
    param(
        [hashtable]$Data,
        [string[]]$PreferredOrder
    )

    $orderedVersions = New-Object System.Collections.Generic.List[string]
    foreach ($version in $PreferredOrder) {
        if ($Data.ContainsKey($version)) { $orderedVersions.Add($version) }
    }
    foreach ($version in $Data.Keys) {
        if (-not $orderedVersions.Contains($version)) {
            $orderedVersions.Add($version)
        }
    }

    $lines = New-Object System.Collections.Generic.List[string]
    $lines.Add('# Release Notes')
    $lines.Add('')

    foreach ($version in $orderedVersions) {
        $lines.Add("## $version")

        foreach ($category in @('Feature', 'Bug', 'Breaking Changes')) {
            $lines.Add("### $category")
            if ($Data[$version][$category].Count -eq 0) {
                $lines.Add('- none')
            } else {
                foreach ($entry in $Data[$version][$category]) {
                    $lines.Add("- $entry")
                }
            }
            $lines.Add('')
        }
    }

    return ($lines -join "`n") + "`n"
}

if (-not (Test-Path $LibRoot)) {
    throw "Lib root not found: $LibRoot"
}

$modulesUpdated = 0

Get-ChildItem -Path $LibRoot -Directory | ForEach-Object {
    $moduleDir = $_.FullName
    $moduleName = $_.Name
    $releaseNotesPath = Join-Path $moduleDir 'release_notes.md'

    $docFiles = Get-ChildItem -Path (Join-Path $moduleDir 'doc') -Filter 'Applikationsbeschreibung*.md' -ErrorAction SilentlyContinue
    if (-not $docFiles) { return }

    $combinedHistory = @{}
    $preferredOrder = New-Object System.Collections.Generic.List[string]

    foreach ($doc in $docFiles) {
        $history = Parse-AppDocHistory -Path $doc.FullName
        foreach ($version in $history.Keys) {
            if (-not $combinedHistory.ContainsKey($version)) {
                $combinedHistory[$version] = [ordered]@{
                    Feature = New-Object System.Collections.Generic.List[string]
                    Bug = New-Object System.Collections.Generic.List[string]
                    'Breaking Changes' = New-Object System.Collections.Generic.List[string]
                }
            }

            if (-not $preferredOrder.Contains($version)) {
                $preferredOrder.Add($version)
            }

            foreach ($category in @('Feature', 'Bug', 'Breaking Changes')) {
                foreach ($entry in $history[$version][$category]) {
                    if (-not $combinedHistory[$version][$category].Contains($entry)) {
                        $combinedHistory[$version][$category].Add($entry)
                    }
                }
            }
        }
    }

    if ($combinedHistory.Count -eq 0) { return }

    $existing = Parse-ReleaseNotesFile -Path $releaseNotesPath
    $versionOrder = $preferredOrder.ToArray()
    $merged = Merge-HistoryIntoReleaseNotes -Existing $existing -History $combinedHistory -VersionOrder $versionOrder
    $content = Build-ReleaseNotesContent -Data $merged -PreferredOrder $versionOrder
    Set-Content -Path $releaseNotesPath -Value $content -Encoding UTF8

    Write-Host "Merged app-doc history into $moduleName/release_notes.md" -ForegroundColor Green
    $modulesUpdated++
}

Write-Host "Done. Updated modules: $modulesUpdated" -ForegroundColor Green
