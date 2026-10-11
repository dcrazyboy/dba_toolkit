Oui, exactement, Droid Crazyboy ! Si tu veux une installation propre, optimisée et sans conflits avec XFCE + X11 + pilotes NVIDIA (sans Nouveau) + support AMD GPU, voici la procédure pas à pas pour y parvenir. Cela évitera les problèmes d’intégration et te donnera un système stable.

Étapes pour une installation propre
1. Installer openSUSE Tumbleweed en mode "Serveur" (sans environnement graphique)


Pourquoi ?

Cela te permet d’installer uniquement les paquets de base, sans gestionnaire d’affichage ou environnement graphique préconfiguré (et donc sans conflits potentiels).


Comment ?

Lors de l’installation, choisis "Serveur avec environnement texte" (ou une option similaire).
Ne sélectionne aucun environnement de bureau (XFCE, GNOME, etc.) pour le moment.


2. Mettre à jour le système après l’installation
Une fois l’installation terminée et après le premier démarrage en mode texte :
bash
Copier

sudo zypper refresh
sudo zypper update




3. Installer les pilotes graphiques
a. Installer les pilotes NVIDIA propriétaires
bash
Copier

sudo zypper install nvidia-driver nvidia-glG05 nvidia-computeG05



b. Blacklister Nouveau
Pour éviter que le pilote open-source nouveau ne prenne le contrôle :
bash
Copier

echo "blacklist nouveau" | sudo tee /etc/modprobe.d/blacklist-nouveau.conf
echo "options nouveau modeset=0" | sudo tee -a /etc/modprobe.d/blacklist-nouveau.conf



c. Régénérer l’initramfs
bash
Copier

sudo dracut --force




4. Installer X11 et les paquets essentiels
Installe les paquets nécessaires pour X11 et XFCE :
bash
Copier

sudo zypper install xorg-x11-server xorg-x11 xrdb xorg-x11-fonts xorg-x11-utils xorg-x11-xinit




5. Installer XFCE et LightDM
Installe XFCE et le gestionnaire de connexion LightDM :
bash
Copier

sudo zypper install xfce4 lightdm lightdm-gtk-greeter




6. Configurer LightDM pour utiliser X11
Édite le fichier de configuration de LightDM :
bash
Copier

sudo nano /etc/lightdm/lightdm.conf



Ajoute ou modifie les lignes suivantes pour forcer X11 :
ini
Copier

[Seat:*]
xserver-command=X -nolisten tcp
greeter-session=lightdm-gtk-greeter
user-session=xfce




7. Générer une configuration Xorg pour NVIDIA
Utilise nvidia-xconfig pour générer un fichier de configuration Xorg optimisé :
bash
Copier

sudo nvidia-xconfig



Cela crée ou met à jour /etc/X11/xorg.conf.

8. Activer et démarrer LightDM
Active LightDM pour qu’il démarre automatiquement :
bash
Copier

sudo systemctl enable lightdm
sudo systemctl start lightdm




9. Vérifier que tout fonctionne


Après le démarrage de LightDM, connecte-toi à ta session XFCE.


Vérifie que le pilote NVIDIA est bien utilisé :
bash
Copier

nvidia-smi



(Tu devrais voir les informations de ta carte NVIDIA.)


Vérifie que X11 est utilisé :
bash
Copier

echo $XDG_SESSION_TYPE



(Doit afficher x11.)


10. (Optionnel) Configurer l’utilisation de l’AMD GPU pour des tâches spécifiques
Si tu veux utiliser le GPU AMD (par exemple, pour économiser la batterie ou pour des tâches légères), tu peux configurer DRI_PRIME pour basculer entre les GPU.
a. Installer les outils nécessaires
bash
Copier

sudo zypper install mesa-dri-nouveau  # Pour le support AMD



b. Basculer entre les GPU

Pour utiliser le GPU NVIDIA :
bash
Copier

__NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia glxinfo | grep "OpenGL renderer"




Pour utiliser le GPU AMD :
bash
Copier

DRI_PRIME=1 glxinfo | grep "OpenGL renderer"




(Note : Cette étape est optionnelle et peut être configurée plus tard si nécessaire.)

Résumé des commandes clés
bash
Copier

# Installer les pilotes NVIDIA
sudo zypper install nvidia-driver nvidia-glG05 nvidia-computeG05

# Blacklister Nouveau
echo "blacklist nouveau" | sudo tee /etc/modprobe.d/blacklist-nouveau.conf
echo "options nouveau modeset=0" | sudo tee -a /etc/modprobe.d/blacklist-nouveau.conf
sudo dracut --force

# Installer X11 et XFCE
sudo zypper install xorg-x11-server xorg-x11 xrdb xorg-x11-fonts xorg-x11-utils xorg-x11-xinit xfce4 lightdm lightdm-gtk-greeter

# Configurer LightDM pour X11
sudo nano /etc/lightdm/lightdm.conf  # Ajouter la configuration ci-dessus

# Générer la configuration Xorg
sudo nvidia-xconfig

