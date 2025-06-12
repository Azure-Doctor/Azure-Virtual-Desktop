# Azure Virtual Desktop Starter Kit

> **Azure Doctor** : arrêtez de subir Azure, commencez à en profiter.

Ce dépôt renferme un script PowerShell qui déploie en une seule passe un environnement Azure Virtual Desktop (AVD) cloud-only avec Microsoft Entra ID Join. En quelques minutes, vous aurez :

- Les ressources réseau (RG, VNet, Subnet, NSG)
- Un workspace AVD, un host pool et son application group
- Une VM Windows 11 configurée en Session Host
- L’agent AVD et son Boot Loader installés sans RDP
- Les rôles RBAC essentiels attribués



## Contenu

| Fichier                     | Description                   |
|-----------------------------|-------------------------------|
| `avd-deploy-starterkit.ps1` | Script de déploiement complet |
| `README.md`                 | Ce guide                      |



## Variables principales

| Nom de variable | Description                                 | Exemple                           |
|-----------------|---------------------------------------------|-----------------------------------|
| `$RG`           | Nom du Resource Group Azure                 | `azdoc-avd-demo-rg`               |
| `$LOCATION`     | Région Azure cible                          | `westeurope`                      |
| `$VM_NAME`      | Nom de la VM Session Host                   | `azdocshvm01`                     |
| `$UPN`          | UPN Azure AD de l'utilisateur final         | `prenom.nom@mondomaine.fr`        |
| `$IMAGE`        | Image Windows utilisée pour la VM           | `win11-22h2-avd`                  |



Principe d’exécution
1- Modules Az Vérifier et importer les modules PowerShell Az requis pour interagir avec Azure.

2- Infrastructure de base Créer le groupe de ressources, le réseau virtuel, le sous-réseau et le groupe de sécurité réseau.

3- Configuration AVD Déployer l’espace de travail AVD, le host pool et le groupe d’applications Desktop.

4- Token d’enregistrement Générer un token valide 24 heures pour enregistrer automatiquement la VM dans le host pool.

5- Provisionnement de la VM Créer une VM Windows 11 avec identité managée, configurer l’OS et la connecter au réseau.

5- Entra ID Join Installer l’extension AADLoginForWindows pour joindre la VM à Microsoft Entra ID.

6- Installation de l’agent AVD Exécuter en VM le script qui télécharge et installe l’agent AVD et le Boot Loader, puis redémarrer le service RDAgentBootLoader.

7- Assignation des rôles Attribuer les rôles Virtual Machine User Login et Desktop Virtualization User.

---

## Prérequis

- PowerShell avec modules Az (`Az.Accounts`, `Az.DesktopVirtualization`, etc.)
- Accès au portail Azure avec rôle **Contributor** minimum
- Port sortant TCP 443 vers `*.wvd.microsoft.com` et `*.trafficmanager.net`
- Un UPN Azure valide (Azure AD ou Entra ID)

---

## Démarrage rapide

```powershell
# Se connecter à Azure
Connect-AzAccount

# Lancer le script
./avd-deploy-starterkit.ps1
Personnalisez les variables en haut de script si nécessaire (noms, région, mot de passe, UPN…).

## Vérification post-déploiement

1. Accéder à Azure Portal → Azure Virtual Desktop → Host Pools  
2. Vérifier que la VM est visible comme Session Host dans le host pool  
3. Tester la connexion via le client AVD ou le web client  
4. Confirmer que l’utilisateur `$UPN` voit bien un bureau publié  
5. Contrôler l’état du service `RDAgentBootLoader` (via run-command ou portail)



## Diagnostic rapide

| Symptôme                   | Cause possible                       | Action recommandée                                          |
|----------------------------|--------------------------------------|-------------------------------------------------------------|
| VM absente du host pool    | Token expiré                         | Regénérer (étape 4) et relancer l’installation              |
| RDP bloqué par MFA         | Extension refusée par CA             | Vérifier et adapter les politiques Conditional Access        |
| Profil FSLogix introuvable | Droits de partage insuffisants       | Ajouter le rôle **Storage File Data SMB Share Contributor** |



## Nettoyer l’environnement (optionnel)

```powershell
# Supprime toutes les ressources associées
Remove-AzResourceGroup -Name "azdoc-avd-demo-rg" -Force


Prescrit par Azure Doctor 🩺
« Le cloud, sans surcharge mentale »
