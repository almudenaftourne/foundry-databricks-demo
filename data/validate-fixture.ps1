$ErrorActionPreference = 'Stop'

function Assert-Equal {
    param($Actual, $Expected, [string]$Label)
    if ($Actual -ne $Expected) {
        throw "${Label}: expected '$Expected', got '$Actual'."
    }
}

function Test-IsoDate {
    param([string]$Value)
    $parsed = [datetime]::MinValue
    return [datetime]::TryParseExact(
        $Value, 'yyyy-MM-dd', [cultureinfo]::InvariantCulture,
        [System.Globalization.DateTimeStyles]::None, [ref]$parsed
    )
}

function Assert-Columns {
    param([object[]]$Rows, [string[]]$Columns, [string]$Label)
    Assert-Equal (($Rows[0].PSObject.Properties.Name) -join ',') ($Columns -join ',') "$Label columns"
}

$teams = @(Import-Csv -LiteralPath (Join-Path $PSScriptRoot 'raw\teams.csv'))
$projects = @(Import-Csv -LiteralPath (Join-Path $PSScriptRoot 'raw\projects.csv'))
$raw = @(Import-Csv -LiteralPath (Join-Path $PSScriptRoot 'raw\work_items.csv'))
$asOf = [datetime]::ParseExact('2026-10-23', 'yyyy-MM-dd', [cultureinfo]::InvariantCulture)

Assert-Equal $teams.Count 4 'Team count'
Assert-Equal $projects.Count 8 'Project count'
Assert-Equal $raw.Count 44 'Raw work-item count'
Assert-Columns $teams @('team_id','team_name','region','manager_handle','hourly_rate_eur') 'Teams'
Assert-Columns $projects @('project_id','team_id','project_name','owner_handle','priority','status','start_date','target_date','budget_eur','currency') 'Projects'
Assert-Columns $raw @('work_item_id','project_id','title','category','assignee_handle','priority','status','created_date','due_date','completed_date','estimated_hours','actual_hours','blocked_reason','updated_at') 'Work items'
Assert-Equal @($teams.team_id | Select-Object -Unique).Count 4 'Unique team IDs'
Assert-Equal @($projects.project_id | Select-Object -Unique).Count 8 'Unique project IDs'

$teamById = @{}
foreach ($team in $teams) {
    $teamById[$team.team_id] = $team
    if ([decimal]$team.hourly_rate_eur -le 0) { throw "Invalid rate: $($team.team_id)" }
}
$projectById = @{}
foreach ($project in $projects) {
    if (-not $teamById.ContainsKey($project.team_id)) { throw "Unknown team: $($project.project_id)" }
    if (-not (Test-IsoDate $project.start_date) -or -not (Test-IsoDate $project.target_date)) {
        throw "Invalid project dates: $($project.project_id)"
    }
    Assert-Equal $project.currency 'EUR' 'Project currency'
    if ([decimal]$project.budget_eur -le 0) { throw "Invalid budget: $($project.project_id)" }
    $projectById[$project.project_id] = $project
}

# Parse timestamps before comparing them so the deduplication rule is explicit.
$latestById = @{}
$duplicates = 0
foreach ($row in $raw) {
    $timestamp = [datetimeoffset]::ParseExact(
        $row.updated_at, "yyyy-MM-dd'T'HH:mm:ss'Z'",
        [cultureinfo]::InvariantCulture, [System.Globalization.DateTimeStyles]::AssumeUniversal
    )
    if ($latestById.ContainsKey($row.work_item_id)) {
        $duplicates++
        $previous = $latestById[$row.work_item_id]
        if ($timestamp -eq $previous.Timestamp) { throw "Ambiguous duplicate timestamp: $($row.work_item_id)" }
        if ($timestamp -lt $previous.Timestamp) { continue }
    }
    $latestById[$row.work_item_id] = @{ Row = $row; Timestamp = $timestamp }
}
Assert-Equal $duplicates 1 'Duplicate rows removed'

$clean = @()
$rejected = @()
foreach ($entry in $latestById.Values) {
    $row = $entry.Row
    $reasons = @()
    if ($row.status -notin @('todo','in_progress','blocked','done','cancelled')) { $reasons += 'invalid_status' }
    if (-not $projectById.ContainsKey($row.project_id)) { $reasons += 'unknown_project' }
    if (-not (Test-IsoDate $row.due_date)) { $reasons += 'invalid_due_date' }
    if ($reasons.Count -gt 0) {
        $rejected += [pscustomobject]@{ Id = $row.work_item_id; Reasons = $reasons -join ';' }
        continue
    }
    if (-not (Test-IsoDate $row.created_date)) { throw "Invalid creation date: $($row.work_item_id)" }
    if ($row.status -eq 'done' -and -not (Test-IsoDate $row.completed_date)) {
        throw "Missing valid completion date: $($row.work_item_id)"
    }
    if ($row.status -ne 'done' -and $row.completed_date) { throw "Unexpected completion date: $($row.work_item_id)" }
    if ($row.status -eq 'blocked' -and -not $row.blocked_reason) { throw "Missing blocker: $($row.work_item_id)" }
    if ($row.status -ne 'blocked' -and $row.blocked_reason) { throw "Unexpected blocker: $($row.work_item_id)" }
    if ([decimal]$row.actual_hours -lt 0 -or [decimal]$row.estimated_hours -lt 0) {
        throw "Negative effort: $($row.work_item_id)"
    }
    $clean += $row
}
Assert-Equal $clean.Count 40 'Clean work-item count'
Assert-Equal $rejected.Count 3 'Quarantined row count'
Assert-Equal (($rejected | Sort-Object Id | ForEach-Object { "$($_.Id):$($_.Reasons)" }) -join ',') 'WI041:invalid_status,WI042:unknown_project,WI043:invalid_due_date' 'Quarantine reasons'
Assert-Equal ($clean | Where-Object work_item_id -eq 'WI001').actual_hours 40 'Latest WI001 effort'

