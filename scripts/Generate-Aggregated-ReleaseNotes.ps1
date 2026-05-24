param(
    [Parameter(Mandatory = $true)]
    [string]$OldDependenciesFile,

    [Parameter(Mandatory = $true)]
    [string]$NewDependenciesFile,

    [string]$OutputFileRelease = "release/release_notes.md",
    [string]$OutputFileRoot = "RELEASE_NOTES.md"
)

function Parse-DependencyFile {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if (-not (Test-Path $Path)) {
        throw "Dependency file not found: $Path"
    }

    $result = @{}
    $lineNumber = 0
    foreach ($line in (Get-Content $Path)) {
        $lineNumber++
        if ([string]::IsNullOrWhiteSpace($line)) { continue }
        if ($line.StartsWith("#") -or $line.StartsWith("-------")) { continue }

        $parts = $line -split ' ', 5
        if ($parts.Count -lt 4) {
            Write-Host "WARN: Skip malformed line $lineNumber in '$Path': $line" -ForegroundColor Yellow
            continue
        }

        $hash = $parts[0]
        $version = "unknown"

        if ($parts.Count -eq 4) {
            # Legacy format without version: hash branch modulePath remote
            $branch = $parts[1]
            $modulePath = $parts[2]
            $remote = $parts[3]
        } elseif ($parts.Count -ge 5) {
            # New format: hash version branch modulePath remote
            if ($parts[3] -match '^lib/') {
                $version = $parts[1]
                $branch = $parts[2]
                $modulePath = $parts[3]
                $remote = $parts[4]
            } else {
                # Backward compatible fallback to previous new format: hash branch version modulePath remote
                $branch = $parts[1]
                $version = $parts[2]
                $modulePath = $parts[3]
                $remote = $parts[4]
            }
        }

        $result[$modulePath] = [PSCustomObject]@{
            Hash = $hash
            Branch = $branch
            ModulePath = $modulePath
            Remote = $remote
            Version = $version
        }
    }

    return $result
}

function Parse-VersionObject {
    param([string]$VersionText)

    if ([string]::IsNullOrWhiteSpace($VersionText)) {
        return $null
    }

    $normalized = $VersionText.Trim()
    if ($normalized.StartsWith("v")) {
        $normalized = $normalized.Substring(1)
    }

    $versionObj = $null
    if ([System.Version]::TryParse($normalized, [ref]$versionObj)) {
        return $versionObj
    }

    return $null
}

