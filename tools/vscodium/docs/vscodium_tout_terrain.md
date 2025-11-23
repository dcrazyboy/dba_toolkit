# Installation VSCodium tout terrain
1. [Installation VSCodium tout terrain](#installation-vscodium-tout-terrain)
   1. [But](#but)
   1. [Prérequis](#prérequis)
   1. [Installer VSCodium](#installer-vscodium)
      1. [Sur Red Hat family (Red Hat, fedore, Rocky, Centos, Almalinux, ...)](#sur-red-hat-family-red-hat-fedore-rocky-centos-almalinux-)
      1. [Sur openSUSE family (Tumbleweed, Leap, ...)](#sur-opensuse-family-tumbleweed-leap-)
   1. [L'espace de travail](#lespace-de-travail)
      1. [Arborescence](#arborescence)
         1. [:file\_folder:  Structure de la partie externe.](#file_folder--structure-de-la-partie-externe)
         1. [:file\_folder:  Structure de la partie interne.](#file_folder--structure-de-la-partie-interne)
         1. [Initialisation](#initialisation)
         1. [Installations complementaires](#installations-complementaires)
            1. [Installer les extensions](#installer-les-extensions)
            1. [Installer les fichiers de configuration](#installer-les-fichiers-de-configuration)
            1. [Mise à jour du gestionnaire d'application](#mise-à-jour-du-gestionnaire-dapplication)
               1. [GNOME](#gnome)
         1. [Test](#test)
   1. [📌 Notes](#-notes)
      1. [Paramètrage et shortcut](#paramètrage-et-shortcut)
         1. [Général](#général)
            1. [Paramètrage](#paramètrage)
            1. [Shortcut](#shortcut)
         1. [Extension : Gitlens](#extension--gitlens)
            1. [Paramètrage](#paramètrage-1)
            1. [Shortcut](#shortcut-1)
         1. [Extension : Markdown All In One](#extension--markdown-all-in-one)
            1. [Parametrage](#parametrage)
            1. [Shortcut](#shortcut-2)
         1. [Extension : Project Manager](#extension--project-manager)
            1. [Paramètrage](#paramètrage-2)
         1. [Extension : Shellcheck](#extension--shellcheck)
            1. [Paramètrage](#paramètrage-3)
      1. [A propos des extensions](#a-propos-des-extensions)
      1. [A propos des emoji](#a-propos-des-emoji)
         1. [Comment les Utiliser ?](#comment-les-utiliser-)
      1. [A propos de project manager](#a-propos-de-project-manager)
         1. [Comment bascule d'un projet à un autre ?](#comment-bascule-dun-projet-à-un-autre-)
   1. [:pray: Remerciement](#pray-remerciement)

## But

Voici ma manière d'installer et organiser **VSCodium** afin de pouvoir transporter mes projets de manière un minimum sécurisé et compatible avec un environnement hététrogène
Ce document n'est aps exhaustif mais je l'espère tout public et oui je l'ai travaillé avec le :cat: venteux (aka Lechat - mistral)
Les :bearded_person: à long barbe peuvent y trouver une inspiration, un point de vue, ceux à la barbe naissante un HOW TO pour apprendre

La version de **VSCodium** utilisée est : 
```
Version: 1.105.17075
Commit: 14bd1561ce547502e6ff1968090dc18c49160aab
Date: 2025-10-21T20:24:03.344Z
Electron: 37.6.0
ElectronBuildId: undefined
Chromium: 138.0.7204.251
Node.js: 22.19.0
V8: 13.8.258.32-electron.0
```

## Prérequis

- 1 pc (portable ou fixe)
- 1 disque externe ou pouquoi pas un clef usb formatée pour linux
- git installe sur le PC
- et biensur
  - acces au terminal
  - votre éditeur préféré (vim, nano, emacs,...)

## Installer VSCodium
Vous pouovez-biensur utilise Snap, mais je préfère la méthode :hammer_and_wrench: 

### Sur Red Hat family (Red Hat, fedore, Rocky, Centos, Almalinux, ...)
```bash
sudo rpmkeys --import https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/-/raw/master/pub.gpg
sudo dnf config-manager --add-repo https://paulcarroty.gitlab.io/vscodium-deb-rpm-repo/rpms/
sudo dnf install codium
```
### Sur openSUSE family (Tumbleweed, Leap, ...)
```bash
sudo rpm --import https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/-/raw/master/pub.gpg
sudo zypper ar -f https://paulcarroty.gitlab.io/vscodium-deb-rpm-repo/rpms/ vscodium
sudo zypper install codium
```


## L'espace de travail

Choix : Installation de l'espace de travail sur disque externe ou clef usb (petits projets ou pour demo/partage)

### Arborescence
#### :file_folder:  Structure de la partie externe.
```
<racine_ext>/
  └── <path_ext>/
        ├── <repo_priv>/        # :lock: Projet privé (GitHub privé)
        |      └── <repo_priv>.code-workspace
        ├── <repo_col>/         # :handshake:hake Projet collaboratif (GitHub en bascule privé/public)
        |      └── <repo_col>.code-workspace
        ├── <repo_pub/          # :earth_africa: Projet public (GitHub public)
        |      └── <repo_pub>.code-workspace
        └── README.md           # Ce fichier
```
#### :file_folder:  Structure de la partie interne.
Ceci est la partie installation par defaut si le disque externe 'nest pas présent
```
<racine_int>/
  └── <path_int>/
```
En général la < racine_int > est votre **$HOME** aussi notée **~**

#### Initialisation
On part du principe que sur vos different PC privés (fixe ou portable) vous avez toujours un compte de connexion identique (nonobstant le mot de passe bien sur)

```bash
# 1) création des dossier du disque externe
# se placer sur la racine du DD ou de la clef
cd <racine_ext>
# créer le dossier de stockage
mkdir -p <path_ext>
# creer les dossier projets
mkdir -p vscodium/{.vscode,<repo_priv>,<repo_col>,<repo_pub>}

# 2) gerer git
# pour chaque repo
cd <path_ext>/<repo_xxx>
git init
echo "toto" | tee .gitignore
# si vous avez decider d'utiliser github comme repo de sauvegarde
git remote set-url origin git@github.com:<utilisateur>/<depot associe github>.git
echo -e "<repo_xxx>.code-workspace" | tee .gitignore

#3) Droits et owner sur le disque externe
# mise en place des droits et owner
cd <racine_ext>
chown -R $USER:$USER <path_ext>/
chmod -R 750 <path_ext>/
# ou
chmod -R u+rwx,g+rx,o-rwx <path_ext>/

#4) le dossier du disque interne
# se dépalcer sur le $HOME
cd ~
# s'il n'existe pas crer un dossier scripts
mkdir -p scripts
# s'il nexiste pas créer le dossier de config personalisé
mkdir -p .config
mkdir -p .config/VSCodium
mkdir -p .config/VSCodium/User
# s'il n'existe pas creer le dossier par defaut pour VSCodium
mkdir -p default_codium
```

#### Installations complementaires
##### Installer les extensions
```bash
# Installation des extensions
codium --install-extension eamodio.gitlens
codium --install-extension alefragnani.project-manager
codium --install-extension yzhang.markdown-all-in-one
codium --install-extension timonwong.shellcheck
```
##### Installer les fichiers de configuration
Récupérer sur github les fichiers scripts dans lechat_work/vscodium/scripts et les installer
```bash
# Téléchargement des fichiers de workspace codium pour chaque repo (ne pas oublie de mettre les bonnes valeurs dans la commande pour racine_ext,path_ext et repo_ext )
wget https://raw.githubusercontent.com/dcrazyboy/dba_toolkit/main/vscodium/workspaces_and_settings/<repo_xxx>.code-workspace -O <racine_ext>/<path_ext>/<repo_xxx>/<repo_xxx>.code-workspace
# Téléchargement des fichiers de configuration codium
wget https://raw.githubusercontent.com/dcrazyboy/dba_toolkit/main/vscodium/workspaces_and_settings/settings.json -O ~/scripts/settings.json
wget https://raw.githubusercontent.com/dcrazyboy/dba_toolkit/main/vscodium/workspaces_and_settings/projects.json -O ~/scripts/projects.json
# Téléchargement des fichiers de scripts
wget https://raw.githubusercontent.com/dcrazyboy/dba_toolkit/main/vscodium/scripts/launch_codium.sh -O ~/scripts/launch_codium.sh
```
Avec votre éditeur préféré dans les fichiers récupérés sur **~/scripts/**, remplcer < racine_ext >, < path_ext > et < repo_xxx > par vos propres valeurs

```bash
# Installation des fichiers de configuration
mv ~/scripts/settings.json ~/.config/VSCodium/User/settings.json
mv ~/scripts/projects.json ~/.config/VSCodium/User/projects.json
chmod +x ~/scripts/launch_codium.sh
```
##### Mise à jour du gestionnaire d'application
###### GNOME
Récupérer le .desktop general et l'installe dans le $HOME
```bash
cp /usr/share/applications/codium.desktop ~/.local/share/applications/
```
Mettre à jour le **~/.local/share/applications/codium.desktop** avec votre éditeur préféré
```bash
# ligen a modifier
# Exec=/usr/share/codium/codium %F
# devient
Exec=/bin/bash -c "~/scripts/launch_codium.sh"
# régénérer le cache
update-desktop-database ~/.local/share/applications/
```
#### Test
DD ou clef USB retirée lancer VSCodium
Il doit démarrer dan le dossier par defaut ~/default_codium

Branche le DD ou la clef USB
Vérifier qu'elle est bien montée et accessible
Relance VSCodium
Il doit démarre sur < disque externe >/prof/vscodium

## 📌 Notes
### Paramètrage et shortcut

#### Général
##### Paramètrage
```
  // Apparence
  "workbench.colorTheme": "Default Dark+",
  "workbench.iconTheme": "material-icon-theme",
  // Raccourcis personnalisés (à ajouter dans keybindings.json)
  "workbench.startupEditor": "newUntitledFile",
  //editeur
  "editor.fontSize": 14,
  "editor.fontFamily": "'Fira Code', 'Courier New', monospace",
  "editor.fontLigatures": true,
  "editor.tabSize": 2,
  // Comportement
  "editor.formatOnSave": false,
  "editor.codeActionsOnSave": {
    "source.fixAll": "explicit"
  },
  // Dossiers exclus
  "files.exclude": {
    "**/.git": true,
    "**/node_modules": true,
    "**/__pycache__": true,
    "**/*.pyc": true
  },
  // Terminal
  "terminal.integrated.shell.linux": "/bin/bash",
  "terminal.integrated.fontFamily": "'Fira Code'",
  // Extensions
  "extensions.autoUpdate": true,
```
##### Shortcut
Pas de shortcut

#### Extension : Gitlens
##### Paramètrage
Paramètrage Git
```
  // Git
  "git.enableSmartCommit": true,
  "git.confirmSync": false,
  "git.ignoreMissingGitWarning": true,

```
Paramètrage Gitlens
```
  // GitLens
  "gitlens.codeLens.enabled": true,
  "gitlens.currentLine.enabled": true,
  "gitlens.hovers.currentLine.over": "line",
  "gitlens.hovers.enabled": true,
```
##### Shortcut
| Raccourci | Commande GitLens                                |
| :-------- | :---------------------------------------------- |
| Alt+G B   | Basculer le blame du fichier                    |
| Alt+G L   | Basculer le blame de la ligne                   |
| Alt+G H   | Ouvrir l'historique du fichier                  |
| Alt+G F   | Ouvrir l'historique rapide du fichier           |
| Alt+G R   | Ouvrir l'historique rapide du dépôt             |
| Alt+G C   | Voir les détails du commit actuel               |
| Alt+G D   | Voir les détails du commit de la ligne actuelle |

#### Extension : Markdown All In One
##### Parametrage
```
  // Markdown
  "markdown.preview.fontSize": 14,
  "markdown.preview.fontFamily": "'Fira Code'",
  // Activation des fonctionnalités de base
  "markdown.extension.toc.levels": "1..6",
  "markdown.extension.toc.orderedList": true,
  // Formatage automatique
  "markdown.extension.orderedList.marker": "one",
  // Prévisualisation
  "markdown.extension.preview.autoShowPreviewToSide": true,
  // Autres paramètres utiles
  "markdown.extension.completion.enabled": true,
```

##### Shortcut
| Raccourci              | Action                                           |
| :--------------------- | :----------------------------------------------- |
| Ctrl+B                 | Mettre en gras le texte sélectionné.             |
| Ctrl+I                 | Mettre en italique le texte sélectionné.         |
| Ctrl+Shift+``          | Insérer un bloc de code.                         |
| Ctrl+K v               | Afficher/retirer la prévisualisation Markdown.   |
| Ctrl+Shift+P > "Table" | Insérer un tableau Markdown.                     |

#### Extension : Project Manager
##### Paramètrage
```
  // Project Manager
  "projectManager.sortList": "Name",
  "projectManager.git.baseFolders": [
    "/run/media/dcrazyboy/My Passport/prof/vscodium/"
  ],
```
#### Extension : Shellcheck
##### Paramètrage
```
  // ShellCheck
  "shellcheck.ignorePatterns": {
    "**/node_modules/**": true,
    "**/vendor/**": true
  }
```
### A propos des extensions
Pour ajouter des **extensions spécifiques** à un projet, édite son fichier `.code-workspace` et possiblement ajouter des entrée dans le `.gitignore`

### A propos des emoji
#### Comment les Utiliser ?
- Dans un fichier `.md`, tape `:nom_emoji:` (ex: `:cat:`).
- **Codium** les convertira automatiquement en emoji.

### A propos de project manager
#### Comment bascule d'un projet à un autre ?

![alt text](use_project_manager.png)

1. Dans la side bar, choisit Project Manager
2. Dans les favoris choisir le projet global (vscodium) ou le sous-projet que l'on veux utilliser 
---
## :pray: Remerciement
- A tous ceux qui maintiennent et mettent a disposition **Codium**
- A tous ceux qui maintiennet et mettent a disposition les extensions d e **Codium** qui m'aident bien
- Au échanges avec le :cat: de mistral, parfois houleux car comme tous les :cat: il a tendance a changer de :yarn: sans prévenir.... 😛   