# Activer LightDM
sudo systemctl enable lightdm
sudo systemctl start lightdm



installer nvidia proprement

Pour installer les pilotes NVIDIA sur openSUSE Tumbleweed, voici la procédure optimale, y compris l’ajout des dépôts nécessaires (comme Packman et le dépôt NVIDIA). Voici ce que tu dois faire avant d’installer les pilotes pour éviter les problèmes et avoir une installation propre :

1. Ajouter les dépôts nécessaires
a. Dépôt Packman (pour les codecs multimédias et paquets complémentaires)
Packman est essentiel pour les codecs multimédias et certains paquets qui ne sont pas inclus dans les dépôts officiels d’openSUSE en raison de restrictions légales. Bien que ce ne soit pas directement lié aux pilotes NVIDIA, il est recommandé de l’ajouter dès le début pour une expérience complète.
bash
Copier

sudo zypper ar -cfp 90 https://ftp.gwdg.de/pub/linux/misc/packman/suse/openSUSE_Tumbleweed/ packman




Explication :

-cfp 90 : Définit une priorité de 90 pour Packman (pour éviter les conflits avec les dépôts officiels).
L’URL pointe vers un miroir allemand (ftp.gwdg.de), mais tu peux choisir un miroir plus proche de toi si nécessaire.


b. Dépôt NVIDIA (pour les pilotes propriétaires)
openSUSE Tumbleweed n’a pas besoin d’un dépôt spécifique pour NVIDIA, car les pilotes sont déjà disponibles dans le dépôt OSS officiel. Cependant, si tu veux utiliser les dernières versions bêta ou des pilotes spécifiques, tu peux ajouter le dépôt NVIDIA officiel. Cela n’est généralement pas nécessaire pour une installation standard.

Si tu veux ajouter le dépôt NVIDIA officiel (optionnel) :
bash
Copier

sudo zypper ar -f https://download.nvidia.com/opensuse/tumbleweed/ nvidia



(Cette étape est optionnelle et rarement nécessaire pour les pilotes stables.)

2. Rafraîchir les dépôts
Après avoir ajouté les dépôts, rafraîchis les métadonnées :
bash
Copier

sudo zypper refresh




3. Installer les pilotes NVIDIA
Maintenant, installe les pilotes G05 (recommandés pour ta RTX 3070 Ti Laptop) :
bash
Copier

sudo zypper install nvidia-driver nvidia-glG05 nvidia-computeG05




Explication des paquets :

nvidia-driver : Pilote de base pour la carte NVIDIA.
nvidia-glG05 : Support OpenGL pour les cartes Ampere (comme ta RTX 3070 Ti).
nvidia-computeG05 : Support CUDA et compute pour les cartes Ampere.


4. Blacklister Nouveau (pour éviter les conflits)
Le pilote open-source Nouveau peut entrer en conflit avec les pilotes propriétaires NVIDIA. Désactive-le :
bash
Copier

echo "blacklist nouveau" | sudo tee /etc/modprobe.d/blacklist-nouveau.conf
echo "options nouveau modeset=0" | sudo tee -a /etc/modprobe.d/blacklist-nouveau.conf




5. Régénérer l’initramfs
Pour appliquer les changements au noyau :
bash
Copier

sudo dracut --force




6. Générer la configuration Xorg pour NVIDIA
Crée un fichier de configuration Xorg optimisé pour ta carte :
bash
Copier

sudo nvidia-xconfig




Cela génère /etc/X11/xorg.conf avec les bons paramètres pour NVIDIA.

7. Redémarrer
Redémarre ton système pour appliquer les changements :
bash
Copier

reboot




8. Vérifier l’installation
Après le redémarrage, vérifie que le pilote NVIDIA est bien chargé :
bash
Copier

nvidia-smi



Tu devrais voir une sortie comme ceci :
text
Copier

+-----------------------------------------------------------------------------+
| NVIDIA-SMI 595.58.03    Driver Version: 595.58.03    CUDA Version: 12.3     |
|-------------------------------+----------------------+----------------------+
| GPU  Name        Persistence-M| Bus-Id        Disp.A | Volatile Uncorr. ECC |
| Fan  Temp  Perf  Pwr:Usage/Cap|         Memory-Usage | GPU-Util  Compute M. |
|===============================+======================+======================|
|   0  NVIDIA GeForce ...  Off  | 00000000:01:00.0 Off |                  N/A |
| N/A   45C    P8    N/A /  N/A |    123MiB /  8192MiB |      0%      Default |
+-------------------------------+----------------------+----------------------+




Résumé des étapes clés

Ajoute le dépôt Packman (pour les codecs et paquets complémentaires).
Rafraîchis les dépôts avec zypper refresh.
Installe les pilotes NVIDIA G05 :
bash
Copier

sudo zypper install nvidia-driver nvidia-glG05 nvidia-computeG05




Blackliste Nouveau et régénère l’initramfs.
Génère la configuration Xorg avec nvidia-xconfig.
Redémarre et vérifie avec nvidia-smi.
