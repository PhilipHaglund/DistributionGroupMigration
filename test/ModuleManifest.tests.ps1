$ModuleName = $env:BHProjectName
$Manifest = Import-PowerShellDataFile -Path $env:BHPSModuleManifest
$OutputDir = Join-Path -Path $ENV:BHProjectPath -ChildPath 'Release'
$OutputModDir = Join-Path -Path $OutputDir -ChildPath $env:BHProjectName
$OutputManifestPath = Join-Path -Path $OutputModDir -Child "$($ModuleName).psd1"
$ChangelogPath = Join-Path -Path $env:BHProjectPath -Child 'CHANGELOG.md'

Describe 'Module manifest' {
    Context 'Validation' {

        $script:Manifest = $null

        It 'has a valid manifest' {
            {
                $script:Manifest = Test-ModuleManifest -Path $OutputManifestPath -Verbose:$false -ErrorAction Stop -WarningAction SilentlyContinue
            } | Should Not Throw
        }

        It 'has a valid name in the manifest' {
            $script:Manifest.Name | Should Be $env:BHProjectName
        }

        It 'has a valid root module' {
            $script:Manifest.RootModule | Should Be "$($ModuleName).psm1"
        }

        It 'has a valid version in the manifest' {
            $script:Manifest.Version -as [Version] | Should Not BeNullOrEmpty
        }

        It 'has a valid description' {
            $script:Manifest.Description | Should Not BeNullOrEmpty
        }

        It 'has a valid author' {
            $script:Manifest.Author | Should Not BeNullOrEmpty
        }

        It 'has a valid guid' {
            {
                [guid]::Parse($script:Manifest.Guid)
            } | Should Not throw
        }

        It 'has a valid copyright' {
            $script:Manifest.CopyRight | Should Not BeNullOrEmpty
        }
    }
}
