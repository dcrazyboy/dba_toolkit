#!/bin/bash
#==============================================
# Variables
#==============================================
flag_disk=true
flag_git=true
flag_distro=true
flag_codium=true
flag_github=true
LIST_EXTENSIONS=("bierner.emojisense" "eamodio.gitlens" "alefragnani.project-manager" "yzhang.markdown-all-in-one" "timonwong.shellcheck")
ID=
RACINE_EXT=
# =============================================
# EN-TÊTE
# =============================================
echo "🔍 Script de validation pour VSCodium (Linux/WSL)"
echo "   Vérifie les prérequis pour une installation manuelle."
echo "   Auteur : D. Crazyboy"
echo "   Version : 1.1.0"
echo ""

# Vérification de curl 
if ! command -v curl &> /dev/null; then
    echo "⚠️ 'curl' n'est pas installé. Le test GitHub sera ignoré."
    flag_github=false
fi

# =============================================
# SECTION 1 : Validation du disque externe
# =============================================
echo "📌 [1/5] Vérification du disque externe..."
RACINE_EXT=$1  

if [ ! -d "$RACINE_EXT" ]; then
  echo "❌ Erreur : Le disque externe (${RACINE_EXT}) n'est pas monté."
  echo "   Solutions :"
  echo "   - Branchez votre disque externe."
  echo "   - Sous WSL, utilisez /mnt/<lettre> (ex: /mnt/d pour D:)."
  echo "   - Vérifiez avec : lsblk (Linux) ou wmic diskdrive list brief (Windows)."
  flag_disk=false
fi

if [ ! -w "$RACINE_EXT" ]; then
  echo "❌ Erreur : Pas de permissions en écriture sur ${RACINE_EXT}."
  echo "   Solutions :"
  echo "   - Utilisez : sudo chmod u+rwx ${RACINE_EXT}"
  echo "   - Ou : sudo chown $USER:$USER ${RACINE_EXT}"
  flag_disk=false
fi

# =============================================
# SECTION 2 : Validation de Git (obligatoire)
# =============================================
echo -e "\n📌 [2/5] Vérification de Git..."

if ! command -v git &> /dev/null; then
    echo "❌ Erreur : Git n'est pas installé (obligatoire pour les workspaces)."
    echo "   Solutions :"
    echo "   - Debian/Ubuntu : sudo apt install git"
    echo "   - Red Hat : sudo dnf install git"
    echo "   - openSUSE : sudo zypper install git"
    flag_git=false
else
  echo "✅ Git est installé : $(git --version | head -n 1)"
fi


# =============================================
# SECTION 3 : Validation de la distro
# =============================================
echo -e "\n📌 [3/5] Vérification de la distribution Linux..."

if [ ! -f /etc/os-release ]; then
    echo "❌ Erreur : Impossible de détecter la distro (fichier /etc/os-release manquant)."
    echo "   Solution : Ce script ne fonctionne que sur Linux/WSL."
    flag_distro=false
else
  source /etc/os-release
  case $ID in
    ubuntu|debian|mint)
        echo "✅ Distro détectée : Debian family (${ID})."
        echo "   Commandes d'installation recommandées :"
        echo "   wget -qO - https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/-/raw/master/pub.gpg | sudo apt-key add -"
        echo "   echo 'deb https://paulcarroty.gitlab.io/vscodium-deb-rpm-repo/debs/ vscodium main' | sudo tee /etc/apt/sources.list.d/vscodium.list"
        echo "   sudo apt update && sudo apt install codium"
        ;;
    fedora|rhel|centos|rocky|almalinux)
        echo "✅ Distro détectée : Red Hat family (${ID})."
        echo "   Commandes d'installation recommandées :"
        echo "   sudo rpmkeys --import https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/-/raw/master/pub.gpg"
        echo "   sudo dnf config-manager --add-repo https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/rpms/"
        echo "   sudo dnf install codium"
        ;;
    opensuse*)
        echo "✅ Distro détectée : openSUSE family (${ID})."
        echo "   Commandes d'installation recommandées :"
        echo "   sudo rpm --import https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/-/raw/master/pub.gpg"
        echo "   sudo zypper ar -f https://paulcarroty.gitlab.io/vscodium-deb-rpm-repo/rpms/ vscodium"
        echo "   sudo zypper install codium"
        ;;
    *)
        echo "❌ Erreur : Distro non supportée (${ID})."
        echo "   Solutions :"
        echo "   - Utilisez une distro supportée (Debian, Red Hat, openSUSE)."
        echo "   - Consultez la documentation pour une installation manuelle."
        flag_distro=false
        ;;
  esac
