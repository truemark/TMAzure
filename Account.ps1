Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Log into Azure with a specific tenant and subscription.
function Invoke-TMAzureLogin
(
    [Parameter(Mandatory=$false)]
    [string]$Path
)
{
    $tid = Get-TMAzureWorkSet -TenantId
    if (!$tid) {
        throw "TenantId not set"
    }

    if ($Path -And [System.IO.File]::Exists($Path)) {
        Import-AzureRmContext -Path $Path
    }

    $needLogin = $true
    try {
        $ctx = Get-AzureRmContext
        if ($ctx) {
            $needLogin = ([string]::IsNullOrEmpty($ctx.Account))
            if ($ctx.Tenant -And $ctx.Tenant.Id -ne $tid) {
                Info "Disconnecting from Azure Tenant $($ctx.Tenant.Id)"
                Disconnect-AzureRmAccount -ErrorAction Stop
                $needLogin = $true
            }
        }
    } catch {
        Write-Host $_.Exception
        if ($_ -like "*Login-AzureRmAccount to login*") {
            $needLogin = $true
        }
    }
    if ($needLogin) {
        Info "Logging into Azure Tenant $tid"
        Login-AzureRmAccount -TenantId $tid -ErrorAction Stop
    } else {
        Info "Already logged into Azure Tenant $tid"
    }
    Set-TMAzureSubscription

    if ($Path) {
        Save-AzureRmContext -Path $Path -Force
    }
}

# Sets the Azure subscription on the current context
function Set-TMAzureSubscription()
{
    $sid = Get-TMAzureWorkSet -SubscriptionId
    if (!$sid) {
        throw "SubsriptionId not set"
    }
    Info "Setting subscription to $sid"
    $y = Get-AzureRmContext | Select subscription |ft -HideTableHeaders | out-string
    if ($y -notmatch $sid) {
        Set-AzureRmContext -SubscriptionId $sid -ErrorAction Stop
    }
}