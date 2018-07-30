Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
Import-Module AzureRM

. $PSScriptRoot/Log.ps1
. $PSScriptRoot/Account.ps1
. $PSScriptRoot/Network.ps1
. $PSScriptRoot/ResourceGroup.ps1
. $PSScriptRoot/Storage.ps1
. $PSScriptRoot/Util.ps1
. $PSScriptRoot/VirtualMachine.ps1
. $PSScriptRoot/WorkSet.ps1