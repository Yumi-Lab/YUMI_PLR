# PLR Klipper

PLR Klipper est un simple système de récupération d'impression pour Klipper, un micrologiciel d'imprimante 3D. Il vous permet de reprendre les impressions après une perte de courant ou une autre interruption, sans perdre la qualité d'impression.

## Prérequis
etre sur un USer qui a le nom 'pi' est obligatoire 
Avec le user pi, avoir déja installé klipper, moonraker et mainsail ( vous pouvez utiliser Kiauh )

Pour installer PLR Klipper, suivez les étapes suivantes :
Vous devez obligatoirement avoir creer votre installation klipper avec l'user 'pi' le script ne gere pas encore completement les autres cas.

## Installation
1. Clonez le référentiel PLR Klipper à partir de GitHub vers votre machine locale :
```bash
git clone [https://github.com/Yumi-Lab/plr-klipper.git](https://github.com/Yumi-Lab/YUMI_PLR.git)
cd YUMI_PLR
chmod +x install.sh
sudo ./install.sh
```
1. Le script effectuera les actions suivantes :
    * Créer le fichier variable.cfg dans le répertoire ~/printer_data, s'il n'existe pas déjà.
    * Copier les fichiers plr.cfg, plr.sh et gcode_shell_command.py dans les bons répertoire Klipper.
    * Rendre le fichier plr.sh exécutable.
    * Ajouter la directive [include /home/pi/printer_data/plr.cfg] en haut du fichier printer.cfg, si elle n'existe pas déjà.
3. Modifiez les fichiers plr.cfg et plr.sh pour refléter l'emplacement de votre carte SD virtuelle dans Klipper.
5. Ajouter les informations pour les mise à jour depuis mainsail et klipperscreen dans la configuration de moonraker 
5. Ajoutez les lignes suivantes au code de début et de fin de votre trancheuse :

###start-gcode à rajouter dans votre slicer:
```bash
SAVE_VARIABLE VARIABLE=was_interrupted VALUE=True
```

###end-gcode à rajouter dans votre slicer:
```bash
SAVE_VARIABLE VARIABLE=was_interrupted VALUE=False
```
   
