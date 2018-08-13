Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Set-TMAzureVMConfig
(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Name,
    [Parameter(Mandatory = $true, ParameterSetName = "lnx")]
    [switch]$Linux,
    [Parameter(Mandatory = $true, ParameterSetName = "win")]
    [switch]$Windows,
    [Parameter(Mandatory = $false, ParameterSetName = "win")]
    [switch]$EnableAutoUpdate,
    [Parameter(Mandatory = $false, ParameterSetName = "win")]
    [switch]$ProvisionVMAgent,
    [Parameter(Mandatory = $false)]
    [string]$VMSize = "Standard_B1s",
    [Parameter(Mandatory = $false)]
    [string]$PublisherName,
    [Parameter(Mandatory = $false)]
    [string]$Offer,
    [Parameter(Mandatory = $false)]
    [string]$Sku,
    [Parameter(Mandatory = $false)]
    [string]$Version = "latest",
    [Parameter(Mandatory = $false)]
    [string]$StorageAccountType = [TMAzureStorageSkus]::Standard_LRS.ToString()
){   
    # Validation
    $cred = Get-TMAzureWorkSet -LocalAdminCredential
    if (!$cred) {
        throw "LocalAdminCredential not set"
    }
    if ($Name -cne $Name.ToLower()) {
        Warn "Best practice suggests VirtualMachine names should be lowercase"
    }
    if ($Name -notmatch ".*-vm[\d]+$") {
        Warn "Best practices recommend a VirtualMachine name end with '-vm<number>'"
        Warn "See https://docs.microsoft.com/en-us/azure/architecture/best-practices/naming-conventions"
    }
    if ($Name.length -gt 15) {
        Warn "Best practive recommends a VirtualMachine name be 15 characters or less"
    }
    # Make sure all dependencies are there
    $nid = Get-TMAzureWorkSet -NetworkInterfaceId
    if (!$nid -And $Create) {
        throw "NetworkInterface not set"
    }

    $vmc = New-AzureRmVMConfig -VMName $Name -VMSize $VMSize -ErrorAction Stop
    if ($PSCmdlet.ParameterSetName -eq "win") {
        if (!$PublisherName) {
            $PublisherName = "MicrosoftWindowsServer"
        }
        if (!$Offer) {
            $Offer = "WindowsServer"
        }
        if (!$Sku) {
            $Sku = "2016-Datacenter"
        }
        $vmc = Set-AzureRmVMOperatingSystem -VM $vmc -Windows `
        -ComputerName $Name -Credential $cred `
        -ProvisionVMAgent:$ProvisionVMAgent -EnableAutoUpdate:$EnableAutoUpdate `
        -ErrorAction Stop
    } else { # Linux
        if (!$PublisherName) {
            $PublisherName = "Canonical"
        }
        if (!$Offer) {
            $Offer = "UbuntuServer"
        }
        if (!$Sku) {
            $Sku = "18.04-LTS"
        }
        $vmc = Set-AzureRmVMOperatingSystem -VM $vmc -Linux `
        -ComputerName $Name -Credential $cred `
        -ErrorAction Stop
    }
    $vmc = Set-AzureRmVMSourceImage -VM $vmc `
    -PublisherName $PublisherName -Offer $Offer `
    -Skus $Sku -Version $Version -ErrorAction Stop
    $vmc = Add-AzureRmVMNetworkInterface -VM $vmc -Id $nid -ErrorAction Stop
    $vmc = Set-AzureRmVMBootDiagnostics -Disable -VM $vmc
    $vmc = Set-AzureRmVMOSDisk `
    -VM $vmc -StorageAccountType $StorageAccountType `
    -CreateOption FromImage -Name "$($Name)_OsDisk"
    Set-TMAzureWorkSet -VirtualMachineConfig $vmc
    return $vmc
}

function Set-TMAzureVM()
{
    $rgn = Get-TMAzureWorkSet -ResourceGroupName
    $loc = Get-TMAzureWorkSet -Location
    $vmc = Get-TMAzureWorkSet -VirtualMachineConfig
    if (!$rgn) {
        throw "ResourceGroup is not set"
    }
    if (!$loc) {
        throw "Location is not set"
    }
    if (!$vmc) {
        throw "VirtualMachineConfig is not set"
    }
    $notPresent = $false
    $vm = Get-AzureRmVM -Name $vmc.Name -ResourceGroupName $rgn -ErrorVariable notPresent -ErrorAction SilentlyContinue
    if ($notPresent) {
        Info("Creating VM $($vmc.Name)")
        New-AzureRmVM -VM $vmc -ResourceGroupName $rgn -Location $loc -ErrorAction Stop
    } else {
        Info("VirtaualMachine $($vmc.Name) already exists")
    }
    if (!$vm) {
        $vm = Get-AzureRmVM -Name $vmc.Name -ResourceGroupName $rgn -ErrorAction Stop
    }
    Set-TMAzureWorkSet -VirtualMachine $vm
    return $vm
}

function Set-TMAzureVMDataDisk(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Name,
    [Parameter(Mandatory = $true, Position = 1)]
    [Int32]$Lun,
    [Parameter(Mandatory = $false, Position = 2)]
    [Int32]$DiskSizeInGB = 32,
    [Parameter(Mandatory = $false, Position = 3)]
    [string]$StorageAccountType = [TMAzureStorageSkus]::Standard_LRS.ToString()
)
{
    $rgn = Get-TMAzureWorkSet -ResourceGroupName
    if (!$rgn) {
        throw "ResourceGroup is not set"
    }
    $vm = Get-TMAzureWorkSet -VirtualMachine
    if (!$vm) {
        throw "VirtualMachine is not set"
    }
    $notPresent = $false
    $disk = Get-AzureRmDisk -ResourceGroupName $rgn -DiskName $Name -ErrorAction SilentlyContinue -ErrorVariable notPresent
    if ($notPresent) {
        Info "Creating disk $Name"
        $disk = Add-AzureRmVMDataDisk -VM $vm -Name $Name -Lun $Lun -DiskSizeInGB $DiskSizeInGB -CreateOption Empty
        Update-AzureRmVM -ResourceGroupName $rgn -VM $vm
    } else {
        Info "Disk $Name already exists"
    }
    return $disk
}