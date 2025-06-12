# ==============================================
# 🖥️ Azure Virtual Desktop - Starter Kit
# Auteur : Azure Doctor | https://azuredoctor.fr
# Date : Juin 2025
# ==============================================

# ===========================
# 0. CONFIGURATION
# ===========================
$RG         = "azdoc-avd-demo-rg"
$LOCATION   = "westeurope"
$VNET       = "azdoc-avd-demo-vnet"
$SUBNET     = "azdoc-avd-demo-subnet"
$VM_NAME    = "azdocshvm01"
$VM_SIZE    = "Standard_D2s_v3"
$AVD_USER   = "azureadmin"
$AVD_PASS   = ConvertTo-SecureString "Password@2025!" -AsPlainText -Force
$WORKSPACE  = "a2i-avd-workspace"
$POOL       = "a2i-avd-pool"
$APPGROUP   = "$POOL-appgroup"
$IMAGE      = "MicrosoftWindowsDesktop:windows-11:win11-22h2-avd:latest"

# 🔐 Remplace ici par ton vrai UPN Azure AD
$UPN        = "hicham@a2itechnologies.fr"

# ================================================
# 1. MODULES REQUIS
# ================================================
$requiredModules = @("Az.Accounts", "Az.Resources", "Az.Network", "Az.Compute", "Az.DesktopVirtualization")
foreach ($module in $requiredModules) {
    if (-not (Get-Module -ListAvailable -Name $module)) {
        Install-Module $module -Force -AllowClobber
    }
    Import-Module $module
}

# ================================================
# 2. INFRASTRUCTURE DE BASE
# ================================================
New-AzResourceGroup -Name $RG -Location $LOCATION -Force
$nsg = New-AzNetworkSecurityGroup -Name "$SUBNET-nsg" -ResourceGroupName $RG -Location $LOCATION
$subnetConfig = New-AzVirtualNetworkSubnetConfig -Name $SUBNET -AddressPrefix "10.150.0.0/24" -NetworkSecurityGroup $nsg
$vnet = New-AzVirtualNetwork -Name $VNET -ResourceGroupName $RG -Location $LOCATION -AddressPrefix "10.150.0.0/16" -Subnet $subnetConfig
$publicIp = New-AzPublicIpAddress -Name "$VM_NAME-pip" -ResourceGroupName $RG -Location $LOCATION -AllocationMethod Static -Sku Standard

# ================================================
# 3. AVD WORKSPACE + HOSTPOOL + APPGROUP
# ================================================
New-AzWvdWorkspace -ResourceGroupName $RG -Name $WORKSPACE -Location $LOCATION -FriendlyName $WORKSPACE
New-AzWvdHostPool -ResourceGroupName $RG -Name $POOL -Location $LOCATION -FriendlyName $POOL `
    -HostPoolType "Pooled" -LoadBalancerType "BreadthFirst" -PreferredAppGroupType "Desktop"
$hostPool = Get-AzWvdHostPool -ResourceGroupName $RG -Name $POOL
$appGroup = New-AzWvdApplicationGroup -ResourceGroupName $RG -HostPoolArmPath $hostPool.Id `
    -Name $APPGROUP -Location $LOCATION -FriendlyName $APPGROUP -ApplicationGroupType "Desktop"
Update-AzWvdWorkspace -ResourceGroupName $RG -Name $WORKSPACE -ApplicationGroupReference @($appGroup.Id)

# ================================================
# 4. TOKEN D’ENREGISTREMENT AVD
# ================================================
$TOKEN = (Update-AzWvdHostPool -ResourceGroupName $RG -Name $POOL `
    -RegistrationInfoExpirationTime (Get-Date).ToUniversalTime().AddDays(1) `
    -RegistrationInfoRegistrationTokenOperation "Update").RegistrationInfo.Token

# ================================================
# 5. CRÉATION NIC + VM
# ================================================
$subnetRef = Get-AzVirtualNetworkSubnetConfig -Name $SUBNET -VirtualNetwork $vnet
$nic = New-AzNetworkInterface -Name "$VM_NAME-nic" -ResourceGroupName $RG -Location $LOCATION `
    -SubnetId $subnetRef.Id -NetworkSecurityGroupId $nsg.Id -PublicIpAddressId $publicIp.Id

$vmConfig = New-AzVMConfig -VMName $VM_NAME -VMSize $VM_SIZE -IdentityType "SystemAssigned" | `
    Set-AzVMOperatingSystem -Windows -ComputerName $VM_NAME -Credential (New-Object PSCredential($AVD_USER, $AVD_PASS)) -ProvisionVMAgent -EnableAutoUpdate | `
    Set-AzVMSourceImage -PublisherName "MicrosoftWindowsDesktop" -Offer "windows-11" -Skus "win11-22h2-avd" -Version "latest" | `
    Add-AzVMNetworkInterface -Id $nic.Id -Primary | `
    Set-AzVMOSDisk -CreateOption FromImage

New-AzVM -ResourceGroupName $RG -Location $LOCATION -VM $vmConfig

# ================================================
# 6. EXTENSION ENTRA ID JOIN + REDÉMARRAGE
# ================================================
Set-AzVMExtension -ResourceGroupName $RG -VMName $VM_NAME `
  -Name "AADLoginForWindows" `
  -Publisher "Microsoft.Azure.ActiveDirectory" `
  -ExtensionType "AADLoginForWindows" `
  -TypeHandlerVersion "1.0" `
  -Location $LOCATION

Restart-AzVM -ResourceGroupName $RG -Name $VM_NAME
Start-Sleep -Seconds 30

# ================================================
# 7. INSTALLATION BOOTLOADER + AVD AGENT
# ================================================
$script = @"
`$agentUrl = 'https://go.microsoft.com/fwlink/?linkid=2310011'
`$bootloaderUrl = 'https://go.microsoft.com/fwlink/?linkid=2311028'
`$agentPath = 'C:\\AVDAgentInstaller.msi'
`$bootloaderPath = 'C:\\BootLoaderInstaller.msi'

Invoke-WebRequest -Uri `$agentUrl -OutFile `$agentPath -UseBasicParsing
Invoke-WebRequest -Uri `$bootloaderUrl -OutFile `$bootloaderPath -UseBasicParsing

Start-Process msiexec.exe -ArgumentList \"/i `$agentPath /quiet /l*v C:\\AVDAgentInstall.log REGISTRATIONTOKEN=$TOKEN\" -Wait
Start-Process msiexec.exe -ArgumentList \"/i `$bootloaderPath /quiet /l*v C:\\BootLoader.log\" -Wait

Restart-Service RDAgentBootLoader -ErrorAction SilentlyContinue
"@

Invoke-AzVMRunCommand -ResourceGroupName $RG -VMName $AVD_VM -CommandId 'RunPowerShellScript' -ScriptString $script


# ================================================
# 8. ASSIGNATION DES RÔLES
# ================================================
$aadUser = Get-AzADUser -UserPrincipalName $UPN

New-AzRoleAssignment -ObjectId $aadUser.Id -RoleDefinitionName "Virtual Machine User Login" -Scope "/subscriptions/$(Get-AzContext).Subscription.Id/resourceGroups/$RG/providers/Microsoft.Compute/virtualMachines/$VM_NAME"

New-AzRoleAssignment -ObjectId $aadUser.Id -RoleDefinitionName "Desktop Virtualization User" -Scope $appGroup.Id

# ===========================
#    FIN DU SCRIPT
# ===========================
Write-Host "`L'infrastructure AVD a été déployée avec succès"
