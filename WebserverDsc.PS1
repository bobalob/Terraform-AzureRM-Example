Start-Transcript -Path C:\Scripts\WebserverDsc.Log
Write-Host "Provisioning $($env:COMPUTERNAME)"

configuration LocalIIS {
    Import-DscResource -ModuleName 'PSDesiredStateConfiguration'
    Node $ComputerName {

        WindowsFeature IIS{
            Name = 'web-server'
            Ensure = 'Present'
        }
        
    }
}
$computername = 'localhost'

LocalIIS -OutputPath c:\DSC\Config

Start-DscConfiguration -Path C:\DSC\Config -ComputerName localhost

Write-Host "DSC Configuration Started."

Stop-Transcript
