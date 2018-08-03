Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Set-TMAzureSqlServer
(
    [Parameter(Mandatory=$true)]
    [string] $Name
)
{
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
    if ($Name -notmatch ".*sql-vm[\d]+$") {
        Warn "Best practices recommend a SQL Server name end with 'sql-vm<number>'"
        Warn "See https://docs.microsoft.com/en-us/azure/architecture/best-practices/naming-conventions"
    }
    if ($Name -cne $Name.ToLower()) {
        Warn "Best practice suggests VirtualMachine names should be lowercase"
    }
    if ($Name.length -gt 15) {
        Warn "Best practive recommends a VirtualMachine name be 15 characters or less"
    }
    $notPresent = $false
    $sqlserver = Get-AzureRmSqlServer -ResourceGroupName $rgn -Name $Name -ErrorVariable notPresent -ErrorAction SilentlyContinue
    if ($notPresent) {
        Info "Creating SQL Server $Name"
        $sqlserver = New-AzureRmSqlServer -ResourceGroupName $rgn -ServerName $Name -Location $loc -SqlAdministratorCredentials $cred -ErrorAction Stop
        } Else {
            Info "SQL Server $Name already exists"
    }
    Set-TMAzureWorkSet -SQLServerName $Name
    return $Name
}
function Set-TMAzureSQLElasticPool
(
    [Parameter(Mandatory=$true)]
    [string] $epname,
    [Parameter(Mandatory=$false)]
    [ValidateSet("Basic", "Standard", "Premium", ignorecase=$True)]
    [string] $edition,
    [Parameter(Mandatory=$false)]
    [Int32] $dtu
)
{
    $rgn = Get-TMAzureWorkSet -ResourceGroupName
    $sn = Get-TMAzureWorkSet -SQLServerName
    # Validation
    if (!$rgn) {
        throw "Resource Group is not set"
    }
    if (!$sn) {
        throw "SQL Server is not set"
    }
    if ($edition -eq "Basic" ) 
    {
        [int[]] $TMAzureElasticPoolBasicDTU = 50,100,200,300,400,800,1200,1600
        if (!($TMAzureElasticPoolBasicDTU -contains $dtu))
        {
            Info "DTU's for $edition must be set to $TMAzureElasticPoolBasicDTU DTU's "
            throw "Basic Edition of the Elastic Pool doesn't allow $dtu DTU's"
            Throw "See https://docs.microsoft.com/en-us/azure/sql-database/sql-database-dtu-resource-limits-elastic-pools#elastic-pool-storage-sizes-and-performance-levels"
        }
    }
    if ($edition -eq "Standard")
    {
        [int[]] $TMAzureElasticPoolStandardDTU = 50,100,200,300,400,800,1200,1600,2000,2500,3000
        if (!($TMAzureElasticPoolStandardDTU -contains $dtu))
        {
            Info "DTU's for $edition must be set to $TMAzureElasticPoolStandardDTU DTU's "
            throw "Standard Edition of the Elastic Pool doesn't allow $dtu DTU's"
            Throw "See https://docs.microsoft.com/en-us/azure/sql-database/sql-database-dtu-resource-limits-elastic-pools#elastic-pool-storage-sizes-and-performance-levels"

        }
    }
    if ($edition -eq "Premium")
    {
        [int[]] $TMAzureElasticPoolPremiumDTU = 125,250,500,1000,1500,2000,2500,3000,3500,4000
        if (!($TMAzureElasticPoolPremiumDTU -contains $dtu))
        {
            Info "DTU's for $edition must be set to $TMAzureElasticPoolPremiumDTU DTU's "
            throw "Premium Edition of the Elastic Pool doesn't allow $dtu DTU's"
            Throw "See https://docs.microsoft.com/en-us/azure/sql-database/sql-database-dtu-resource-limits-elastic-pools#elastic-pool-storage-sizes-and-performance-levels"

        }
    }
    if ($epname -cne $epname.ToLower()) {
        $epname = $epname.ToLower()
        Warn "Best practice suggests Elastic Pool names should be lowercase"
        Info "Modifying Elastic Pool name to $epname"
    }
    if ($epname.endsWith("-ep")) {
        Warn "Best practices recommend a Elastic Pool name end with '-ep'"
    }
    $notPresent = $false
    # Checks if the Elastic Pool already exists
    $elasticpool = Get-AzureRmSqlElasticPool -ResourceGroupName $rgn -ServerName $sn -ElasticPoolName $epname -ErrorVariable notPresent -ErrorAction SilentlyContinue
    # Creates the Elastic Pool if it doesn't exit
    if ($notPresent) {
        Info "Creating Elastic Pool $epname on $sn"
        $elasticpool = New-AzureRmSqlElasticPool -ResourceGroupName $rgn -ElasticPoolName $epname -ServerName $sn -Edition $edition -Dtu $dtu 
    } else {
            Info "Elastic Pool $epname on $sn already exists"
    }
    Set-TMAzureWorkSet -ElasticPoolName $epname
    return $epname
}