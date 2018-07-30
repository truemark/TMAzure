Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Set-TMAzureResourceGroup
(
    [Parameter(Mandatory=$true)]
    [string]$Name
)
{
    # Validation
    $location = Get-TMAzureWorkSet -Location
    if (!$location) {
        throw "Location is not set"
    }
    if (!$Name.endsWith("-rg")) {
        Warn "Best practices recommend a ResourceGroup name end with '-rg'"
        Warn "See https://docs.microsoft.com/en-us/azure/architecture/best-practices/naming-conventions"
    }
    if ($Name -cne $Name.ToLower()) {
        Warn "Best practice suggests ResourceGroup names should be lowercase"
    }

    $notPresent = $false
    $rg = Get-AzureRmResourceGroup -Name $Name -ErrorVariable notPresent -ErrorAction SilentlyContinue
    if ($notPresent) {
        Info "Creating ResourceGroup $Name in $location"
        $rg = New-AzureRmResourceGroup -Name "$Name" -Location $location -ErrorAction Stop
    } else {
        Info "Resource Group $Name already exists"
    }
    Set-TMAzureWorkSet -ResourceGroup $rg
    return $rg
}