# DBA Toolkit (En Développement)

**Boîte à outils en cours de construction** pour les administrateurs PostgreSQL (débutants ou pas).
*Ce dépôt est actuellement en développement actif. Certaines fonctionnalités et scripts ne sont pas encore disponibles.*

---
## 📋 Table des Matières
1. [DBA Toolkit (En Développement)](#dba-toolkit-en-développement)
   1. [📋 Table des Matières](#-table-des-matières)
   1. [📂 Structure du Dépôt](#-structure-du-dépôt)
   1. [⚠️ Statut Actuel](#️-statut-actuel)
   1. [📌 Prérequis](#-prérequis)
   1. [🚀 Installation / utilisation](#-installation--utilisation)
      1. [Pour commencer :](#pour-commencer-)
   1. [🤝 Contribuer](#-contribuer)
   1. [📜 Licence](#-licence)
   1. [⚠️ Bonnes pratiques IMPORTANTES](#️-bonnes-pratiques-importantes)
   1. [📬 Contact](#-contact)
   1. [🙏 Remerciements](#-remerciements)

---

## 📂 Structure du Dépôt
```
dba_toolkit/
│
├── tools/
│   └── vscodium/           # Configuration portable de VSCodium (documentation complète disponible)
│       ├── docs/           # Guides d'installation et d'utilisation
│       ├── config/         # Fichiers de configuration (settings.json, etc.)
│       └── scripts/        # Scripts d'automatisation et de validation
│
├── postgres/               # À venir : Scripts PostgreSQL (backup, monitoring, etc.)
│
├── .gitignore
├── README.md               # Ce fichier
└── LICENSE
```

## ⚠️ Statut Actuel
- **Phase** : Développement actif.
- **Disponible** :
  - **VSCodium** : 
    - Configuration portable et multi-environnement (Linux/WSL/Windows). [ici](tools/vscodium/tout_terrain/)
    - Configuration portable sur PC multi-OS (Linux/WSL/Windows). [ici](tools/vscodium/multisys)
    - → [Script de validation](tools/vscodium/tout_terrain/scripts/validate_codium.sh)
  
  - Structure de base pour les futurs outils (PostgreSQL, etc.).
- **À venir** :
  - Scripts PostgreSQL (backup, monitoring, maintenance).
  - Support pour d’autres SGBD (MySQL, MongoDB).


---


## 📌 Prérequis
- **Côté système** :
  - Un PC avec une distribution Linux ou WSL (Windows Subsystem for Linux).
  - Un disque externe ou une clé USB (pour la portabilité, optionnel).
- **Côté développement** :
  - Git (pour cloner le dépôt et gérer les workspaces).
  - Bash (version 4+).
  - **VSCodium** (recommandé pour une expérience optimale, voir `tools/vscodium/`).
- **Côté bases de données** (à venir) :
  - PostgreSQL (version 15+ recommandée).
  

## 🚀 Installation / utilisation
### Pour commencer :
1. **Cloner le dépôt** :
  ```bash
   git clone https://github.com/dcrazyboy/dba_toolkit.git
   cd dba_toolkit
```
2. **Explorer les outils disponibles :**

3. **Contribuer** : Voir la section Contribuer pour ajouter des outils ou améliorer la documentation.


## 🤝 Contribuer
Les contributions sont les bienvenues ! Voici comment participer :

- Forkez ce dépôt.
- Créez une branche pour votre fonctionnalité (git checkout -b ma-fonctionnalite).
- Validez vos modifications (git commit -am 'Ajout de ma fonctionnalité').
- Remontez la branche (git push origin ma-fonctionnalite).
- Ouvrez une [Pull Request](https://github.com/dcrazyboy/dba_toolkit/pulls).


## 📜 Licence
Ce projet est sous licence MIT – voir le fichier **[MIT](LICENSE)** pour plus de détails.

## ⚠️ Bonnes pratiques IMPORTANTES

- **Testez toujours** les scripts dans un environnement de staging avant de les utiliser en production.
- **Ne jamais versionner** des mots de passe ou des informations sensibles (utilise .env ou .gitignore).
- **Pour VScodium**
  - Utilisez le [script de validation](tools/vscodium/scripts/validate_codium.sh) pour vérifier les prérequis avant l’installation.
    - exemple
```bash
cd tools/vscodium/scripts/
chmod +x validate_codium.sh
./validate_codium.sh "/mnt/d"  # Exemple : "/mnt/d" pour un disque D: sous WSL
```
  - Préférez les chemins natifs de WSL (~/projects/) aux chemins montés (/mnt/) pour de meilleures performances.
- **Pour les bases de données** (à venir)
  - Les scripts supposent que la base soit correctement configurée sur votre machine.
  - Anonymisez toujours les données avant de partager des exemples.

## 📬 Contact
Pour toute question ou suggestion, [ouvrez une issue](https://github.com/dcrazyboy/dba_toolkit/issues) ou contactez-moi via GitHub.

## 🙏 Remerciements

- Aux mainteneurs de VSCodium et de ses extensions.
- À la communauté open-source pour les outils utilisés (Git, PostgreSQL, etc.).
- À la communauté Github qui a été une source d'inspiration par le partage où j'espère apporte ma Pierre
- Au Matou 🐱 (aka Lechat de Mistral AI) pour l’aide à la rédaction, aux tests et sa compilation de milliers de pages de documentation me permettant d'affiner ma compréhension dans les domaines que je maitrise moins. Bah oui j'ai (osons le grot mot) **travaillé et appris** avec cet IA Générative et me suis pas contenter de mettre ici un truc bugger récupéré en 2 click et trois questions bancales et c'est pas de tout repos 😀.

