#this script is to get aid from the running computer and then collect the maintenance token against it
Write-Host "Gathering Device ID"

$HostName= hostname
Write-Host 'hostname: $HostName'

#
$deviceID = [System.BitConverter]::ToString( ((Get-ItemProperty 'HKLM:\System\CurrentControlSet\services\CSAgent\Sim' -Name AG).AG)).ToLower() -replace '-',''

Write-Host "Device ID is $deviceID"

$AuthUri = "https://api.crowdstrike.com/oauth2/token"
$clientID = "<modify>"
$clientSecret = "<modify>"

$body = @{
    "client_id" = $clientID
    "client_secret" = $clientSecret
    "scope" = "oauth2:write"
    "grant_type" = "client_credentials"
}

$response = Invoke-RestMethod -Uri $AuthUri -Method POST -Body $body

$accessToken = $response.access_token
#Write-Host "Bearer Token: $accessToken"
$RevealUninstallTokenUri = "https://api.crowdstrike.com/policy/combined/reveal-uninstall-token/v1"
$token = "Bearer $accessToken"

$headers = @{
    "accept" = "application/json"
    "authorization" = $token
    "Content-Type" = "application/json"
}

# Prompt for the audit message
$auditMessage = Read-Host -Prompt "Enter the audit message"

    $body = @{
        "audit_message" = $auditMessage
        "device_id" = $deviceID
    } | ConvertTo-Json

    $response = Invoke-RestMethod -Uri $RevealUninstallTokenUri -Method POST -Headers $headers -Body $body

    # Optional: Display the response
    $response | ConvertTo-Json
