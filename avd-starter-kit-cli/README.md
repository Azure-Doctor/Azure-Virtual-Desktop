<!-- README.md -->

# Azure Virtual Desktop Starter Kit

Ce dépôt contient un script PowerShell pour déployer un environnement Azure Virtual Desktop (AVD) cloud-only avec Microsoft Entra ID Join. Le script crée les ressources Azure nécessaires, configure une VM Windows 11 en Session Host, installe l’agent AVD et le Boot Loader, puis attribue les rôles RBAC requis sans aucune connexion RDP.

## Contenu

| Fichier                         | Description                                  |
|---------------------------------|----------------------------------------------|
| `avd-deploy-starterkit.ps1`     | Script complet de déploiement                |
| `README.md`                     | Document de référence                        |

## Aperçu du script

1. Vérification et import des modules PowerShell Az  
2. Création du groupe de ressources, du réseau virtuel, du sous-réseau et du groupe de sécurité réseau  
3. Déploiement de l’espace de travail AVD, du host pool et du groupe d’applications Bureau  
4. Génération d’un token d’enregistrement valide 24 h  
5. Provisionnement d’une VM Windows 11 avec identité managée  
6. Ajout de l’extension AADLoginForWindows pour rejoindre Microsoft Entra ID  
7. Exécution d’un script à l’intérieur de la VM pour télécharger et installer l’agent AVD et le Boot Loader  
8. Attribution des rôles :  
   - Virtual Machine User Login (sur la VM)  
   - Desktop Virtualization User (sur le groupe d’applications)  

## Prérequis

- Az PowerShell 10.4 ou ultérieur  
- Rôle **Contributor** (ou supérieur) sur la souscription  
- Accès sortant TCP 443 vers `*.wvd.microsoft.com` et `*.trafficmanager.net`  

## Démarrage rapide

```powershell
# Connexion à Azure
Connect-AzAccount

# Exécution du script
./avd-deploy-starterkit.ps1
