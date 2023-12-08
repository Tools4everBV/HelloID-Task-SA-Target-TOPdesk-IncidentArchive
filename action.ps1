# TOPdesk-Task-SA-Target-TOPdesk-IncidentArchive
###########################################################
# Form mapping
$formObject = @{
    id = $form.archivingReasonId
}
$incidentId = $form.id

try {
    Write-Information "Executing TOPdesk action: [ArchiveIncident] for: [$($incidentId)]"
    Write-Verbose "Creating authorization headers"
    # Create authorization headers with TOPdesk API key
    $pair = "${topdeskApiUsername}:${topdeskApiSecret}"
    $bytes = [System.Text.Encoding]::ASCII.GetBytes($pair)
    $base64 = [System.Convert]::ToBase64String($bytes)
    $key = "Basic $base64"
    $headers = @{
        "authorization" = $Key
        "Accept"        = "application/json"
    }

    Write-Verbose "Archiving TOPdesk Incident: [$($incidentId)]"
    $splatArchiveIncidentParams = @{
        Uri         = "$($topdeskBaseUrl)/tas/api/incidents/id/$($incidentId)/archive"
        Method      = "PATCH"
        Body        = ([System.Text.Encoding]::UTF8.GetBytes(($formObject | ConvertTo-Json -Depth 10)))
        Verbose     = $false
        Headers     = $headers
        ContentType = "application/json; charset=utf-8"
    }
    $response = Invoke-RestMethod @splatArchiveIncidentParams

    $auditLog = @{
        Action            = "UpdateResource"
        System            = "TOPdesk"
        TargetIdentifier  = [String]$response.id
        TargetDisplayName = [String]$response.number
        Message           = "TOPdesk action: [ArchiveIncident] for: [$($incidentId)] executed successfully"
        IsError           = $false
    }
    Write-Information -Tags "Audit" -MessageData $auditLog

    Write-Information "TOPdesk action: [ArchiveIncident] for: [$($incidentId)] executed successfully"
}
catch {
    $ex = $_
    $auditLog = @{
        Action            = "UpdateResource"
        System            = "TOPdesk"
        TargetIdentifier  = [String]$incidentId
        TargetDisplayName = [String]$incidentDisplayName
        Message           = "Could not execute TOPdesk action: [ArchiveIncident] for: [$($incidentId)], error: $($ex.Exception.Message)"
        IsError           = $true
    }
    if ($($ex.Exception.GetType().FullName -eq "Microsoft.PowerShell.Commands.HttpResponseException")) {
        $auditLog.Message = "Could not execute TOPdesk action: [ArchiveIncident] for: [$($incidentId)]"
        Write-Error "Could not execute TOPdesk action: [ArchiveIncident] for: [$($incidentId)], error: $($ex.ErrorDetails)"
    }
    Write-Information -Tags "Audit" -MessageData $auditLog
    Write-Error "Could not execute TOPdesk action: [ArchiveIncident] for: [$($incidentId)], error: $($ex.Exception.Message)"
}
###########################################################