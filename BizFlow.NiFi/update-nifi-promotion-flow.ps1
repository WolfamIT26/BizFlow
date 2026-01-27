# Update SQL for Query Promotions and start promotion flow processors
# Usage: powershell -NoLogo -File nifi/update-nifi-promotion-flow.ps1

$ErrorActionPreference = 'Stop'
$base = 'http://localhost:8090/nifi-api'
$rootId = 'e6edd706-019b-1000-e4d5-d2a47e113373'
$names = @('Query Promotions','Split JSON','Jolt Transform','Post Promotion')
$sqlPath = Join-Path $PSScriptRoot 'sql/promotions.sql'
$sql = Get-Content -Raw $sqlPath

# Locate the top-level Promotion Sync process group under root
$search = Invoke-RestMethod "$base/flow/search-results?q=Promotion%20Sync"
$pg = $search.searchResultsDTO.processGroupResults | Where-Object { $_.groupId -eq $rootId } | Select-Object -First 1
if (-not $pg) { throw 'Promotion Sync process group not found under root' }
$pgId = $pg.id

$flow = Invoke-RestMethod "$base/flow/process-groups/$pgId"
$procs = $flow.processGroupFlow.flow.processors
foreach ($n in $names) {
    if (-not ($procs | Where-Object { $_.component.name -eq $n })) {
        throw "Processor $n not found in process group $pgId"
    }
}

# Update SQL on Query Promotions
$qp = $procs | Where-Object { $_.component.name -eq 'Query Promotions' }
$qpId = $qp.id
$qpFull = Invoke-RestMethod "$base/processors/$qpId"
$rev = @{ clientId = $qpFull.revision.clientId; version = $qpFull.revision.version }
$body = @{ revision = $rev; component = @{ id = $qpId; config = @{ properties = @{ 'db-sql-select-query' = $sql } } } } | ConvertTo-Json -Depth 20
Invoke-RestMethod -Method Put -Uri "$base/processors/$qpId" -ContentType 'application/json' -Body $body | Out-Null
Write-Host 'Updated SQL for Query Promotions.'

function Start-Processor($id) {
    $p = Invoke-RestMethod "$base/processors/$id"
    $rev = @{ clientId = $p.revision.clientId; version = $p.revision.version }
    $body = @{ revision = $rev; state = 'RUNNING' } | ConvertTo-Json
    Invoke-RestMethod -Method Put -Uri "$base/processors/$id/run-status" -ContentType 'application/json' -Body $body | Out-Null
}

foreach ($n in $names) {
    $pid = ($procs | Where-Object { $_.component.name -eq $n }).id
    Start-Processor $pid
    Write-Host "Started $n"
}

Write-Host 'Done.' -ForegroundColor Green
