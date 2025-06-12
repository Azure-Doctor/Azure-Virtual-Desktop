<#
.SYNOPSIS
    Télécharge puis installe l’Azure Virtual Desktop Agent + Boot Loader
    à l’intérieur d’un Session Host *Microsoft Entra ID-join*.

.PARAMETER RegistrationToken
    Token d’enregistrement généré via l’étape 6 de ton script bash.
#>

param(
    [Parameter(Mandatory)]
    [string]$RegistrationToken
)

# -------- VARIABLES ---------------------------------------------------------
$AgentUrl       = 'https://go.microsoft.com/fwlink/?linkid=2310011'   # AVD Agent MSI
$BootLoaderUrl  = 'https://go.microsoft.com/fwlink/?linkid=2311028'   # Boot Loader MSI
$Temp           = 'C:\Temp';   New-Item $Temp -ItemType Directory -EA SilentlyContinue | Out-Null
$Logs           = 'C:\Logs';   New-Item $Logs -ItemType Directory -EA SilentlyContinue | Out-Null
$AgentMsi       = Join-Path $Temp 'AVDAgentInstaller.msi'
$BootMsi        = Join-Path $Temp 'BootLoaderInstaller.msi'
$AgentLog       = Join-Path $Logs 'AVDAgentInstall.log'
$BootLoaderLog  = Join-Path $Logs 'BootLoaderInstall.log'

# -------- DOWNLOAD ----------------------------------------------------------
Write-Host "⬇️  Téléchargement des MSI..."
Invoke-WebRequest -Uri $AgentUrl      -OutFile $AgentMsi      -UseBasicParsing
Invoke-WebRequest -Uri $BootLoaderUrl -OutFile $BootMsi       -UseBasicParsing

# -------- INSTALL -----------------------------------------------------------
Write-Host " Installation de l’Agent AVD..."
Start-Process msiexec.exe -ArgumentList "/i `"$AgentMsi`"  /quiet /qn /l*v `"$AgentLog`" REGISTRATIONTOKEN=$RegistrationToken" -Wait

Write-Host "  Installation du Boot Loader..."
Start-Process msiexec.exe -ArgumentList "/i `"$BootMsi`"    /quiet /qn /l*v `"$BootLoaderLog`""                                   -Wait

# -------- SERVICE CHECK -----------------------------------------------------
Write-Host " Redémarrage & vérification..."
Restart-Service RDAgentBootLoader -ErrorAction SilentlyContinue
Get-Service RDAgentBootLoader | Select-Object Status, StartType

Write-Host " Agents AVD installés avec succès."
