# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

$TestCertPath = JOin-Path $TestDir CarbonTestCertificate.cer -Resolve
$TestCert = New-Object Security.Cryptography.X509Certificates.X509Certificate2 $TestCertPath

function Start-TestFixture
{
    & (Join-Path -Path $PSScriptRoot -ChildPath '..\Import-CarbonForTest.ps1' -Resolve)
}

function Start-Test
{
    if( -not (Get-Certificate -Thumbprint $TestCert.Thumbprint -StoreLocation CurrentUser -StoreName My) ) 
    {
        Install-Certificate -Path $TestCertPath -StoreLocation CurrentUser -StoreName My
    }
}

function Stop-Test
{
    Uninstall-Certificate -Certificate $TestCert -storeLocation CurrentUser -StoreName My
}

function Test-ShouldFindCertificatesByFriendlyName
{
    $cert = Get-Certificate -FriendlyName $TestCert.friendlyName -StoreLocation CurrentUser -StoreName My
    Assert-TestCert $cert
}


function Test-ShouldFindCertificateByPath
{
    $cert = Get-Certificate -Path $TestCertPath
    Assert-TestCert $cert
}

function Test-ShouldFindCertificateByRelativePath
{
    Push-Location -Path $PSScriptRoot
    try
    {
        $cert = Get-Certificate -Path ('.\{0}' -f (Split-Path -Leaf -Path $TestCertPath))
        Assert-TestCert $cert
    }
    finally
    {
        Pop-Location
    }
}

function Test-ShouldFindCertificateByThumbprint
{
    $cert = Get-Certificate -Thumbprint $TestCert.Thumbprint -StoreLocation CurrentUser -StoreName My
    Assert-TestCert $cert
}

function Test-ShouldNotThrowErrorWhenCertificateDoesNotExist
{
    $cert = Get-Certificate -Thumbprint '1234567890abcdef1234567890abcdef12345678' -StoreLocation CurrentUser -StoreName My -ErrorAction SilentlyContinue
    Assert-NoError
    Assert-Null $cert
}

function Test-ShouldFindCertificateInCustomStoreByThumbprint
{
    $expectedCert = Install-Certificate -Path $TestCertPath -StoreLocation CurrentUser -CustomStoreName 'Carbon'
    try
    {
        $cert = Get-Certificate -Thumbprint $expectedCert.Thumbprint -StoreLocation CurrentUser -CustomStoreName 'Carbon'
        Assert-NotNull $cert
        Assert-Equal $expectedCert.Thumbprint $cert.Thumbprint
    }
    finally
    {
        Uninstall-Certificate -Certificate $expectedCert -StoreLocation CurrentUser -CustomStoreName 'Carbon'
    }
}

function Test-ShouldFindCertificateInCustomStoreByFriendlyName
{
    $expectedCert = Install-Certificate -Path $TestCertPath -StoreLocation CurrentUser -CustomStoreName 'Carbon'
    try
    {
        $cert = Get-Certificate -FriendlyName $expectedCert.FriendlyName -StoreLocation CurrentUser -CustomStoreName 'Carbon'
        Assert-NotNull $cert
        Assert-Equal $expectedCert.Thumbprint $cert.Thumbprint
    }
    finally
    {
        Uninstall-Certificate -Certificate $expectedCert -StoreLocation CurrentUser -CustomStoreName 'Carbon'
    }
}

function Test-ShouldGetPasswordProtectedCertificate
{
    [Security.Cryptography.X509Certificates.X509Certificate2]$cert = Get-Certificate -Path (Join-Path -Path $PSScriptRoot -ChildPath 'CarbonTestCertificateWithPassword.cer') -Password 'password'
    Assert-NoError
    Assert-NotNull $cert
    Assert-Equal 'DE32D78122C2B5136221DE51B33A2F65A98351D2' $cert.Thumbprint
    Assert-Equal 'Carbon Test Certificate - Password Protected' $cert.FriendlyName
}

function Test-ShouldIncludeExceptionWhenFailingToLoadCertificate
{
    $cert = Get-Certificate -Path (Join-Path -Path $PSScriptRoot -ChildPath 'CarbonTestCertificateWithPassword.cer') -ErrorAction SilentlyContinue
    Assert-Error -Last -Regex 'password'
    Assert-Null $cert
    Assert-NotNull $Error[1].Exception
    Assert-Is $Error[1].Exception ([Management.Automation.MethodInvocationException])
}

function Test-ShouldGetCertificatesInCAStore
{
    $foundACert = $false
    dir Cert:\CurrentUser\CA | ForEach-Object {
        $cert = Get-Certificate -Thumbprint $_.Thumbprint -StoreLocation CurrentUser -StoreName CertificateAuthority
        Assert-NotNull $cert
        $foundACert = $true
    }
}

function Assert-TestCert($actualCert)
{
    
    Assert-NotNull $actualCert
    Assert-Equal $TestCert.Thumbprint $actualCert.Thumbprint
}

