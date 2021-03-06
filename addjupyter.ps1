$jpcommand = Get-Command jupyter.exe | Select-Object -ExpandProperty Definition

if($jpcommand -eq $null){
    Write-Output "Could not find jupyter.exe in environment path"
    Break
}

Write-Output $jpcommand

New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT

function createRegedit([string]$registryPath, [string]$value)
{
    $name = "(Default)"

    If(!(Test-Path $registryPath)){
        New-Item -Path $registryPath -Force | Out-Null    
    }
    
    New-ItemProperty -Path $registryPath -Name $name -Value $value `
        -PropertyType String -Force | Out-Null    
}

$openText = "Open Jupyter Notebook server here"

createRegedit "HKCR:\Directory\Background\shell\jupyter" $openText
createRegedit "HKCR:\Directory\shell\jupyter" $openText

$commandText = "`"" + $jpcommand + "`" `"notebook`" `"%V`""

createRegedit "HKCR:\Directory\Background\shell\jupyter\command" $commandText
createRegedit "HKCR:\Directory\shell\jupyter\command" $commandText

$currentPath = (Get-Item -Path ".\" -Verbose).FullName

#change to favicon-notebook.ico for alternative icon
$jpicon = "$($currentPath)\favicon.ico"

#set icons
New-ItemProperty -Path "HKCR:\Directory\Background\shell\jupyter" -Name "Icon" -Value $jpicon `
        -PropertyType String -Force | Out-Null    

New-ItemProperty -Path "HKCR:\Directory\shell\jupyter" -Name "Icon" -Value $jpicon `
        -PropertyType String -Force | Out-Null  