$open = @($clean | Where-Object { $_.status -in @('todo','in_progress','blocked') })
$overdue = @($open | Where-Object { [datetime]::ParseExact($_.due_date, 'yyyy-MM-dd', [cultureinfo]::InvariantCulture) -lt $asOf })
$blocked = @($clean | Where-Object status -eq 'blocked')
$unassigned = @($open | Where-Object { -not $_.assignee_handle })
Assert-Equal $open.Count 21 'Open work items'
Assert-Equal $overdue.Count 9 'Overdue open work items'
Assert-Equal $blocked.Count 7 'Blocked work items'
Assert-Equal $unassigned.Count 7 'Unassigned open work items'
Assert-Equal @($clean | Where-Object status -eq 'done').Count 17 'Done work items'
Assert-Equal @($clean | Where-Object status -eq 'cancelled').Count 2 'Cancelled work items'
Assert-Equal @($open | Where-Object { $_.due_date -eq '2026-10-23' }).Count 2 'Open items due on reference date'
Assert-Equal @($overdue | Where-Object status -eq 'blocked').Count 5 'Overdue blocked work items'
Assert-Equal @($clean | Where-Object {
    $_.status -eq 'done' -and
    [datetime]::ParseExact($_.completed_date, 'yyyy-MM-dd', [cultureinfo]::InvariantCulture) -gt
    [datetime]::ParseExact($_.due_date, 'yyyy-MM-dd', [cultureinfo]::InvariantCulture)
}).Count 2 'Late completions'

$expectedHours = @(100,30,82,40,72,48,20,25)
$expectedCosts = @(8000,2400,8200,4000,6480,4320,1400,1750)
$summary = @()
for ($i = 0; $i -lt $projects.Count; $i++) {
    $project = $projects[$i]
    $hours = [decimal](($clean | Where-Object project_id -eq $project.project_id | Measure-Object actual_hours -Sum).Sum)
    $cost = $hours * [decimal]$teamById[$project.team_id].hourly_rate_eur
    Assert-Equal $hours $expectedHours[$i] "$($project.project_id) hours"
    Assert-Equal $cost $expectedCosts[$i] "$($project.project_id) effort cost"
    $summary += [pscustomobject]@{
        Project = $project.project_id
        Name = $project.project_name
        Open = @($open | Where-Object project_id -eq $project.project_id).Count
        Overdue = @($overdue | Where-Object project_id -eq $project.project_id).Count
        Hours = $hours
        EffortCostEUR = $cost
        BudgetEUR = [decimal]$project.budget_eur
    }
}
Assert-Equal @($summary | Where-Object { $_.EffortCostEUR -gt $_.BudgetEUR }).Count 3 'Over-budget projects'
Assert-Equal (($summary | Measure-Object Hours -Sum).Sum) 417 'Total actual hours'
Assert-Equal (($summary | Measure-Object EffortCostEUR -Sum).Sum) 36550 'Total effort cost'
Assert-Equal (($summary | Measure-Object BudgetEUR -Sum).Sum) 43500 'Total budget'

$expectedTeamHours = @(130,122,120,45)
$expectedTeamCosts = @(10400,12200,10800,3150)
$expectedTeamBudgets = @(10000,13000,16000,4500)
$expectedTeamOpen = @(6,6,6,3)
$expectedTeamOverdue = @(3,3,2,1)
for ($i = 0; $i -lt $teams.Count; $i++) {
    $team = $teams[$i]
    $projectIds = @($projects | Where-Object team_id -eq $team.team_id | ForEach-Object { $_.project_id })
    $teamProjects = @($summary | Where-Object { $_.Project -in $projectIds })
    Assert-Equal $teamProjects.Count 2 "$($team.team_id) project count"
    Assert-Equal (($teamProjects | Measure-Object Hours -Sum).Sum) $expectedTeamHours[$i] "$($team.team_id) hours"
    Assert-Equal (($teamProjects | Measure-Object EffortCostEUR -Sum).Sum) $expectedTeamCosts[$i] "$($team.team_id) effort cost"
    Assert-Equal (($teamProjects | Measure-Object BudgetEUR -Sum).Sum) $expectedTeamBudgets[$i] "$($team.team_id) budget"
    Assert-Equal (($teamProjects | Measure-Object Open -Sum).Sum) $expectedTeamOpen[$i] "$($team.team_id) open items"
    Assert-Equal (($teamProjects | Measure-Object Overdue -Sum).Sum) $expectedTeamOverdue[$i] "$($team.team_id) overdue items"
}

Write-Output 'PASS: fixture schemas, counts, relationships, cleaning outcomes, and benchmark totals.'
Write-Output 'Reference date: 2026-10-23. Open excludes done/cancelled. Due today is not overdue.'
$summary | Format-Table -AutoSize
Write-Output 'Quarantine:'
$rejected | Sort-Object Id | Format-Table -AutoSize
