# This script was used to generate the initial TMAzure.ps1
# and is only here as a reference.
$manifest = @{
    Path              = '.\TMAzure.psd1'
    RootModule        = 'TMAzure.psm1'
    Author            = 'TrueMark, LLC'
}
New-ModuleManifest @manifest