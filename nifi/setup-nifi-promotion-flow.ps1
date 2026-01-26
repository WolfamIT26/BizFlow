# Requires: Docker running, bizflow-nifi container up, internet to download MySQL driver.
# Usage: pwsh -File nifi/setup-nifi-promotion-flow.ps1
# This script will:
# 1) Download MySQL JDBC driver into NiFi container and restart NiFi
# 2) Create DBCP + JsonRecordSetWriter controller services
# 3) Create a process group with QueryDatabaseTableRecord -> SplitJson -> JoltTransformJSON -> InvokeHTTP
# 4) Start the processors

$ErrorActionPreference = 'Stop'

# ----------------------
# Configurable settings
# ----------------------
$NifiApi    = 'http://localhost:8090/nifi-api'
$MysqlHost  = 'mysql'
$MysqlPort  = 3306
$MysqlDb    = 'bizflow_db'
$MysqlUser  = 'root'
$MysqlPass  = '123456'   # change if different
$MysqlDriverVersion = '8.3.0'
$PromotionSyncUrl   = 'http://host.docker.internal:8082/api/v1/promotions/sync' # change if service is inside compose: http://promotion-service:8082/api/v1/promotions/sync

# SQL & Jolt paths (relative to repo)
$SqlPath  = Join-Path $PSScriptRoot 'sql/promotions.sql'
$JoltPath = Join-Path $PSScriptRoot 'jolt/promotion-dto.json'

# Processor canvas positions (for nicer layout)
$X = 0; $Y = 0; $dx = 400

# ----------------------
# Helper functions
# ----------------------
function Get-ClientId {
    return (Invoke-RestMethod "$NifiApi/flow/client-id").clientId
}
function Get-RootPgId {
    return (Invoke-RestMethod "$NifiApi/flow/process-groups/root").processGroupFlow.id
}
function New-Revision($clientId, $version) {
    return @{ clientId = $clientId; version = $version }
}
function Enable-ControllerService($id, $rev) {
    Invoke-RestMethod -Method Put -Uri "$NifiApi/controller-services/$id/run-status" -ContentType 'application/json' -Body (@{
        revision = $rev
        state    = 'ENABLED'
    } | ConvertTo-Json -Depth 10)
}
function Start-Processor($id) {
    $p = Invoke-RestMethod "$NifiApi/processors/$id"
    $rev = New-Revision $p.revision.clientId ($p.revision.version)
    Invoke-RestMethod -Method Put -Uri "$NifiApi/processors/$id/run-status" -ContentType 'application/json' -Body (@{
        revision = $rev
        state    = 'RUNNING'
    } | ConvertTo-Json -Depth 10)
}

# ----------------------
# Step 0: ensure MySQL driver in container
# ----------------------
$driverUrl = "https://repo1.maven.org/maven2/com/mysql/mysql-connector-j/$MysqlDriverVersion/mysql-connector-j-$MysqlDriverVersion.jar"
$tmpJar = Join-Path $env:TEMP "mysql-connector-j-$MysqlDriverVersion.jar"
Write-Host "Downloading MySQL driver $driverUrl ..."
Invoke-WebRequest -Uri $driverUrl -OutFile $tmpJar

Write-Host "Copying driver into bizflow-nifi ..."
docker cp $tmpJar bizflow-nifi:/opt/nifi/nifi-current/lib/ | Out-Null

Write-Host "Restarting bizflow-nifi to pick up driver ..."
docker restart bizflow-nifi | Out-Null
Start-Sleep -Seconds 20

# ----------------------
# Step 1: base IDs
# ----------------------
$clientId = Get-ClientId
$rootPgId = Get-RootPgId

# ----------------------
# Step 2: controller services
# ----------------------
$dbcPayload = @{
    revision  = New-Revision $clientId 0
    component = @{
        type = 'org.apache.nifi.dbcp.DBCPConnectionPool'
        name = 'Bizflow DBCP'
        properties = @{
            'Database Connection URL'      = "jdbc:mysql://${MysqlHost}:${MysqlPort}/${MysqlDb}?useSSL=false&serverTimezone=Asia/Ho_Chi_Minh&allowPublicKeyRetrieval=true&useUnicode=true&characterEncoding=utf8&connectionCollation=utf8mb4_unicode_ci"
            'Database Driver Class Name'   = 'com.mysql.cj.jdbc.Driver'
            'Database User'                = $MysqlUser
            'Password'                     = $MysqlPass
        }
    }
}
$dbc = Invoke-RestMethod -Method Post -Uri "$NifiApi/process-groups/$rootPgId/controller-services" -ContentType 'application/json' -Body ($dbcPayload | ConvertTo-Json -Depth 10)
$dbcRev = New-Revision $clientId $dbc.revision.version
Enable-ControllerService $dbc.id $dbcRev | Out-Null

