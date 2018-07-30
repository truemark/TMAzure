Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

<#
Utility method that will reutrn all the powerhsell module paths.
#>
function Get-TMAzurePSModulePath() {
    return $env:PSModulePath -split ";"
}

<#
Reads an ini file and returns an associative array with the contents.
#>
function Get-TMAzureIni($filePath)
{
    if ( -not (Test-Path -LiteralPath $filePath))  {
        throw [System.IO.FileNotFoundException] "$filePath not found."
    }
    $ini = @{}
    $section = "NO_SECTION"
    $ini[$section] = @{}
    switch -regex -file $FilePath
    {
        "^\[(.+)\]" # Section
        {
            $section = $matches[1]
            $ini[$section] = @{}
            $CommentCount = 0
        }
        "^(;.*)$" # Comment
        {
            $value = $matches[1]
            $CommentCount = $CommentCount + 1
            $name = "Comment" + $CommentCount
            $ini[$section][$name] = $value
        } 
        "(.+?)\s*=(.*)" # Key
        {
            $name,$value = $matches[1..2]
            $value = $value.Trim()
            $name = $name.Trim()
            if ($ini[$section].Contains($name)) {
                if ($ini[$section][$name] -isnot [System.Collections.ArrayList]) {
                    $cval = $ini[$section][$name]
                    $ini[$section][$name] = New-Object System.Collections.ArrayList
                    $ini[$section][$name].Add($cval)
                }
                $ini[$section][$name].Add($value)
            } else {
                $ini[$section][$name] = $value
            } 
        }
    }
    return $ini
}

<#
Takes a username and password and returns a Credential object.
Please know this is not secure.
#>
function Get-TMAzureCredential
(
    [Parameter(Mandatory=$true, Position=0)]
    $Username,
    [Parameter(Mandatory=$true, Position=1)]
    $Password
)
{
    $SecurePassword = $Password | ConvertTo-SecureString -AsPlainText -Force
    $Credential = New-Object  System.Management.Automation.PSCredential -ArgumentList $Username,$SecurePassword
    return $Credential
}