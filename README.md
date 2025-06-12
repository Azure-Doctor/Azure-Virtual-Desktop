Azure Virtual Desktop Starter Kit

Ce dépôt contient un script PowerShell pour déployer un environnement Azure Virtual Desktop (AVD) cloud-only avec Microsoft Entra ID Join. Le script crée les ressources Azure nécessaires, configure une VM Windows 11 en Session Host, installe l’agent AVD et le Boot Loader, puis attribue les rôles RBAC requis sans aucune connexion RDP.

Contenu

Fichier

Description

avd-deploy-starterkit.ps1

Script complet de déploiement

README.md

Document de référence

Aperçu du script

Vérification et import des modules PowerShell Az

Création du groupe de ressources, du réseau virtuel, du sous-réseau et du groupe de sécurité réseau

Déploiement de l’espace de travail AVD, du host pool et du groupe d’applications Bureau

Génération d’un token d’enregistrement valide 24 h

Provisionnement d’une VM Windows 11 avec identité managée

Ajout de l’extension AADLoginForWindows pour rejoindre Microsoft Entra ID

Exécution d’un script à l’intérieur de la VM pour télécharger et installer l’agent AVD et le Boot Loader

Attribution des rôles :

Virtual Machine User Login (sur la VM)

Desktop Virtualization User (sur le groupe d’applications)

Prérequis

Az PowerShell 10.4 ou ultérieur

Rôle Contributor (ou supérieur) sur la souscription

Accès sortant TCP 443 vers *.wvd.microsoft.com et *.trafficmanager.net

Démarrage rapide

# Connexion à Azure
Connect-AzAccount

# Exécution du script
./avd-deploy-starterkit.ps1

Personnalisez les variables dans la section 0. CONFIGURATION en tête du script (noms, région, taille de VM, mot de passe, UPN).

Résolution de problèmes

Symptôme

Cause

Solution

Session Host absent du host pool

Token expiré avant installation de l’agent

Regénérer le token (section 4) et relancer section 7

Connexion en boucle MFA

Conditional Access bloque l’extension AADLogin

Vérifier les politiques Conditional Access

Profil FSLogix non monté

Permissions de stockage insuffisantes

Ajouter le rôle Storage File Data SMB Share Contributor

Roadmap

Modèle Bicep pour déploiement CI/CD

Module optionnel MSIX App Attach

Publié par Azure Doctor — Azure sans surcharge.