$writerPayload = @{
    revision  = New-Revision $clientId 0
    component = @{
        type = 'org.apache.nifi.json.JsonRecordSetWriter'
        name = 'Bizflow JSON Writer'
        properties = @{
            'Schema Access Strategy' = 'Infer Schema'
            'Pretty Print JSON'      = 'false'
        }
    }
}
$writer = Invoke-RestMethod -Method Post -Uri "$NifiApi/process-groups/$rootPgId/controller-services" -ContentType 'application/json' -Body ($writerPayload | ConvertTo-Json -Depth 10)
$writerRev = New-Revision $clientId $writer.revision.version
Enable-ControllerService $writer.id $writerRev | Out-Null

# ----------------------
# Step 3: create process group
# ----------------------
$pgPayload = @{
    revision  = New-Revision $clientId 0
    component = @{ name = 'Promotion Sync' }
    position  = @{ x = 0; y = 0 }
}
$pg = Invoke-RestMethod -Method Post -Uri "$NifiApi/process-groups/$rootPgId/process-groups" -ContentType 'application/json' -Body ($pgPayload | ConvertTo-Json -Depth 10)
$pgId = $pg.id

# Helper to create processor
function New-Processor($type, $name, $x, $y) {
    $payload = @{
        revision  = New-Revision $clientId 0
        component = @{
            type = $type
            name = $name
            position = @{ x = $x; y = $y }
        }
    }
    return Invoke-RestMethod -Method Post -Uri "$NifiApi/process-groups/$pgId/processors" -ContentType 'application/json' -Body ($payload | ConvertTo-Json -Depth 10)
}

# ----------------------
# Step 4: create processors
# ----------------------
$sqlText  = Get-Content -Raw $SqlPath
$joltSpec = Get-Content -Raw $JoltPath

$q = New-Processor 'org.apache.nifi.processors.standard.QueryDatabaseTableRecord' 'Query Promotions' $X $Y; $X += $dx
$s = New-Processor 'org.apache.nifi.processors.standard.SplitJson'               'Split JSON'        $X $Y; $X += $dx
$j = New-Processor 'org.apache.nifi.processors.standard.JoltTransformJSON'       'Jolt Transform'    $X $Y; $X += $dx
$h = New-Processor 'org.apache.nifi.processors.standard.InvokeHTTP'              'Post Promotion'    $X $Y

# Update processor configs
function Update-Processor($proc, $config) {
    $payload = @{
        revision  = New-Revision $clientId $proc.revision.version
        component = @{
            id = $proc.id
            config = $config
        }
    }
    Invoke-RestMethod -Method Put -Uri "$NifiApi/processors/$($proc.id)" -ContentType 'application/json' -Body ($payload | ConvertTo-Json -Depth 10)
}

# QueryDatabaseTableRecord config
$cfgQ = @{
    properties = @{
        'Database Connection Pooling Service' = $dbc.id
        'db-fetch-size'                       = '0'
        'db-table-name'                       = ''
        'db-sql-select-query'                 = $sqlText
        'record-writer'                       = $writer.id
    }
    autoTerminatedRelationships = @('failure')
    schedulingPeriod = '60 sec'
}
Update-Processor $q $cfgQ | Out-Null

# SplitJson
$cfgS = @{
    properties = @{ 'JsonPath Expression' = '$.records[*]' }
    autoTerminatedRelationships = @('failure','original')
}
Update-Processor $s $cfgS | Out-Null

# Jolt
$cfgJ = @{
    properties = @{
        'Jolt Specification'         = $joltSpec
        'Jolt Transformation DSL'    = 'jolt-spec'
        'Custom Classpath'           = ''
        'Pretty Print'               = 'false'
    }
    autoTerminatedRelationships = @('failure')
}
Update-Processor $j $cfgJ | Out-Null

# InvokeHTTP
$cfgH = @{
    properties = @{
        'Remote URL'        = $PromotionSyncUrl
        'HTTP Method'       = 'POST'
        'Content-Type'      = 'application/json'
        'Send Message Body' = 'true'
        'Follow Redirects'  = 'false'
    }
    autoTerminatedRelationships = @('failure','retry','no retry','response','success')
}
Update-Processor $h $cfgH | Out-Null

# ----------------------
# Step 5: connect processors
# ----------------------
function New-Connection($name, $sourceId, $sourceType, $rel, $destId, $destType) {
    $payload = @{
        revision  = New-Revision $clientId 0
        component = @{
            name = $name
            source = @{ id = $sourceId; type = $sourceType }
            destination = @{ id = $destId; type = $destType }
            selectedRelationships = @($rel)
        }
    }
    Invoke-RestMethod -Method Post -Uri "$NifiApi/process-groups/$pgId/connections" -ContentType 'application/json' -Body ($payload | ConvertTo-Json -Depth 10)
}

New-Connection 'q->split'   $q.id 'PROCESSOR' 'success' $s.id 'PROCESSOR' | Out-Null
New-Connection 'split->jolt' $s.id 'PROCESSOR' 'split'   $j.id 'PROCESSOR' | Out-Null
New-Connection 'jolt->http'  $j.id 'PROCESSOR' 'success' $h.id 'PROCESSOR' | Out-Null

# ----------------------
# Step 6: start processors
# ----------------------
Start-Processor $q
Start-Processor $s
Start-Processor $j
Start-Processor $h

Write-Host "Done. Open http://localhost:8090/nifi to verify flow and provenance events." -ForegroundColor Green