function Get-ParsedReleaseNotes {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ModuleDirectory
    )

    $releaseNotesPath = Join-Path $ModuleDirectory "release_notes.md"
    if (-not (Test-Path $releaseNotesPath)) {
        return @{}
    }

    $versions = @{}
    $currentVersion = $null
    $currentCategory = $null

    foreach ($line in (Get-Content $releaseNotesPath)) {
        if ($line -match '^##\s+(.+)$') {
            $currentVersion = $Matches[1].Trim()
            if (-not $versions.ContainsKey($currentVersion)) {
                $versions[$currentVersion] = [ordered]@{
                    Feature = @()
                    Bug = @()
                    'Breaking Changes' = @()
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
            $entry = $Matches[1].Trim()
            if ($entry) {
                $versions[$currentVersion][$currentCategory] += $entry
            }
        }
    }

    return $versions
}

function Get-ReleaseNoteDelta {
    param(
        [hashtable]$AllNotes,
        [string]$OldVersion,
        [string]$NewVersion
    )

    if ($AllNotes.ContainsKey($NewVersion)) {
        return [PSCustomObject]@{
            Feature = $AllNotes[$NewVersion]['Feature']
            Bug = $AllNotes[$NewVersion]['Bug']
            BreakingChanges = $AllNotes[$NewVersion]['Breaking Changes']
            Source = "release_notes"
        }
    }

    $oldVersionObj = Parse-VersionObject $OldVersion
    $newVersionObj = Parse-VersionObject $NewVersion

    if ($oldVersionObj -and $newVersionObj) {
        $feature = @()
        $bug = @()
        $breaking = @()

        foreach ($key in $AllNotes.Keys) {
            $keyObj = Parse-VersionObject $key
            if (-not $keyObj) { continue }
            if ($keyObj -gt $oldVersionObj -and $keyObj -le $newVersionObj) {
                $feature += $AllNotes[$key]['Feature']
                $bug += $AllNotes[$key]['Bug']
                $breaking += $AllNotes[$key]['Breaking Changes']
            }
        }

        if ($feature.Count -gt 0 -or $bug.Count -gt 0 -or $breaking.Count -gt 0) {
            return [PSCustomObject]@{
                Feature = $feature
                Bug = $bug
                BreakingChanges = $breaking
                Source = "release_notes_range"
            }
        }
    }

    return $null
}

function Classify-CommitMessages {
    param(
        [string[]]$Messages
    )

    $feature = @()
    $bug = @()
    $breaking = @()

    foreach ($msg in $Messages) {
        $text = $msg.Trim()
        if (-not $text) { continue }

        $lower = $text.ToLowerInvariant()
        if ($lower -match 'breaking|break:' -or $lower -match '!\s') {
            $breaking += $text
        } elseif ($lower -match 'fix|bug|hotfix|error') {
            $bug += $text
        } else {
            $feature += $text
        }
    }

    return [PSCustomObject]@{
        Feature = $feature
        Bug = $bug
        BreakingChanges = $breaking
    }
}

function Get-CommitFallback {
    param(
        [string]$ModuleDirectory,
        [string]$OldHash,
        [string]$NewHash
    )

    if (-not (Test-Path (Join-Path $ModuleDirectory ".git"))) {
        return $null
    }

    $logOutput = & git -C $ModuleDirectory log --pretty=format:"%h %s" "$OldHash..$NewHash" 2>$null
    if (-not $logOutput) {
        return $null
    }

    $classified = Classify-CommitMessages $logOutput
    return [PSCustomObject]@{
        Feature = $classified.Feature
        Bug = $classified.Bug
        BreakingChanges = $classified.BreakingChanges
        Source = "git_log"
    }
}

$oldDeps = Parse-DependencyFile -Path $OldDependenciesFile
$newDeps = Parse-DependencyFile -Path $NewDependenciesFile

$allModulePaths = @($newDeps.Keys | Sort-Object)
$changedModules = @()

foreach ($modulePath in $allModulePaths) {
    $newEntry = $newDeps[$modulePath]
    $oldEntry = if ($oldDeps.ContainsKey($modulePath)) { $oldDeps[$modulePath] } else { $null }

    if (-not $oldEntry) {
        $changedModules += $modulePath
        continue
    }

    if ($oldEntry.Hash -ne $newEntry.Hash -or $oldEntry.Version -ne $newEntry.Version) {
        $changedModules += $modulePath
    }
}

$lines = @()
$lines += "# Aggregated Release Notes"
$lines += ""
$lines += "Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
$lines += "Old dependencies: $OldDependenciesFile"
$lines += "New dependencies: $NewDependenciesFile"
$lines += ""

if ($changedModules.Count -eq 0) {
    $lines += "No module changes detected between dependency snapshots."
} else {
    foreach ($modulePath in $changedModules) {
        $newEntry = $newDeps[$modulePath]
        $oldEntry = if ($oldDeps.ContainsKey($modulePath)) { $oldDeps[$modulePath] } else { $null }

        $oldVersion = if ($oldEntry) { $oldEntry.Version } else { "none" }
        $oldHash = if ($oldEntry) { $oldEntry.Hash } else { "none" }
        $newVersion = $newEntry.Version
        $newHash = $newEntry.Hash

        $moduleDirectory = Join-Path (Get-Location) $modulePath
        $allNotes = Get-ParsedReleaseNotes -ModuleDirectory $moduleDirectory
        $delta = Get-ReleaseNoteDelta -AllNotes $allNotes -OldVersion $oldVersion -NewVersion $newVersion

        if (-not $delta -and $oldEntry) {
            $delta = Get-CommitFallback -ModuleDirectory $moduleDirectory -OldHash $oldHash -NewHash $newHash
        }

        $lines += "## $modulePath"
        $lines += "From version: $oldVersion ($oldHash)"
        $lines += "To version: $newVersion ($newHash)"
        $lines += ""

        $source = if ($delta) { $delta.Source } else { "none" }
        $lines += "Source: $source"
        $lines += ""

        $featureEntries = if ($delta -and $delta.Feature.Count -gt 0) { $delta.Feature } else { @("none") }
        $bugEntries = if ($delta -and $delta.Bug.Count -gt 0) { $delta.Bug } else { @("none") }
        $breakingEntries = if ($delta -and $delta.BreakingChanges.Count -gt 0) { $delta.BreakingChanges } else { @("none") }

        $lines += "### Feature"
        foreach ($entry in $featureEntries) { $lines += "- $entry" }
        $lines += ""

        $lines += "### Bug"
        foreach ($entry in $bugEntries) { $lines += "- $entry" }
        $lines += ""

        $lines += "### Breaking Changes"
        foreach ($entry in $breakingEntries) { $lines += "- $entry" }
        $lines += ""
    }
}

$outputReleaseDir = Split-Path -Parent $OutputFileRelease
if ($outputReleaseDir -and -not (Test-Path $outputReleaseDir)) {
    New-Item -ItemType Directory -Path $outputReleaseDir -Force | Out-Null
}

$lines | Set-Content -Path $OutputFileRelease -Encoding UTF8
$lines | Set-Content -Path $OutputFileRoot -Encoding UTF8

Write-Host "Wrote aggregated release notes to '$OutputFileRelease' and '$OutputFileRoot'." -ForegroundColor Green
