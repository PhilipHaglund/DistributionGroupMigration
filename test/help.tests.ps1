# Taken with love from @juneb_get_help (https://raw.githubusercontent.com/juneb/PesterTDD/master/Module.Help.Tests.ps1)

$OutputDir = Join-Path -Path $env:BHProjectPath -ChildPath 'Release'
$OutputModDir = Join-Path -Path $outputDir -ChildPath $env:BHProjectName
$Manifest = Import-PowerShellDataFile -Path $env:BHPSModuleManifest

# Get module commands
# Remove all versions of the module from the session. Pester can't handle multiple versions.
# Get-Module $env:BHProjectName | Remove-Module -Force
# Import-Module -Name (Join-Path -Path $OutputModDir -ChildPath "$($env:BHProjectName).psd1") -Verbose:$false -ErrorAction Stop
$Commands = Get-Command -Module (Get-Module $env:BHProjectName) -CommandType Cmdlet, Function, Workflow  # Not alias

## When testing help, remember that help is cached at the beginning of each session.
## To test, restart session.

foreach ($Command in $Commands) {
    $CommandName = $Command.Name

    # The module-qualified command fails on Microsoft.PowerShell.Archive cmdlets
    $Help = Get-Help $CommandName -ErrorAction SilentlyContinue

    Describe "Test help for $CommandName" {

        # If help is not found, synopsis in auto-generated help is the syntax diagram
        It 'should not be auto-generated' {
            $Help.Synopsis | Should Not BeLike '*`[`<CommonParameters`>`]*'
        }

        # Should be a description for every function
        It "gets description for $CommandName" {
            $Help.Description | Should Not BeNullOrEmpty
        }

        # Should be at least one example
        It "gets example code from $CommandName" {
            ($Help.Examples.Example | Select-Object -First 1).Code | Should Not BeNullOrEmpty
        }

        # Should be at least one example description
        It "gets example help from $CommandName" {
            ($Help.Examples.Example.Remarks | Select-Object -First 1).Text | Should Not BeNullOrEmpty
        }

        Context "Test parameter help for $CommandName" {

            $Common = 'Debug', 'ErrorAction', 'ErrorVariable', 'InformationAction', 'InformationVariable', 'OutBuffer',
            'OutVariable', 'PipelineVariable', 'Verbose', 'WarningAction', 'WarningVariable', 'Confirm', 'Whatif'

            $Parameters = $command.ParameterSets.Parameters |
            Sort-Object -Property Name -Unique |
            Where-Object { $_.Name -notin $Common }
            $ParameterNames = $Parameters.Name

            ## Without the filter, WhatIf and Confirm parameters are still flagged in "finds help parameter in code" test
            $HelpParameters = $Help.Parameters.Parameter |
            Where-Object { $_.Name -notin $Common } |
            Sort-Object -Property Name -Unique
            $HelpParameterNames = $HelpParameters.Name

            foreach ($Parameter in $Parameters) {
                $ParameterName = $Parameter.Name
                $ParameterHelp = $Help.parameters.parameter | Where-Object Name -EQ $ParameterName

                # Should be a description for every parameter
                It "gets help for parameter: $ParameterName : in $CommandName" {
                    $ParameterHelp.Description.Text | Should Not BeNullOrEmpty
                }

                # Required value in Help should match IsMandatory property of parameter
                It "help for $ParameterName parameter in $CommandName has correct Mandatory value" {
                    $CodeMandatory = $Parameter.IsMandatory.ToString()
                    $ParameterHelp.Required | Should Be $CodeMandatory
                }

                # Parameter type in Help should match code
                # It "help for $CommandName has correct parameter type for $ParameterName" {
                #     $codeType = $Parameter.ParameterType.Name
                #     # To avoid calling Trim method on a null object.
                #     $HelpType = if ($ParameterHelp.parameterValue) { $ParameterHelp.parameterValue.Trim() }
                #     $HelpType | Should be $codeType
                # }
            }

            foreach ($HelpParm in $HelpParameterNames) {
                # Shouldn't find extra parameters in help.
                It "finds help parameter in code: $HelpParm" {
                    $HelpParm -in $ParameterNames | Should Be $true
                }
            }
        }

        #Context "Help Links should be Valid for $CommandName" {
        #    $link = $Help.relatedLinks.navigationLink.uri
#
        #    foreach ($link in $links) {
        #        if ($link) {
        #            # Should have a valid uri if one is provided.
        #            It "[$link] should have 200 Status Code for $CommandName" {
        #                $Results = Invoke-WebRequest -Uri $link -UseBasicParsing
        #                $Results.StatusCode | Should Be '200'
        #            }
        #        }
        #    }
        #}
    }
}