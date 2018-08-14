Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$Script:WorkSet = @{}

function Set-TMAzureWorkSet (
    [Parameter(Mandatory = $false)]
    [string]$SubscriptionId,
    [Parameter(Mandatory = $false)]
    [string]$TenantId,
    [Parameter(Mandatory = $false)]
    [string]$Location,
    [Parameter(Mandatory = $false)]
    [object]$ResourceGroup,
    [Parameter(Mandatory = $false)]
    [string]$ResourceGroupName,
    [Parameter(Mandatory = $false)]
    [object]$VirtualNetwork,
    [Parameter(Mandatory = $false)]
    [string]$VirtualNetworkName,
    [Parameter(Mandatory = $false)]
    [object]$Subnet,
    [Parameter(Mandatory = $false)]
    [string]$SubnetName,
    [Parameter(Mandatory = $false)]
    [object]$StorageAccount,
    [Parameter(Mandatory = $false)]
    [string]$StorageAccountName,
    [Parameter(Mandatory = $false)]
    [object]$PublicIpAddress,
    [Parameter(Mandatory = $false)]
    [string]$PublicIpAddressName,
    [Parameter(Mandatory = $false)]
    [object]$NetworkSecurityGroup,
    [Parameter(Mandatory = $false)]
    [string]$NetworkSecurityGroupName,
    [Parameter(Mandatory = $false)]
    [object]$NetworkInterface,
    [Parameter(Mandatory = $false)]
    [object]$NetworkInterfaceName,
    [Parameter(Mandatory = $false)]
    [object]$LocalAdminCredential,
    [Parameter(Mandatory = $false)]
    [object]$VirtualMachineConfig,
    [Parameter(Mandatory = $false)]    
    [object]$VirtualMachine,
    [Parameter(Mandatory = $false)]    
    [object]$SqlServer,
    [Parameter(Mandatory = $false)]    
    [object]$SqlServerName,
    [Parameter(Mandatory = $false)]
    [object]$SqlAdminCredential,
    [Parameter(Mandatory = $false)]
    [object]$SqlElasticPool,
    [Parameter(Mandatory = $false)]
    [object]$SqlElasticPoolName

){
    foreach ($name in $PSCmdlet.MyInvocation.BoundParameters.Keys) {
        switch ($name) {
            "ResourceGroupName" {
                $Script:WorkSet["ResourceGroup"] = Get-AzureRmResourceGroup -Name $ResourceGroupName -ErrorAction Stop
            }
            "VirtualNetworkName" {
                $rg = $Script:WorkSet["ResourceGroup"]
                if (!$rg) {
                    Throw "ResourceGroup must be set before a VirtualNetworkName can be used"
                }
                $Script:WorkSet["VirtualNetwork"] = Get-AzureRmVirtualNetwork -Name $VirtualNetworkName -ResourceGroupName $rg.ResourceGroupName -ErrorAction Stop
            }
            "SubnetName" {
                $vnet = $Script:WorkSet["VirtualNetwork"]
                if (!$vnet) {
                    Throw "VirualNework must be set before a SubnetName can be used"
                }
                $Script:WorkSet["Subnet"] = Get-AzureRmVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name $SubnetName -ErrorAction Stop
            }
            "StorageAccountName" {
                $rg = $Script:WorkSet["ResourceGroup"]
                if (!$rg) {
                    Throw "ResourceGroup must be set before a StorageAccountName can be used"
                }
                $Script:WorkSet["StorageAccount"] = Get-AzureRmStorageAccount -Name $StorageAccountName -ResourceGroupName $rg.ResourceGroupName -ErrorAction Stop
            }
            "PublicIpAddressName" {
                $rg = $Script:WorkSet["ResourceGroup"]
                if (!$rg) {
                    Throw "ResourceGroup must be set before a PublicIpAddress can be used"
                }
                $Script:WorkSet["PublicIpAddress"] = Get-AzureRmPublicIpAddress -Name $PublicIpAddressName -ResourceGroupName $rg.ResourceGroupName -ErrorAction Stop
            }
            "NetworkSecurityGroupName" {
                $rg = $Script:WorkSet["ResourceGroup"]
                if (!$rg) {
                    Throw "ResourceGroup must be set before a NetworkSecurityGroup can be used"
                }
                $Script:WorkSet["NetworkSecurityGroup"] = Get-AzureRmNetworkSecurityGroup -Name $NetworkSecurityGroupName -ResourceGroupName $rg.ResourceGroupName -ErrorAction Stop
            }
            "NetworkInterfaceName" {
                $rg = $Script:WorkSet["ResourceGroup"]
                if (!$rg) {
                    Throw "ResourceGroup must be set before a NetworkInterfaceName can be used"
                }
                $Script:WorkSet["NetworkInterface"] = Get-AzureRmNetworkInterface -Name $NetworkInterfaceName -ResourceGroupName $rg.ResourceGroupname -ErrorAction Stop
            }
            "SqlServerName" {
                $rg = $Script:WorkSet["ResourceGroup"]
                if (!$rg) {
                    Throw "ResourceGroup must be set before a SqlServer can be used"
                }
                $Script:WorkSet["SqlServer"] = Get-AzureRmSqlServer -Name $SqlServerName -ResourceGroupName $rg.ResourceGroupname -ErrorAction Stop
            }
            "SqlElasticPoolName" {
                $rg = $Script:WorkSet["ResourceGroup"]
                if (!$rg) {
                    Throw "ResourceGroup must be set before a SqlServer can be used"
                }
                $sql = $Script:WorkSet["SqlServer"]
                if (!$sql) {
                    Throw "SqlServer must be set before a SqlElasticPool can be used"
                }
                $Script:WorkSet["SqlElasticPool"] = Get-AzureRmSqlElasticPool -ElasticPoolName $SqlElasticPoolName -ResourceGroupName $rg.ResourceGroupname  -ServerName $sql.ServerName -ErrorAction Stop
            }
            default {
                $value = $PSCmdlet.MyInvocation.BoundParameters[$name]
                $Script:WorkSet[$name] = $value
            }
        }
    }
}

