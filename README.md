# 🛠️ **DBA Toolkit**

> *Outils et procédures pour la gestion des bases de données PostgreSQL et des environnements systèmes.*

Ce dépôt centralise des **scripts, configurations, et documentations** pour faciliter la gestion des bases de données PostgreSQL et des environnements systèmes (OpenSUSE, Rocky, Debian, etc.).  
Il est conçu pour être **modulaire** : tu peux récupérer uniquement les parties qui t’intéressent.

⚠️ **Attention** : Les scripts sont **prêts à l’emploi une fois les chemins adaptés** à ton environnement (ex: chemins relatifs, variables d’environnement, etc.). Consulte les `README.md` de chaque dossier pour les détails d’installation et de configuration.

1. [🛠️ **DBA Toolkit**](#️-dba-toolkit)
   1. [📁 **Structure du dépôt**](#-structure-du-dépôt)
   1. [🎯 **À quoi sert ce dépôt ?**](#-à-quoi-sert-ce-dépôt-)
   1. [🚀 **Comment utiliser ce dépôt ?**](#-comment-utiliser-ce-dépôt-)
      1. [📥 **Option 1 : Télécharger une release (pour les débutants)**](#-option-1--télécharger-une-release-pour-les-débutants)
      1. [🪛 **Option 2 : Cloner le dépôt complet (pour les utilisateurs Git)**](#-option-2--cloner-le-dépôt-complet-pour-les-utilisateurs-git)
      1. [🎯 **Option 3 : Cloner uniquement une partie (pour les utilisateurs Git avancés)**](#-option-3--cloner-uniquement-une-partie-pour-les-utilisateurs-git-avancés)
      1. [Exécuter un script Bash](#exécuter-un-script-bash)
      1. [Exécuter un script SQL](#exécuter-un-script-sql)
   1. [📌 **Dossiers clés**](#-dossiers-clés)
   1. [🔧 **Bonnes pratiques**](#-bonnes-pratiques)
   1. [🤝 **Contribuer**](#-contribuer)
   1. [📜 **Licence**](#-licence)
   1. [🙏 Remerciements](#-remerciements)

---

## 📁 **Structure du dépôt**

```bash
dba_toolkit/
│
├── system/                    # Outils et astuces spécifiques aux systèmes d'exploitation
│   ├── opensuse/              # Scripts et docs pour OpenSUSE (partitionnement, NVIDIA, etc.)
│   ├── rocky/                 # À venir : Scripts pour Rocky Linux
│   ├── debian/                # À venir : Scripts pour Debian
│   ├── multi_system/          # Scripts multi-systèmes (ex: gestion de disques externes)
│   └── README.md              # Documentation générale pour le dossier `system`
│
├── tools/                     # Outils de développement
│   ├── vscodium/              # Configuration et scripts pour VSCodium (IDE)
│   │   ├── tout_terrain/      # Installation et configuration commune à tous les systèmes
│   │   ├── multisys/           # Configuration pour les environnements multi-systèmes
│   │   └── README.md
│   └── README.md              # Documentation générale pour le dossier `tools`
│
├── postgreSQL/                # Tout ce qui concerne PostgreSQL
│   ├── bash/                  # Scripts Bash pour PostgreSQL
│   │   ├── discover/          # Scripts de découverte et analyse
│   │   ├── env_sync/          # Synchronisation des environnements (dev ↔ preprod ↔ prod)
│   │   └── shared/            # Fonctions et outils réutilisables (ex: `function_central.sh`)
│   │
│   ├── scripts_sql/           # Scripts SQL pour PostgreSQL
│   │   ├── backup/            # Scripts de sauvegarde
│   │   ├── maintenance/       # Maintenance (VACUUM, REINDEX, etc.)
│   │   ├── db_cloning/        # Clonage de bases de données
│   │   └── fdw_hub/           # Base pivot utilisant des FDW pour fédérer l'accès aux données multi-sources
│   │
│   ├── monitoring/            # Configuration pour le monitoring (Graphana, Prometheus, etc.)
│   │   ├── sql_exporte/       # Exporteurs SQL pour Prometheus
│   │   ├── grafana_config/    # Dashboards et configurations Grafana
│   │   └── prometheus_config/ # Configurations Prometheus
│   │
│   ├── configs/               # Fichiers de configuration exemple (postgresql.conf, pg_hba.conf, etc.)
│   └── docs/                  # Documentation technique (bonnes pratiques, dépannage, etc.)
│
├── README.md                  # Ce fichier
└── LICENSE                    # Licence du dépôt
```

---

## 🎯 **À quoi sert ce dépôt ?**

Ce toolkit est conçu pour **simplifier la vie des DBAs** en fournissant :

- **Des scripts adaptables** pour PostgreSQL (backup, maintenance, monitoring) : *les chemins et variables doivent être mis à jour selon ton environnement*.
- **Des outils pour synchroniser les environnements** (dev, preprod, prod) sans erreur.
- **Des astuces systèmes** pour gérer les environnements (OpenSUSE, Rocky, etc.), y compris le **montage de disques externes** (nécessaire pour VSCodium, Podman, etc.).
- **Une base pivot (`fdw_hub`)** pour fédérer l’accès à des données multi-sources (Oracle, PostgreSQL, etc.) via des FDW.

---

## 🚀 **Comment utiliser ce dépôt ?**

### 📥 **Option 1 : Télécharger une release (pour les débutants)**

Les **releases** sont des packages prêts à l’emploi pour des cas d’usage spécifiques.  
**→ [Voir les releases disponibles](https://github.com/dcrazyboy/dba_toolkit/releases)**


| Release                    | Description                                                               | Lien                                                                                          |
| -------------------------- | ------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------- |
| `postgreSQL-env_sync-v1.0` | Synchronisation des environnements PostgreSQL (dev ↔ preprod ↔ prod).     | [Télécharger](https://github.com/dcrazyboy/dba_toolkit/releases/tag/postgreSQL-env_sync-v1.0) |
| `postgreSQL-fdw_hub-v1.0`  | Base pivot pour fédérer l’accès aux données multi-sources via des FDW.    | [Télécharger](https://github.com/dcrazyboy/dba_toolkit/releases/tag/postgreSQL-fdw_hub-v1.0)  |
| `system-opensuse-v1.0`     | Scripts et astuces pour OpenSUSE (partitionnement, pilotes NVIDIA, etc.). | [Télécharger](https://github.com/dcrazyboy/dba_toolkit/releases/tag/system-opensuse-v1.0)     |
| `vscodium-setup-v1.0`      | Configuration de VSCodium + scripts pour monter les disques externes.     | [Télécharger](https://github.com/dcrazyboy/dba_toolkit/releases/tag/vscodium-setup-v1.0)      |


---

### 🪛 **Option 2 : Cloner le dépôt complet (pour les utilisateurs Git)**

```bash
git clone https://github.com/dcrazyboy/dba_toolkit.git
```

---

### 🎯 **Option 3 : Cloner uniquement une partie (pour les utilisateurs Git avancés)**

Utilise `git sparse-checkout` pour ne cloner que les dossiers qui t’intéressent.  
**Exemple** : Cloner uniquement `postgreSQL/env_sync/` et `postgreSQL/bash/shared/` :

```bash
git clone --filter=blob:none --no-checkout https://github.com/dcrazyboy/dba_toolkit.git
cd dba_toolkit
git sparse-checkout init --cone
git sparse-checkout set postgreSQL/bash/env_sync postgreSQL/bash/shared
```

---

### Exécuter un script Bash

```bash
# Exemple : Synchroniser preprod → dev
cd postgreSQL/bash/env_sync
# 1. Adapter les chemins dans le script si nécessaire
# 2. Exécuter
./sync_preprod_to_dev.sh --db ma_base --user mon_user
```

### Exécuter un script SQL

```bash
# Exemple : Exécuter un backup
psql -U postgres -d ma_base -f postgreSQL/scripts_sql/backup/full_backup.sql
```

---

## 📌 **Dossiers clés**


| Dossier                                                                | Description                                                                                        | Cas d’usage typique                                                     |
| ---------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------- |
| `[system/](./system/)`                                                 | Scripts et astuces pour les systèmes d’exploitation (OpenSUSE, Rocky, etc.).                       | Résoudre un problème de pilote NVIDIA, **monter des disques externes**. |
| `[tools/vscodium/](./tools/vscodium/)`                                 | Configuration de l’IDE VSCodium pour le développement (nécessite le montage des disques externes). | Installer VSCodium sur un nouvel environnement.                         |
| `[postgreSQL/bash/env_sync/](./postgreSQL/bash/env_sync/)`             | Synchronisation des bases entre environnements (dev, preprod, prod).                               | Réinitialiser l’env de dev avec la preprod.                             |
| `[postgreSQL/scripts_sql/fdw_hub/](./postgreSQL/scripts_sql/fdw_hub/)` | Base pivot utilisant des FDW pour fédérer l’accès aux données multi-sources.                       | Interroger des données Oracle depuis PostgreSQL.                        |
| `[postgreSQL/monitoring/](./postgreSQL/monitoring/)`                   | Configurations pour Graphana, Prometheus, et exporteurs SQL.                                       | Surveiller les performances de PostgreSQL.                              |


---

## 🔧 **Bonnes pratiques**

- **Adapte les chemins** : Les scripts utilisent des chemins relatifs. Vérifie qu’ils pointent vers les bons emplacements dans ton environnement.
- **Lis les READMEs** : Chaque dossier contient un `README.md` avec des exemples et des explications spécifiques.
- **Utilise `function_central.sh**` : Pour les scripts Bash, incluez toujours ce fichier pour les appels SQL normalisés :
  ```bash
  source ../shared/function_central.sh
  ```
- **Évite les chemins absolus** : Utilise des chemins relatifs pour inclure des fichiers ou appels SQL.
- **Documente tes modifications** : Si tu ajoutes un script, mets à jour le `README.md` du dossier concerné.

---

## 🤝 **Contribuer**

- **Propose des améliorations** : Ouvre une issue ou une PR pour ajouter un script ou une documentation.
- **Signale les bugs** : Si un script ne fonctionne pas, décris le problème dans une issue.

---

## 📜 **Licence**

Ce dépôt est sous licence **[LICENSE](./LICENSE)**. Voir le fichier pour plus de détails.

## 🙏 Remerciements

    Aux mainteneurs de VSCodium et de ses extensions.
    À la communauté open-source pour les outils utilisés (Git, PostgreSQL, etc.).
    À la communauté Github qui a été une source d'inspiration par le partage où j'espère apporte ma Pierre
    Au Matou 🐱 (aka Lechat de Mistral AI) pour l’aide à la rédaction, aux tests et sa compilation de milliers de pages de documentation me permettant d'affiner ma compréhension dans les domaines que je maitrise moins. Bah oui j'ai (osons le gros mot) travaillé et appris avec cet IA Générative et me suis pas contenter de mettre ici un truc bugger récupéré en 2 click et trois questions bancales et c'est pas de tout repos 😀.
