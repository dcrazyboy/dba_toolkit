#  Table des matières

1. [Table des matières](#table-des-matières)
   1. [:thinking: L'idée](#thinking-lidée)
   1. [:wrench: Convention de nomage](#wrench-convention-de-nomage)
   1. [:framed\_picture: Vue d'ensemble](#framed_picture-vue-densemble)
      1. [:file\_folder:  Structure de la partie externe.](#file_folder--structure-de-la-partie-externe)
      1. [:hammer\_and\_wrench: Extensions Communes](#hammer_and_wrench-extensions-communes)
   1. [:rocket: On y va ?](#rocket-on-y-va-)
   1. [🚀 Comment bascule d'un projet à un autre ?](#-comment-bascule-dun-projet-à-un-autre-)
   1. [📌 Notes](#-notes)

## :warning: Avertissement <!-- omit in toc -->
Comme tout ici, j'ai travaillé avec Le Matou :cat: (AKA : Lechat - Mistral AI) et biensur ce fut épique, partir d'une :thinking: et se faire aider par un :cat2: pour arrive a une :yarn:, c'est sportif et ne se fait pas en 2h comme beaucoup de DEV ou de créateurs de SAAS, que je croise, le pensent ou le disent

Ce dossier contient une proposition de solution que j'utilise et j'espère KISS (enfin pourr moi çà l'est). Vous pouvez l'utiliser telquel ou vous en inspirer au choix

## :thinking: L'idée
J'utilise VSCode pour developper mes outils, parfois je le trouve chez les clients dans leurs Centre Logiciel (version officielle crosoft), parfois je peux venir avec mon portable (sous linux), patfois je suis chez moi en TT sur le PC fixe (aussi sous linux mais d'une autre famille)

La question est donc, comment je me débrouille de manière aussi simple que possible pour accéder à mes petits secrets ou developper des projets perso ou pour mon client, récupérables  dans tous les cas, avec une connexion pas forcement simple et libre.

Cela passe par 3 axes : 
- Un compte Github avec différents repo pour mes besoins (vous êtes actuellment sur l'un d'ente eux)
- Un support externe (clef USB, DD ou dossier privé sur le pc qu'on me fourni si le RSSI a fait bloque les ports USB)
- Un support interne (le pc fourni ou je mais ce que je fais spécifiquement pour le client)

Un outils logiciel de developpemnt ici VSCode (officiel) ou codium (version libre sans télémétrie et flicage (fonctionne sous Wintruc et Linux))

## :wrench: Convention de nomage
Dans ce document j'emploierai **Codium** pour désigne une installaitn officielle ou libre de VSCode
- < **racine_ext** > : Point de montage linux ou Racine Windows de l'installation privée
  - exemple : `/mnt/usb_drive`
- < **racine_int** > : Point de montage linux *$HOME** ou Racine Windows de l'installation du dossier de travail par défaut
  - exemple : `~` ou `$HOME` 
- < **path_ext** > : chemin d'istallation de l'organisation externe
  - exemple : `professionel\codium`
- < **path_int** > : chemin d'istallation de l'organisation interne par defaut
  - exemple : `default_codium`
- < **repo_priv** > : dossier contenant le repos git associe au repos privé de github
  - exemple : `perso` ou votre username
- < **repo_col** > : dossier contenant le repos git associe au repos collaboratif de github (par exemple pour permettre au :cat: de mettre son museau et valider)
  - exemple : nom du projet partage ou le chat IA avec qui vous collable `lecaht_work`
- < **repo_pub** > : dossier contenant le repos git associe au repos public de github (celui ou vous me lisez)
  - exemple : `postgreSQL` ou `dba_toolkit`

Vous avez donc une configuration **hybride** pour VSCodium, optimisée pour :
- **Travailler sur plusieurs projets Git** en isolation un par < **repos_piv** >.
- **Basculer facilement** entre un contexte global et des workspaces dédiés.
- **Partager des fichiers** entre repository (ex: SQL, scripts, docs, ...) en vous placant sur < **racine_ext** >< **path_ext** > avant de vous remettre en mode isolé.
---

## :framed_picture: Vue d'ensemble
### :file_folder:  Structure de la partie externe.
```
<racine_ext>/
  └── <pathçext>/
        ├── <repo_priv>/        # :lock: Projet privé (GitHub privé)
        |      └── <repo_priv>.code-workspace
        ├── <repo_col>/         # :handshake:hake Projet collaboratif (GitHub privé/public)
        |      └── <repo_col>.code-workspace
        ├── <repo_pub/          # :earth_africa: Projet public (GitHub public)
        |      └── <repo_pub>.code-workspace
        └── README.md           # Ce fichier
```

---

### :hammer_and_wrench: Extensions Communes
Toutes les configurations incluent ces extensions de base :
- **:emojisense:** : Pour ajouter des icones sympas dans les markdown (au moin ici)
- **GitLens** : Superpouvoirs Git (historique, blame, etc.).
- **macros** : permet de rajoute des macro a Codium
- **Markdown All in One** : Édition avancée de Markdown.
- **Project MAnager** : Basculer entre les workspaces en 1 clic.
- **ShellCheck** : Vérification des scripts shell.

---

## :rocket: On y va ?

:warning: ATTENTION, cette installation est prévue pour Linux.

Désolé, je n'ai que la version non automatisée (en cours de dev) à proposer pour le moment mais même un :bearded_person: léger devrait s'en sortir ...
Vous la trouverez [ici](docs/vscodium_tout_terrain.md)


## 🚀 Comment bascule d'un projet à un autre ?

![alt text](docs/use_project_manager.png)

1. Dans la side bar, choisit Project Manager
2. Dans les favoris choisir le projet global (vscodium) ou le sous-projet que l'on veux utilliser 

---

## 📌 Notes
- Les **paramètres communs** sont dans `settings.json` (partagés entre tous les workspaces).
- Pour ajouter des **extensions spécifiques** à un projet, édite son fichier `.code-workspace`.
