<#
.SYNOPSIS
Creates the get-carbon.org website.

.DESCRIPTION
The `New-Website.ps1` script generates the get-carbon.org website. It uses the Silk module for Markdown to HTML conversion.
#>

# Copyright 2012 Aaron Jensen
# 
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

[CmdletBinding()]
param(
    [Switch]
    # Skips generating the command help.
    $SkipCommandHelp
)

#Requires -Version 4
Set-StrictMode -Version 'Latest'

function Out-HtmlPage
{
    param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        # The contents of the page.
        $Content,

        [Parameter(Mandatory=$true)]
        # The title of the page.
        $Title,

        [Parameter(Mandatory=$true)]
        # The path under the web root of the page.
        $VirtualPath
    )

    begin
    {
        Set-StrictMode -Version 'Latest'
    }

    process
    {

        $webRoot = Join-Path -Path $PSScriptRoot -ChildPath 'Website'
        $path = Join-Path -Path $webRoot -ChildPath $VirtualPath
        $templateArgs = @(
                            $Title,
                            $Content,
                            (Get-Date).Year
                        )
        @'
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
    <title>{0}</title>
	<link href="/styles.css" type="text/css" rel="stylesheet" />
</head>
<body>

    <ul id="SiteNav">
		<li><a href="/">Get-Carbon</a></li>
        <li><a href="/help/about_Carbon_Installation.html">-Install</a></li>
		<li><a href="/help/index.html">-Documentation</a></li>
        <li><a href="/releasenotes.html">-ReleaseNotes</a></li>
		<li><a href="http://pshdo.com">-Blog</a></li>
    </ul>

    {1}

	<div class="Footer">
		Copyright &copy; 2012 - {2} <a href="http://pshdo.com">Aaron Jensen</a>.  All rights reserved.
	</div>

</body>
</html>
'@ -f $templateArgs | Set-Content -Path $path
    }

    end
    {
    }
}


& (Join-Path -Path $PSScriptRoot -ChildPath '.\Tools\Silk\Import-Silk.ps1' -Resolve)

if( (Get-Module -Name 'Blade') )
{
    Remove-Module 'Blade'
}

& (Join-Path -Path $PSScriptRoot -ChildPath '.\Carbon\Import-Carbon.ps1' -Resolve) -Force

$headingMap = @{
                    'NEW DSC RESOURCES' = 'New DSC Resources';
                    'ADDED PASSTHRU PARAMETERS' = 'Added PassThru Parameters';
                    'SWITCH TO SYSTEM.DIRECTORYSERVICES.ACCOUNTMANAGEMENT API FOR USER/GROUP MANAGEMENT' = 'Switch To System.DirectoryServices.AccountManagement API For User/Group Management';
                    'INSTALL FROM ZIP ARCHIVE' = 'Install From ZIP Archive';
                    'INSTALL FROM POWERSHELL GALLERY' = 'Install From PowerShell Gallery';
                    'INSTALL WITH NUGET' = 'Install With NuGet';
               }

$help = Convert-ModuleHelpToHtml -ModuleName 'Carbon' -HeadingMap $headingMap -SkipCommandHelp:$SkipCommandHelp |
            ForEach-Object {
                $_.Html | Out-HtmlPage -Title ('PowerShell - {0} - Carbon' -f $_.Name) -VirtualPath ('/help/{0}.html' -f $_.Name)
                $_
            }

New-ModuleHelpIndex -TagsJsonPath (Join-Path -Path $PSScriptRoot -ChildPath 'tags.json') -ModuleName 'Carbon' |
     Out-HtmlPage -Title 'PowerShell - Carbon Module Documentation' -VirtualPath '/help/index.html'

$carbonTitle = 'Carbon: PowerShell DevOps module for configuring and setting up Windows computers, applications, and websites'
Get-Item -Path (Join-Path -Path $PSScriptRoot -ChildPath 'Carbon\about_Carbon.help.txt') |
    Convert-AboutTopicToHtml -ModuleName 'Carbon' |
    ForEach-Object {
        $text = $_ -replace '<a href="([^/]+)\.html">([^<]+)</a>','<a href="/help/$1.html">$2</a>'
        $text -replace '<h1>about_Carbon</h1>','<h1>Carbon</h1>'
    } |
    Out-HtmlPage -Title $carbonTitle -VirtualPath '/index.html'

Get-Content -Path (Join-Path -Path $PSScriptRoot -ChildPath 'RELEASE NOTES.txt') -Raw | 
    Edit-HelpText -ModuleName 'Carbon' |
    Convert-MarkdownToHtml | 
    Out-HtmlPage -Title ('Release Notes - {0}' -f $carbonTitle) -VirtualPath '/releasenotes.html'

