<!-- README.md -->
<img align="right" src="https://1.bp.blogspot.com/-4cExxWC9Wpo/YG71Y14tmLI/AAAAAAAAFMs/bhXFN9oT9_Ew2RTB71kwsZ2lY93bauHeACLcBGAsYHQ/s320/ninja-transparent.png" alt="Azure Ninja" />

# Azure Virtual Desktop • A2I Lab

Ce dépôt héberge les scripts et templates nécessaires pour **déployer** et **gérer** rapidement un environnement **Azure Virtual Desktop (AVD)** 100 % cloud-only (Microsoft Entra ID join).  
> *« Stop au blabla, vive les scripts ! » — Azure Doctor 🩺*



## 📄 Contenu du dépôt

| Fichier | Rôle | Points clefs |
|---------|------|--------------|
| **`avd-deploy.sh`** | Déploiement **infrastructure AVD** *(bash + Azure CLI)* | Resource Group, VNet/Subnet, Workspace, Host Pool, App Group, Token d’enregistrement |
| **`avd-agents.ps1`** | Installation **Agents AVD** *(PowerShell Run Command)* | Télécharge & installe l’Agent + Boot Loader, injecte le token, vérifie le service |
| **`README.md`** | Documentation | Cette page : vision, pré-requis, guide pas-à-pas |
| **`.bicep`** *(à venir)* | Templates IaC | Provisioning Workspace/Host Pool en pur IaC |


## 1️⃣ Vision globale

> Déployer AVD ne devrait pas être un parcours du combattant.  
> **Objectif** : un lab prêt en **< 15 min**.

```mermaid
graph TD;
    subgraph Réseau
        VNet[VNet 10.100.0.0/16]
        Subnet[Subnet AVD 10.100.0.0/24]
    end
    Workspace --> HostPool
    HostPool -->|token| SessionHost
    SessionHost --> AzureFiles[(FSLogix)]
    classDef res fill:#2563eb,stroke:#fff,color:#fff;
    class VNet,Subnet res;

2️⃣ Scripts détaillés
avd-deploy.sh 
Déploie l’infra-socle :

Resource Group & VNet/Subnet

Workspace, Host Pool, App Group (Desktop)

Génère le token d’enregistrement (24 h)

Placeholder VM — à remplacer par un Session Host Entra ID join

Pourquoi bash ?

Rapide à exécuter depuis n’importe quel terminal (macOS, WSL, Cloud Shell)

Lisibilité maximale (pas de boucles obscures sauf pour les RDSH si besoin)

avd-agents.ps1 💉
Installe l’Agent AVD et le Boot Loader sur un Session Host déjà :

Entra ID-join

Extension AADLoginForWindows installée

Connectivité HTTPS vers *.wvd.microsoft.com

Étapes :

powershell
Copier
# 1. Download MSI
Invoke-WebRequest -Uri $AgentUrl       -OutFile C:\Temp\AVDAgent.msi
Invoke-WebRequest -Uri $BootLoaderUrl  -OutFile C:\Temp\AVDBootLoader.msi

# 2. Silent install (+ token)
Start-Process msiexec -ArgumentList "/i C:\Temp\AVDAgent.msi /quiet REGISTRATIONTOKEN=$Token" -Wait
Start-Process msiexec -ArgumentList "/i C:\Temp\AVDBootLoader.msi /quiet" -Wait

# 3. Health check
Get-Service RDAgentBootLoader
3️⃣ Pré-requis
Élément	Version / Remarque
Azure CLI	>= 2.61 + extension desktopvirtualization
PowerShell	5.x ou 7.x sur la VM
Rôles Azure	Owner ou Contributor sur la souscription
Ports sortants	443 vers *.wvd.microsoft.com & *.trafficmanager.net
Token AVD	Valide (< 24 h) lors de l’installation des agents

4️⃣ Guide rapide
bash
Copier
# Login & déploiement infra
az login
chmod +x avd-deploy.sh
./avd-deploy.sh

# Création d'un Session Host (Entra ID join)
az vm create --resource-group a2i-avd-demo-rg --name avd-host01 \
  --image MicrosoftWindowsDesktop:windows-11:win11-22h2-avd:latest \
  --size Standard_D2s_v3 --assign-identity \
  --enable-agent --enable-vtpm --enable-secure-boot \
  --vnet-name a2i-avd-demo-vnet --subnet a2i-avd-demo-subnet

# Extension AAD Login
az vm extension set --publisher Microsoft.Azure.ActiveDirectory \
  --name AADLoginForWindows --resource-group a2i-avd-demo-rg \
  --vm-name avd-host01

# Installation Agents AVD
pwsh ./avd-agents.ps1 -VmName avd-host01 -Token "<token>"
5️⃣ Troubleshooting express
Symptôme	Diagnostic	Remède
Agent not reporting	Token expiré	Regénérer le token (avd-deploy.sh étape 6)
RDP > MFA loop	CA bloque AAD Login	Vérifier policy Conditional Access
FSLogix KO	SMB non accessible	Rôle Storage File Data SMB Share Contributor sur le partage

6️⃣ Roadmap
 Bicep : template complet Workspace / Host Pool

 Pipeline DevOps pour déploiement CI/CD

 Scripts MSIX App Attach façon Azure Doctor

🤝 Contribuer
Les PR sont bienvenues !

« Ensemble, faisons respirer Azure. » — Azure Doctor

Créé avec ❤️ par Azure Doctor pour la communauté A2I.
