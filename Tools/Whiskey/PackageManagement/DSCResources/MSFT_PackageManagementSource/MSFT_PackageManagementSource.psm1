#
# Copyright (c) Microsoft Corporation.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
# This PS DSC resource enables register or unregister a package source through DSC Get, Set and Test operations on DSC managed nodes.

Import-LocalizedData -BindingVariable LocalizedData -filename MSFT_PackageManagementSource.strings.psd1

Import-Module -Name "$PSScriptRoot\..\PackageManagementDscUtilities.psm1"

function Get-TargetResource
{
    <#
    .SYNOPSIS

    This DSC resource provides a mechanism to register/unregister a package source on your computer. 

    Get-TargetResource returns the current state of the resource.

    .PARAMETER Name
    Specifies the name of the package source to be registered or unregistered on your system.

    .PARAMETER ProviderName
    Specifies the name of the PackageManagement provider through which you can interop with the package source.

    .PARAMETER SourceLocation
    Specifies the Uri of the package source.
    #>

    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [parameter(Mandatory = $true)]
        [System.String]
        $ProviderName,

        [parameter(Mandatory = $true)]
        [System.String]
        $SourceLocation
    )

    #initialize a local var
    $ensure = "Absent"

    #Set the installation policy by default, untrusted. 
    $installationPolicy ="Untrusted"

    $PSBoundParameters.Add("Location", $SourceLocation)
    $PSBoundParameters.Remove("SourceLocation")

    #Validate Uri and add Location because PackageManagement uses Location not SourceLocation. 
    #ValidateArgument  -Argument $PSBoundParameters['Location'] -Type 'PackageSource' -ProviderName $ProviderName

    Write-Verbose -Message ($localizedData.StartGetPackageSource -f $($Name))

    #check if the package source already registered on the computer
    # Note: Assume Get-PackageSource returns the first source if multiple are found
    $source = PackageManagement\Get-PackageSource @PSBoundParameters -ForceBootstrap -ErrorAction SilentlyContinue -WarningAction SilentlyContinue  
        

    if (($source.count -gt 0) -and ($source.IsRegistered))
    {
        Write-Verbose -Message ($localizedData.PackageSourceFound -f $($Name))
        $ensure = "Present"
    }
    else
    {
        Write-Verbose -Message ($localizedData.PackageSourceNotFound -f $($Name))
    }

    Write-Debug -Message "Source $($Name) is $($ensure)"
                         
    
    if ($ensure -eq 'Absent')
    {
        return @{
            Ensure       = $ensure
            Name         = $Name
            ProviderName = $ProviderName
        }
    }
    else
    {
        if ($source.IsTrusted)
        {
            $installationPolicy = "Trusted"
        }

        return @{
            Ensure             = $ensure
            Name               = $Name
            ProviderName       = $ProviderName
            SourceLocation          = $source.Location
            InstallationPolicy = $installationPolicy
        }
    } 
}

function Test-TargetResource
{
    <#
    .SYNOPSIS

    This DSC resource provides a mechanism to register/unregister a package source on your computer. 

    Test-TargetResource validates whether the resource is currently in the desired state.

    .PARAMETER Name
    Specifies the name of the package source to be registered or unregistered on your system.

    .PARAMETER ProviderName
    Specifies the name of the PackageManagement provider through which you can interop with the package source.

    .PARAMETER SourceLocation
    Specifies the Uri of the package source.

    .PARAMETER Ensure
    Determines whether the package source to be registered or unregistered.

    .PARAMETER SourceCredential
    Provides access to the package on a remote source. 

    .PARAMETER InstallationPolicy
    Determines whether you trust the package’s source.
    #>

    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [parameter(Mandatory = $true)]
        [System.String]
        $ProviderName,

        [parameter(Mandatory = $true)]
        [System.String]
        $SourceLocation,

        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure="Present",

        [System.Management.Automation.PSCredential]
        $SourceCredential,

        [ValidateSet("Trusted","Untrusted")]
        [System.String]
        $InstallationPolicy="Untrusted"
    )

    #Get the current status of the package source 
    Write-Debug -Message  "Calling Get-TargetResource"

    $status = Get-TargetResource -Name $Name -ProviderName $ProviderName -SourceLocation $SourceLocation
 
    if($status.Ensure -eq $Ensure)
    {
        
        if ($status.Ensure -eq "Present") 
        {
            #Check if the source location matches. As get-package takes location (SourceLocation) parameter, the result from Get-package should 
            #belong to the particular source location. But currently it does not. Below is the workaround.
            #
            if ($status.SourceLocation -ine $SourceLocation) 
            {
                Write-Verbose -Message ($localizedData.NotInDesiredStateDuetoLocationMismatch -f $($Name), $($SourceLocation), $($status.SourceLocation))
                return $false 
            }  

            #Check if the installationPolicy matches. Sometimes the registered source and desired source can be the same except for InstallationPolicy
            #
            if ($status.InstallationPolicy -ine $InstallationPolicy)
            {
                Write-Verbose -Message ($localizedData.NotInDesiredStateDuetoPolicyMismatch -f $($Name), $($InstallationPolicy), $($status.InstallationPolicy))
                return $false 
            }           
        }

        Write-Verbose -Message ($localizedData.InDesiredState -f $($Name), $($Ensure), $($status.Ensure))                   
        return $true
    }
    else
    {
        Write-Verbose -Message ($localizedData.NotInDesiredState -f $($Name), $($Ensure), $($status.Ensure))
        return $false
    }
}

