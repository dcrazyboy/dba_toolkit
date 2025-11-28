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
   1. [🤝 Contribuer](#-contribuer)
   1. [📜 Licence](#-licence)
   1. [⚠️ Bonnes pratiques IMPORTANTES](#️-bonnes-pratiques-importantes)
   1. [📬 Contact](#-contact)
   1. [:pray: Remerciements](#pray-remerciements)

---

## 📂 Structure du Dépôt
```
dba_toolkit/
│
├── tools/
│   └── vscodium/              # Configuration VSCodium (portable)
│       ├── docs/
│       ├── config/
│       └── scripts/
│
├── postgres/
│   ├── scripts/
│   │   ├── backup/
│   │   ├── monitoring/
│   │   └── maintenance/
│   ├── config/
│   ├── docs/
│   └── sql/
│
├── .gitignore
├── README.md                  # Description globale du dépôt
└── LICENSE
```

## ⚠️ Statut Actuel
- **Phase** : Développement initial (commencée).
- **Disponible** :
  - Structure de base.
  - Ajout de Vscodium dans Tools
- **À venir** :
  - Tous le reste

---


## 📌 Prérequis
- **Coté système**
  - Un pc avec une distro linux ou SWL installé sur Windows
- **Coté développement**
  - Votre IDE préféré ou **Codium** (voir tools/vscodium si besoin)
  - Bash : (version 4+).
- **Coté bases de données** (à venir)
  - **PostgreSQL** (version 10+ recommandée).
  - **Outils PostgreSQL** :
  

## 🚀 Installation / utilisation
Vous pouvez : 
- **Cloner le dépôt** et travailler en autonimie sur cette base
  ```bash
    git clone https://github.com/dcrazyboy/postgres_dba_toolkit.git
    cd dba_toolkit
  ```
- **Explorer, nourrir votre réfflecxion et picorer**

## 🤝 Contribuer
Les contributions sont les bienvenues ! Voici comment participer :

- Forkez ce dépôt.
- Créez une branche pour votre fonctionnalité (git checkout -b ma-fonctionnalite).
- Validez vos modifications (git commit -am 'Ajout de ma fonctionnalité').
- Remontez la branche (git push origin ma-fonctionnalite).
- Ouvrez une Pull Request.


## 📜 Licence
Ce projet est sous licence MIT – voir le fichier **[MIT](LICENSE)** pour plus de détails.

## ⚠️ Bonnes pratiques IMPORTANTES

- Testez toujours les scripts dans un environnement de staging avant de les utiliser en production.
- Ne jamais versionner des mots de passe ou des informations sensibles (utilise .env).
- Les scripts de BDD supposent que la base soit correctement configurée sur votre machine.
- Si vous décidez de contribuer et partagez des exemples, penez a anonymisez

## 📬 Contact
Pour toute question ou suggestion, ouvre une issue ou contacte-moi via GitHub.

## :pray: Remerciements

- Aux mainteneurs de VSCodium et de ses extensions.
- À la communauté open-source pour les outils utilisés (Git, PostgreSQL, etc.).
- À la communauté Github qui a été une source d'inspiration par le partage où j'espère apporte ma Pierre
- Au Matou 🐱 (aka Lechat de Mistral AI) pour l’aide à la rédaction, aux tests et sa compilation de milliers de pages de documentation me permettant d'affiner ma compréhension dans les domaines que je maitrise moins. 

