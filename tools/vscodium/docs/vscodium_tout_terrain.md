# Installation VSCodium tout terrain
1. [Installation VSCodium tout terrain](#installation-vscodium-tout-terrain)
   1. [:thinking: But](#thinking-but)
   1. [:wrench: Prérequis](#wrench-prérequis)
   1. [:construction\_worker\_man: Installer VSCodium](#construction_worker_man-installer-vscodium)
      1. [Sur Red Hat family (Red Hat, Fedora, Rocky, CentOS, Almalinux, ...)](#sur-red-hat-family-red-hat-fedora-rocky-centos-almalinux-)
      1. [Sur openSUSE family (Tumbleweed, Leap, ...)](#sur-opensuse-family-tumbleweed-leap-)
      1. [Sur Debian family (Debian, Ubuntu, Mint, ...)](#sur-debian-family-debian-ubuntu-mint-)
      1. [Sur Windows via WSL](#sur-windows-via-wsl)
   1. [:construction: L'espace de travail](#construction-lespace-de-travail)
      1. [Arborescence](#arborescence)
         1. [:file\_folder:  Structure de la partie externe.](#file_folder--structure-de-la-partie-externe)
         1. [:file\_folder:  Structure de la partie interne.](#file_folder--structure-de-la-partie-interne)
         1. [Initialisation](#initialisation)
         1. [Installations complémentaires](#installations-complémentaires)
            1. [Installer les extensions](#installer-les-extensions)
            1. [Installer les fichiers de configuration](#installer-les-fichiers-de-configuration)
            1. [Mise à jour du gestionnaire d'application](#mise-à-jour-du-gestionnaire-dapplication)
               1. [GNOME](#gnome)
         1. [Test](#test)
   1. [📌 Notes](#-notes)
      1. [Paramétrage et shortcut](#paramétrage-et-shortcut)
         1. [Général](#général)
            1. [Paramétrage](#paramétrage)
            1. [Shortcut](#shortcut)
         1. [Extension : Gitlens](#extension--gitlens)
            1. [Paramétrage](#paramétrage-1)
            1. [Shortcut](#shortcut-1)
         1. [Extension : Markdown All In One](#extension--markdown-all-in-one)
            1. [Paramétrage](#paramétrage-2)
            1. [Shortcut](#shortcut-2)
         1. [Extension : Project Manager](#extension--project-manager)
            1. [Paramétrage](#paramétrage-3)
         1. [Extension : Shellcheck](#extension--shellcheck)
            1. [Paramètrage](#paramètrage)
      1. [A propos des extensions](#a-propos-des-extensions)
      1. [A propos des emoji](#a-propos-des-emoji)
         1. [Comment les Utiliser ?](#comment-les-utiliser-)
      1. [A propos de project manager](#a-propos-de-project-manager)
         1. [Comment bascule d'un projet à un autre ?](#comment-bascule-dun-projet-à-un-autre-)
   1. [:pray: Remerciement](#pray-remerciement)

## :thinking: But

Voici ma manière d'installer et organiser **VSCodium** afin de pouvoir transporter mes projets de manière un minimum sécurisé et compatible avec un environnement hétérogène
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

## :wrench: Prérequis

- 1 pc (portable ou fixe)
- 1 disque externe ou pourquoi pas un clef usb formatée pour Linux
- git installe sur le PC
- et bien sûr
  - accès au terminal
  - votre éditeur préféré (vim, nano, emacs,...)

## :construction_worker_man: Installer VSCodium
Vous pouvez bien sûr utilise Snap, mais je préfère la méthode :hammer_and_wrench: 

### Sur Red Hat family (Red Hat, Fedora, Rocky, CentOS, Almalinux, ...)
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
### Sur Debian family (Debian, Ubuntu, Mint, ...)
```bash
#installer les dépendances
sudo apt install dirmngr software-properties-common apt-transport-https curl -y
#installer le repo
curl -fSsL https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg | sudo gpg --dearmor | sudo tee /usr/share/keyrings/vscodium.gpg >/dev/null
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/vscodium.gpg] https://download.vscodium.com/debs vscodium main" | sudo tee /etc/apt/sources.list.d/vscodium.list
#installer codium
sudo apt update
sudo apt install codium
```
### Sur Windows via WSL
Bah oui c'est possible
a déveloper

## :construction: L'espace de travail

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
Ceci est la partie installation par défaut si le disque externe n'est pas présent
```
<racine_int>/
  └── <path_int>/
```
En général la < racine_int > est votre **$HOME** aussi noté **~**

#### Initialisation
On part du principe que sur vos different PC privés (fixe ou portable) vous avez toujours un compte de connexion identique (nonobstant le mot de passe bien sur)

```bash
# 1) création des dossier du disque externe
# se placer sur la racine du DD ou de la clef
cd <racine_ext>
# créer le dossier de stockage
mkdir -p <path_ext>
# créer les dossier projets
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
# se déplacer sur le $HOME
cd ~
# s'il n'existe pas créer un dossier scripts
mkdir -p scripts
# s'il n'existe pas créer le dossier de config personnalisé
mkdir -p .config
mkdir -p .config/VSCodium
mkdir -p .config/VSCodium/User
# s'il n'existe pas créer le dossier par défaut pour VSCodium
mkdir -p default_codium
```

#### Installations complémentaires
##### Installer les extensions
```bash
# Installation des extensions
codium --install-extension eamodio.gitlens
codium --install-extension alefragnani.project-manager
codium --install-extension yzhang.markdown-all-in-one
codium --install-extension timonwong.shellcheck
```
##### Installer les fichiers de configuration
Récupérer sur github les fichiers scripts dans dba_toolkit/tool/vscodium/scripts et les installer
```bash
# Téléchargement des fichiers de workspace codium pour chaque repo (ne pas oublie de mettre les bonnes valeurs dans la commande pour <repo_xxx> )
wget https://raw.githubusercontent.com/dcrazyboy/dba_toolkit/tree/main/tools/vscodium/workspaces_and_settings/<repo_xxx>.code-workspace -O <racine_ext>/<path_ext>/<repo_xxx>/<repo_xxx>.code-workspace
# Téléchargement des fichiers de configuration codium
wget https://raw.githubusercontent.com/dcrazyboy/dba_toolkit/tree/main/tools/vscodium/workspaces_and_settings/settings.json -O ~/scripts/settings.json
wget https://raw.githubusercontent.com/dcrazyboy/dba_toolkit/tree/main/tools/vscodium/workspaces_and_settings/projects.json -O ~/scripts/projects.json
# Téléchargement des fichiers de scripts
wget https://raw.githubusercontent.com/dcrazyboy/dba_toolkit/tree/main/tools/vscodium/scripts/launch_codium.sh -O ~/scripts/launch_codium.sh
```
Avec votre éditeur préféré dans les fichiers récupérés sur **~/scripts/**, remplacer < racine_ext >, < path_ext > et < repo_xxx > par vos propres valeurs

```bash
# Installation des fichiers de configuration
mv ~/scripts/settings.json ~/.config/VSCodium/User/settings.json
mv ~/scripts/projects.json ~/.config/VSCodium/User/projects.json
chmod +x ~/scripts/launch_codium.sh
```
##### Mise à jour du gestionnaire d'application
###### GNOME
Récupérer le .desktop général et l'installer dans le $HOME
```bash
cp /usr/share/applications/codium.desktop ~/.local/share/applications/
```
Mettre à jour le **~/.local/share/applications/codium.desktop** avec votre éditeur préféré
```bash
# ligne a modifier
# Exec=/usr/share/codium/codium %F
# devient
Exec=/bin/bash -c "~/scripts/launch_codium.sh"
# régénérer le cache
update-desktop-database ~/.local/share/applications/
```
#### Test
DD ou clef USB retirée lancer VSCodium
Il doit démarrer dan le dossier par défaut ~/default_codium

Branche le DD ou la clef USB
Vérifier qu'elle est bien montée et accessible
Relance VSCodium
Il doit démarre sur < disque externe >/prof/vscodium

## 📌 Notes
### Paramétrage et shortcut

#### Général
##### Paramétrage
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
##### Paramétrage
Paramétrage Git
```
  // Git
  "git.enableSmartCommit": true,
  "git.confirmSync": false,
  "git.ignoreMissingGitWarning": true,

```
Paramétrage Gitlens
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
##### Paramétrage
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
##### Paramétrage
```
  // Project Manager
  "projectManager.sortList": "Name",
  "projectManager.git.baseFolders": [
    "< racine_ext>/< path_ext >"
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
2. Dans les favoris choisir le projet global (vscodium) ou le sous-projet que l'on veux utiliser 
---
## :pray: Remerciement
- A tous ceux qui maintiennent et mettent a disposition **Codium**
- A tous ceux qui maintiennent et mettent a disposition les extensions d e **Codium** qui m'aident bien
- Au échanges avec le :cat: de mistral, parfois houleux car comme tous les :cat: il a tendance a changer de :yarn: sans prévenir.... 😛   

