# 👋 Salut, et bienvenue dans l’AVD Starter Kit – CLI Edition

Tu veux déployer un environnement Azure Virtual Desktop sans y passer l’après-midi ?  
Voici un **kit Bash complet** pour déployer un environnement AVD de bout en bout, **à la manière d’Azure Doctor** : sans prise de tête, bien structuré, et prêt à l’emploi.


##  Ce que fait ce script pour toi

✅ Crée une **infrastructure complète** pour tester AVD  
✅ Installe un **contrôleur de domaine (AD DS)**  
✅ Configure un réseau avec **DNS pointant vers le DC**  
✅ Crée un **host pool**, un **workspace** et un **app group**  
✅ Déploie une **VM Windows 11 AVD-ready**, joint le domaine et installe les agents  
✅ Gère l’intégration avec **JoinUser**, tokens, rôles et restart  
✅ Le tout, en **1 seul script `.sh`** documenté et modifiable


##  Avant de commencer

Tu as besoin de :

- Un terminal avec Bash (Linux, WSL, Mac)
- Azure CLI v2.45 ou plus récent
- Un abonnement Azure actif avec droits “Contributeur”
- Un groupe de ressources vierge ou isolé pour les tests


##  Lancer le déploiement

```bash
git clone https://github.com/Azure-Doctor/avd-starter-kit-cli.git
cd avd-starter-kit-cli/cli
chmod +x deploy-avd.sh
./deploy-avd.sh

Tu peux modifier les variables globales en haut du script : noms des VM, mots de passe, domaine, région, etc.

 Structure du dépôt
bash
Copier le code
avd-starter-kit-cli/
├── cli/
│   └── deploy-avd.sh               # Script Bash principal
├── docs/
│   └── architecture.png            # Schéma d’infrastructure
├── .github/
│   └── workflows/
│       └── validate-shell.yml      # (Optionnel) Lint/Syntax check automatique
├── LICENSE
└── README.md
 Ce que ça déploie concrètement
Domaine AD a2itechnologies.local

VM dc-avd-demo (DC + DNS)

VM avd-pooled-1 (Windows 11)

Pool AVD : a2i-avd-hp-pooled

Workspace AVD : a2i-avd-workspace

Application Group (type "Desktop")

DNS, jointure domaine, installation agents, token d’enregistrement

 Le tout est déployé dans un Virtual Network isolé avec nommage clair :
a2i-avd-demo-*



📄 Licence
Ce kit est publié sous licence MIT — libre à toi de le réutiliser, le modifier, le partager.
Et si tu l’améliores ? Fais une pull request .


🩺 – Azure Doctor
