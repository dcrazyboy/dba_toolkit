# :warning: Avertissement <!-- omit in toc -->
Comme tout ici, j'ai travaillé avec Le Matou :cat: (AKA : Lechat - Mistral AI) et bien sur ce fut épique, partir d'une :thinking: et se faire aider par un :cat2: pour arrive a une :yarn:, c'est sportif et ne se fait pas en 2h comme beaucoup de DEV ou de créateurs de SAAS, que je croise, le pensent ou le disent

Ce dossier contient une proposition de solution que j'utilise et j'espère KISS (enfin pourr moi çà l'est). Vous pouvez l'utiliser tel quel ou vous en inspirer au choix
# Sommaire <!-- omit in toc -->

1. [:thinking: L'idée](#thinking-lidée)
1. [:wrench: Convention de nommage](#wrench-convention-de-nommage)
1. [:framed\_picture: Vue d'ensemble](#framed_picture-vue-densemble)
   1. [:file\_folder:  Structure de la partie externe.](#file_folder--structure-de-la-partie-externe)
   1. [:hammer\_and\_wrench: Extensions Communes](#hammer_and_wrench-extensions-communes)
1. [:rocket: Prêt à vous lancer ?](#rocket-prêt-à-vous-lancer-)
1. [� Notes complémentaires](#-notes-complémentaires)



## :thinking: L'idée
J'utilise VSCode pour développer mes outils, parfois je le trouve chez les clients dans leurs Centre Logiciel (version officielle Crosoft), parfois je peux venir avec mon portable (sous Linux), parfois je suis chez moi en TT sur le PC fixe (aussi sous Linux mais d'une autre famille)

La question est donc, comment je me débrouille de manière aussi simple que possible pour accéder à mes petits secrets ou développer des projets perso ou pour mon client, récupérables  dans tous les cas, avec une connexion pas forcement simple et libre.

Cela passe par 3 axes : 
- Un compte Github avec différents repo pour mes besoins (vous êtes actuellement sur l'un d'ente eux)
- Un support externe (clef USB, DD ou dossier privé sur le pc qu'on me fourni si le RSSI a fait bloque les ports USB)
- Un support interne (le pc fourni ou je mais ce que je fais spécifiquement pour le client)

Un outils logiciel de développement ici VSCode (officiel) ou codium (version libre sans télémétrie et flicage (fonctionne sous Wintruc et Linux))

## :wrench: Convention de nommage
Dans ce document j'emploierai **Codium** pour désigne une installation officielle ou libre de VSCode
- < **racine_ext** > : Point de montage Linux ou Racine Windows de l'installation privée
  - exemple : `/mnt/usb_drive`
- < **racine_int** > : Point de montage Linux *$HOME** ou Racine Windows de l'installation du dossier de travail par défaut
  - exemple : `~` ou `$HOME` 
- < **path_ext** > : chemin d'installation de l'organisation externe
  - exemple : `prof\codium`
- < **path_int** > : chemin d'installation de l'organisation interne par défaut
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
- **Partager des fichiers** entre repository (ex: SQL, scripts, docs, ...) en vous plaçant sur < **racine_ext** >< **path_ext** > avant de vous remettre en mode isolé.
---

## :framed_picture: Vue d'ensemble
### :file_folder:  Structure de la partie externe.
```
<racine_ext>/
  └── <path_ext>/
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
- **:emojisense:** : Pour ajouter des icônes sympas dans les markdown (au moin ici)
- **GitLens** : Superpouvoirs Git (historique, blame, etc.).
- **macros** : permet de rajoute des macro a Codium
- **Markdown All in One** : Édition avancée de Markdown.
- **Project MAnager** : Basculer entre les workspaces en 1 clic.
- **ShellCheck** : Vérification des scripts shell.

---

## :rocket: Prêt à vous lancer ?

:warning: **Pour votre sécurité avant de vous faire :gun:**, une ou deux recommendations pour la route : 
- Pour faciliter la personnalisation, utilisez des variables d'environnement :
```bash
export RACINE_EXT="/mnt/usb_drive"
export PATH_EXT="prof/vscodium"
```
- Sauvegardez vos clés SSH et tokens GitHub en lieu sûr. (par exemple dans un coffre fort informatique (Keepass, Bitwarden,...) ou réel)
- Si vous emmenez votre disque ou clef usb a l’extérieur, envisagez une solution de cryptage (ex : LUCKS sous Linux)
- ATTENTION, cette installation est prévue pour Linux. Si vous êtes un Windowsien, pourquoi ne pas en profiter pour regarder du coté de WSL et commencer à faire pousser votre barbe :smile:

Désolé, je n'ai que la version non automatisée à proposer pour le moment mais même un :bearded_person: léger devrait s'en sortir ...

Vous la trouverez [ici](docs/vscodium_tout_terrain.md)

---

## 📌 Notes complémentaires
- Les **paramètres communs** sont dans `settings.json` (partagés entre tous les workspaces).
- Pour ajouter des **extensions spécifiques** à un projet, édite son fichier `.code-workspace`.
- Comment bascule d'un projet à un autre ?

![alt text](docs/use_project_manager.png)

1. Dans la side bar, choisit Project Manager
2. Dans les favoris choisir le projet global (vscodium) ou le sous-projet que l'on veux utiliser 
