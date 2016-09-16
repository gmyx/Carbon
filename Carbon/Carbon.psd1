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
#
# Module manifest for module 'Carbon'
#
# Generated by: Aaron Jensen
#
# Generated on: 8/30/2011
#

#Requires -Version 4

@{

    # Script module or binary module file associated with this manifest
    RootModule = 'Carbon.psm1'

    # Version number of this module.
    ModuleVersion = '2.3.0'

    # ID used to uniquely identify this module
    GUID = '075d9444-c01b-48c3-889a-0b3490716fa2'

    # Author of this module
    Author = 'Aaron Jensen'

    # Company or vendor of this module
    CompanyName = ''

    # Copyright statement for this module
    Copyright = 'Copyright 2011 - 2016 Aaron Jensen.'
    
    # Description of the functionality provided by this module
    Description = @'
Carbon is a PowerShell module for automating the configuration Windows 7, 8, 2008, and 2012 and automation the installation and configuration of Windows applications, websites, and services. It can configure and manage:

 * Local users and groups
 * IIS websites, virtual directories, and applications
 * File system, registry, and certificate permissions
 * Certificates
 * Privileges
 * Services
 * Encryption
 * Junctions
 * Hosts file
 * INI files
 * Performance counters
 * Shares
 * .NET connection strings and app settings
 * And much more!

All functions are idempotent: when run multiple times with the same arguments, your system will be in the same state without failing or producing errors.
'@

    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion = '4.0'

    # Name of the Windows PowerShell host required by this module
    PowerShellHostName = ''

    # Minimum version of the Windows PowerShell host required by this module
    PowerShellHostVersion = ''

    # Minimum version of the .NET Framework required by this module
    DotNetFrameworkVersion = ''

    # Minimum version of the common language runtime (CLR) required by this module
    CLRVersion = ''

    # Processor architecture (None, X86, Amd64, IA64) required by this module
    ProcessorArchitecture = ''

    # Modules that must be imported into the global environment prior to importing this module
    RequiredModules = @()

    # Assemblies that must be loaded prior to importing this module
    RequiredAssemblies = @( 'bin\Carbon.dll' )

    # Script files (.ps1) that are run in the caller's environment prior to importing this module
    ScriptsToProcess = @( )

    # Type files (.ps1xml) to be loaded when importing this module
    TypesToProcess = 'Carbon.types.ps1xml'

    # Format files (.ps1xml) to be loaded when importing this module
    FormatsToProcess = @( 'Carbon.format.ps1xml', 'Formats\Carbon.Security.HttpUrlAcl.format.ps1xml' )

    # Modules to import as nested modules of the module specified in ModuleToProcess
    NestedModules = @()

    # Functions to export from this module
    FunctionsToExport = @(
                            'Add-GroupMember',
                            'Add-IisDefaultDocument',
                            'Add-TrustedHost',
                            'Assert-AdminPrivilege',
                            'Assert-FirewallConfigurable',
                            'Assert-Service',
                            'Clear-DscLocalResourceCache',
                            'Clear-MofAuthoringMetadata',
                            'Clear-TrustedHost',
                            'Complete-Job',
                            'Compress-Item',
                            'ConvertFrom-Base64',
                            'Convert-SecureStringToString',
                            'ConvertTo-Base64',
                            'ConvertTo-ContainerInheritanceFlags',
                            'ConvertTo-InheritanceFlag',
                            'ConvertTo-PropagationFlag',
                            'ConvertTo-SecurityIdentifier',
                            'Convert-XmlFile',
                            'Copy-DscResource',
                            'Disable-FirewallStatefulFtp',
                            'Disable-IEEnhancedSecurityConfiguration',
                            'Disable-IisSecurityAuthentication',
                            'Disable-NtfsCompression',
                            'Enable-FirewallStatefulFtp',
                            'Enable-IEActivationPermission',
                            'Enable-IisDirectoryBrowsing',
                            'Enable-IisSecurityAuthentication',
                            'Enable-IisSsl',
                            'Enable-NtfsCompression',
                            'Expand-Item',
                            'Find-ADUser',
                            'Format-ADSearchFilterValue',
                            'Get-ADDomainController',
                            'Get-Certificate',
                            'Get-CertificateStore',
                            'Get-ComPermission',
                            'Get-ComSecurityDescriptor',
                            'Get-DscError',
                            'Get-DscWinEvent',
                            'Get-FileShare',
                            'Get-FileSharePermission',
                            'Get-FirewallRule',
                            'Get-Group',
                            'Get-HttpUrlAcl',
                            'Get-IisApplication',
                            'Get-IisAppPool',
                            'Get-IisConfigurationSection',
                            'Get-IisHttpHeader',
                            'Get-IisHttpRedirect',
                            'Get-IisMimeMap',
                            'Get-IisSecurityAuthentication',
                            'Get-IisVersion',
                            'Get-IisWebsite',
                            'Get-IPAddress',
                            'Get-Msi',
                            'Get-MsmqMessageQueue',
                            'Get-MsmqMessageQueuePath',
                            'Get-PathProvider',
                            'Get-PathToHostsFile',
                            'Get-PerformanceCounter',
                            'Get-Permission',
                            'Get-PowerShellModuleInstallPath',
                            'Get-PowershellPath',
                            'Get-Privilege',
                            'Get-ProgramInstallInfo',
                            'Get-RegistryKeyValue',
                            'Get-ScheduledTask',
                            'Get-ServiceAcl',
                            'Get-ServiceConfiguration',
                            'Get-ServicePermission',
                            'Get-ServiceSecurityDescriptor',
                            'Get-SslCertificateBinding',
                            'Get-TrustedHost',
                            'Get-User',
                            'Get-WindowsFeature',
                            'Get-WmiLocalUserAccount',
                            'Grant-ComPermission',
                            'Grant-HttpUrlPermission',
                            'Grant-MsmqMessageQueuePermission',
                            'Grant-Permission',
                            'Grant-Privilege',
                            'Grant-ServiceControlPermission',
                            'Grant-ServicePermission',
                            'Initialize-Lcm',
                            'Install-Certificate',
                            'Install-Directory',
                            'Install-FileShare',
                            'Install-Group',
                            'Install-IisApplication',
                            'Install-IisAppPool',
                            'Install-IisVirtualDirectory',
                            'Install-IisWebsite',
                            'Install-Junction',
                            'Install-Msi',
                            'Install-Msmq',
                            'Install-MsmqMessageQueue',
                            'Install-PerformanceCounter',
                            'Install-RegistryKey',
                            'Install-ScheduledTask',
                            'Install-Service',
                            'Install-User',
                            'Install-WindowsFeature',
                            'Invoke-AppCmd',
                            'Invoke-PowerShell',
                            'Join-IisVirtualPath',
                            'Lock-IisConfigurationSection',
                            'New-Credential',
                            'New-Junction',
                            'New-RsaKeyPair',
                            'New-TempDirectory',
                            'Protect-Acl',
                            'Protect-String',
                            'Read-File',
                            'Remove-DotNetAppSetting',
                            'Remove-EnvironmentVariable',
                            'Remove-GroupMember',
                            'Remove-HostsEntry',
                            'Remove-IisMimeMap',
                            'Remove-IniEntry',
                            'Remove-Junction',
                            'Remove-RegistryKeyValue',
                            'Remove-SslCertificateBinding',
                            'Reset-HostsFile',
                            'Reset-MsmqQueueManagerID',
                            'Resolve-FullPath',
                            'Resolve-Identity',
                            'Resolve-IdentityName',
                            'Resolve-NetPath',
                            'Resolve-PathCase',
                            'Resolve-RelativePath',
                            'Restart-RemoteService',
                            'Revoke-ComPermission',
                            'Revoke-HttpUrlPermission',
                            'Revoke-Permission',
                            'Revoke-Privilege',
                            'Revoke-ServicePermission',
                            'Set-DotNetAppSetting',
                            'Set-DotNetConnectionString',
                            'Set-EnvironmentVariable',
                            'Set-HostsEntry',
                            'Set-IisHttpHeader',
                            'Set-IisHttpRedirect',
                            'Set-IisMimeMap',
                            'Set-IisWebsiteID',
                            'Set-IisWebsiteSslCertificate',
                            'Set-IisWindowsAuthentication',
                            'Set-IniEntry',
                            'Set-RegistryKeyValue',
                            'Set-ServiceAcl',
                            'Set-SslCertificateBinding',
                            'Set-TrustedHost',
                            'Split-Ini',
                            'Start-DscPullConfiguration',
                            'Test-AdminPrivilege',
                            'Test-DotNet',
                            'Test-DscTargetResource',
                            'Test-FileShare',
                            'Test-FirewallStatefulFtp',
                            'Test-Group',
                            'Test-GroupMember',
                            'Test-Identity',
                            'Test-IisAppPool',
                            'Test-IisConfigurationSection',
                            'Test-IisSecurityAuthentication',
                            'Test-IisWebsite',
                            'Test-IPAddress',
                            'Test-MsmqMessageQueue',
                            'Test-NtfsCompression',
                            'Test-OSIs32Bit',
                            'Test-OSIs64Bit',
                            'Test-PathIsJunction',
                            'Test-PerformanceCounter',
                            'Test-PerformanceCounterCategory',
                            'Test-Permission',
                            'Test-PowerShellIs32Bit',
                            'Test-PowerShellIs64Bit',
                            'Test-Privilege',
                            'Test-RegistryKeyValue',
                            'Test-ScheduledTask',
                            'Test-Service',
                            'Test-SslCertificateBinding',
                            'Test-TypeDataMember',
                            'Test-UncPath',
                            'Test-User',
                            'Test-WindowsFeature',
                            'Test-ZipFile',
                            'Uninstall-Certificate',
                            'Uninstall-Directory',
                            'Uninstall-FileShare',
                            'Uninstall-Group',
                            'Uninstall-IisAppPool',
                            'Uninstall-IisWebsite',
                            'Uninstall-Junction',
                            'Uninstall-MsmqMessageQueue',
                            'Uninstall-PerformanceCounterCategory',
                            'Uninstall-ScheduledTask',
                            'Uninstall-Service',
                            'Uninstall-User',
                            'Uninstall-WindowsFeature',
                            'Unlock-IisConfigurationSection',
                            'Unprotect-String',
                            'Write-DscError',
                            'Write-File'
                        )

    # Cmdlets to export from this module
    CmdletsToExport = ''

    # Variables to export from this module
    VariablesToExport = ''

    # Aliases to export from this module
    AliasesToExport = '*'

    # List of all modules packaged with this module
    ModuleList = @()

    # List of all files packaged with this module
    FileList = @()

    # Private data to pass to the module specified in ModuleToProcess
    PrivateData = @{

        PSData = @{

            # Tags applied to this module. These help with module discovery in online galleries.
            Tags = @('.net','acl','active-directory','certificates','com','compression','computer','credential','cryptography','directory','dsc','dsc-resources','encryption','environment','file-system','firewall','groups','hosts-file','http','identity','iis','ini','installers','internet-explorer','ip','junctions','msi','msmq','netsh','networking','ntfs','operating-system','os','path','performance-counters','powershell','principal','privileges','programs','registry','rsa','scheduled-tasks','security','service','shares','sid','smb','ssl','text','trusted-host','users','wcf','windows','windows-features','xml','zip','PSModule','DscResources','setup','automation','admin')

            # A URL to the license for this module.
            LicenseUri = 'http://www.apache.org/licenses/LICENSE-2.0'

            # A URL to the main website for this project.
            ProjectUri = 'http://get-carbon.org/'

            # ReleaseNotes of this module
            ReleaseNotes = @'
## Enhancements

 * Aded a `LiteralPath` parameter to `Test-PathIsJunction` for testing paths that contain wildcard characters (e.g. `[`, `]`, etc.).
 * `Remove-Junction` now supports removing multiple junctions with wildcards.
 * Added a `LiteralPath` parameter to `Remove-Junction` for deleting junctions whose paths contain wildcard characters (e.g. `[`, `]`, etc.).
 * Added a `LiteralPath` parameter to `Uninstall-Junction` for deleting junctions whose paths contain wildcard characters (e.g. `[`, `]`, etc.).
 * Created `Remove-DotNetAppSetting` function for removing app settings from .NET framework machine.config files.
 * Created `Read-File` function for reading text files and retrying if the read fails. Good for reading files that get intermittently locked, like the Windows hosts file.
 * Created `Write-File` function for writing text files and retrying if the write fails. Good for writing files that get intermittently locked, like the Windows hosts file.
 * Made the following functions obsolete:
   * `Get-WindowsFeature`
   * `Install-Msmq`
   * `Install-WindowsFeature`
   * `Resolve-WindowsFeatureName`
   * `Uninstall-WindowsFeature`

## Bug Fixes

 * Fixed: `Add-GroupMember`, over PowerShell remoting, fails to add a member to groups that have non-local users/groups (fixes [issue #187: Add-GroupMember fails when using PowerShell Remoting](https://bitbucket.org/splatteredbits/carbon/issues/187/add-groupmember-fails-when-using))
 * Fixed: `Remove-GroupMember`, over PowerShell remoting, fails to remove a member from groups that have non-local users/groups.
 * Fixed: `Test-PathIsJunction` returns multiple results if the `Path` parameter contains wildcards and matches multiple items.
 * Fixed: `Install-Junction` can't install a junction whose path contains wildcard characters (fixes [issue #190](https://bitbucket.org/splatteredbits/carbon/issues/190/install-junction-fails-when-the-path)).
 * Fixed: `New-Junction` writes wrong error when creating an existing junction whose path contains wildcard characters.
 * Fixed: `Install-Service` doesn't update/change an existing service's account when using the `Credential` parameter (fixes [issue #185](https://bitbucket.org/splatteredbits/carbon/issues/185/install-service-never-updates-logon-as-if)).
 * Fixed: `Uninstall-FileShare` fails if a share's physical path doesn't exist.
 * Fixed (hopefully): `Get-FileSharePermission` writes an error if a share's security information is corrupted (fixes [issue #188](https://bitbucket.org/splatteredbits/carbon/issues/188/get-filesharepermission-crashes-when-a)). I was unable to reproduce the error, and the error was reported anonyously, so I did my best.
 * Fixed: `Get-PowerShellModuleInstallPath` returns multiple paths if the standard PowerShell module path is listed twice in the `PSModulePath` environment variable.
 * Fixed: Chocolatey package fails if the standard PowerShell module path is listed twice in the`PSModulePath` environment (fixes [issue #192](https://bitbucket.org/splatteredbits/carbon/issues/192/installation-of-carbon-via-chocolatey)).
 * Fixed: `Get-PowerShellModuleInstallPath` doesn't return the module install path if it doesn't exist. Sometimes it doesn't yet.
 * Fixed: `Carbon_ScheduledTask` and `Carbon_IniFile` DSC resources' `Get-TargetResource` functions don't return correct resource properties and causes `Get-DscConfiguration` to fail (fixes [issue #193](https://bitbucket.org/splatteredbits/carbon/issues/193/get-targetresource-returns-taskname-in-its)).
 * Fixed: `Carbon_FirewallRule` DSC resource always re-installs a firewall rule if `Profile` property contains multiple values (i.e. it doesn't properly parse netsh output).
 * Fixed: `about_Carbon_Installation` help topic had a typo.
 * Fixed: `Set-HostsEntry` fails to stop when the hosts file is in use and can't be read.
'@
        } # End of PSData hashtable
    
    } # End of PrivateData hashtable
}
