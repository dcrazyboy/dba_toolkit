# DBA Toolkit (En Développement)

**Boîte à outils en cours de construction** pour les administrateurs PostgreSQL (débutants ou pas).
*Ce dépôt est actuellement en développement actif. Certaines fonctionnalités et scripts ne sont pas encore disponibles.*

---
## 📋 Table des Matières
1. [DBA Toolkit (En Développement)](#dba-toolkit-en-développement)
   1. [📋 Table des Matières](#-table-des-matières)
   1. [⚠️ Statut Actuel](#️-statut-actuel)
   1. [📌 Prérequis](#-prérequis)
   1. [🚀 Installation](#-installation)
   1. [📂 Structure du Dépôt](#-structure-du-dépôt)
   1. [🛠 Utilisation](#-utilisation)
   1. [🤝 Contribuer](#-contribuer)
   1. [📜 Licence](#-licence)
   1. [💡 Exemples d’Utilisation](#-exemples-dutilisation)
   1. [⚠️ Avertissements](#️-avertissements)
   1. [📬 Contact](#-contact)

---

## ⚠️ Statut Actuel
- **Phase** : Développement initial.
- **Disponible** :
  - Structure de base.
  - Quelques scripts de démonstration.
- **À venir** :
  - Scripts de sauvegarde, monitoring et maintenance.
  - Documentation complète.

---


## 📌 Prérequis
- **PostgreSQL** (version 10+ recommandée).
- **Bash** (version 4+).
- **Outils PostgreSQL** :
  ```bash
  sudo zypper install postgresql-client
  ```


## 🚀 Installation

-   **Cloner le dépôt** 
  ```bash
    git clone https://github.com/dcrazyboy/postgres_dba_toolkit.git
    cd postgres_dba_toolkit
  ```


-   **Rendre les scripts exécutables**
```bash
chmod +x scripts/*.sh
```

-   **Configurer les variables d’environnement (optionnel)**

Copie le fichier d’exemple :
```bash 
cp config/env.example config/.env
```

Édite config/.env avec tes paramètres (ex : PG_HOST, PG_USER).




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

## 🛠 Utilisation
- Sauvegardes


Sauvegarde complète :
./scripts/backup/full_backup.sh --db ma_base --dir /chemin/vers/sauvegardes

Options :

--db : Nom de la base à sauvegarder.
--dir : Répertoire de destination.





Restauration :
./scripts/backup/restore_backup.sh --file sauvegarde.dump --db ma_base


Monitoring


Vérifier l’état des bases :
./scripts/monitoring/check_db_status.sh

Affiche l’état des connexions, la taille des bases, et les requêtes bloquantes.



Analyser les performances :
./scripts/monitoring/query_performance.sh --top 10

Affiche les 10 requêtes les plus lentes.



Maintenance


Optimiser les tables :
./scripts/maintenance/vacuum_analyze.sh --db ma_base

Exécute VACUUM ANALYZE sur toutes les tables.



Réindexer les tables :
./scripts/maintenance/reindex_tables.sh --db ma_base --table ma_table



## 🤝 Contribuer
Les contributions sont les bienvenues ! Voici comment participer :

Fork ce dépôt.
Crée une branche pour ta fonctionnalité (git checkout -b ma-fonctionnalite).
Commit tes modifications (git commit -am 'Ajout de ma fonctionnalité').
Push la branche (git push origin ma-fonctionnalite).
Ouvre une Pull Request.


## 📜 Licence
Ce projet est sous licence MIT – voir le fichier **[MIT](LICENSE)** pour plus de détails.

## 💡 Exemples d’Utilisation
1. Sauvegarder une base
./scripts/backup/full_backup.sh --db ma_base --dir ~/sauvegardes
1. Surveiller les requêtes lentes
./scripts/monitoring/query_performance.sh --top 5
1. Optimiser une base
./scripts/maintenance/vacuum_analyze.sh --db ma_base

## ⚠️ Avertissements

Teste toujours les scripts dans un environnement de staging avant de les utiliser en production.
Ne jamais versionner des mots de passe ou des informations sensibles (utilise .env).
Les scripts supposent que PostgreSQL est correctement configuré sur ta machine.


## 📬 Contact
Pour toute question ou suggestion, ouvre une issue ou contacte-moi via GitHub.

