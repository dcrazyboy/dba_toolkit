# ⚠️ Avertissement <!-- omit in toc -->
Comme tout ici, j'ai travaillé avec Le Matou 🐱 (AKA : Lechat - Mistral AI) et bien sur ce fut épique, partir d'une 🤔 et se faire aider par un 🐈 pour arrive a une 🧶, c'est sportif et ne se fait pas en 2h comme beaucoup de DEV ou de créateurs de SAAS, que je croise, le pensent ou le disent

Ce dossier contient une proposition de solution que j'utilise et j'espère KISS (enfin pourr moi çà l'est). Vous pouvez l'utiliser tel quel ou vous en inspirer au choix

# Sommaire <!-- omit in toc -->
1. [🤔 L'idée de base](#-lidée-de-base)


# 🤔 L'idée de base

Monter un github pour parler de base de données ou d'outils, implique de choisr un OS sur le PC. Là ou cela se complique c'est le choix de l'OS de base et ce que cela implique dans la gestion. Ce github  présente des olutions plus ou moin dépendantes du système, dans les outils ou l'installation de la base et son organisation.
J'ai choisit un PC Portable qui me sert de base pour tous ces documents et en même temps de mini lab que je peux utiliser chez un client par exemple. Comme toujours c'est une proposition, vous pouvez choisir celui que vous voulez, mais voici sa cofiguration pour mes périgrinations et galères 😃.

# 🔧 Le matériel de base

- PC portable : Asus Rog
- Processeur : AMD Ryzen 7 6800H (8 cœurs / 16 threads)
- Memoire :
  - **Capacité** : 30 GiB DDR5
  - **Swap** : 63 GiB (partition dédiée)
- DD :
  - **SSD principal** : Sandisk PC SN735 / WD_BLACK SN750 SE NVMe (DRAM-less) (1 To)
  - **Disques externes** : WD My Passport 2626 (x2, connectés en USB) (1 To + 4 to)
- Carte Graphisue : 
  - **Dédiée** : NVIDIA GeForce RTX 3070 Ti Laptop GPU (architecture GA104)
  - **Intégrée** : AMD Radeon 680M (partagée avec le CPU)
- Réseau
  - **Ethernet** : Realtek RTL8125 2.5GbE Controller
  - **Wi-Fi/Bluetooth** : AzureWave ASUS PCE-AXE59BT (compatible Wi-Fi 6E)

*Source : `hwinfo --short` et `free -h` sous openSUSE Tumbleweed.*

*Pour plus de détails : `lscpu`, `lspci -v`, `lsblk -f`.*

# 🤔 ok mais avec quel OS ?
Linux, ca c'est sur , mais 
- quelle famille ? 
- quelle techno (versions stables ou rolling release) ?

Choix cornélien s'il en est 😄. Je ne suis pas un grand barcu facçon ZZ Top donc Archlinux etait un peu hors de portée pour moi (même si j'ai essayé, pour voir)

Après mure réflexion et pas mal d'échange avec le 🐱, mon choix a été le suivant : 
- **Rocky** (pour la famille Redhat)
- **Debian** (pour la famille Debian)
- **Thumbleweed** (pour la famille OpneSuse), elle a en plus l'avantage d'être une rolling release plus facile à maitriser que Arch

Cela sera donc un mini lab multi-système. C'est pour cela que dans les différents documents, vous trouverez les instructions pour chaque, mais rien ne vous empeche de n'en choisir qu'un et vous y tenir, ou dans les chapitres suivants, les spécificités et problème que j'ai pu rencontrer pour chaque

# 🤔 Comment organiser tout ça ?

## Implantaiton des OS

Je en prétend pas que c'est la meilleur organisation, il y en a peut-être d'autre, mais ma proposition à l'avantage d'être versatile sans devoir tout recommencer si l'envie vous prend de changer d'os plus tard ou commencer direct en multi-systèmes

Pour cela le partitionnement initial est important. pour les PC recent en général c'est du GPT car on boot en mode UEFI. 

On va enssuite séparer le DD en deux grandes masse : 
- 1 pour les données ''partagée'', c'est a direlà oou vous stockerez toutes vos documentaiotn, des scripts sql, des pdf, une petite instance de test PostgreSQL, ... Enfin tout ce que vous voulez conserver et qui doit être accessible si vous decidez plus tard de changer d'OS ou qui doivent etre accessible si vous avez monter (comme moi) un multi-système
- 1 pour gerer le ou les systèmes, le swap, le boot. 
  - Généralement Lunix est peu gournamnt (max 10G pour un système opérationnel, mais un peu plus  pour pouvoir stocker des truc perso non partageable c'est sympa aussi). Pensez a reserve le double ou le triple pour pouvoir faire les montées de version majeur proprement ou installer un autre systémé et avoir la place pour les montées de versions 😄
  - Pour éviter les problèmes et de potentiel fort ralentissement, le swap devrait faire le double de la taille mémoire 
  - Pour le **boot**, il necessite un point de montage particulier, si vous n'êtes pas aventureux et sur de ne fonctionne que sur un système 500 MB sont suffisant dans mon cas et pour ce que je voulais faire j'ai mis 2 G (ce qui me permet le multi-système et ajouter un gestionnaire de boot style REIND)

Pour résumer et à titre indicatif voici ma prévision de partitionnement : 
```
DD interne (1 To)
  ├── boot     :   2 G : montage : /boot/efi : formatage FAT (obligatoire)
  ├── partagé  : 500 G : montage : /shared   : foramt EXT4 (données partagées)
  ├── swap     :  64 G : montage : /swap
  ├── system 1 :  60 G : montage : /         : foramt EXT4
  ├── system 2 :  60 G : montage : /         : foramt EXT4
  ├── system X :  60 G : montage : /         : foramt EXT4
  └── libre
```
## Un gestionnaire de session graphique ?
Même si PostgreSQL se gère de manière courrante a partir d'un terminal, il y a des cas ou un gestionnaire de session graphique se révelle indispensable, par exemple pour afficher le monitoring ou l'emploi de PGADMIN par exemple. Il y a bien sur un certain nombre de famille de gestionnaires, plus ou moins convivials, plus ou moins nécessitant la mise des mains dans le camboui et surtotu plus ou moins gourmand en ressources système.