function Set-TargetResource
{
    <#
    .SYNOPSIS

    This DSC resource provides a mechanism to register/unregister a package source on your computer. 

    Set-TargetResource sets the resource to the desired state. "Make it so".

    .PARAMETER Name
    Specifies the name of the package source to be registered or unregistered on your system.

    .PARAMETER ProviderName
    Specifies the name of the PackageManagement provider through which you can interop with the package source.

    .PARAMETER SourceLocation
    Specifies the Uri of the package source.

    .PARAMETER Ensure
    Determines whether the package source to be registered or unregistered.

    .PARAMETER SourceCredential
    Provides access to the package on a remote source. 

    .PARAMETER InstallationPolicy
    Determines whether you trust the package’s source.
    #>

    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [parameter(Mandatory = $true)]
        [System.String]
        $ProviderName,

        [parameter(Mandatory = $true)]
        [System.String]
        $SourceLocation,

        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure="Present",

        [System.Management.Automation.PSCredential]
        $SourceCredential,

        [ValidateSet("Trusted","Untrusted")]
        [System.String]
        $InstallationPolicy="Untrusted"
    )

    #Add Location because PackageManagement uses Location not SourceLocation. 
    $PSBoundParameters.Add("Location", $SourceLocation)

    if ($PSBoundParameters.ContainsKey("SourceCredential"))
    {
        $PSBoundParameters.Add("Credential", $SourceCredential)
    }

    if ($InstallationPolicy -ieq "Trusted")
    {
        $PSBoundParameters.Add("Trusted", $True)
    }
    else
    {
        $PSBoundParameters.Add("Trusted", $False)
    }
    

    if($Ensure -ieq "Present")
    {   
        #
        #Warn a user about the installation policy
        #
        Write-Warning -Message ($localizedData.InstallationPolicyWarning -f $($Name), $($SourceLocation), $($InstallationPolicy))

        $extractedArguments = ExtractArguments -FunctionBoundParameters $PSBoundParameters `
                                               -ArgumentNames ("Name","ProviderName", "Location", "Credential", "Trusted")   
        
        Write-Verbose -Message ($localizedData.StartRegisterPackageSource -f $($Name)) 

        if ($name -eq "psgallery")
        {         
            # In WMF 5.0 RTM, we are not able to register 'psgallery' package source. Thus let's try Set-PSRepository to see if we can
            # update the registration. 
            
            # Before calling the Set-PSRepository cmdlet, we need to make sure the PSGallery already registered.

            $psgallery = PackageManagement\Get-PackageSource -name $name -Location $SourceLocation -ProviderName $ProviderName -ErrorAction SilentlyContinue -WarningAction SilentlyContinue

            if( $psgallery)
            {
                Set-PSRepository -Name $name -SourceLocation $SourceLocation -InstallationPolicy $InstallationPolicy -ErrorVariable ev 
            }
            else
            {
                # The following works if you are running TP5 or later
                $extractedArguments.Remove("Location")
                PackageManagement\Register-PackageSource @extractedArguments -Force -ErrorVariable ev  

            }
        }
        else
        {                                       
            PackageManagement\Register-PackageSource @extractedArguments -Force -ErrorVariable ev  
        }
            
        if($null -ne $ev -and $ev.Count -gt 0)
        {
            ThrowError  -ExceptionName "System.InvalidOperationException" `
                        -ExceptionMessage ($localizedData.RegisterFailed -f $Name, $ev.Exception)`
                        -ErrorId "RegisterFailed" `
                        -ErrorCategory InvalidOperation                  
        }
        else
        {
            Write-Verbose -Message ($localizedData.RegisteredSuccess -f $($Name))           
        }                      
    }
    #Ensure=Absent
    else 
    {
        $extractedArguments = ExtractArguments -FunctionBoundParameters $PSBoundParameters `
                                               -ArgumentNames $("Name","ProviderName", "Location", "Credential")  
                                                       
        Write-Verbose -Message ($localizedData.StartUnRegisterPackageSource -f $($Name))  
                         
        PackageManagement\Unregister-PackageSource @extractedArguments -Force -ErrorVariable ev 
        
        if($null -ne $ev -and $ev.Count -gt 0)
        {
            ThrowError  -ExceptionName "System.InvalidOperationException" `
                        -ExceptionMessage ($localizedData.UnRegisterFailed -f $Name, $ev.Exception)`
                        -ErrorId "UnRegisterFailed" `
                        -ErrorCategory InvalidOperation       
        }
        else
        {
            Write-Verbose -Message ($localizedData.UnRegisteredSuccess -f $($Name))            
        }                    
    }  
 }

