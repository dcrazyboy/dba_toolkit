#!/bin/bash

# Chemins (avec échappement des espaces)
EXTERNAL_DISK_PATH="<racine_ext>/<path_ext>"
FALLBACK_PATH="<racine_int>/dev/vscodium/default_codium"
EXTENSIONS_DIR="<racine_int>/dev/vscodium/extensions"
USER_DATA_DIR="<racine_int>/dev/vscodium/.config/VSCodium"

# Vérifie si le disque externe est accessible ET en écriture
if [ -d "$EXTERNAL_DISK_PATH" ] && [ -w "$EXTERNAL_DISK_PATH" ]; then
    echo "Disque externe détecté et accessible en écriture : $EXTERNAL_DISK_PATH"
    WORKSPACE_PATH="$EXTERNAL_DISK_PATH"
else
    echo "Disque externe non accessible ou en lecture seule. Utilisation du chemin de repli : $FALLBACK_PATH"
    WORKSPACE_PATH="$FALLBACK_PATH"
fi

# Affiche le chemin final pour débogage
echo "Chemin du workspace utilisé : $WORKSPACE_PATH"

# Lance VSCodium
/usr/share/codium/codium \
    --extensions-dir "$EXTENSIONS_DIR" \
    --user-data-dir "$USER_DATA_DIR" \
    "$WORKSPACE_PATH"
