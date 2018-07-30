Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Set-TMAzureSubnet
(
    [Parameter(Mandatory=$true)]
    [string]$Name,
    [Parameter(Mandatory=$true)]
    [string]$AddressPrefix
)
{
    # Validation
    $vnet = Get-TMAzureWorkSet -VirtualNetwork
    if (!$vnet) {
        throw "VirtualNetwork is not set"
    }
    if ($Name -cne $Name.ToLower()) {
        Warn "Best practice suggests Subnet names should be lowercase"
    }

    $notPresent = $false
    Get-AzureRmVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name $Name -ErrorAction SilentlyContinue -ErrorVariable notPresent
    if ($notPresent) {
        Info "Creating Subnet $Name in VirtualNetwork $($vnet.Name)"
        Add-AzureRmVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name $Name -AddressPrefix $AddressPrefix -ErrorAction Stop
        $VirtualNetwork | Set-AzureRmVirtualNetwork
    } else {
        Info "Subnet $Name already exists"
    }
    $subnet = Get-AzureRmVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name $Name -ErrorAction Stop
    Set-TMAzureWorkSet -Subnet $subnet
    return $subnet
}

Enum TMAzureIpAllocationMethod
{
Static
Dynamic
}

function Set-TMAzurePublicIpAddress
(
    [Parameter(Mandatory=$true)]
    [string]$Name,
    [Parameter(Mandatory=$true)]
    [string]$DomainNameLabel,
    [Parameter(Mandatory=$false)]
    [string]$AllocationMethod = [TMAzureIpAllocationMethod]::Dynamic.ToString()
)
{
    # Validation
    $rgn = Get-TMAzureWorkSet -ResourceGroupName
    $location = Get-TMAzureWorkSet -Location
    if (!$rgn) {
        throw "ResourceGroup is not set"
    }
    if (!$location) {
        throw "Location is not set"
    }
    if ($Name -cne $Name.ToLower()) {
        Warn "Best practice suggests Public IP Address names should be lowercase"
    }
    if (!$Name.EndsWith("-pip")) {
        Warn "Best practices recommend a PublicIpAddress name end with '-pip'"
        Warn "See https://docs.microsoft.com/en-us/azure/architecture/best-practices/naming-conventions"
    }
    if ($DomainNameLabel -cne $DomainNameLabel.ToLower()) {
        Warn "Best practice suggests DomainNameLabel should be lowercase"
    }

    $notPresent = $false
    $pip = Get-AzureRmPublicIpAddress -Name $Name -ResourceGroupName $rgn -ErrorAction SilentlyContinue -ErrorVariable notPresent
    if ($notPresent) {
        Info "Creating new Public IP Address $Name"
        $pip = New-AzureRmPublicIpAddress -Name $Name -ResourceGroupName $rgn `
            -Location $location -AllocationMethod $AllocationMethod `
            -DomainNameLabel $DomainNameLabel -ErrorAction Stop
    } else {
        Info "Public IP Address $Name already exists"
    }
    Set-TMAzureWorkSet -PublicIpAddress $pip
    return $pip
}

function Set-TMAzureNetworkSecurityGroup
(
    [Parameter(Mandatory=$true)]
    [string]$Name
)
{
    # Validation
    $rgn = Get-TMAzureWorkSet -ResourceGroupName
    $location = Get-TMAzureWorkSet -Location
    if (!$rgn) {
        throw "ResourceGroup not set"
    }
    if (!$location) {
        throw "Location not set"
    }
    if ($Name -cne $Name.ToLower()) {
        Warn "Best practice suggests NetworkSecurityGroup names should be lowercase"
    }
    if (!$Name.EndsWith("-nsg")) {
        Warn "Best practices recommend a NetworkSecurityGroup name end with '-nsg'"
        Warn "See https://docs.microsoft.com/en-us/azure/architecture/best-practices/naming-conventions"
    }

    $notPresent = $false
    $nsg = Get-AzureRmNetworkSecurityGroup -Name $Name -ResourceGroupName $rgn -ErrorAction SilentlyContinue -ErrorVariable notPresent
    if ($notPresent) {
        Info "Creating new Network Security Group $Name"
        $nsg = New-AzureRmNetworkSecurityGroup -Name $Name -ResourceGroupName $rgn -Location $location -ErrorAction Stop
    } else {
        Info "Network Security Group $Name already exists"
    }
    Set-TMAzureWorkSet -NetworkSecurityGroup $nsg
    return $nsg
}

function Set-TMAzureNetworkInterface
(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$Name
)
{
    # Validation
    $rgn = Get-TMAzureWorkSet -ResourceGroupName
    $loc = Get-TMAzureWorkSet -Location
    $sid = Get-TMAzureWorkSet -SubnetId
    $nid = Get-TMAzureWorkSet -NetworkSecurityGroupId
    $pid = Get-TMAzureWorkSet -PublicIpAddressId
    if (!$rgn) {
        throw "ResourceGroup not set"
    }
    if (!$loc) {
        throw "Locsation not set"
    }
    if (!$sid) {
        throw "Subnet not set"
    }
    if (!$nid) {
        throw "NetworkSecurityGroup not set"
    }
    if (!$pid) {
        throw "PublicIpAddress not"
    }
    if ($Name -cne $Name.ToLower()) {
       Warn "Best practice suggests Nework Interface names should be lowercase"
    }
    if ($Name -notmatch ".*-nic[\d]+$") {
        Warn "Best practices recommend a VirtualMachine name end with '-nic<number>'"
        Warn "See https://docs.microsoft.com/en-us/azure/architecture/best-practices/naming-conventions"
    }

    $notPresent = $false
    $nic = Get-AzureRmNetworkInterface -Name $Name -ResourceGroupName $rgn -ErrorVariable notPresent -ErrorAction SilentlyContinue
    if ($notPresent) {
        Info "Creating Network Inteface $Name"
        $nic = New-AzureRmNetworkInterface -Name $Name `
            -ResourceGroupName $rgn -Location $loc `
            -SubnetId $sid -PublicIpAddressId $pid `
            -NetworkSecurityGroupId $nid -ErrorAction Stop
    } else {
        Info "NetworkInterface $Name already exits"
    }
    Set-TMAzureWorkSet -NetworkInterface $nic
    return $nic
}