Export-ModuleMember -function Get-TargetResource, Set-TargetResource, Test-TargetResource


# SIG # Begin signature block
# MIIarQYJKoZIhvcNAQcCoIIanjCCGpoCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUC4EZxk7d5RVeBsaJdj90rek1
# /OOgghWAMIIEwjCCA6qgAwIBAgITMwAAAL6kD/XJpQ7hMAAAAAAAvjANBgkqhkiG
# 9w0BAQUFADB3MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4G
# A1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSEw
# HwYDVQQDExhNaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EwHhcNMTYwOTA3MTc1ODQ5
# WhcNMTgwOTA3MTc1ODQ5WjCBsjELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hp
# bmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jw
# b3JhdGlvbjEMMAoGA1UECxMDQU9DMScwJQYDVQQLEx5uQ2lwaGVyIERTRSBFU046
# ODQzRC0zN0Y2LUYxMDQxJTAjBgNVBAMTHE1pY3Jvc29mdCBUaW1lLVN0YW1wIFNl
# cnZpY2UwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCROfFjRVxKmgTC
# tN14U6jxq1vAK7TBi39qS2BIU56Xw1IeOFNjg7bw6O8DMLr04Ghia8ath6lj3yab
# PSyXiYULrfk/7PkLUAqDbr6CFA/kuvoLYmePEgYKgI2vtruq05MABGYyw4WpUfLt
# chCNiBYWawyrdeHaw80xvfUrb7cDAU8st94bIkgyboaDN7f3oIzQHqyxok8XSSaZ
# JKTyqNtEtDo7p6ZJ3ygCa98lCk/SjpVnLkGlX0lJ3y/H2FM28gNnfQZQO8Pe0ICv
# 3KCpi4CPqx9LEuPgQoJrYK573I1LJlbjTV+l73UHPbo2w40W9L1SGu5UWrwNb6tZ
# qk4RwEvJAgMBAAGjggEJMIIBBTAdBgNVHQ4EFgQUHG4NXaJsQp0+3x29Li7nwpc0
# kH8wHwYDVR0jBBgwFoAUIzT42VJGcArtQPt2+7MrsMM1sw8wVAYDVR0fBE0wSzBJ
# oEegRYZDaHR0cDovL2NybC5taWNyb3NvZnQuY29tL3BraS9jcmwvcHJvZHVjdHMv
# TWljcm9zb2Z0VGltZVN0YW1wUENBLmNybDBYBggrBgEFBQcBAQRMMEowSAYIKwYB
# BQUHMAKGPGh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2kvY2VydHMvTWljcm9z
# b2Z0VGltZVN0YW1wUENBLmNydDATBgNVHSUEDDAKBggrBgEFBQcDCDANBgkqhkiG
# 9w0BAQUFAAOCAQEAbmBxbLeCqxsZFPMYFz/20DMP8Q12dH/1cNQursRMH0Yg0cTw
# Ln1IF3DGypfHZJwbyl9HWNVf+2Jq05zMajfjxiEu+khzmMnA9/BJ1utPwR0nPyyL
# bN+0IGBMfYLeIAdC81e0CW9TpWpc6lH/jgWbhviUt4Mvt2DQMWIQ7WwJAdBeGjCn
# tLINPxC9RmHysFGexMsXS+hYNR2z/h/PmvsNwhq7CtM6bM71ZvYFaBSCmtdQ8/KQ
# CPiN6acb2V/28VuZEwjq3GFAJfcKMvhssewRgCYsKxhvWZHUkBrUxWnsvxNCOWPp
# enBiVSYl5nT9jBoVoTDChMITR35gr//DmhzXszCCBOswggPToAMCAQICEzMAAAF4
# JVq1zSPGX5UAAQAAAXgwDQYJKoZIhvcNAQEFBQAweTELMAkGA1UEBhMCVVMxEzAR
# BgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1p
# Y3Jvc29mdCBDb3Jwb3JhdGlvbjEjMCEGA1UEAxMaTWljcm9zb2Z0IENvZGUgU2ln
# bmluZyBQQ0EwHhcNMTcwODExMjAxMTE1WhcNMTgwODExMjAxMTE1WjCBgjELMAkG
# A1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQx
# HjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEMMAoGA1UECxMDQU9DMR4w
# HAYDVQQDExVNaWNyb3NvZnQgQ29ycG9yYXRpb24wggEiMA0GCSqGSIb3DQEBAQUA
# A4IBDwAwggEKAoIBAQCZbh1TVaudsrIbXUPPB9c8S+E+dKSbskHKYlG6SGTH8jhT
# hpuvGiAO87F2b9GHVN+DvszaMkGy/xQgHaGEJLfpnb3kpakic7E0bjDHdG4KnHRb
# no/wfUkGLfS79o+cw//RY8Ck6yE+0czDBcxp0Gbw5JyGP+KFqvzRR/3Tv3nt/5x0
# 5ZnEOHYP+eDVikDvn/DH+oxxtiCfX3tkvtm/yX4eOb47YdmYKQjCgz2+Nil/lupY
# vU0QFIjvke3jshqQINDng/vO9ys2qA0ex/q5hlLKQTST99dGoM86Ge6F723ReToq
# KnGLN8kiCG7uNapOAIQrpCHZq96CVumiaA5ZvxU9AgMBAAGjggFgMIIBXDATBgNV
# HSUEDDAKBggrBgEFBQcDAzAdBgNVHQ4EFgQUjuhtD3FD7tk/RKloJFX05cpgLjcw
# UQYDVR0RBEowSKRGMEQxDDAKBgNVBAsTA0FPQzE0MDIGA1UEBRMrMjI5ODAzKzFh
# YmY5ZTVmLWNlZDAtNDJlNi1hNjVkLWQ5MzUwOTU5ZmUwZTAfBgNVHSMEGDAWgBTL
# EejK0rQWWAHJNy4zFha5TJoKHzBWBgNVHR8ETzBNMEugSaBHhkVodHRwOi8vY3Js
# Lm1pY3Jvc29mdC5jb20vcGtpL2NybC9wcm9kdWN0cy9NaWNDb2RTaWdQQ0FfMDgt
# MzEtMjAxMC5jcmwwWgYIKwYBBQUHAQEETjBMMEoGCCsGAQUFBzAChj5odHRwOi8v
# d3d3Lm1pY3Jvc29mdC5jb20vcGtpL2NlcnRzL01pY0NvZFNpZ1BDQV8wOC0zMS0y
# MDEwLmNydDANBgkqhkiG9w0BAQUFAAOCAQEAYnG/oHG/xgZYR8NAMHZ/vE9GM0e4
# 7YdhuTea2uY7pSGwM707wp8Wan0Fa6evK1PWfcd/XNOh2BpEv5o8RmKDoEsG0ECP
# 13Jug7cklfKreBVHQ+Djg43VVFLZpuo7aOAVK6wjlcnpPUtn+SfH9K0aM2FjDKVJ
# FW6XFKXBat5R+Zp6uOxWTxpSeMTeDC5zF6IY6ogR1uzU+9EQoRlAvkwX6po+exEL
# nMLr4++P+fqOxIU+PODIoB8ijClAqwwKvLlMPa3qlrNHt+LweTMu7lvGC/RA18wU
# zzXAeomuZ03blUw+bkOiVgWOk4S0RN7EnW7zjJV8gd/+G2dbToUi1cB/fTCCBbww
# ggOkoAMCAQICCmEzJhoAAAAAADEwDQYJKoZIhvcNAQEFBQAwXzETMBEGCgmSJomT
# 8ixkARkWA2NvbTEZMBcGCgmSJomT8ixkARkWCW1pY3Jvc29mdDEtMCsGA1UEAxMk
# TWljcm9zb2Z0IFJvb3QgQ2VydGlmaWNhdGUgQXV0aG9yaXR5MB4XDTEwMDgzMTIy
# MTkzMloXDTIwMDgzMTIyMjkzMloweTELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldh
# c2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBD
# b3Jwb3JhdGlvbjEjMCEGA1UEAxMaTWljcm9zb2Z0IENvZGUgU2lnbmluZyBQQ0Ew
# ggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCycllcGTBkvx2aYCAgQpl2
# U2w+G9ZvzMvx6mv+lxYQ4N86dIMaty+gMuz/3sJCTiPVcgDbNVcKicquIEn08Gis
# TUuNpb15S3GbRwfa/SXfnXWIz6pzRH/XgdvzvfI2pMlcRdyvrT3gKGiXGqelcnNW
# 8ReU5P01lHKg1nZfHndFg4U4FtBzWwW6Z1KNpbJpL9oZC/6SdCnidi9U3RQwWfjS
# jWL9y8lfRjFQuScT5EAwz3IpECgixzdOPaAyPZDNoTgGhVxOVoIoKgUyt0vXT2Pn
# 0i1i8UU956wIAPZGoZ7RW4wmU+h6qkryRs83PDietHdcpReejcsRj1Y8wawJXwPT
# AgMBAAGjggFeMIIBWjAPBgNVHRMBAf8EBTADAQH/MB0GA1UdDgQWBBTLEejK0rQW
# WAHJNy4zFha5TJoKHzALBgNVHQ8EBAMCAYYwEgYJKwYBBAGCNxUBBAUCAwEAATAj
# BgkrBgEEAYI3FQIEFgQU/dExTtMmipXhmGA7qDFvpjy82C0wGQYJKwYBBAGCNxQC
# BAweCgBTAHUAYgBDAEEwHwYDVR0jBBgwFoAUDqyCYEBWJ5flJRP8KuEKU5VZ5KQw
# UAYDVR0fBEkwRzBFoEOgQYY/aHR0cDovL2NybC5taWNyb3NvZnQuY29tL3BraS9j
# cmwvcHJvZHVjdHMvbWljcm9zb2Z0cm9vdGNlcnQuY3JsMFQGCCsGAQUFBwEBBEgw
# RjBEBggrBgEFBQcwAoY4aHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraS9jZXJ0
# cy9NaWNyb3NvZnRSb290Q2VydC5jcnQwDQYJKoZIhvcNAQEFBQADggIBAFk5Pn8m
# Rq/rb0CxMrVq6w4vbqhJ9+tfde1MOy3XQ60L/svpLTGjI8x8UJiAIV2sPS9MuqKo
# VpzjcLu4tPh5tUly9z7qQX/K4QwXaculnCAt+gtQxFbNLeNK0rxw56gNogOlVuC4
# iktX8pVCnPHz7+7jhh80PLhWmvBTI4UqpIIck+KUBx3y4k74jKHK6BOlkU7IG9KP
# cpUqcW2bGvgc8FPWZ8wi/1wdzaKMvSeyeWNWRKJRzfnpo1hW3ZsCRUQvX/TartSC
# Mm78pJUT5Otp56miLL7IKxAOZY6Z2/Wi+hImCWU4lPF6H0q70eFW6NB4lhhcyTUW
# X92THUmOLb6tNEQc7hAVGgBd3TVbIc6YxwnuhQ6MT20OE049fClInHLR82zKwexw
# o1eSV32UjaAbSANa98+jZwp0pTbtLS8XyOZyNxL0b7E8Z4L5UrKNMxZlHg6K3RDe
# ZPRvzkbU0xfpecQEtNP7LN8fip6sCvsTJ0Ct5PnhqX9GuwdgR2VgQE6wQuxO7bN2
# edgKNAltHIAxH+IOVN3lofvlRxCtZJj/UBYufL8FIXrilUEnacOTj5XJjdibIa4N
# XJzwoq6GaIMMai27dmsAHZat8hZ79haDJLmIz2qoRzEvmtzjcT3XAH5iR9HOiMm4
# GPoOco3Boz2vAkBq/2mbluIQqBC0N1AI1sM9MIIGBzCCA++gAwIBAgIKYRZoNAAA
# AAAAHDANBgkqhkiG9w0BAQUFADBfMRMwEQYKCZImiZPyLGQBGRYDY29tMRkwFwYK
# CZImiZPyLGQBGRYJbWljcm9zb2Z0MS0wKwYDVQQDEyRNaWNyb3NvZnQgUm9vdCBD
# ZXJ0aWZpY2F0ZSBBdXRob3JpdHkwHhcNMDcwNDAzMTI1MzA5WhcNMjEwNDAzMTMw
# MzA5WjB3MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UE
# BxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSEwHwYD
# VQQDExhNaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EwggEiMA0GCSqGSIb3DQEBAQUA
# A4IBDwAwggEKAoIBAQCfoWyx39tIkip8ay4Z4b3i48WZUSNQrc7dGE4kD+7Rp9FM
# rXQwIBHrB9VUlRVJlBtCkq6YXDAm2gBr6Hu97IkHD/cOBJjwicwfyzMkh53y9Gcc
# LPx754gd6udOo6HBI1PKjfpFzwnQXq/QsEIEovmmbJNn1yjcRlOwhtDlKEYuJ6yG
# T1VSDOQDLPtqkJAwbofzWTCd+n7Wl7PoIZd++NIT8wi3U21StEWQn0gASkdmEScp
# ZqiX5NMGgUqi+YSnEUcUCYKfhO1VeP4Bmh1QCIUAEDBG7bfeI0a7xC1Un68eeEEx
# d8yb3zuDk6FhArUdDbH895uyAc4iS1T/+QXDwiALAgMBAAGjggGrMIIBpzAPBgNV
# HRMBAf8EBTADAQH/MB0GA1UdDgQWBBQjNPjZUkZwCu1A+3b7syuwwzWzDzALBgNV
# HQ8EBAMCAYYwEAYJKwYBBAGCNxUBBAMCAQAwgZgGA1UdIwSBkDCBjYAUDqyCYEBW
# J5flJRP8KuEKU5VZ5KShY6RhMF8xEzARBgoJkiaJk/IsZAEZFgNjb20xGTAXBgoJ
# kiaJk/IsZAEZFgltaWNyb3NvZnQxLTArBgNVBAMTJE1pY3Jvc29mdCBSb290IENl
# cnRpZmljYXRlIEF1dGhvcml0eYIQea0WoUqgpa1Mc1j0BxMuZTBQBgNVHR8ESTBH
# MEWgQ6BBhj9odHRwOi8vY3JsLm1pY3Jvc29mdC5jb20vcGtpL2NybC9wcm9kdWN0
# cy9taWNyb3NvZnRyb290Y2VydC5jcmwwVAYIKwYBBQUHAQEESDBGMEQGCCsGAQUF
# BzAChjhodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpL2NlcnRzL01pY3Jvc29m
# dFJvb3RDZXJ0LmNydDATBgNVHSUEDDAKBggrBgEFBQcDCDANBgkqhkiG9w0BAQUF
# AAOCAgEAEJeKw1wDRDbd6bStd9vOeVFNAbEudHFbbQwTq86+e4+4LtQSooxtYrhX
# AstOIBNQmd16QOJXu69YmhzhHQGGrLt48ovQ7DsB7uK+jwoFyI1I4vBTFd1Pq5Lk
# 541q1YDB5pTyBi+FA+mRKiQicPv2/OR4mS4N9wficLwYTp2OawpylbihOZxnLcVR
# DupiXD8WmIsgP+IHGjL5zDFKdjE9K3ILyOpwPf+FChPfwgphjvDXuBfrTot/xTUr
# XqO/67x9C0J71FNyIe4wyrt4ZVxbARcKFA7S2hSY9Ty5ZlizLS/n+YWGzFFW6J1w
# lGysOUzU9nm/qhh6YinvopspNAZ3GmLJPR5tH4LwC8csu89Ds+X57H2146SodDW4
# TsVxIxImdgs8UoxxWkZDFLyzs7BNZ8ifQv+AeSGAnhUwZuhCEl4ayJ4iIdBD6Svp
# u/RIzCzU2DKATCYqSCRfWupW76bemZ3KOm+9gSd0BhHudiG/m4LBJ1S2sWo9iaF2
# YbRuoROmv6pH8BJv/YoybLL+31HIjCPJZr2dHYcSZAI9La9Zj7jkIeW1sMpjtHhU
# BdRBLlCslLCleKuzoJZ1GtmShxN1Ii8yqAhuoFuMJb+g74TKIdbrHk/Jmu5J4PcB
# ZW+JC33Iacjmbuqnl84xKf8OxVtc2E0bodj6L54/LlUWa8kTo/0xggSXMIIEkwIB
# ATCBkDB5MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UE
# BxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSMwIQYD
# VQQDExpNaWNyb3NvZnQgQ29kZSBTaWduaW5nIFBDQQITMwAAAXglWrXNI8ZflQAB
# AAABeDAJBgUrDgMCGgUAoIGwMBkGCSqGSIb3DQEJAzEMBgorBgEEAYI3AgEEMBwG
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBRUbRG+
# HLqXgrUq7uDiLWHSWeV9yzBQBgorBgEEAYI3AgEMMUIwQKAWgBQAUABvAHcAZQBy
# AFMAaABlAGwAbKEmgCRodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vUG93ZXJTaGVs
# bCAwDQYJKoZIhvcNAQEBBQAEggEAI20eKfbSyUNRa/eBDaQeSXZ/zHJUm5EFAgge
# cfjadevki5mDcDwcMFy6/con+p/iYFOk/QZ+o89dreFdMQ865jGf8pBBZu5cTftB
# aKjIgONYbYP/6czrFNXu+l8IlMetzfDRHsOG1RwhZvP8y9RIM7kueGmZLaVridB1
# SVgn0rw+SeO0LSmpAb4xOlQOkS7QNeb5erONCgaJ1Wz2W7FK7SR2R9aMew9olN62
# i4dcInDnitAcIXhLeUqV1tI1NfN165xR7ZTCnGqwuFbm72gB3YKC3LteFcgfM5hT
# qiRSHd2RWfBmckdnUhAsR4LYkkPLFeBN7DGmbDTnPOdw9Is0yaGCAigwggIkBgkq
# hkiG9w0BCQYxggIVMIICEQIBATCBjjB3MQswCQYDVQQGEwJVUzETMBEGA1UECBMK
# V2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0
# IENvcnBvcmF0aW9uMSEwHwYDVQQDExhNaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EC
# EzMAAAC+pA/1yaUO4TAAAAAAAL4wCQYFKw4DAhoFAKBdMBgGCSqGSIb3DQEJAzEL
# BgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTE3MTAxNzIwMTAzMlowIwYJKoZI
# hvcNAQkEMRYEFL3pVoA5Rch1WTc37V+uiKMSfIXdMA0GCSqGSIb3DQEBBQUABIIB
# AFjvJk+96VprFiMB4fWc6oNRrl4M+00eC1w0ErC0hj1gfOQ/GtFmeZCzgHknvwc/
# PGTz6Bj5BPDWCwuGjW+gWL51eU8SiGVRv0qtHXIrGwSW3wiToF6B24Du+g6lp/6S
# AbomXopNP4SRHlSJmFraGSsmKJSiAeI8mcCDeSVm2cIhvxZy6QjMxHt0+5cl+0c4
# gIcUOhA9+c7+T1/KuGG41+OmNtNwge19MDI8AJw3EBXwFk8hyagKuP3iY6pqe4PU
# qybxawtH2PtHapW1mmXVu6GfvopAtbPOX1guWMKE2X5VNZnH3aWTlo8oy8QxbPaI
# zOgnZYgDjWVJs2PiQpwLYmA=
# SIG # End signature block
