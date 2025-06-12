#!/bin/bash
 
# === CONFIGURATION GLOBALE ===
RG="a2i-avd-demo-rg"
LOCATION="westeurope"
VNET="a2i-avd-demo-vnet"
SUBNET="a2i-avd-demo-subnet"
AVD_VM="a2iavddemo01"
AVD_USER="azureadmin"
AVD_PASS="Password2025!"
IMAGE="MicrosoftWindowsDesktop:windows-11:win11-22h2-avd:latest"
 
# === 0. CREATION RG + VNET ===
az group create --name "$RG" --location "$LOCATION"
 
az network vnet create \
  --resource-group "$RG" \
  --name "$VNET" \
  --address-prefix 10.100.0.0/16 \
  --subnet-name "$SUBNET" \
  --subnet-prefix 10.100.0.0/24
 
# === 5. CRÉATION AVD (Workspace, Pool, AppGroup) ===
WORKSPACE="a2i-avd-demo-workspace"
POOL="a2i-avd-demo-pool"
AG="$POOL-appgroup"
 
az desktopvirtualization workspace create \
  --resource-group "$RG" \
  --location "$LOCATION" \
  --name "$WORKSPACE" \
  --friendly-name "$WORKSPACE"
 
az desktopvirtualization hostpool create \
  --resource-group "$RG" \
  --location "$LOCATION" \
  --name "$POOL" \
  --friendly-name "$POOL" \
  --host-pool-type "Pooled" \
  --load-balancer-type "BreadthFirst" \
  --preferred-app-group-type "Desktop"
 
az desktopvirtualization applicationgroup create \
  --resource-group "$RG" \
  --location "$LOCATION" \
  --host-pool-arm-path "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$RG/providers/Microsoft.DesktopVirtualization/hostPools/$POOL" \
  --name "$AG" \
  --application-group-type "Desktop" \
  --friendly-name "$AG"
 
az desktopvirtualization workspace update \
  --resource-group "$RG" \
  --name "$WORKSPACE" \
  --application-group-references "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$RG/providers/Microsoft.DesktopVirtualization/applicationGroups/$AG"
 
# === 6. TOKEN AVD ===
TOKEN=$(az desktopvirtualization hostpool update \
  --resource-group "$RG" \
  --name "$POOL" \
  --registration-info expiration-time="$(date -u -d '+1 day' +"%Y-%m-%dT%H:%M:%SZ")" registration-token-operation="Update" \
  --query "registrationInfo.token" -o tsv)

# == IMANE DOIT REVOIR CETTE PARTIE ===
 
# === 7. VM AVD ===
az vm create \
  --resource-group "$RG" \
  --name "$AVD_VM" \
  --image "$IMAGE" \
  --size "Standard_D2s_v3" \
  --admin-username "$AVD_USER" \
  --admin-password "$AVD_PASS" \
  --vnet-name "$VNET" \
  --subnet "$SUBNET" \
  --assign-identity \
  --location "$LOCATION" \
  --public-ip-sku Standard \
  --nsg ""
 
# === 8. ROLE AVD SUR LA VM ===
PRINCIPAL_ID=$(az vm show -g "$RG" -n "$AVD_VM" --query "identity.principalId" -o tsv)
az role assignment create \
  --assignee "$PRINCIPAL_ID" \
  --role "Desktop Virtualization User" \
  --scope "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$RG"
 
 
# === 10. INSTALL AGENTS AVD ===
az vm run-command invoke \
  --resource-group "$RG" \
  --name "$AVD_VM" \
  --command-id RunPowerShellScript \
  --scripts "
\$agentUrl = 'https://go.microsoft.com/fwlink/?linkid=2310011'
\$bootloaderUrl = 'https://go.microsoft.com/fwlink/?linkid=2311028'
\$agentPath = 'C:\\AVDAgentInstaller.msi'
\$bootloaderPath = 'C:\\BootLoaderInstaller.msi'
 
Invoke-WebRequest -Uri \$agentUrl -OutFile \$agentPath -UseBasicParsing
Invoke-WebRequest -Uri \$bootloaderUrl -OutFile \$bootloaderPath -UseBasicParsing
 
Start-Process msiexec.exe -ArgumentList \"/i \$agentPath /quiet /l*v C:\\AVDAgentInstall.log REGISTRATIONTOKEN=$TOKEN\" -Wait
Start-Process msiexec.exe -ArgumentList \"/i \$bootloaderPath /quiet /l*v C:\\BootLoader.log\" -Wait
 
Restart-Service RDAgentBootLoader -ErrorAction SilentlyContinue
"
 
echo "✅ Déploiement AVD terminé avec succès 🚀"