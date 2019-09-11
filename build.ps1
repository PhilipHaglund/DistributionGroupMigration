[CmdletBinding(
    DefaultParameterSetName = 'Task'
)]
param(
    # Build task(s) to execute
    [Parameter(ParameterSetName = 'Task', Position = 0)]
    [string[]]$Task = @('Test', 'BuildHelp', 'GenerateHelpFiles'),

    # Bootstrap dependencies
    [switch]$Bootstrap,

    # List available build tasks
    [Parameter(ParameterSetName = 'Help')]
    [switch]$Help
)

$ErrorActionPreference = 'Stop'

# Bootstrap dependencies
if ($Bootstrap.IsPresent) {
    Get-PackageProvider -Name Nuget -ForceBootstrap > $null
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
    if (-not (Get-Module -Name PSDepend -ListAvailable)) {
        Install-Module -Name PSDepend -Repository PSGallery -Scope CurrentUser -Force
    }
    Import-Module -Name PSDepend -Verbose:$false
    Invoke-PSDepend -Path './requirements.psd1' -Install -Import -Force -WarningAction SilentlyContinue
}

# Execute psake task(s)
$PSakeFile = './build.psake.ps1'
if ($PSCmdlet.ParameterSetName -eq 'Help') {
    Get-PSakeScriptTasks -buildFile $PSakeFile |
    Format-Table -Property Name, Description, Alias, DependsOn
}
else {
    Set-BuildEnvironment -Force -BuildOutput Release

    Invoke-psake -buildFile $PSakeFile -taskList $Task -nologo
    exit ( [int]( -not $psake.build_success ) )
}