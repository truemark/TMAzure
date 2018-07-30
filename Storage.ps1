Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Enum TMAzureStorageSkus
{
    Standard_LRS
    Standard_ZRS
    Standard_GRS
    Standard_RAGRS
    Premium_LRS
}

Enum TMAzureStorageKind
{
    Storage
    BlogStorage
}

function Set-TMAzureStorageAccount
(
    [Parameter(Mandatory=$true, Position=2)]
    [string]$Name,
    [Parameter(Mandatory=$false, Position=3)]
    [string]$SkuName = [TMAzureStorageSkus]::Premium_LRS.ToString(),
    [Parameter(Mandatory=$false, Position=4)]
    [string]$Kind = [TMAzureStorageKind]::Storage.ToString()
)
{
    # Validation
    $rgn = Get-TMAzureWorkSet -ResourceGroupName
    $loc = Get-TMAzureWorkSet -Location
    if (!$rgn) {
        throw "ResourceGroup is not set"
    }
    if (!$loc) {
        throw "Location is not set"
    }
    if ($Name -cne $Name.ToLower()) {
        Warn "Best practice suggests Storage Account names should be lowercase"
    }

    $notPresent = $false
    $sto = Get-AzureRmStorageAccount `
        -ResourceGroupName $rgn -Name $Name `
        -ErrorAction SilentlyContinue -ErrorVariable notPresent
    if ($notPresent) {
        Info "Creating new Storage Account $Name in Resource Group $rgn"
        $sto = New-AzureRmStorageAccount -ResourceGroupName $rgn -Name $Name `
        -SkuName $SkuName -Location $loc -Kind $Kind -ErrorAction Stop
    } else {
        Info "Storage Account $Name already exists"
    }
    Set-TMAzureWorkSet -StorageAccount $sto
    return $sto
}