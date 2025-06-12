<!-- README.md -->

<img align="right" src="https://1.bp.blogspot.com/-4cExxWC9Wpo/YG71Y14tmLI/AAAAAAAAFMs/bhXFN9oT9_Ew2RTB71kwsZ2lY93bauHeACLcBGAsYHQ/s320/ninja-transparent.png" alt="Azure Ninja" />

# Azure Virtual Desktop • A2I Lab

Ce dépôt héberge les scripts et templates nécessaires pour déployer et gérer rapidement un environnement **Azure Virtual Desktop (AVD)** 100 % cloud‑only (Microsoft Entra ID join).

> « Stop au blabla, vive les scripts ! » — Azure Doctor 🩺



## 📄 Contenu du dépôt

| Fichier                    | Rôle                                                                | Points clefs                                                                                     |
| -------------------------- | ------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------ |
| **`avd-deploy.sh`**        | Déploiement **infrastructure AVD** *(bash + Azure CLI)*             | Resource Group, VNet/Subnet, Workspace, Host Pool, App Group, génération du *registration token* |
| **`Install-AVDAgent.ps1`** | Installation **Agent AVD + Boot Loader** *(PowerShell Run‑Command)* | Télécharge les MSI, installation silencieuse, injection du token, redémarrage service            |
| **`README.md`**            | Documentation                                                       | Cette page : vision, pré‑requis, guides                                                          |
| **`.bicep`** *(à venir)*   | Templates IaC                                                       | Provisioning Workspace / Host Pool en pur IaC                                                    |



## 1️⃣ Vision globale

> Déployer AVD ne devrait pas être un parcours du combattant.
> **Objectif : un lab prêt en **< 15 min.

```mermaid
graph TD;
    subgraph Réseau
        VNet[VNet 10.100.0.0/16]
        Subnet[Subnet AVD 10.100.0.0/24]
    end
    Workspace --> HostPool
    HostPool -->|token| SessionHost
    SessionHost --> AzureFiles[(FSLogix)]
    classDef res fill:#2563eb,stroke:#fff,color:#fff;
    class VNet,Subnet res;
```



## 2️⃣ Scripts détaillés

 `avd-deploy.sh` 

Déploie l’infrastructure socle :

1. **Resource Group** & **VNet/Subnet**
2. **Workspace**, **Host Pool**, **App Group** (Desktop)
3. Génère un **token d’enregistrement** (validité 24 h)
4. Laisse un *placeholder* pour les Session Hosts, à remplacer par des VM **Entra ID join**

> **Pourquoi bash ?** Rapide, portable (macOS, WSL, Cloud Shell) et lisible (pas de boucles obscures — sauf pour les RDSH si besoin).



### `Install-AVDAgent.ps1` 

Installe l’Agent AVD et le Boot Loader à l’intérieur d’un Session Host \*
Microsoft Entra ID‑join\* — sans ouverture de session RDP :

```powershell
<# Synopsis : voir le script complet dans le dépôt #>

param(
    [Parameter(Mandatory)]
    [string]$RegistrationToken,
    [string]$AgentUrl      = 'https://go.microsoft.com/fwlink/?linkid=2310011',
    [string]$BootLoaderUrl = 'https://go.microsoft.com/fwlink/?linkid=2311028'
)
# Téléchargement, installation silencieuse + logs, restart service…
```

Étapes clés :

| # | Action             | Détails                                                 |
| - | ------------------ | ------------------------------------------------------- |
| 1 | **Download MSI**   | Depuis `$AgentUrl` & `$BootLoaderUrl` vers `C:\Temp`    |
| 2 | **Silent install** | `msiexec /quiet … REGISTRATIONTOKEN=$RegistrationToken` |
| 3 | **Health check**   | Redémarre & vérifie `RDAgentBootLoader`                 |

> Appelé via *az vm run-command*, il n’exige aucun port RDP ouvert.



## 3️⃣ Pré‑requis

| Élément                   | Version / Remarque                                           |
| ------------------------- | ------------------------------------------------------------ |
| **Azure CLI**             | `>= 2.61` + extension `desktopvirtualization`                |
| **PowerShell**            | 5.x ou 7.x sur la VM                                         |
| **Rôles Azure**           | `Owner` ou `Contributor` sur la souscription                 |
| **Connectivité sortante** | Port 443 vers `*.wvd.microsoft.com` & `*.trafficmanager.net` |
| **Token AVD**             | Valide (< 24 h) lors de l’installation des agents            |



## 4️⃣ Guide rapide

```bash
# 1. Login & déploiement de l’infra
az login
chmod +x avd-deploy.sh
./avd-deploy.sh

# 2. Création d’un Session Host (Entra ID join)
az vm create \
  --resource-group a2i-avd-demo-rg --name avd-host01 \
  --image MicrosoftWindowsDesktop:windows-11:win11-22h2-avd:latest \
  --size Standard_D2s_v3 --assign-identity \
  --enable-agent --enable-vtpm --enable-secure-boot \
  --vnet-name a2i-avd-demo-vnet --subnet a2i-avd-demo-subnet

# 3. Extension AAD Login
a z vm extension set --publisher Microsoft.Azure.ActiveDirectory \
  --name AADLoginForWindows --resource-group a2i-avd-demo-rg \
  --vm-name avd-host01

# 4. Installation des agents AVD (inside VM)
az vm run-command invoke \
  --resource-group a2i-avd-demo-rg \
  --name avd-host01 \
  --command-id RunPowerShellScript \
  --scripts @./Install-AVDAgent.ps1 \
  --parameters RegistrationToken="<token>"
```



## 5️⃣ Troubleshooting express

| Symptôme                | Diagnostic                          | Remède                                                          |
| ----------------------- | ----------------------------------- | --------------------------------------------------------------- |
| **Agent not reporting** | Token expiré                        | Regénérer le token (`avd-deploy.sh` étape 3)                    |
| **RDP → loop MFA**      | Conditional Access bloque AAD Login | Vérifier la policy CA                                           |
| **FSLogix KO**          | SMB non accessible                  | Rôle **Storage File Data SMB Share Contributor** sur le partage |



## 6️⃣ Roadmap

* [ ] **Bicep** : template complet Workspace / Host Pool
* [ ] **Pipeline DevOps** : déploiement CI/CD
* [ ] Scripts **MSIX App Attach** façon Azure Doctor



## 🤝 Contribuer

Les PR sont bienvenues !

> *« Ensemble, faisons respirer Azure. » — Azure Doctor*



Créé avec ❤️ par **Azure Doctor** pour la communauté A2I.
