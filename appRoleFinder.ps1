# Requires -Modules Microsoft.Graph
# Install-Module Microsoft.Graph -Scope CurrentUser if not installed

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true, ValueFromRemainingArguments = $true)]
    [string[]]$AppRoleIds
)

function Connect-GraphAPI {
    Connect-Graph -Scopes 'User.Read', 'Application.Read.All' -NoWelcome # You must be part of the Microsoft Graph PowerShell `Users & groups` Azure Application
}

function Get-AppRoleAssignments {
    param (
        [string]$servicePrincipalId
    )

    $apiUrl = "https://graph.microsoft.com/v1.0/servicePrincipals/$servicePrincipalId/appRoleAssignedTo"
    $res = Invoke-GraphRequest -Uri $apiUrl -Method Get
    return $res
}

function Find-AppRoleAssignments {
    param (
        [object]$res,
        [string[]]$appRoleIds
    )

    $matchedEntries = New-Object System.Collections.Generic.List[Object]

    do {
        $res.value | ForEach-Object {
            if ($appRoleIds -contains $_.appRoleId) {
                $matchedEntries.Add([PSCustomObject]@{
                    ApplicationName = $_.principalDisplayName
                    AppRoleId = $_.appRoleId
                })
            }
        }
        if ($res.'@odata.nextLink') {
            $res = Invoke-GraphRequest -Uri $res.'@odata.nextLink' -Method Get
        }
    } while ($res.'@odata.nextLink')

    return $matchedEntries
}

try {
    Connect-GraphAPI

    $servicePrincipalId = "[MS-Graph-Aggregator-ObjectID]" # Unique to your tenant
    $res = Get-AppRoleAssignments -servicePrincipalId $servicePrincipalId

    $matchedEntries = Find-AppRoleAssignments -res $res -appRoleIds $AppRoleIds

    # Display all entries
    $matchedEntries | Format-Table -AutoSize
} catch {
    Write-Host "Error: $_"
    Write-Host "Ensure you have the required Microsoft Graph permissions and the Microsoft.Graph PowerShell module is installed."
    Write-Host 'Usage: .\appRoleFinder.ps1 "<AppRoleId1>" "<AppRoleId2>" ...'
}
