# Azure Virtual Desktop Starter Kit

> **Azure Doctor** : arrêtez de subir Azure, commencez à en profiter.

Ce dépôt renferme un script PowerShell qui déploie en une seule passe un environnement Azure Virtual Desktop (AVD) cloud-only avec Microsoft Entra ID Join. En quelques minutes, vous aurez :

* Les ressources réseau (RG, VNet, Subnet, NSG)
* Un workspace AVD, un host pool et son application group
* Une VM Windows 11 configurée en Session Host
* L’agent AVD et son Boot Loader installés sans RDP
* Les rôles RBAC essentiels attribués

## Contenu

| Fichier                     | Description                   |
| --------------------------- | ----------------------------- |
| `avd-deploy-starterkit.ps1` | Script de déploiement complet |
| `README.md`                 | Ce guide                      |

## Principe d’exécution

1. **Modules Az**
   Vérifier et importer les modules PowerShell Az requis pour interagir avec Azure.

2. **Infrastructure de base**
   Créer le groupe de ressources, le réseau virtuel, le sous-réseau et le groupe de sécurité réseau.

3. **Configuration AVD**
   Déployer l’espace de travail AVD, le host pool et le groupe d’applications Desktop.

4. **Token d’enregistrement**
   Générer un token valide 24 heures pour enregistrer automatiquement la VM dans le host pool.

5. **Provisionnement de la VM**
   Créer une VM Windows 11 avec identité managée, configurer l’OS et la connecter au réseau.

6. **Entra ID Join**
   Installer l’extension AADLoginForWindows pour joindre la VM à Microsoft Entra ID.

7. **Installation de l’agent AVD**
   Exécuter en VM le script qui télécharge et installe l’agent AVD et le Boot Loader, puis redémarrer le service RDAgentBootLoader.

8. **Assignation des rôles**
   Attribuer les rôles Virtual Machine User Login et Desktop Virtualization User.

## Prérequis

* Az PowerShell 10.4+ ou module Az installé
* Rôle **Contributor** (ou supérieur) sur la souscription
* Sortie TCP 443 vers `*.wvd.microsoft.com` et `*.trafficmanager.net`
* UPN Azure AD valide (variable `$UPN`)

## Démarrage rapide

```powershell
# Se connecter à Azure
Connect-AzAccount

# Lancer le déploiement
./avd-deploy-starterkit.ps1
```

Personnalisez les variables en début de script : noms, région, taille de VM, mot de passe, UPN.

## Diagnostic rapide

| Symptôme                   | Cause possible                       | Action recommandée                                          |
| -------------------------- | ------------------------------------ | ----------------------------------------------------------- |
| VM absente du host pool    | Token expiré                         | Regénérer (étape 4) et relancer l’installation de la VM     |
| RDP bloqué par MFA         | Extension AADLoginForWindows refusée | Ajuster les politiques Conditional Access                   |
| Profil FSLogix introuvable | Permissions de partage manquantes    | Ajouter le rôle **Storage File Data SMB Share Contributor** |

## Roadmap

* Template Bicep pour pipeline CI/CD
* Module MSIX App Attach optionnel

---

**Prescrit par Azure Doctor** 🩺  « Le cloud, sans surcharge mentale »