fi
# =============================================
# SECTION 4 : Vérification de l'accès à GitHub (facultatif)
# =============================================
echo -e "\n📌 [4/5] Vérification de l'accès à GitHub (facultatif)..."

if flag_github ; then # on ne fait le test que si le test curl en entete est validé
  # Test de connexion à GitHub (sans bloquer le script)
  if curl --output /dev/null --silent --head --fail "https://github.com"; then
      echo "✅ Accès à GitHub : OK (facultatif pour les fichiers de configuration)."
      echo "   Vous pouvez télécharger les fichiers depuis :"
      echo "   https://github.com/dcrazyboy/dba_toolkit/tree/main/tools/vscodium"
  else
      echo "⚠️ Accès à GitHub : Impossible (facultatif)."
      echo "   - Vérifiez votre connexion Internet."
      echo "   - Les fichiers de configuration devront être installés manuellement."
      flag_github=false
  fi
fi

# =============================================
# SECTION 5 : Validation de Codium et des extensions
# =============================================
echo -e "\n📌 [5/5] Vérification de VSCodium et des extensions..."

if ! command -v codium &> /dev/null; then
    echo "❌ VSCodium n'est pas installé."
    echo "   Solution : Suivez les commandes d'installation ci-dessus pour votre distro."
    case $ID in
        ubuntu|debian|mint) echo "   → Voir section Debian ci-dessus." ;;
        fedora|rhel|centos|rocky|almalinux) echo "   → Voir section Red Hat ci-dessus." ;;
        opensuse*) echo "   → Voir section openSUSE ci-dessus." ;;
        *) echo "Distribution non prise en compte"
    esac        
    flag_codium=false
else
    echo "✅ VSCodium est installé : $(codium --version | head -n 1)"

    # Vérification des extensions
    MISSING_EXTENSIONS=()
    for ext in "${LIST_EXTENSIONS[@]}"; do
        if ! codium --list-extensions | grep -q "$ext"; then
            MISSING_EXTENSIONS+=("$ext")
        fi
    done

    if [ ${#MISSING_EXTENSIONS[@]} -gt 0 ]; then
        echo "⚠️ Extensions manquantes : "
        echo "   Solution : Installez-les avec :"
        for ext in "${MISSING_EXTENSIONS[@]}"; do
            echo "   codium --install-extension $ext"
        done
    else
        echo "✅ Toutes les extensions sont installées."
    fi
fi

# =============================================
# RÉSUMÉ
# =============================================
echo -e "\n📋 Résumé des vérifications :"
if $flag_disk ; then
  echo "   ✅ Disque externe : OK (${RACINE_EXT})"
else
  echo "   ❌ Disque externe : KO (${RACINE_EXT})"
fi
if $flag_git ; then
  echo "   ✅ Git : OK ($(git --version | head -n 1))"
else
  echo "   ❌ Git : KO ($(git --version | head -n 1))"
fi
if $flag_distro ; then
  echo "   ✅ Distro : OK (${ID})"
else
  echo "   ❌ Distro : non prevue ou inconnue"
fi
if $flag_codium ; then
    echo "   ✅ VSCodium : Installé"
else
    echo "   ❌ VSCodium : Non installé"
fi
if $flag_github ; then
    echo "   ✅ GitHub : Accessible"
else
    echo "   ⚠️ GitHub : Inaccessible (facultatif)"
fi

echo -e "\n📌 Prochaines étapes :"
echo "   1. Installez VSCodium si nécessaire (commandes ci-dessus)."
echo "   2. Installez les extensions manquantes (si applicable)."
echo "   3. Configurez vos workspaces selon la documentation."
echo "   4. Téléchargez les fichiers de configuration depuis GitHub (si accessible)."
