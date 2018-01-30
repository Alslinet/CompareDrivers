

$ComputerModel = (Get-WMIObject Win32_COmputerSystem).Model
$CurrentDateTime = Get-Date –f "yyyyMMddHHmmss"
$CurrentDateTime.Year+$CurrentDateTime.Day
$Path = $PSScriptRoot + "\" + $ComputerModel + "\" 
$Path
if (Get-Item $Path){
    #Do nothing
} else {
    #Path does not exist, create path
    New-Item $Path -ItemType Directory -Force 
}
$ExportFile = $PSScriptRoot +"\" + $ComputerModel + "\" +$CurrentDateTime + ".csv"
$CurrentDrivers = Get-WmiObject Win32_PnPSignedDriver
$CurrentDrivers | Export-Csv $ExportFile -Force -NoTypeInformation

$DriverExports = Get-ChildItem $Path | sort Name -Descending
$Current = $DriverExports[0]
$Previous = $DriverExports[1]
$Original = $DriverExports | select -Last 1

$Current = Import-Csv $Current.FullName
$Previous = Import-Csv $Previous.FullName
$Original = Import-Csv $Original.FullName



Function CompareDrivers ($Old,$New) {
    $GroupedCompare = Compare-Object $Old $New -Property DeviceID,Description,DriverVersion,DriverDate
    $GroupedCompare | ForEach {
        if ($_.SideIndicator -eq "=>"){
            $_.SideIndicator = "Gammel"
            $_.DriverDate = [Management.ManagementDateTImeConverter]::ToDateTime($_.DriverDate)
        } elseif ($_.SideIndicator -eq "<="){
            $_.SideIndicator = "Ny"
            $_.DriverDate = [Management.ManagementDateTImeConverter]::ToDateTime($_.DriverDate)
        }
    }

    $GroupedCompare
}

CompareDrivers $Current $Previous
CompareDrivers $Current $Original
