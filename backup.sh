#!/bin/bash

# Format de la date, nom du fichier, répertoire de sauvegarde, répertoire à archiver
NOW=$(date +"%d-%m-%Y-%HH%M")
FILE="projet9.$NOW.tar"
BACKUP_DIR="/home/philippe/backups"
WWW_DIR="/var/www/wordpress"

# Identifiants MySQL
DB_USER="philippe"
DB_PASS="philippe"
DB_NAME="db_wordpress"
DB_FILE="projet9.$NOW.sql"

# Amélioration de la structure d'archivage
WWW_TRANSFORM='s,^var/www/wordpress,www,'
DB_TRANSFORM='s,^home/philippe/backups,www/database,'

# Informations sur le serveur FTP
FTP_ADDRESS='192.168.2.4'
FTP_USER='philippe'
FTP_PASS='philippe'

# Emplacement des logs
LOG='/home/philippe/FTP/Sauvegarde-FTP'.$NOW

function backup() {

	echo "Début de la sauvegarde le $NOW à `date +%HH%M`" > $LOG
	
	# Création de l'archive et du dump MySQL
	echo "Compression des dossiers débutée à `date +%HH%M`" >> $LOG
	sudo tar -cvf $BACKUP_DIR/$FILE --transform $WWW_TRANSFORM $WWW_DIR
	mysqldump -u$DB_USER -p$DB_PASS $DB_NAME --no-tablespaces > $BACKUP_DIR/$DB_FILE

	# Ajout du dump à cette archive, suppression du dump et compression du tout
	sudo tar --append --file=$BACKUP_DIR/$FILE --transform $DB_TRANSFORM $BACKUP_DIR/$DB_FILE
	rm $BACKUP_DIR/$DB_FILE
	gzip -9 $BACKUP_DIR/$FILE

	# Statut de la compression
	status=$?
	case $status in
	0) echo "Compression des dossiers terminée à `date +%HH%M`" >> $LOG;;
	1) echo "Une erreur s'est produite lors de la compression des dossiers" >> $LOG && exit;;
	esac
}

# Destination

DESTINATION='/home/philippe/backups'
function send() {
	echo "Envoi des fichiers sur le serveur FTP à `date +%HH%M`" >> $LOG

	# Envoi de la sauvegarde locale vers le serveur FTP
	lftp ftp://$FTP_USER:$FTP_PASS@$FTP_ADDRESS -e "mirror -e -R $DESTINATION $BACKUP_DIR/$FILE;quit" >> $LOG

	echo "Sauvegarde terminée le `date +%d-%M-%Y` à `date +%HH%M`" >> $LOG
}

function rotate() {
	# Rotation des sauvegardes
#	lftp ftp://$FTP_USER:$FTP_PASS@$FTP_ADDRESS -e cd /home/philippe/scripts; rotate.sh;quit"
	ssh $FTP_USER:$FTP_PASS@$FTP_ADDRESS 'cd /home/philippe/scripts && ./rotate.sh'
}

# Dossier Backups local clean
function clean() {
	rm $BACKUP_DIR/*
	echo "Dossier Backup local nettoyé à `date +%HH%M`" >> $LOG
}

backup
send
rotate
clean
