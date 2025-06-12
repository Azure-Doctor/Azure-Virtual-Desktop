# Azure Virtual Desktop Starter Kit

> **Azure Doctor** : arrêtez de subir Azure, commencez à en profiter.

Ce dépôt renferme un script PowerShell qui déploie en une seule passe un environnement Azure Virtual Desktop (AVD) cloud-only avec Microsoft Entra ID Join. En quelques minutes, vous aurez :

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



##  Variables principales

| Nom de variable | Description                         | Exemple                     |
|-----------------|-------------------------------------|-----------------------------|
| `$RG`           | Nom du Resource Group Azure         | `azdoc-avd-demo-rg`         |
| `$LOCATION`     | Région Azure cible                  | `westeurope`                |
| `$VM_NAME`      | Nom de la VM Session Host           | `azdocshvm01`               |
| `$UPN`          | UPN Azure AD de l'utilisateur final | `prenom.nom@mondomaine.fr`  |
| `$IMAGE`        | Image Windows utilisée              | `win11-22h2-avd`            |



##  Principe d’exécution

1. **Modules Az**  
   Vérifie et importe les modules PowerShell requis.

2. **Infrastructure de base**  
   Crée le Resource Group, VNet, Subnet, NSG, IP publique.

3. **Configuration AVD**  
   Déploie l’espace de travail, le host pool et l’application group.

4. **Token d’enregistrement**  
   Génère un token valide 24h pour rattacher la VM au host pool.

5. **Provisionnement de la VM**  
   Déploie une VM Windows 11 avec identité managée et configuration réseau.

6. **Entra ID Join**  
   Active l’extension AADLoginForWindows pour intégrer la VM dans Entra ID.

7. **Installation de l’agent AVD**  
   Exécute dans la VM un script qui installe l’agent AVD et le boot loader.

8. **Assignation des rôles**  
   Attribue à l’utilisateur les rôles nécessaires :  
   - Virtual Machine User Login  
   - Desktop Virtualization User



##  Prérequis

- PowerShell avec les modules `Az.*` installés (`Az.Accounts`, `Az.DesktopVirtualization`, etc.)
- Accès Azure avec rôle **Contributor** minimum
- Port sortant 443 ouvert vers `*.wvd.microsoft.com` et `*.trafficmanager.net`
- Un compte utilisateur (UPN) valide dans Microsoft Entra ID

---

## ▶️ Démarrage rapide

```powershell
# Se connecter à Azure
Connect-AzAccount

# Lancer le script
./avd-deploy-starterkit.ps1
```
💡 Personnalisez les variables en haut du script (noms, région, mot de passe, UPN…).

 ##  Vérification post-déploiement
Accéder à Azure Portal → Azure Virtual Desktop → Host Pools

Vérifier que la VM apparaît bien comme Session Host

Tester la connexion via le client AVD ou le portail web

Confirmer que l’utilisateur $UPN voit bien un bureau publié

Vérifier que le service RDAgentBootLoader est en cours d’exécution

##  Diagnostic rapide

| Symptôme                     | Cause possible                       | Action recommandée                                              |
|------------------------------|--------------------------------------|-----------------------------------------------------------------|
| VM absente du host pool      | Token expiré                         | Regénérer le token (étape 4) et relancer l’agent AVD            |
| RDP bloqué par MFA           | Extension refusée par une policy CA | Vérifier et adapter les politiques Conditional Access           |
| Profil FSLogix introuvable   | Partage de fichiers mal configuré    | Ajouter le rôle **Storage File Data SMB Share Contributor**     |


## Nettoyer l’environnement (optionnel)
```powershell

Remove-AzResourceGroup -Name "azdoc-avd-demo-rg" -Force
```
##  Ressources utiles

Tu veux aller plus loin dans la maîtrise d’Azure ? Voici deux guides conçus pour t'accompagner concrètement :

 **Masterclass Azure RBAC – Guide ultime du consultant**  
Comprends (enfin) les rôles, scopes et permissions dans Azure. Tu découvriras comment sécuriser ton environnement cloud sans te perdre dans la matrice RBAC.  
📘 Format pratique, cas réels, astuces de terrain.

 **Masterclass Azure Cloud Shell – Guide ultime du consultant**  
Apprends à piloter ton infra 100 % en ligne, depuis n’importe quel navigateur. Commandes essentielles, scripts utiles, automatisation... tout ce qu’il faut pour ne plus dépendre de ton poste local.  
☁️ Optimisé pour les consultants pressés.

Ces deux eBooks sont disponibles sur [azuredoctor.fr](https://azuredoctor.fr/ebooks/) — un vrai kit de survie pour devenir autonome dans Azure.

---

Et bien sûr, les classiques à garder sous le coude :

- [Documentation AVD](https://learn.microsoft.com/fr-fr/azure/virtual-desktop/)
- [Microsoft Entra ID Join](https://learn.microsoft.com/fr-fr/azure/active-directory/devices/concept-azure-ad-join)
- [Rôles RBAC Azure](https://learn.microsoft.com/fr-fr/azure/role-based-access-control/built-in-roles)
- [Agent AVD (MSI)](https://go.microsoft.com/fwlink/?linkid=2310011)
- [Boot Loader AVD (MSI)](https://go.microsoft.com/fwlink/?linkid=2311028)


Prescrit par Azure Doctor 🩺
Le cloud, sans surcharge mentale.
