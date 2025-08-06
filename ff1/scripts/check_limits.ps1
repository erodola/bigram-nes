<#
    This script parses a linker map file to calculate and report
    the used and remaining space in BANK_0E. It extracts the sizes
    of the main bank, inference code, and model parameters, then
    prints a summary including available free space.
#>

$mapFile = "build\map.txt"
$maxSize = 0x4000
$warnThreshold = 256
$lines = Get-Content $mapFile
$freeBytes = $maxSize

function Get-BankSize {
    param (
        [string]$bankName
    )
    foreach ($line in $lines) {
        if ($line -match "$bankName\s+.*Size\s*=\s*([0-9A-Fa-f]+)") {
            return [Convert]::ToInt32($matches[1], 16)
        }
    }
    return 0
}

$mainBank = "BANK_0E"
$inferBank = "BANK_0E_INFER"
$paramsBank = "BANK_0E_T"

$mainSize = Get-BankSize $mainBank
$freeBytes -= $mainSize
Write-Host "$mainBank size:`t$mainSize bytes" -ForegroundColor Yellow

$inferSize = Get-BankSize $inferBank
$freeBytes -= $inferSize
Write-Host "Inference code:`t$inferSize bytes" -ForegroundColor Yellow

$paramsSize = Get-BankSize $paramsBank
$freeBytes -= $paramsSize
Write-Host "Model params:`t$paramsSize bytes" -ForegroundColor Yellow

Write-Host ""
Write-Host "Free space:`t$freeBytes bytes" -ForegroundColor Green
