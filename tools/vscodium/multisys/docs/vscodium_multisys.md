# Installation VSCodium tout terrain
1. [Installation VSCodium tout terrain](#installation-vscodium-tout-terrain)
   1. [🤔 But](#-but)
   1. [🔧 Prérequis](#-prérequis)
   1. [👷 Installer VSCodium](#-installer-vscodium)
      1. [Sur Red Hat family (Red Hat, Fedora, Rocky, CentOS, Almalinux, ...)](#sur-red-hat-family-red-hat-fedora-rocky-centos-almalinux-)
      1. [Sur openSUSE family (Tumbleweed, Leap, ...)](#sur-opensuse-family-tumbleweed-leap-)
      1. [Sur Debian family (Debian, Ubuntu, Mint, ...)](#sur-debian-family-debian-ubuntu-mint-)
      1. [Sur Windows via WSL](#sur-windows-via-wsl)
         1. [Installer WSL](#installer-wsl)
         1. [Installer une distribution Linux](#installer-une-distribution-linux)
         1. [Points à vérifier](#points-à-vérifier)
         1. [Installation de Codium](#installation-de-codium)
   1. [🏗️ L'espace de travail pour le premier sytème installé](#️-lespace-de-travail-pour-le-premier-sytème-installé)
      1. [Arborescence](#arborescence)
         1. [📁  Structure de la partie externe.](#--structure-de-la-partie-externe)
         1. [📁  Structure de la partie interne.](#--structure-de-la-partie-interne)
      1. [⚠️ Rappel pour mémoire](#️-rappel-pour-mémoire)
         1. [Initialisation](#initialisation)
         1. [Installations complémentaires](#installations-complémentaires)
            1. [Installer les extensions](#installer-les-extensions)
            1. [Installer les fichiers de configuration](#installer-les-fichiers-de-configuration)
            1. [Mise à jour du gestionnaire d'application](#mise-à-jour-du-gestionnaire-dapplication)
               1. [GNOME](#gnome)
         1. [Test](#test)
   1. [🏗️ L'espace de travail pour les systèmes additionnels](#️-lespace-de-travail-pour-les-systèmes-additionnels)
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
   1. [🔍 P'tit Bonus : Script de Validation](#-ptit-bonus--script-de-validation)
   1. [🙏 Remerciement](#-remerciement)

## 🤔 But

Voici ma manière d'installer et organiser **VSCodium**.
C'est une alternative a la version **Tout Terrain** : 
- afin de pouvoir transporter mes projets de manière un minimum sécurisé et compatible avec un environnement hétérogène
- Partage sur un pc **multi système** un environement centralisé utilisable quelque que soit le système démarré

Ce document n'est aps exhaustif mais je l'espère tout public et oui je l'ai travaillé avec le 🐱 venteux (aka Lechat - mistral)
Les 🧔 à long barbe peuvent y trouver une inspiration, un point de vue, ceux à la barbe naissante un HOW TO pour apprendre

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

## 🔧 Prérequis

- 1 pc (portable ou fixe) avec 1 To de disque interne avec un point de montage partage entre els systèmes installés
- 1 disque externe ou pourquoi pas un clef usb formatée pour Linux
- et bien sûr sur chaque sytème installé
  - git installé
  - accès au terminal
  - votre éditeur préféré (vim, nano, emacs,...)

## 👷 Installer VSCodium
Vous pouvez bien sûr utilise Snap, mais je préfère la méthode 🛠️ qui peut vous eviter quelques déboires en cas de mise à jour

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
# Ajoute le dépôt VSCodium
wget -qO - https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/-/raw/master/pub.gpg | sudo apt-key add -
echo 'deb https://paulcarroty.gitlab.io/vscodium-deb-rpm-repo/debs/ vscodium main' | sudo tee /etc/apt/sources.list.d/vscodium.list
sudo apt update
sudo apt install codium 
```
### Sur Windows via WSL
Bah oui c'est possible, j'ai testé sur un  portable Windows 10 impossible à upgrader en 11 et que je ne peux pas basculer sous Linux pour le moment. Voila ma procédure, mais les Windosiens sauront adapter et pourquoi pas partager
#### Installer WSL
Lancer Powershel en mode administrateur
```Powershell
# activer le sous-système
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
# active la fonctionalite de machine virtuelle
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
```
Charger le package de mise a jour du noyau Windows

[Télécharger la mise à jour du noyau WSL 2](https://aka.ms/wsl2kernel)

et l'executer

Revenir sous powershel mode administrateur
```powershell
# définir WSL 2 par défaut
wsl.exe --set-default-version 2
```
Redémarrer le PC
#### Installer une distribution Linux
Revenir sur Powershell en mode administrateur
```powershell
# Liste les distributions disponibles
wsl --list --online

# Installe Ubuntu 22.04 (recommandé pour la compatibilité)
# exemple
wsl --install -d Ubuntu-22.04
```

Quand l'installation est finie, lancer Ubuntu depuis le Menu Démarrer et configurer un utilisateur et un mot de passe
Dans le terminal qui s'ouvre (ATTENTION la on est en Bash et pas en Powershell)
Mettre a jour Linux dans WSL
```bash
# suivant la distribution choisie
#red Hat family
sudo dnf update && sudo dnf upgrade -y
sudo dnf install git
#open SUSE
sudo zypper dup
sudo zypper instal git
#debian
sudo apt update && sudo apt upgrade -y
sudo apt install git
```
#### Points à vérifier
- Accès aux fichiers Windows : Dans WSL, les disques windows sont montés sous /mnt/< lettre du disque windows >
Dans le terminal WSL : 
```bash
ls /mnt/<disque windows> 
#affiche l'arborescence de <disque windows>:\
# créer un fichier
touch /mnt/c/Users/<user windows>/test_wsl.txt
# vérifier que le fichier est bien visible et accessible depuis l'explorateur windows
```
- ⚠️ Les fichiers situés dans /mnt/< disque >/ peuvent être plus lents que ceux dans le système de fichiers natif de WSL (~/).
- ⚠️ Pour de meilleurs performances, stockez vos projets dans ~/projects/ et utilisez /mnt/< disque > uniquement pour les fichiers partagés avec Windows.
- L'installation finalisé, vous pouvez sauvegarder/restaurer votre distribution pour gagner un peu de place et libérer de la mémoire et de la CPU en utilisant Powershell
```Powershell
# Sauvegarde
wsl --export Ubuntu-22.04 backup.tar
# restauration
wsl --import Ubuntu-22.04 C:\wsl\ubuntu backup.tar
``` 

#### Installation de Codium
Il va y avoir une double installation à faire
- dans le terminal WSL pour les outils, utiliser l'installation précédemment décrite en fonction de votre famille de distribution Linux
- Dans Windows pour l'interface: 
  - Si ce n'est pas deja fait, installer VSCodium depuis : https://vscodium.com/
  - Ouvris VSCodium et installer l'extension "Remote - WSL"
  - Lance un terminal intégré (Ctrl+Shift+P → "New WSL Window") une fois pour initialiser le partage, apres vous pourrez lancer codium depuis le terminal et finir l'installation depuis le terminal

Une fois la double installation faite (WSL Linux et Windows), le reste se fera dans WSL comme avec un Linux normal

## 🏗️ L'espace de travail pour le premier sytème installé

Choix : 
- Installation de l'espace de travail sur disque externe ou clef usb (petits projets ou pour demo/partage)
- Installation des fichiers de configuration et démarrage sur la partition partagée

### Arborescence
#### 📁  Structure de la partie externe.
```
<racine_ext>/
  └── <path_ext>/
        ├── <repo_priv>/        # 🔒 Projet privé (GitHub privé)
        |      └── <repo_priv>.code-workspace
        ├── <repo_col>/         # 🔏 Projet collaboratif (GitHub en bascule privé/public)
        |      └── <repo_col>.code-workspace
        ├── <repo_pub/          # 🗺️ Projet public (GitHub public)
        |      └── <repo_pub>.code-workspace
        └── README.md           # Ce fichier
```
#### 📁  Structure de la partie interne.
Ceci est la partie installation par défaut si le disque externe n'est pas présent
```
<racine_int>/                      # 🔒 propriété du compte root
  ├── dev/                         # 🔓 propriete du compte utilisateur commun
  |     ├── vscodium/              # Installation commune de l'environnement VSCodium
  |     |      ├── default_codium  # Dossier par default si le DD externe n'est pas detecté
  |     |      ├── extensions      # Dossier d'installation des extensions
  |     |      ├── scripts         # Dossier d'installation du script de lancement
  |     |      └── .config         # Dossier de parametrage de VSCodium
  |     |             ├── User     # Dossier d'installation des fichiers json privés
  |     |             ├── /.../
  |     |             └── /.../
  |     ├── /.../
  |     └── /.../
  ├── /.../
  └── /.../
```
### ⚠️ Rappel pour mémoire

- La <racine_int> est le point de montage de la partition de partage mis en place à l'installation du système, il apaprtient au compte **root**
- Le premier dossier de <racine_int> DOIT appartenir au compte utilisateur, il importe donc de créer le même compte avec la même (UID / GID) sur tous els systèmes disponible 


#### Initialisation
On part du principe que sur votre PC (fixe ou portable) vous avez toujours un compte de connexion identique (nonobstant le mot de passe bien sur) sur tous les sytèmes, même nom, même identifiant (UID / GID) pour éviter les problèmes de droit

```bash
# 1) création des dossier du disque externe
# se placer sur la racine du DD ou de la clef
cd <racine_ext>
# créer le dossier de stockage
mkdir -p <path_ext>
# créer les dossier projets
mkdir -p <path_ext>/{<repo_priv>,<repo_col>,<repo_pub>}

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

#4) les dossier du disque partagé
# se déplacer sur le $HOME
cd ~
# 4) Créer le dossier avec les droits
sudo mkdir -p <racine_int>/dev
sudo chown $USER:$USER <racine_int>/dev
sudo chmod 750 <racine_int>/dev
# ou
sudo chmod -R u+rwx,g+rx,o-rwx <racine_int>/dev

# 5) Vérifier
ls -ld <racine_int>/dev

# 6) Continuer la configuration
mkdir -p <racine_int>/dev/vscodium
mkdir -p <racine_int>/dev/vscodium/scripts
mkdir -p <racine_int>/dev/vscodium/.config/VSCodium/User
mkdir -p <racine_int>/dev/vscodium/extensions

```

#### Installations complémentaires
##### Installer les extensions
```bash
# Installation des extensions
codium --install-extension eamodio.gitlens --extensions-dir <racine_int>/dev/vscodium/extensions
codium --install-extension alefragnani.project-manager --extensions-dir <racine_int>/dev/vscodium/extensions
codium --install-extension yzhang.markdown-all-in-one --extensions-dir <racine_int>/dev/vscodium/extensions
codium --install-extension timonwong.shellcheck --extensions-dir <racine_int>/dev/vscodium/extensions
codium --install-extension bierner.emojisense --extensions-dir <racine_int>/dev/vscodium/extensions


```
##### Installer les fichiers de configuration
Récupérer sur github les fichiers scripts dans dba_toolkit/tool/vscodium/scripts et les installer
```bash
# Téléchargement des fichiers de workspace codium pour chaque repo (ne pas oublie de mettre les bonnes valeurs dans la commande pour <repo_xxx> )
wget https://raw.githubusercontent.com/dcrazyboy/dba_toolkit/main/tools/vscodium/multi/workspaces_and_settings/<repo_xxx>.code-workspace -O <racine_ext>/<path_ext>/<repo_xxx>/<repo_xxx>.code-workspace
# Téléchargement des fichiers de configuration codium
wget https://raw.githubusercontent.com/dcrazyboy/dba_toolkit/main/tools/vscodium/multi/workspaces_and_settings/settings.json -O <racine_int>/dev/vscodium/.config/VSCodium/User/settings.json
wget https://raw.githubusercontent.com/dcrazyboy/dba_toolkit/main/tools/vscodium/multi/workspaces_and_settings/projects.json -O <racine_int>/dev/vscodium/.config/VSCodium/User/projects.json
# Téléchargement des fichiers de scripts
wget https://raw.githubusercontent.com/dcrazyboy/dba_toolkit/main/tools/vscodiummulti//scripts/launch_codium.sh -O <racine_int>/dev/vscodium/scripts/launch_codium.sh
```
Avec votre éditeur préféré dans les fichiers récupérés sur **<racine_int>/dev/vscodium/scripts/** et **<racine_int>/dev/vscodium/.config/VSCodium/User**, remplacer < racine_int >,< racine_ext >, < path_ext > et < repo_xxx > par vos propres valeurs

```bash
# Installation des fichiers de configuration
chmod +x <racine_int>/dev/vscodium/scripts/launch_codium.sh
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
Exec=/bin/bash -c "/shared/dev/vscodium/scripts/launch_codium.sh"
# régénérer le cache
update-desktop-database ~/.local/share/applications/
```
#### Test
DD ou clef USB retirée lancer VSCodium
Il doit démarrer dan le dossier par défaut ~/default_codium

Branche le DD ou la clef USB
Vérifier qu'elle est bien montée et accessible
Relance VSCodium
Il doit démarre sur < racine_ext >/< path_ext >

## 🏗️ L'espace de travail pour les systèmes additionnels
, vérifier que le compte utilisateur a bien les droits sur <racine>/dev
⚠️ Après l'installation de l'OS, vérifier que le compte utilisateur a bien les droits sur < racine >/dev et au disque externe. Le cas échéant corriger les droit d'accès du compte

Si tout est bon : 
- Installer VSCodium pour votre OS
- Récupérer le .desktop général et l'installer dans le $HOME
```bash
cp /usr/share/applications/codium.desktop ~/.local/share/applications/
```
- Mettre à jour le **~/.local/share/applications/codium.desktop** avec votre éditeur préféré
```bash
# ligne a modifier
# Exec=/usr/share/codium/codium %F
# devient
Exec=/bin/bash -c "/shared/dev/vscodium/scripts/launch_codium.sh"
# régénérer le cache
update-desktop-database ~/.local/share/applications/
```


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

![alt text](/vscodium/assets/use_project_manager.png)

1. Dans la side bar, choisit Project Manager
2. Dans les favoris choisir le projet global (vscodium) ou le sous-projet que l'on veux utiliser 

## 🔍 P'tit Bonus : Script de Validation
Pour vérifier que votre environnement est prêt, exécutez :
```bash
wget https://raw.githubusercontent.com/dcrazyboy/dba_toolkit/main/tools/vscodium/multisys/scripts/validate_vscodium.sh
chmod +x validate_vscodium.sh
./validate_vscodium.sh "< Disque Externe >"
```
Exemple d'utilisation :
```bash
./validate_codium.sh "/mnt/d"  # Remplacez "/mnt/d" par votre chemin de disque externe
```

## 🙏 Remerciement
- A tous ceux qui maintiennent et mettent a disposition **Codium**
- A tous ceux qui maintiennent et mettent a disposition les extensions d e **Codium** qui m'aident bien
- Au échanges avec le 🐱 de mistral, parfois houleux car comme tous les 🐱 il a tendance a changer de 🧶 sans prévenir.... 😆   