function Get-TMAzureWorkSet
(
    [Parameter(Mandatory = $false, ParameterSetName = "1")]
    [switch]$SubscriptionId,
    [Parameter(Mandatory = $false, ParameterSetName = "2")]
    [switch]$TenantId,
    [Parameter(Mandatory = $false, ParameterSetName = "3")]
    [switch]$Location,
    [Parameter(Mandatory = $false, ParameterSetName = "4")]
    [switch]$ResourceGroup,
    [Parameter(Mandatory = $false, ParameterSetName = "5")]
    [switch]$ResourceGroupName,
    [Parameter(Mandatory = $false, ParameterSetName = "6")]
    [switch]$VirtualNetwork,
    [Parameter(Mandatory = $false, ParameterSetName = "7")]
    [switch]$VirtualNetworkName,
    [Parameter(Mandatory = $false, ParameterSetName = "8")]
    [switch]$Subnet,
    [Parameter(Mandatory = $false, ParameterSetName = "9")]
    [switch]$SubnetName,
    [Parameter(Mandatory = $false, ParameterSetName = "10")]
    [switch]$SubnetId,
    [Parameter(Mandatory = $false, ParameterSetName = "11")]
    [switch]$StorageAccount,
    [Parameter(Mandatory = $false, ParameterSetName = "12")]
    [switch]$StorageAccountName,
    [Parameter(Mandatory = $false, ParameterSetName = "13")]
    [switch]$PublicIpAddress,
    [Parameter(Mandatory = $false, ParameterSetName = "14")]
    [switch]$PublicIpAddressName,
    [Parameter(Mandatory = $false, ParameterSetName = "15")]
    [switch]$PublicIpAddressId,
    [Parameter(Mandatory = $false, ParameterSetName = "16")]
    [switch]$NetworkSecurityGroup,
    [Parameter(Mandatory = $false, ParameterSetName = "17")]
    [switch]$NetworkSecurityGroupName,
    [Parameter(Mandatory = $false, ParameterSetName = "18")]
    [switch]$NetworkSecurityGroupId,
    [Parameter(Mandatory = $false, ParameterSetName = "19")]
    [switch]$NetworkInterface,
    [Parameter(Mandatory = $false, ParameterSetName = "20")]
    [switch]$NetworkInterfaceName,
    [Parameter(Mandatory = $false, ParameterSetName = "21")]
    [switch]$NetworkInterfaceId,
    [Parameter(Mandatory = $false, ParameterSetName = "22")]
    [switch]$LocalAdminCredential,
    [Parameter(Mandatory = $false, ParameterSetName = "23")]
    [switch]$VirtualMachineConfig,
    [Parameter(Mandatory = $false, ParameterSetName = "24")]
    [switch]$VirtualMachine,
    [Parameter(Mandatory = $false, ParameterSetName = "25")]
    [switch]$SqlServer,
    [Parameter(Mandatory = $false, ParameterSetName = "26")]
    [switch]$SqlAdminCredential,
    [Parameter(Mandatory = $false, ParameterSetName = "27")]
    [switch]$SqlServerName,
    [Parameter(Mandatory = $false, ParameterSetName = "28")]
    [switch]$SqlElasticPool,
    [Parameter(Mandatory = $false, ParameterSetName = "29")]
    [switch]$SqlElasticPoolName
){
    if ($ResourceGroupName) {
         $rg = $Script:WorkSet["ResourceGroup"]
         $name = if ($rg) {$rg.ResourceGroupName} else {$null}
         return $name
    }
    if ($VirtualNetworkName) {
        $vnet = $Script:WorkSet["VirtualNetwork"]
        $name = if ($vnet) {$vnet.Name} else {$null}
        return $name
    }
    if ($SubnetName) {
        $subnet = $Script:WorkSet["Subnet"]
        $name = if ($subnet) {$subnet.Name} else {$null}
        return $name
    }
    if ($SubnetId) {
        $s = $Script:WorkSet["Subnet"]
        $id = if ($s) {$s.Id} else {$null}
        return $id
    }
    if ($StorageAccountName) {
        $sa = $Script:WorkSet["StorageAccount"]
        $name = if ($sa) {$sa.Name} else {$null}
        return $name
    }
    if ($PublicIpAddressName) {
        $pip = $Script:WorkSet["PublicIpAddress"]
        $name = if ($pip) {$pip.Name} else {$null}
        return $name
    }
    if ($PublicIpAddressId) {
        $pip = $Script:WorkSet["PublicIpAddress"]
        $id = if ($pip) {$pip.Id} else {$null}
        return $id
    }
    if ($NetworkSecurityGroupName) {
        $nsg = $Script:WorkSet["NetworkSecurityGroup"]
        $name = if ($nsg) {$nsg.Name} else {$null}
        return $name
    }
    if ($NetworkSecurityGroupId) {
        $nsg = $Script:WorkSet["NetworkSecurityGroup"]
        $id = if ($nsg) {$nsg.Id} else {$null}
        return $id
    }
    if ($NetworkInterfaceName) {
        $nic = $Script:WorkSet["NetworkInterface"]
        $name = if ($nic) {$nic.Name} else {$null}
        return $name
    }
    if ($NetworkInterfaceId) {
        $nic = $Script:WorkSet["NetworkInterface"]
        $id = if ($nic) {$nic.Id} else {$null}
        return $id
    }
    if ($SqlServerName) {
        $sql = $Script:WorkSet["SqlServer"]
        $name = if ($sql) {$sql.ServerName} else {$null}
        return $name
    }
    if ($SqlElasticPoolName) {
        $ep = $Script:WorkSet["SqlElasticPool"]
        $name = if ($ep) {$ep.ElasticPoolName} else {$null}
        return $name
    }
    foreach ($name in $PSCmdlet.MyInvocation.BoundParameters.Keys) {
        return $Script:WorkSet[$name]
    }
}

function Invoke-TMAzureClearWorkSet ()
{
    $Script:WorkSet = @{}
}

function Set-TMAzureLocalAdminCredential([string]$Username, [string]$Password)
{
    $Script:WorkSet["LocalAdminCredential"] = Get-TMAzureCredential $Username $Password
}

function Set-TMAzureSqlAdminCredential([string]$Username, [string]$Password)
{
    $Script:WorkSet["SqlAdminCredential"] = Get-TMAzureCredential $Username $Password
}