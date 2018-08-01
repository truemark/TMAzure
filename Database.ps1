Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Set-TMAzureSqlServer
(
    [Parameter(Mandatory=$true)]
    [string] $Name
)
    # Validation - check that sql server doesn't exist
    $rgn = Get-TMAzureWorkSet -ResourceGroupName
    $loc = Get-TMAzureWorkSet -Location
    $cred = Get-TMAzureWorkSet -SQLAdminCredential

    if (!$rgn) {
        throw "Resource Group is not set"
    }
    if (!$loc) {
        throw "Location is not set"
    }
    if (!$cred) {
        throw "SQL Admin Credential is not set" 
    }

    $notPresent = $false
    $sqlserver = Get-AzureRmSqlServer -ResourceGroupName $rgn -Name $Name -ErrorVariable notPresent -ErrorAction SilentlyContinue
    if ($notPresent) {
        Info "Creating SQL Server $Name"
        $sqlserver = New-AzureRmSqlServer -ResourceGroupName $resourceGroupName -ServerName $Name -Location $loc -SqlAdministratorCredentials $cred -ErrorAction Stop
        Else {
            Info "SQL Server $Name already exists"
            
        }
    }
